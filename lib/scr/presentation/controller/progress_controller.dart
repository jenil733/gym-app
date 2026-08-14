import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/weight_graph_storage.dart';
import 'package:gym/scr/core/services/weight_goal_storage.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/data/model/getweight_model.dart';
import 'package:gym/scr/data/model/heightweight_model.dart';
import 'package:gym/scr/domain/usecase/height_weight_usecase.dart';
import 'package:gym/scr/domain/usecase/profile_usecase.dart';
import 'package:gym/scr/domain/usecase/weight_history_usecase.dart';

enum WeightGraphRange { days, weeks, months, annually }

class ProgressController extends GetxController {
  ProgressController([
    this._heightWeightUseCase,
    this._weightHistoryUseCase,
    this._graphStorage,
    this._goalStorage,
    this._profileUseCase,
  ]);

  final HeightWeightUseCase? _heightWeightUseCase;
  final WeightHistoryUseCase? _weightHistoryUseCase;
  final WeightGraphStorage? _graphStorage;
  final WeightGoalStorage? _goalStorage;
  final ProfileUseCase? _profileUseCase;

  static ProgressController resolve() {
    if (Get.isRegistered<ProgressController>()) {
      return Get.find<ProgressController>();
    }
    return Get.put(
      ProgressController(
        Get.isRegistered<HeightWeightUseCase>()
            ? Get.find<HeightWeightUseCase>()
            : null,
        Get.isRegistered<WeightHistoryUseCase>()
            ? Get.find<WeightHistoryUseCase>()
            : null,
        Get.isRegistered<WeightGraphStorage>()
            ? Get.find<WeightGraphStorage>()
            : null,
        Get.isRegistered<WeightGoalStorage>()
            ? Get.find<WeightGoalStorage>()
            : null,
        Get.isRegistered<ProfileUseCase>() ? Get.find<ProfileUseCase>() : null,
      ),
    );
  }

  final RxBool isHeightWeightSaving = false.obs;
  final RxBool isWeightHistoryLoading = false.obs;
  final RxnString heightWeightError = RxnString();
  final RxnString weightHistoryError = RxnString();
  final Rxn<HeightWeightData> latestHeightWeight = Rxn<HeightWeightData>();
  final RxDouble currentWeight = 0.0.obs;
  final RxDouble currentChange = 0.0.obs;
  final RxDouble currentHeight = 0.0.obs;
  final Rxn<WeightGoal> activeGoal = Rxn<WeightGoal>();
  final Rx<WeightGraphRange> selectedGraphRange = WeightGraphRange.weeks.obs;
  final RxList<WeightGraphPoint> graphPoints = <WeightGraphPoint>[].obs;
  final RxList<ProgressHistoryItem> history = <ProgressHistoryItem>[].obs;

  List<WeightSample> _samples = const [];

  double get goalProgress =>
      activeGoal.value?.progressFor(currentWeight.value) ?? 0;

  double get goalRemaining {
    final goal = activeGoal.value;
    if (goal == null || currentWeight.value <= 0) {
      return 0;
    }
    return (goal.targetWeight - currentWeight.value).abs();
  }

  bool get isGoalCompleted =>
      activeGoal.value?.isCompletedAt(currentWeight.value) ?? false;

  bool get canChangeGoal {
    final goal = activeGoal.value;
    return goal == null || !DateTime.now().isBefore(goal.lockedUntil);
  }

  List<double> get weightPoints =>
      graphPoints.map((point) => point.weight).toList(growable: false);

  String get graphRangeLabel => switch (selectedGraphRange.value) {
    WeightGraphRange.days => 'Last 7 days',
    WeightGraphRange.weeks => 'Last 8 weeks',
    WeightGraphRange.months => 'Last 12 months',
    WeightGraphRange.annually => 'Annual average',
  };

  @override
  void onInit() {
    super.onInit();
    loadWeightProgress();
  }

  Future<void> loadWeightProgress() async {
    final goalStorage = _goalStorage;
    if (goalStorage != null) {
      activeGoal.value = await goalStorage.load();
    }
    await _loadProfileMetrics();

    final storage = _graphStorage;
    if (storage != null) {
      _setSamples(await storage.load());
    }

    final useCase = _weightHistoryUseCase;
    if (useCase == null || isWeightHistoryLoading.value) {
      return;
    }

    isWeightHistoryLoading.value = true;
    weightHistoryError.value = null;
    try {
      final response = await useCase();
      final isSuccessful = response.success == true || response.code == 200;
      final data = response.data;
      if (!isSuccessful || data == null) {
        weightHistoryError.value =
            response.message ?? 'Unable to load weight history.';
        return;
      }

      _applyApiHistory(data);
      final apiSamples = _samplesFromApi(data);
      final merged = storage == null
          ? _mergeInMemory(_samples, apiSamples)
          : await storage.merge(apiSamples);
      _setSamples(merged);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      weightHistoryError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load weight history. Showing saved graph data.';
    } catch (_) {
      weightHistoryError.value =
          'Unable to refresh weight history. Showing saved graph data.';
    } finally {
      isWeightHistoryLoading.value = false;
    }
  }

