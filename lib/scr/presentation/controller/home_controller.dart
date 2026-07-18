import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/services/step_tracking_service.dart';
import 'package:gym/scr/data/model/getweight_model.dart';
import 'package:gym/scr/data/model/get_workout_model.dart';
import 'package:gym/scr/data/model/wrk_history_model.dart';
import 'package:gym/scr/domain/usecase/weight_history_usecase.dart';
import 'package:gym/scr/domain/usecase/workout_history_usecase.dart';
import 'package:gym/scr/domain/usecase/workout_timing_usecase.dart';
import 'package:gym/scr/domain/usecase/profile_usecase.dart';

class HomeController extends GetxController {
  HomeController([
    this._workoutHistoryUseCase,
    this._weightHistoryUseCase,
    this._stepTrackingService,
    this._profileUseCase,
    this._workoutTimingUseCase,
  ]);

  final WorkoutHistoryUseCase? _workoutHistoryUseCase;
  final WeightHistoryUseCase? _weightHistoryUseCase;
  final StepTrackingService? _stepTrackingService;
  final ProfileUseCase? _profileUseCase;
  final WorkoutTimingUseCase? _workoutTimingUseCase;
  Worker? _stepWorker;

  final RxString userName = 'Rahul'.obs;
  final String motivationTitle = 'Consistency is your superpower.';
  final String motivationSubtitle = 'Keep showing up for yourself!';
  final HomeWorkout workout = const HomeWorkout(
    label: "Today's Workout",
    title: 'Choose a workout',
    subtitle: 'Browse exercises to get started',
  );

  final RxList<HomeStatItem> stats = <HomeStatItem>[
    HomeStatItem(
      icon: Icons.watch_later_rounded,
      title: 'Workout Time',
      value: '45',
      unit: 'min',
      trend: '5%',
      trendUp: true,
      color: AppColors.statWorkoutTime,
      history: [
        HomeStatHistoryItem(
          label: 'Today',
          value: '45',
          unit: 'min',
          note: 'Chest workout completed',
        ),
        HomeStatHistoryItem(
          label: 'Yesterday',
          value: '38',
          unit: 'min',
          note: 'Back and biceps',
        ),
        HomeStatHistoryItem(
          label: 'Monday',
          value: '52',
          unit: 'min',
          note: 'Leg day',
        ),
        HomeStatHistoryItem(
          label: 'Sunday',
          value: '30',
          unit: 'min',
          note: 'Cardio session',
        ),
      ],
    ),
    HomeStatItem(
      icon: Icons.directions_walk_rounded,
      title: 'Steps',
      value: '0',
      unit: 'steps',
      trend: 'Starting',
      trendUp: true,
      color: AppColors.primary,
      showTrendIcon: false,
      footer: "today's activity",
      history: [
        HomeStatHistoryItem(
          label: 'Today',
          value: '0',
          unit: 'steps',
          note: 'Daily footsteps',
        ),
      ],
    ),
  ].obs;

  final RxBool isWorkoutHistoryLoading = false.obs;
  final RxBool isProfileNameLoading = false.obs;
  final RxnString workoutHistoryError = RxnString();
  final RxBool isWeightHistoryLoading = false.obs;
  final RxnString weightHistoryError = RxnString();

  static HomeController resolve() {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>();
    }

    WorkoutHistoryUseCase? useCase;
    try {
      useCase = Get.find<WorkoutHistoryUseCase>();
    } catch (_) {
      useCase = null;
    }

