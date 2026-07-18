import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

enum StepTrackingStatus { idle, tracking, permissionDenied, unavailable }

class StepTrackingService extends GetxService {
  static const MethodChannel _androidServiceChannel = MethodChannel(
    'com.example.gym/step_service',
  );

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

  final LocalStorageService _storage;
  final Stream<int>? _rawStepStream;
  final Future<bool> Function()? _requestPermission;

  final RxInt todaySteps = 0.obs;
  final RxInt yesterdaySteps = 0.obs;
  final Rx<StepTrackingStatus> status = StepTrackingStatus.idle.obs;
  final RxnString errorMessage = RxnString();
  final RxBool hasSensorReading = false.obs;
  final RxBool notificationEnabled = true.obs;

  StreamSubscription<int>? _subscription;
  bool _started = false;
  int? _lastRawSteps;
  String? _storedDate;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    await _restore();

    final granted = await (_requestPermission?.call() ?? _requestMotion());
    if (!granted) {
      status.value = StepTrackingStatus.permissionDenied;
      errorMessage.value = 'Activity permission is required to count steps.';
      return;
    }
    if (_rawStepStream == null) {
      await _startAndroidForegroundService();
    }

    final stream =
        _rawStepStream ?? Pedometer.stepCountStream.map((event) => event.steps);
    _subscription = stream.listen(
      (steps) {
        hasSensorReading.value = true;
        processRawStepCount(steps);
      },
      onError: (Object _) {
        status.value = StepTrackingStatus.unavailable;
        errorMessage.value = 'Step sensor is not available on this device.';
      },
    );
    status.value = StepTrackingStatus.tracking;
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
      if (todaySteps.value == 0) {
        todaySteps.value = rawSteps;
      }
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

  Future<void> _restore() async {
    await _storage.init();
    final now = DateTime.now();
    final today = _dateValue(now);
    _storedDate = _storage.getString(_dateKey);
    _lastRawSteps = _storage.getInt(_lastRawKey);

    if (_storedDate == today) {
      todaySteps.value = _storage.getInt(_todayKey, defaultValue: 0) ?? 0;
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
    todaySteps.value = 0;
  }

  Future<void> _persist() async {
    await _storage.saveString(
      _dateKey,
      _storedDate ?? _dateValue(DateTime.now()),
    );
    await _storage.saveInt(_todayKey, todaySteps.value);
    if (_lastRawSteps != null) {
      await _storage.saveInt(_lastRawKey, _lastRawSteps!);
    }
  }

  Future<bool> _requestMotion() async {
    if (kIsWeb) {
      return false;
    }
    final permission = defaultTargetPlatform == TargetPlatform.android
        ? Permission.activityRecognition
        : Permission.sensors;
    final result = await permission.request();
    if (defaultTargetPlatform == TargetPlatform.android && result.isGranted) {
      final notificationResult = await Permission.notification.request();
      notificationEnabled.value =
          notificationResult.isGranted || notificationResult.isLimited;
    }
    return result.isGranted || result.isLimited;
  }

  Future<void> _startAndroidForegroundService() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _androidServiceChannel.invokeMethod<bool>('start');
    } on PlatformException catch (_) {
      errorMessage.value =
          'Could not start background step notification. Tap Steps to retry.';
    } on MissingPluginException catch (_) {
      errorMessage.value = 'Background step notification is unavailable.';
    }
  }

  Future<void> retry() async {
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
    errorMessage.value = null;
    status.value = StepTrackingStatus.idle;

    if (!kIsWeb) {
      final permission = defaultTargetPlatform == TargetPlatform.android
          ? Permission.activityRecognition
          : Permission.sensors;
      if (await permission.isPermanentlyDenied) {
        await openAppSettings();
        status.value = StepTrackingStatus.permissionDenied;
        errorMessage.value = 'Enable activity access in system settings.';
        return;
      }
      if (defaultTargetPlatform == TargetPlatform.android &&
          !notificationEnabled.value) {
        final notificationResult = await Permission.notification.request();
        notificationEnabled.value =
            notificationResult.isGranted || notificationResult.isLimited;
        if (!notificationEnabled.value &&
            await Permission.notification.isPermanentlyDenied) {
          await openAppSettings();
          errorMessage.value = 'Enable notifications in system settings.';
          return;
        }
      }
    }
    await start();
  }

  String _dateValue(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
