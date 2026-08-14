import 'dart:async';

import 'package:get/get.dart';
import 'package:gym/scr/core/services/activity_step_detector.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum StepTrackingStatus { idle, tracking, permissionDenied, unavailable }

class StepTrackingService extends GetxService {
  StepTrackingService([
    LocalStorageService? storage,
    this._rawStepStream,
    this._requestPermission,
  ]) : _storage = storage ?? LocalStorageService();

  static const String _dateKey = 'step_tracking_date';
  static const String _todayKey = 'step_tracking_today';
  static const String _lastRawKey = 'step_tracking_last_raw';
  static const String _yesterdayDateKey = 'step_tracking_yesterday_date';
  static const String _yesterdayStepsKey = 'step_tracking_yesterday_steps';
  static const String _resetBaselinePendingKey =
      'step_tracking_reset_baseline_pending';

  final LocalStorageService _storage;
  final Stream<int>? _rawStepStream;
  final Future<bool> Function()? _requestPermission;

  final RxInt todaySteps = 0.obs;
  final RxInt yesterdaySteps = 0.obs;
  final RxString trackingDate = ''.obs;
  final Rx<StepTrackingStatus> status = StepTrackingStatus.idle.obs;
  final RxnString errorMessage = RxnString();
  final RxBool hasSensorReading = false.obs;
  final RxBool notificationEnabled = true.obs;

  StreamSubscription<int>? _subscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  ActivityStepDetector? _activityDetector;
  double _gyroscopeX = 0;
  double _gyroscopeY = 0;
  double _gyroscopeZ = 0;
  Timer? _dayRolloverTimer;
  bool _started = false;
  int? _lastRawSteps;
  String? _storedDate;
  bool _resetBaselinePending = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    await _restore();
    _scheduleDayRollover();