    final weightUseCase = Get.isRegistered<WeightHistoryUseCase>()
        ? Get.find<WeightHistoryUseCase>()
        : null;
    final stepService = Get.isRegistered<StepTrackingService>()
        ? Get.find<StepTrackingService>()
        : null;
    final profileUseCase = Get.isRegistered<ProfileUseCase>()
        ? Get.find<ProfileUseCase>()
        : null;
    final timingUseCase = Get.isRegistered<WorkoutTimingUseCase>()
        ? Get.find<WorkoutTimingUseCase>()
        : null;
    return Get.put(
      HomeController(
        useCase,
        weightUseCase,
        stepService,
        profileUseCase,
        timingUseCase,
      ),
    );
  }

  WorkoutHistoryUseCase? get _historyUseCase {
    if (_workoutHistoryUseCase != null) {
      return _workoutHistoryUseCase;
    }
    try {
      return Get.find<WorkoutHistoryUseCase>();
    } catch (_) {
      return null;
    }
  }

  WeightHistoryUseCase? get _weightUseCase {
    if (_weightHistoryUseCase != null) {
      return _weightHistoryUseCase;
    }
    return Get.isRegistered<WeightHistoryUseCase>()
        ? Get.find<WeightHistoryUseCase>()
        : null;
  }

  ProfileUseCase? get _profileLoader {
    if (_profileUseCase != null) {
      return _profileUseCase;
    }
    return Get.isRegistered<ProfileUseCase>()
        ? Get.find<ProfileUseCase>()
        : null;
  }

  WorkoutTimingUseCase? get _timingHistoryLoader {
    if (_workoutTimingUseCase != null) {
      return _workoutTimingUseCase;
    }
    return Get.isRegistered<WorkoutTimingUseCase>()
        ? Get.find<WorkoutTimingUseCase>()
        : null;
  }

  @override
  void onInit() {
    super.onInit();
    getWorkoutHistory();
    getWeightHistory();
    getProfileName();
    final stepService = _stepTrackingService;
    if (stepService != null) {
      _syncStepStat();
      _stepWorker = everAll([
        stepService.todaySteps,
        stepService.yesterdaySteps,
        stepService.status,
        stepService.hasSensorReading,
        stepService.notificationEnabled,
      ], (_) => _syncStepStat());
      stepService.start();
    }
  }

  Future<void> getProfileName() async {
    final useCase = _profileLoader;
    if (useCase == null) {
      return;
    }

    isProfileNameLoading.value = true;
    userName.value = '';
    try {
      final response = await useCase();
      final name = response.data?.user?.name?.trim();
      if ((response.success == true || response.code == 200) &&
          name != null &&
          name.isNotEmpty) {
        userName.value = name;
      }
    } catch (_) {
      userName.value = '';
    } finally {
      isProfileNameLoading.value = false;
    }
  }

  void applyUserName(String name) {
    final normalizedName = name.trim();
    if (normalizedName.isNotEmpty) {
      userName.value = normalizedName;
    }
  }

  Future<void> getWorkoutHistory({bool force = false}) async {
    final timingUseCase = _timingHistoryLoader;
    final legacyUseCase = _historyUseCase;
    if ((timingUseCase == null && legacyUseCase == null) ||
        (isWorkoutHistoryLoading.value && !force)) {
      return;
    }

    isWorkoutHistoryLoading.value = true;
    workoutHistoryError.value = null;
    stats[0] = _emptyWorkoutStat();

    try {
      if (timingUseCase != null) {
        final response = await timingUseCase.getHistory();
        final isSuccessful = response.success == true || response.code == 200;
        if (!isSuccessful || response.data == null) {
          workoutHistoryError.value =
              response.message ?? 'Unable to load workout history.';
          return;
        }
        stats[0] = _mapTimingHistory(response.data!);
      } else {
        final response = await legacyUseCase!();
        final isSuccessful = response.success == true || response.code == 200;
        if (!isSuccessful || response.data == null) {
          workoutHistoryError.value =
              response.message ?? 'Unable to load workout history.';
          return;
        }
        stats[0] = _mapWorkoutHistory(response.data!);
      }
    } on DioException catch (error) {
      final responseData = error.response?.data;
      workoutHistoryError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load workout history. Please check your connection.';
    } catch (_) {
      workoutHistoryError.value =
          'Something went wrong while loading workout history.';
    } finally {
      isWorkoutHistoryLoading.value = false;
    }
  }

  HomeStatItem _mapTimingHistory(WorkoutTimingHistoryData data) {
    final percentChange = data.percentChange ?? 0;
    final trend = data.trend?.trim().toLowerCase();
    final isTrendingUp =
        trend == 'up' ||
        trend == 'increase' ||
        (trend != 'down' && trend != 'decrease' && percentChange >= 0);

    return HomeStatItem(
      icon: Icons.watch_later_rounded,
      title: 'Workout Time',
      value: '${data.todayDuration ?? 0}',
      unit: 'min',
      trend: '${percentChange.abs()}%',
      trendUp: isTrendingUp,
      color: AppColors.statWorkoutTime,
      history: data.history
          .map(
            (item) => HomeStatHistoryItem(
              label: item.day?.trim().isNotEmpty == true
                  ? item.day!.trim()
                  : 'Workout',
              value: '${item.durationMinutes ?? 0}',
              unit: 'min',
              note: item.notes?.trim().isNotEmpty == true
                  ? item.notes!.trim()
                  : 'Workout completed',
            ),
          )
          .toList(growable: false),
    );
  }

  HomeStatItem _mapWorkoutHistory(WorkoutHistoryData data) {
    final percentChange = data.percentChange ?? 0;
    final trend = data.trend?.trim().toLowerCase();
    final isTrendingUp =
        trend == 'up' ||
        trend == 'increase' ||
        (trend != 'down' && trend != 'decrease' && percentChange >= 0);

    return HomeStatItem(
      icon: Icons.watch_later_rounded,
      title: 'Workout Time',
      value: '${data.todayDuration ?? 0}',
      unit: 'min',
      trend: '${percentChange.abs()}%',
      trendUp: isTrendingUp,
      color: AppColors.statWorkoutTime,
      history: data.history
          .map(
            (item) => HomeStatHistoryItem(
              label: item.day?.trim().isNotEmpty == true
                  ? item.day!.trim()
                  : 'Workout',
              value: '${item.durationMinutes ?? 0}',
              unit: 'min',
              note: item.notes?.trim().isNotEmpty == true
                  ? item.notes!.trim()
                  : 'Workout completed',
            ),
          )
          .toList(growable: false),
    );
  }

  void _syncStepStat() {
    final service = _stepTrackingService;
    if (service == null) {
      return;
    }
    final today = service.todaySteps.value;
    final yesterday = service.yesterdaySteps.value;
    final stepIndex = stats.indexWhere((item) => item.title == 'Steps');
    if (stepIndex < 0) {
      return;
    }

    final isTracking = service.status.value == StepTrackingStatus.tracking;
    final percent = yesterday <= 0
        ? 0
        : (((today - yesterday) / yesterday) * 100).round();
    final statusText = !service.notificationEnabled.value
        ? 'Notification'
        : switch (service.status.value) {
            StepTrackingStatus.idle => 'Starting',
            StepTrackingStatus.tracking =>
              !service.hasSensorReading.value
                  ? 'Waiting'
                  : yesterday > 0
                  ? '${percent.abs()}%'
                  : 'Today',
            StepTrackingStatus.permissionDenied => 'Permission',
            StepTrackingStatus.unavailable => 'Unavailable',
          };
    final footer = !service.notificationEnabled.value
        ? 'tap to enable step notification'
        : switch (service.status.value) {
            StepTrackingStatus.idle => 'starting step sensor',
            StepTrackingStatus.tracking =>
              !service.hasSensorReading.value
                  ? 'walk a few steps to begin'
                  : yesterday > 0
                  ? 'vs yesterday'
                  : "today's activity",
            StepTrackingStatus.permissionDenied =>
              'tap to enable activity access',
            StepTrackingStatus.unavailable => 'tap to retry the step sensor',
          };

    stats[stepIndex] = HomeStatItem(
      icon: Icons.directions_walk_rounded,
      title: 'Steps',
      value: '$today',
      unit: 'steps',
      trend: statusText,
      trendUp: percent >= 0,
      color: AppColors.primary,
      showTrendIcon: isTracking && yesterday > 0,
      footer: footer,
      history: [
        HomeStatHistoryItem(
          label: 'Today',
          value: '$today',
          unit: 'steps',
          note: 'Daily footsteps',
        ),
        HomeStatHistoryItem(
          label: 'Yesterday',
          value: '$yesterday',
          unit: 'steps',
          note: 'Previous day steps',
        ),
      ],
    );
  }

  final RxList<HomeBodyMetric> bodyMetrics = <HomeBodyMetric>[
    HomeBodyMetric(
      icon: Icons.monitor_weight_rounded,
      title: 'Weight',
      value: '72.5',
      unit: 'kg',
      tag: 'Stable',
      color: AppColors.statWeight,
      history: [
        HomeBodyHistoryItem(
          label: 'Today',
          value: '72.5',
          unit: 'kg',
          note: 'Morning check-in',
        ),
        HomeBodyHistoryItem(
          label: 'Yesterday',
          value: '72.7',
          unit: 'kg',
          note: 'After workout',
        ),
        HomeBodyHistoryItem(
          label: 'Last Week',
          value: '72.9',
          unit: 'kg',
          note: 'Weekly average',
        ),
        HomeBodyHistoryItem(
          label: 'Last Month',
          value: '73.9',
          unit: 'kg',
          note: 'Monthly record',
        ),
      ],
    ),
  ].obs;

  Future<void> getWeightHistory() async {
    final useCase = _weightUseCase;
    if (useCase == null || isWeightHistoryLoading.value) {
      return;
    }

    isWeightHistoryLoading.value = true;
    weightHistoryError.value = null;
    bodyMetrics.clear();
    try {
      final response = await useCase();
      final isSuccessful = response.success == true || response.code == 200;
      if (!isSuccessful || response.data == null) {
        weightHistoryError.value =
            response.message ?? 'Unable to load weight history.';
        return;
      }

      bodyMetrics.assign(_mapWeightHistory(response.data!));
    } on DioException catch (error) {
      final responseData = error.response?.data;
      weightHistoryError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load weight history. Please check your connection.';
    } catch (_) {
      weightHistoryError.value =
          'Something went wrong while loading weight history.';
    } finally {
      isWeightHistoryLoading.value = false;
    }
  }

  HomeBodyMetric _mapWeightHistory(WeightHistoryData data) {
    final currentWeight = _withoutUnit(data.currentWeight, 'kg');
    return HomeBodyMetric(
      icon: Icons.monitor_weight_rounded,
      title: 'Weight',
      value: currentWeight.isEmpty ? '0' : currentWeight,
      unit: 'kg',
      tag: '${data.count ?? data.history.length} records',
      color: AppColors.statWeight,
      history: data.history
          .map(
            (item) => HomeBodyHistoryItem(
              label: _weightDateLabel(item.date),
              value: _withoutUnit(item.weight, 'kg'),
              unit: 'kg',
              note: item.note?.trim().isNotEmpty == true
                  ? item.note!.trim()
                  : 'Weight check-in',
            ),
          )
          .toList(growable: false),
    );
  }

  void applyWeight(double weight) {
    final previousWeight = bodyMetrics.isEmpty ? null : bodyMetrics.first;
    final updatedHistory = <HomeBodyHistoryItem>[
      HomeBodyHistoryItem(
        label: 'Today',
        value: _compactMetric(weight),
        unit: 'kg',
        note: 'Latest measurement',
      ),
      ...?previousWeight?.history,
    ];

    final updatedMetric = HomeBodyMetric(
      icon: Icons.monitor_weight_rounded,
      title: 'Weight',
      value: _compactMetric(weight),
      unit: 'kg',
      tag: 'Updated',
      color: AppColors.statWeight,
      history: updatedHistory,
    );
    if (bodyMetrics.isEmpty) {
      bodyMetrics.add(updatedMetric);
    } else {
      bodyMetrics[0] = updatedMetric;
    }
  }

  HomeStatItem _emptyWorkoutStat() {
    return HomeStatItem(
      icon: Icons.watch_later_rounded,
      title: 'Workout Time',
      value: '0',
      unit: 'min',
      trend: 'No data',
      trendUp: true,
      color: AppColors.statWorkoutTime,
      showTrendIcon: false,
      history: const [],
    );
  }

  String _compactMetric(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String _withoutUnit(String? value, String unit) {
    final normalized = value?.trim() ?? '';
    final suffix = RegExp(
      r'\s*' + RegExp.escape(unit) + r'$',
      caseSensitive: false,
    );
    return normalized.replaceFirst(suffix, '').trim();
  }

  String _weightDateLabel(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Weight entry';
    }
    final date = DateTime.tryParse(normalized);
    return date == null
        ? normalized
        : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void startWorkout() {}

  bool get canRetryStepTracking {
    final stepStatus = _stepTrackingService?.status.value;
    return _stepTrackingService?.notificationEnabled.value == false ||
        stepStatus == StepTrackingStatus.permissionDenied ||
        stepStatus == StepTrackingStatus.unavailable;
  }

  Future<void> retryStepTracking() async {
    await _stepTrackingService?.retry();
  }

  @override
  void onClose() {
    _stepWorker?.dispose();
    super.onClose();
  }
}

class HomeWorkout {
  const HomeWorkout({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final String title;
  final String subtitle;
}

class HomeStatItem {
  const HomeStatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.trend,
    required this.trendUp,
    required this.color,
    this.history = const [],
    this.showTrendIcon = true,
    this.footer = 'vs yesterday',
  });

  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String trend;
  final bool trendUp;
  final Color color;
  final List<HomeStatHistoryItem> history;
  final bool showTrendIcon;
  final String footer;
}

class HomeStatHistoryItem {
  const HomeStatHistoryItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.note,
  });

  final String label;
  final String value;
  final String unit;
  final String note;
}

class HomeBodyMetric {
  const HomeBodyMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.tag,
    required this.color,
    this.history = const [],
  });

  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String tag;
  final Color color;
  final List<HomeBodyHistoryItem>? history;
}

class HomeBodyHistoryItem {
  const HomeBodyHistoryItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.note,
  });

  final String label;
  final String value;
  final String unit;
  final String note;
}