  Future<void> _loadProfileMetrics() async {
    final useCase = _profileUseCase;
    if (useCase == null) {
      return;
    }
    try {
      final response = await useCase();
      final user = response.data?.user;
      final height = _parseMetric(user?.height);
      final weight = _parseMetric(user?.weight);
      if (height != null && height > 0) {
        currentHeight.value = height;
      }
      if (currentWeight.value <= 0 && weight != null && weight > 0) {
        currentWeight.value = weight;
      }
    } catch (_) {
      // Weight history remains available if profile metrics cannot be loaded.
    }
  }

  Future<bool> setSixMonthGoal(double targetWeight) async {
    if (targetWeight <= 0) {
      heightWeightError.value = 'Enter a valid target weight.';
      return false;
    }
    if (!canChangeGoal) {
      heightWeightError.value =
          'Your goal is locked until $goalUnlockDateLabel.';
      ToastHelper.info('Goal is locked', heightWeightError.value!);
      return false;
    }
    final startingWeight = currentWeight.value;
    if (startingWeight <= 0) {
      heightWeightError.value =
          'Log your current weight before setting a target.';
      return false;
    }
    if ((startingWeight - targetWeight).abs() < 0.05) {
      heightWeightError.value =
          'Target weight must be different from your current weight.';
      return false;
    }

    final goal = WeightGoal.create(
      startWeight: startingWeight,
      targetWeight: targetWeight,
    );
    activeGoal.value = goal;
    await _goalStorage?.save(goal);
    heightWeightError.value = null;
    ToastHelper.success(
      'Six-month goal set',
      'Your target is locked until $goalUnlockDateLabel.',
    );
    return true;
  }

  Future<void> startNewGoal() async {
    if (!canChangeGoal) {
      ToastHelper.info(
        'Goal is locked',
        'You can set a new target after $goalUnlockDateLabel.',
      );
      return;
    }
    activeGoal.value = null;
    await _goalStorage?.clear();
  }

  Future<bool> logWeeklyWeight(double weight) async {
    if (weight <= 0) {
      heightWeightError.value = 'Enter a valid weight.';
      return false;
    }
    if (currentHeight.value <= 0) {
      await _loadProfileMetrics();
    }
    if (currentHeight.value <= 0) {
      heightWeightError.value =
          'Add your height in Personal Information before logging weight.';
      return false;
    }
    final wasCompleted = isGoalCompleted;
    final saved = await postHeightWeight(
      height: currentHeight.value,
      weight: weight,
    );
    if (saved && !wasCompleted && isGoalCompleted) {
      ToastHelper.success(
        'Congratulations!',
        'You completed your six-month weight goal.',
      );
    } else if (saved) {
      ToastHelper.success(
        'Weight updated',
        'Your weekly weight has been added to the trend.',
      );
    }
    return saved;
  }

  Future<bool> logDailyWeight(double weight) => logWeeklyWeight(weight);

  String get goalUnlockDateLabel {
    final date = activeGoal.value?.lockedUntil;
    if (date == null) {
      return '';
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void selectGraphRange(WeightGraphRange range) {
    selectedGraphRange.value = range;
    _rebuildGraph();
  }

  Future<void> recordWeight(double weight, {DateTime? date}) async {
    if (weight <= 0) {
      return;
    }
    final sample = WeightSample(date: date ?? DateTime.now(), weight: weight);
    final storage = _graphStorage;
    final merged = storage == null
        ? _mergeInMemory(_samples, [sample])
        : await storage.add(weight, date: sample.date);
    currentWeight.value = weight;
    _setSamples(merged);
  }

  Future<bool> postHeightWeight({
    required double height,
    required double weight,
  }) async {
    if (height <= 0 || weight <= 0) {
      heightWeightError.value = 'Height and weight must be greater than zero.';
      return false;
    }

    final useCase = _heightWeightUseCase;
    if (useCase == null) {
      heightWeightError.value = 'Height and weight service is unavailable.';
      return false;
    }
    if (isHeightWeightSaving.value) {
      return false;
    }

    isHeightWeightSaving.value = true;
    heightWeightError.value = null;
    try {
      final response = await useCase(height: height, weight: weight);
      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      if (!isSuccessful) {
        heightWeightError.value =
            response.message ?? 'Unable to save height and weight.';
        return false;
      }

      latestHeightWeight.value = response.data;
      await recordWeight(
        _parseWeight(response.data?.weight) ?? weight,
        date: DateTime.tryParse(response.data?.date ?? ''),
      );
      return true;
    } on DioException catch (error) {
      final responseData = error.response?.data;
      heightWeightError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to save height and weight. Please check your connection.';
      return false;
    } catch (_) {
      heightWeightError.value =
          'Something went wrong while saving height and weight.';
      return false;
    } finally {
      isHeightWeightSaving.value = false;
    }
  }

  void _applyApiHistory(WeightHistoryData data) {
    final entries = [...data.history]
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a.date ?? '');
        final bDate = DateTime.tryParse(b.date ?? '');
        if (aDate == null || bDate == null) {
          return 0;
        }
        return bDate.compareTo(aDate);
      });
    final current = _parseWeight(data.currentWeight);
    if (current != null) {
      currentWeight.value = current;
    }