    final granted =
        await (_requestPermission?.call() ?? Future<bool>.value(true));
    if (!granted) {
      status.value = StepTrackingStatus.permissionDenied;
      errorMessage.value = 'Activity permission is required to count steps.';
      return;
    }
    if (_rawStepStream != null) {
      _subscription = _rawStepStream.listen((steps) {
        hasSensorReading.value = true;
        processRawStepCount(steps);
      }, onError: _handleSensorError);
    } else {
      try {
        _activityDetector = ActivityStepDetector(
          await TfliteActivityClassifier.load(),
        );
        _gyroscopeSubscription =
            gyroscopeEventStream(
              samplingPeriod: SensorInterval.gameInterval,
            ).listen((event) {
              _gyroscopeX = event.x;
              _gyroscopeY = event.y;
              _gyroscopeZ = event.z;
            }, onError: _handleSensorError);
        _accelerometerSubscription = accelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen(_processAccelerometerEvent, onError: _handleSensorError);
      } catch (_) {
        status.value = StepTrackingStatus.unavailable;
        errorMessage.value = 'The activity model could not be loaded.';
        return;
      }
    }
    status.value = StepTrackingStatus.tracking;
  }

  void _processAccelerometerEvent(AccelerometerEvent event) {
    hasSensorReading.value = true;
    final detectedSteps =
        _activityDetector?.addSample(
          MotionSample(
            accelerometerX: event.x,
            accelerometerY: event.y,
            accelerometerZ: event.z,
            gyroscopeX: _gyroscopeX,
            gyroscopeY: _gyroscopeY,
            gyroscopeZ: _gyroscopeZ,
            timestamp: DateTime.now(),
          ),
        ) ??
        0;
    if (detectedSteps > 0) {
      unawaited(_addDetectedSteps(detectedSteps));
    }
  }

  Future<void> _addDetectedSteps(int steps, {DateTime? now}) async {
    await ensureCurrentDay(now: now);
    todaySteps.value += steps;
    await _persist();
  }

  void _handleSensorError(Object _) {
    status.value = StepTrackingStatus.unavailable;
    errorMessage.value =
        'Motion sensors are unavailable for model-based step counting.';
  }

  Future<void> processRawStepCount(int rawSteps, {DateTime? now}) async {
    if (rawSteps < 0) {
      return;
    }
    final currentTime = now ?? DateTime.now();
    final today = _dateValue(currentTime);

    if (_storedDate != today) {
      await _rollToNewDay(today, currentTime);
      _lastRawSteps = rawSteps;
      await _persist();
      return;
    }

    final previousRaw = _lastRawSteps;
    if (previousRaw == null) {
      _lastRawSteps = rawSteps;
      _resetBaselinePending = false;
      await _persist();
      return;
    }

    final delta = rawSteps >= previousRaw ? rawSteps - previousRaw : rawSteps;
    if (delta > 0) {
      todaySteps.value += delta;
    }
    _lastRawSteps = rawSteps;
    await _persist();
  }

  Future<void> ensureCurrentDay({DateTime? now}) async {
    await _storage.init();
    final currentTime = now ?? DateTime.now();
    final today = _dateValue(currentTime);
    final changed = _storedDate != today;
    if (changed) {
      await _rollToNewDay(today, currentTime);
      await _persist();
    }
    _scheduleDayRollover(from: currentTime);
  }

  Future<void> reconcileTodaySteps(int savedSteps, {DateTime? now}) async {
    if (savedSteps < 0) {
      return;
    }
    await _storage.init();
    final currentTime = now ?? DateTime.now();
    final today = _dateValue(currentTime);
    if (_storedDate != today) {
      await _rollToNewDay(today, currentTime);
      _lastRawSteps = null;
    }
    if (savedSteps > todaySteps.value) {
      todaySteps.value = savedSteps;
    }
    await _persist();
  }

  Future<void> _restore() async {
    await _storage.init();
    final now = DateTime.now();
    final today = _dateValue(now);
    _storedDate = _storage.getString(_dateKey);
    _lastRawSteps = _storage.getInt(_lastRawKey);
    _resetBaselinePending =
        _storage.getBool(_resetBaselinePendingKey, defaultValue: false) ??
        false;

    if (_storedDate == today) {
      todaySteps.value = _storage.getInt(_todayKey, defaultValue: 0) ?? 0;
      trackingDate.value = today;
    } else {
      await _rollToNewDay(today, now);
      _lastRawSteps = null;
      await _persist();
    }

    final yesterday = _dateValue(now.subtract(const Duration(days: 1)));
    yesterdaySteps.value = _storage.getString(_yesterdayDateKey) == yesterday
        ? (_storage.getInt(_yesterdayStepsKey, defaultValue: 0) ?? 0)
        : 0;
  }

  Future<void> _rollToNewDay(String today, DateTime now) async {
    final expectedYesterday = _dateValue(now.subtract(const Duration(days: 1)));
    if (_storedDate == expectedYesterday) {
      yesterdaySteps.value = todaySteps.value;
      await _storage.saveString(_yesterdayDateKey, expectedYesterday);
      await _storage.saveInt(_yesterdayStepsKey, todaySteps.value);
    } else {
      yesterdaySteps.value = 0;
    }
    _storedDate = today;
    trackingDate.value = today;
    todaySteps.value = 0;
    _resetBaselinePending = false;
  }

  Future<void> resetTodaySteps({DateTime? now}) async {
    await _storage.init();
    final currentTime = now ?? DateTime.now();
    _storedDate = _dateValue(currentTime);
    todaySteps.value = 0;
    _resetBaselinePending = _lastRawSteps == null;
    await _persist();
  }

  Future<void> _persist() async {
    await _storage.saveString(
      _dateKey,
      _storedDate ?? _dateValue(DateTime.now()),
    );
    await _storage.saveInt(_todayKey, todaySteps.value);
    await _storage.saveBool(_resetBaselinePendingKey, _resetBaselinePending);
    if (_lastRawSteps != null) {
      await _storage.saveInt(_lastRawKey, _lastRawSteps!);
    }
  }

  void _scheduleDayRollover({DateTime? from}) {
    _dayRolloverTimer?.cancel();
    final now = from ?? DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    final delay = nextDay.difference(now) + const Duration(milliseconds: 250);
    _dayRolloverTimer = Timer(delay, () {
      unawaited(ensureCurrentDay());
    });
  }

  Future<void> retry() async {
    await _subscription?.cancel();
    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();
    _activityDetector?.close();
    _activityDetector = null;
    _subscription = null;
    _started = false;
    errorMessage.value = null;
    status.value = StepTrackingStatus.idle;

    await start();
  }

  String _dateValue(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _dayRolloverTimer?.cancel();
    _subscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _activityDetector?.close();
    super.onClose();
  }
}