    history.assignAll(
      List.generate(entries.length, (index) {
        final item = entries[index];
        final weight = _parseWeight(item.weight) ?? 0;
        final previous = index + 1 < entries.length
            ? _parseWeight(entries[index + 1].weight)
            : null;
        return ProgressHistoryItem(
          label: _dateLabel(item.date),
          weight: '${_compact(weight)} kg',
          change: previous == null ? '—' : _signedWeight(weight - previous),
          note: item.note,
        );
      }),
    );
    if (entries.length > 1) {
      final newest = _parseWeight(entries.first.weight);
      final previous = _parseWeight(entries[1].weight);
      currentChange.value = newest != null && previous != null
          ? newest - previous
          : 0;
    }
  }

  List<WeightSample> _samplesFromApi(WeightHistoryData data) {
    final samples = <WeightSample>[];
    for (final item in data.history) {
      final date = DateTime.tryParse(item.date ?? '');
      final weight = _parseWeight(item.weight);
      if (date != null && weight != null) {
        samples.add(WeightSample(date: date, weight: weight));
      }
    }
    final current = _parseWeight(data.currentWeight);
    if (current != null) {
      samples.add(WeightSample(date: DateTime.now(), weight: current));
    }
    return samples;
  }

  void _setSamples(List<WeightSample> samples) {
    _samples = [...samples]..sort((a, b) => a.date.compareTo(b.date));
    if (currentWeight.value <= 0 && _samples.isNotEmpty) {
      currentWeight.value = _samples.last.weight;
    }
    if (_samples.length > 1 && currentChange.value == 0) {
      currentChange.value =
          _samples.last.weight - _samples[_samples.length - 2].weight;
    }
    _rebuildGraph();
  }

  void _rebuildGraph() {
    if (_samples.isEmpty) {
      graphPoints.clear();
      return;
    }

    final now = DateTime.now();
    late final DateTime cutoff;
    late final String Function(DateTime) keyFor;
    late final String Function(DateTime) labelFor;
    switch (selectedGraphRange.value) {
      case WeightGraphRange.days:
        cutoff = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        keyFor = (date) => '${date.year}-${date.month}-${date.day}';
        labelFor = (date) => '${date.day}/${date.month}';
      case WeightGraphRange.weeks:
        cutoff = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 55));
        keyFor = (date) {
          final start = date.subtract(Duration(days: date.weekday - 1));
          return '${start.year}-${start.month}-${start.day}';
        };
        labelFor = (date) {
          final start = date.subtract(Duration(days: date.weekday - 1));
          return '${start.day}/${start.month}';
        };
      case WeightGraphRange.months:
        cutoff = DateTime(now.year, now.month - 11);
        keyFor = (date) => '${date.year}-${date.month}';
        labelFor = (date) => _monthLabel(date.month);
      case WeightGraphRange.annually:
        cutoff = DateTime(0);
        keyFor = (date) => '${date.year}';
        labelFor = (date) => '${date.year}';
    }

    final grouped = <String, List<WeightSample>>{};
    for (final sample in _samples.where(
      (item) => !item.date.isBefore(cutoff),
    )) {
      grouped.putIfAbsent(keyFor(sample.date), () => []).add(sample);
    }
    final points = grouped.values.map((samples) {
      final average =
          samples.fold<double>(0, (sum, item) => sum + item.weight) /
          samples.length;
      return WeightGraphPoint(
        date: samples.first.date,
        weight: average,
        label: labelFor(samples.first.date),
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
    graphPoints.assignAll(points);
  }

  List<WeightSample> _mergeInMemory(
    Iterable<WeightSample> existing,
    Iterable<WeightSample> incoming,
  ) {
    final values = <String, WeightSample>{};
    for (final sample in [...existing, ...incoming]) {
      values['${sample.date.year}-${sample.date.month}-${sample.date.day}'] =
          sample;
    }
    return values.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  double? _parseWeight(String? value) {
    return double.tryParse(
      (value ?? '').replaceAll(RegExp('kg', caseSensitive: false), '').trim(),
    );
  }

  double? _parseMetric(String? value) {
    return double.tryParse(
      (value ?? '').replaceAll(RegExp(r'[^0-9.]'), '').trim(),
    );
  }

  String _dateLabel(String? value) {
    final date = DateTime.tryParse(value ?? '');
    return date == null
        ? (value?.trim().isNotEmpty == true ? value!.trim() : 'Weight entry')
        : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _signedWeight(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)} kg';
  }

  String _compact(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class WeightGraphPoint {
  const WeightGraphPoint({
    required this.date,
    required this.weight,
    required this.label,
  });

  final DateTime date;
  final double weight;
  final String label;
}

class ProgressHistoryItem {
  const ProgressHistoryItem({
    required this.label,
    required this.weight,
    required this.change,
    this.note,
  });

  final String label;
  final String weight;
  final String change;
  final String? note;
}
