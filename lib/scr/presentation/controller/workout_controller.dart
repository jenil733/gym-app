import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/data/model/category_model.dart';
import 'package:gym/scr/data/model/exercise_model.dart';
import 'package:gym/scr/domain/usecase/category_usecase.dart';
import 'package:gym/scr/domain/usecase/exercise_usecase.dart';
import 'package:gym/scr/domain/repository/workout_timing_repository.dart';
import 'package:gym/scr/domain/usecase/workout_timing_usecase.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';

class WorkoutController extends GetxController {
  WorkoutController([
    this._categoryUseCase,
    this._exerciseUseCase,
    this._workoutTimingUseCase,
  ]);

  static WorkoutController resolve() {
    if (Get.isRegistered<WorkoutController>()) {
      return Get.find<WorkoutController>();
    }

    final categoryUseCase = _findOrNull<CategoryUseCase>();
    final exerciseUseCase = _findOrNull<ExerciseUseCase>();
    final timingUseCase = _findOrNull<WorkoutTimingUseCase>();

    return Get.put(
      WorkoutController(categoryUseCase, exerciseUseCase, timingUseCase),
    );
  }

  static T? _findOrNull<T>() {
    try {
      return Get.find<T>();
    } catch (_) {
      return null;
    }
  }

  final CategoryUseCase? _categoryUseCase;
  final ExerciseUseCase? _exerciseUseCase;
  final WorkoutTimingUseCase? _workoutTimingUseCase;

  static const int maxSelectedExercises = 10;

  final RxList<CategoryData> categories = <CategoryData>[].obs;
  final Rxn<CategoryData> selectedCategory = Rxn<CategoryData>();
  final RxBool isCategoryLoading = false.obs;
  final RxnString categoryError = RxnString();
  final Rxn<ExerciseData> exerciseData = Rxn<ExerciseData>();
  final RxList<ExerciseItem> categoryExercises = <ExerciseItem>[].obs;
  final RxBool isExerciseLoading = false.obs;
  final RxnString exerciseError = RxnString();
  final List<WorkoutExercise> allExercises = _exerciseCatalog;
  final RxList<WorkoutExercise> selectedExercises = <WorkoutExercise>[].obs;
  final RxString workoutSearchQuery = ''.obs;
  final Rxn<WorkoutExercise> activeExercise = Rxn<WorkoutExercise>();
  final RxInt workoutElapsedSeconds = 0.obs;
  final RxInt todayWorkoutElapsedSeconds = 0.obs;
  final RxBool isWorkoutTimerRunning = false.obs;
  final RxBool isTimingSaving = false.obs;
  final RxnString timingError = RxnString();
  final RxList<String> completedExerciseIds = <String>[].obs;
  final RxMap<String, int> completedExerciseDurations = <String, int>{}.obs;
  Timer? _workoutTimer;
  DateTime? _activeExerciseStartedAt;
  int _exerciseRequestId = 0;

  CategoryUseCase? get _useCase {
    if (_categoryUseCase != null) {
      return _categoryUseCase;
    }
    if (Get.isRegistered<CategoryUseCase>()) {
      return Get.find<CategoryUseCase>();
    }
    return null;
  }

  ExerciseUseCase? get _exerciseLoader {
    if (_exerciseUseCase != null) {
      return _exerciseUseCase;
    }
    if (Get.isRegistered<ExerciseUseCase>()) {
      return Get.find<ExerciseUseCase>();
    }
    return null;
  }

  WorkoutTimingUseCase? get _timingUseCase {
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
    if (_useCase != null) {
      getCategories();
    }
  }

  Future<void> getCategories() async {
    final useCase = _useCase;
    if (isCategoryLoading.value) {
      return;
    }

    if (useCase == null) {
      categoryError.value = 'Workout service is unavailable. Restart the app.';
      return;
    }

    isCategoryLoading.value = true;
    categoryError.value = null;

    try {
      final response = await useCase();
      final isSuccessful = response.success == true || response.code == 200;

      if (!isSuccessful) {
        categoryError.value = response.message ?? 'Unable to load categories.';
        return;
      }

      categories.assignAll(response.data ?? <CategoryData>[]);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      categoryError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load categories. Please check your connection.';
    } catch (_) {
      categoryError.value = 'Something went wrong while loading categories.';
    } finally {
      isCategoryLoading.value = false;
    }
  }

  Future<void> getExercises(int categoryId) async {
    final useCase = _exerciseLoader;
    if (useCase == null) {
      return;
    }

    final requestId = ++_exerciseRequestId;
    isExerciseLoading.value = true;
    exerciseError.value = null;
    exerciseData.value = null;
    categoryExercises.clear();

    try {
      final response = await useCase(categoryId);
      if (requestId != _exerciseRequestId) {
        return;
      }
      final isSuccessful = response.success == true || response.code == 200;

      if (!isSuccessful || response.data == null) {
        exerciseError.value = response.message ?? 'Unable to load exercises.';
        return;
      }

      exerciseData.value = response.data;
      categoryExercises.assignAll(response.data!.exercises);
    } on DioException catch (error) {
      if (requestId != _exerciseRequestId) {
        return;
      }
      final responseData = error.response?.data;
      exerciseError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load exercises. Please check your connection.';
    } catch (_) {
      if (requestId != _exerciseRequestId) {
        return;
      }
      exerciseError.value = 'Something went wrong while loading exercises.';
    } finally {
      if (requestId == _exerciseRequestId) {
        isExerciseLoading.value = false;
      }
    }
  }

  Future<void> selectCategory(CategoryData category) async {
    final categoryId = category.id;
    if (categoryId == null) {
      return;
    }

    if ((category.exerciseCount ?? 0) <= 0) {
      _showMessage(
        'Coming soon',
        '${category.categoryName ?? 'This category'} has no exercises yet.',
      );
      return;
    }

    selectedCategory.value = category;
    workoutSearchQuery.value = '';
    await getExercises(categoryId);

    if (exerciseError.value == null && categoryExercises.isEmpty) {
      showCategories();
      _showMessage(
        'No exercises found',
        'Please choose another workout category.',
      );
    }
  }

  void showCategories() {
    _exerciseRequestId += 1;
    selectedCategory.value = null;
    exerciseData.value = null;
    categoryExercises.clear();
    exerciseError.value = null;
    isExerciseLoading.value = false;
    workoutSearchQuery.value = '';
  }

  Future<void> retryExercises() async {
    final categoryId = selectedCategory.value?.id;
    if (categoryId != null) {
      await getExercises(categoryId);
    }
  }

  List<WorkoutExercise> get visibleCategoryExercises {
    final categoryName =
        exerciseData.value?.categoryName ??
        selectedCategory.value?.categoryName ??
        'Workout';
    final query = workoutSearchQuery.value.trim().toLowerCase();

    return categoryExercises
        .where((item) {
          if (query.isEmpty) {
            return true;
          }
          return (item.exerciseName ?? '').toLowerCase().contains(query);
        })
        .map((item) => _mapApiExercise(item, categoryName))
        .toList(growable: false);
  }

  WorkoutExercise _mapApiExercise(ExerciseItem item, String categoryName) {
    final exerciseImage = item.image?.trim();
    final categoryImage = selectedCategory.value?.image?.trim();
    final image = exerciseImage?.isNotEmpty == true
        ? exerciseImage
        : categoryImage;
    final hasNetworkImage =
        image != null &&
        image.isNotEmpty &&
        (image.startsWith('http://') || image.startsWith('https://'));

    return WorkoutExercise(
      id: 'api-${item.id ?? item.exerciseName.hashCode}',
      apiExerciseId: item.id,
      apiCategoryId: selectedCategory.value?.id,
      category: categoryName,
      title: item.exerciseName?.trim().isNotEmpty == true
          ? item.exerciseName!.trim()
          : 'Exercise',
      focus: '${item.calories ?? 0} kcal estimated burn',
      sets: '${item.sets ?? 0}',
      reps: '${item.reps ?? 0}',
      rest: '${item.restSeconds ?? 0} sec',
      calories: '${item.calories ?? 0} kcal',
      icon: Icons.fitness_center_rounded,
      color: AppColors.primary,
      image: hasNetworkImage ? image : banner,
      imageIsNetwork: hasNetworkImage,
      instructions: item.howTo.isEmpty
          ? const ['Instructions are not available for this exercise yet.']
          : item.howTo,
    );
  }

  List<WorkoutExercise> get visibleExercises {
    final query = workoutSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return allExercises;
    }

    return allExercises
        .where(
          (exercise) =>
              exercise.title.toLowerCase().contains(query) ||
              exercise.focus.toLowerCase().contains(query) ||
              exercise.category.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  int get remainingExerciseSlots =>
      maxSelectedExercises - selectedExercises.length;

  bool get canAddExercise => remainingExerciseSlots > 0;

  WorkoutExercise? get nextExercise {
    for (final exercise in selectedExercises) {
      if (!isExerciseCompleted(exercise)) {
        return exercise;
      }
    }
    return null;
  }

  bool get hasCompletedWorkout =>
      selectedExercises.isNotEmpty && nextExercise == null;

  String get formattedWorkoutElapsed =>
      _formatSeconds(workoutElapsedSeconds.value);

  String get formattedTodayWorkoutElapsed =>
      _formatTotalSeconds(todayWorkoutElapsedSeconds.value);

  /// Live calorie estimate for the active exercise.
  ///
  /// Exercise calories are supplied as a target (for example `120 kcal`). The
  /// target duration is estimated from its sets, reps and rests so the value
  /// can progress smoothly with the workout timer without requiring a sensor.
  double get workoutCaloriesBurned =>
      caloriesBurnedAt(workoutElapsedSeconds.value);

  double caloriesBurnedAt(int elapsedSeconds) {
    final exercise = activeExercise.value;
    if (exercise == null || elapsedSeconds <= 0) {
      return 0;
    }

    final targetCalories =
        double.tryParse(
          RegExp(r'\d+(?:\.\d+)?').firstMatch(exercise.calories)?.group(0) ??
              '',
        ) ??
        0;
    if (targetCalories <= 0) {
      return 0;
    }

    return targetCalories *
        elapsedSeconds /
        _estimatedExerciseSeconds(exercise);
  }

  int _estimatedExerciseSeconds(WorkoutExercise exercise) {
    int firstNumber(String value, {required int fallback}) {
      return int.tryParse(RegExp(r'\d+').firstMatch(value)?.group(0) ?? '') ??
          fallback;
    }

    final sets = firstNumber(exercise.sets, fallback: 3).clamp(1, 20);
    final reps = firstNumber(exercise.reps, fallback: 12).clamp(1, 100);
    final restSeconds = firstNumber(exercise.rest, fallback: 45).clamp(0, 300);
    const secondsPerRep = 4;
    const transitionSecondsPerSet = 12;
    final activeSeconds =
        sets * (reps * secondsPerRep + transitionSecondsPerSet);
    final restingSeconds = (sets - 1) * restSeconds;
    return (activeSeconds + restingSeconds).clamp(60, 3600);
  }

  int exerciseDuration(WorkoutExercise exercise) =>
      completedExerciseDurations[exercise.id] ?? 0;

  void updateWorkoutSearch(String value) {
    workoutSearchQuery.value = value;
  }

  bool isExerciseSelected(WorkoutExercise exercise) {
    return selectedExercises.any((item) => item.id == exercise.id);
  }

  bool addExercise(WorkoutExercise exercise) {
    if (isExerciseSelected(exercise)) {
      _showMessage('Already added', '${exercise.title} is in My Workout.');
      return false;
    }

    if (!canAddExercise) {
      _showMessage(
        'Workout limit reached',
        'My Workout can contain up to $maxSelectedExercises exercises.',
      );
      return false;
    }

    selectedExercises.add(exercise);
    _showMessage(
      'Exercise added',
      '${exercise.title} was added to My Workout.',
    );
    return true;
  }

  void removeExercise(WorkoutExercise exercise) {
    selectedExercises.removeWhere((item) => item.id == exercise.id);
    completedExerciseIds.remove(exercise.id);
    final removedDuration = completedExerciseDurations.remove(exercise.id) ?? 0;
    final updatedTotal = todayWorkoutElapsedSeconds.value - removedDuration;
    todayWorkoutElapsedSeconds.value = updatedTotal < 0 ? 0 : updatedTotal;
  }

  void startExercise(WorkoutExercise exercise) {
    activeExercise.value = exercise;
    workoutElapsedSeconds.value = 0;
    timingError.value = null;
    _activeExerciseStartedAt = DateTime.now();
    _startWorkoutTimer();
  }

  void pauseWorkoutTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = null;
    isWorkoutTimerRunning.value = false;
  }

  void resumeWorkoutTimer() {
    if (activeExercise.value == null || isWorkoutTimerRunning.value) {
      return;
    }
    _startWorkoutTimer();
  }

  Future<void> finishWorkout() async {
    final exercise = activeExercise.value;
    final startedAt = _activeExerciseStartedAt;
    final endedAt = DateTime.now();
    final elapsedSeconds = workoutElapsedSeconds.value;
    if (exercise != null) {
      final previousDuration = completedExerciseDurations[exercise.id] ?? 0;
      completedExerciseDurations[exercise.id] = elapsedSeconds;
      todayWorkoutElapsedSeconds.value =
          todayWorkoutElapsedSeconds.value - previousDuration + elapsedSeconds;
      markExerciseCompleted(exercise);
    }

    pauseWorkoutTimer();
    activeExercise.value = null;
    _activeExerciseStartedAt = null;
    workoutElapsedSeconds.value = 0;

    if (exercise != null && startedAt != null) {
      await _saveWorkoutTiming(
        exercise: exercise,
        startedAt: startedAt,
        endedAt: endedAt,
        elapsedSeconds: elapsedSeconds,
      );
    }
  }

  Future<void> _saveWorkoutTiming({
    required WorkoutExercise exercise,
    required DateTime startedAt,
    required DateTime endedAt,
    required int elapsedSeconds,
  }) async {
    final useCase = _timingUseCase;
    if (useCase == null) {
      return;
    }

    isTimingSaving.value = true;
    timingError.value = null;
    try {
      // The API stores workout history in whole minutes and rejects zero.
      final durationMinutes = elapsedSeconds <= 0
          ? 1
          : (elapsedSeconds / 60).ceil();
      final savedEndTime = endedAt.difference(startedAt).inSeconds <= 0
          ? startedAt.add(const Duration(seconds: 1))
          : endedAt;
      final response = await useCase.save(
        WorkoutTimingParams(
          exerciseId: exercise.apiExerciseId,
          categoryId: exercise.apiCategoryId,
          exerciseName: exercise.title,
          categoryName: exercise.category,
          startTime: startedAt,
          endTime: savedEndTime,
          durationMinutes: durationMinutes,
          notes: '${exercise.title} completed',
        ),
      );
      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      if (!isSuccessful) {
        timingError.value = response.message ?? 'Unable to save workout time.';
        _showMessage('Timing not saved', timingError.value!);
        return;
      }

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().getWorkoutHistory(force: true);
      }
    } on DioException catch (error) {
      final responseData = error.response?.data;
      timingError.value = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to save workout time. Please check your connection.';
      _showMessage('Timing not saved', timingError.value!);
    } catch (_) {
      timingError.value = 'Something went wrong while saving workout time.';
      _showMessage('Timing not saved', timingError.value!);
    } finally {
      isTimingSaving.value = false;
    }
  }

  bool isExerciseCompleted(WorkoutExercise exercise) {
    return completedExerciseIds.contains(exercise.id);
  }

  void markExerciseCompleted(WorkoutExercise exercise) {
    if (!completedExerciseIds.contains(exercise.id)) {
      completedExerciseIds.add(exercise.id);
    }
  }

  void _startWorkoutTimer() {
    _workoutTimer?.cancel();
    isWorkoutTimerRunning.value = true;
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      workoutElapsedSeconds.value += 1;
    });
  }

  void _showMessage(String title, String message) {
    ToastHelper.info(title, message);
  }

  @override
  void onClose() {
    _workoutTimer?.cancel();
    super.onClose();
  }
}

class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.category,
    required this.title,
    required this.focus,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.calories,
    required this.icon,
    required this.color,
    required this.image,
    required this.instructions,
    this.imageAlignment = Alignment.center,
    this.imageIsNetwork = false,
    this.apiExerciseId,
    this.apiCategoryId,
  });

  final String id;
  final int? apiExerciseId;
  final int? apiCategoryId;
  final String category;
  final String title;
  final String focus;
  final String sets;
  final String reps;
  final String rest;
  final String calories;
  final IconData icon;
  final Color color;
  final String image;
  final Alignment imageAlignment;
  final bool imageIsNetwork;
  final List<String> instructions;

  bool get hasNetworkImage {
    final uri = Uri.tryParse(image.trim());
    return imageIsNetwork ||
        (uri != null && (uri.scheme == 'http' || uri.scheme == 'https'));
  }
}

const List<WorkoutExercise> _exerciseCatalog = [
  WorkoutExercise(
    id: 'chest-bench-press',
    category: 'Chest',
    title: 'Barbell Bench Press',
    focus: 'Heavy press for chest strength',
    sets: '4',
    reps: '8-10',
    rest: '60 sec',
    calories: '120 kcal',
    icon: Icons.fitness_center_rounded,
    color: AppColors.primary,
    image: login,
    instructions: [
      'Lie with your eyes beneath the bar and plant both feet.',
      'Grip slightly wider than shoulder width and brace your core.',
      'Lower the bar to mid-chest with elbows controlled.',
      'Press upward until your arms are straight without locking hard.',
    ],
  ),
  WorkoutExercise(
    id: 'chest-incline-dumbbell',
    category: 'Chest',
    title: 'Incline Dumbbell Press',
    focus: 'Upper chest and shoulder control',
    sets: '4',
    reps: '10-12',
    rest: '60 sec',
    calories: '110 kcal',
    icon: Icons.trending_up_rounded,
    color: AppColors.primary,
    image: login,
    instructions: [
      'Set the bench to a low incline and hold the dumbbells at chest level.',
      'Pull your shoulder blades back and keep feet planted.',
      'Press the dumbbells up and slightly inward.',
      'Lower slowly until your elbows are just below the bench.',
    ],
  ),
  WorkoutExercise(
    id: 'chest-cable-fly',
    category: 'Chest',
    title: 'Cable Chest Fly',
    focus: 'Chest squeeze and stretch',
    sets: '3',
    reps: '12-15',
    rest: '45 sec',
    calories: '85 kcal',
    icon: Icons.open_in_full_rounded,
    color: AppColors.primary,
    image: login,
    instructions: [
      'Set both pulleys near shoulder height and step forward.',
      'Keep a soft bend in your elbows and brace your torso.',
      'Sweep your hands together in front of your chest.',
      'Return under control until you feel a comfortable stretch.',
    ],
  ),
  WorkoutExercise(
    id: 'chest-push-ups',
    category: 'Chest',
    title: 'Push Ups',
    focus: 'Bodyweight chest finisher',
    sets: '3',
    reps: '15-20',
    rest: '45 sec',
    calories: '75 kcal',
    icon: Icons.arrow_downward_rounded,
    color: AppColors.primary,
    image: login,
    instructions: [
      'Place hands just wider than shoulders and extend your legs.',
      'Keep a straight line from head to heels.',
      'Lower your chest while keeping elbows angled back.',
      'Push the floor away without letting your hips sag.',
    ],
  ),
  WorkoutExercise(
    id: 'back-lat-pulldown',
    category: 'Back',
    title: 'Lat Pulldown',
    focus: 'Wide back activation',
    sets: '4',
    reps: '10-12',
    rest: '60 sec',
    calories: '105 kcal',
    icon: Icons.keyboard_double_arrow_down_rounded,
    color: AppColors.statWorkoutTime,
    image: banner,
    imageAlignment: Alignment.centerRight,
    instructions: [
      'Secure your thighs and take a wide overhand grip.',
      'Lean back slightly with your chest lifted.',
      'Pull the bar toward your upper chest by driving elbows down.',
      'Return slowly until your arms are extended.',
    ],
  ),
  WorkoutExercise(
    id: 'back-seated-row',
    category: 'Back',
    title: 'Seated Cable Row',
    focus: 'Mid-back thickness',
    sets: '4',
    reps: '10-12',
    rest: '60 sec',
    calories: '110 kcal',
    icon: Icons.rowing_rounded,
    color: AppColors.statWorkoutTime,
    image: banner,
    instructions: [
      'Sit tall with knees slightly bent and hold the handle.',
      'Brace your core and keep your shoulders down.',
      'Pull the handle toward your ribs while squeezing your back.',
      'Extend your arms slowly without rounding forward.',
    ],
  ),
  WorkoutExercise(
    id: 'back-single-arm-row',
    category: 'Back',
    title: 'Single Arm Dumbbell Row',
    focus: 'Unilateral pulling control',
    sets: '3',
    reps: '12 each',
    rest: '60 sec',
    calories: '95 kcal',
    icon: Icons.fitness_center_rounded,
    color: AppColors.statWorkoutTime,
    image: banner,
    instructions: [
      'Support one hand and knee on a bench.',
      'Keep your back flat and hold the dumbbell below your shoulder.',
      'Drive your elbow toward your hip.',
      'Lower the weight fully without twisting your torso.',
    ],
  ),
  WorkoutExercise(
    id: 'biceps-dumbbell-curl',
    category: 'Biceps',
    title: 'Standing Dumbbell Curl',
    focus: 'Biceps volume and control',
    sets: '4',
    reps: '12-15',
    rest: '45 sec',
    calories: '70 kcal',
    icon: Icons.fitness_center_rounded,
    color: AppColors.workoutAccent,
    image: banner,
    instructions: [
      'Stand tall with dumbbells at your sides and palms forward.',
      'Keep your elbows close to your ribs.',
      'Curl the weights without swinging your torso.',
      'Lower slowly until your arms are fully extended.',
    ],
  ),
  WorkoutExercise(
    id: 'biceps-hammer-curl',
    category: 'Biceps',
    title: 'Hammer Curl',
    focus: 'Forearms and brachialis',
    sets: '3',
    reps: '12',
    rest: '45 sec',
    calories: '65 kcal',
    icon: Icons.pan_tool_alt_rounded,
    color: AppColors.workoutAccent,
    image: banner,
    instructions: [
      'Hold dumbbells with palms facing your thighs.',
      'Keep shoulders relaxed and elbows stationary.',
      'Curl both weights toward your shoulders.',
      'Lower under control while keeping the neutral grip.',
    ],
  ),
  WorkoutExercise(
    id: 'biceps-preacher-curl',
    category: 'Biceps',
    title: 'Preacher Curl',
    focus: 'Strict curl isolation',
    sets: '3',
    reps: '10-12',
    rest: '45 sec',
    calories: '70 kcal',
    icon: Icons.fitness_center_rounded,
    color: AppColors.workoutAccent,
    image: banner,
    instructions: [
      'Adjust the seat so your upper arms rest fully on the pad.',
      'Begin with elbows nearly straight and wrists neutral.',
      'Curl the weight toward your shoulders without lifting your arms.',
      'Lower slowly before the next repetition.',
    ],
  ),
  WorkoutExercise(
    id: 'triceps-pushdown',
    category: 'Triceps',
    title: 'Cable Triceps Pushdown',
    focus: 'Lockout strength',
    sets: '4',
    reps: '10-12',
    rest: '45 sec',
    calories: '75 kcal',
    icon: Icons.keyboard_double_arrow_down_rounded,
    color: AppColors.primary,
    image: login,
    instructions: [
      'Stand close to the cable with elbows pinned to your sides.',
      'Start with forearms roughly parallel to the floor.',
      'Press the handle down until your arms are straight.',
      'Return without allowing your elbows to drift forward.',
    ],
  ),
  WorkoutExercise(
    id: 'triceps-overhead-extension',
    category: 'Triceps',
    title: 'Overhead Extension',
    focus: 'Long head stretch',
    sets: '3',
    reps: '12',
    rest: '45 sec',
    calories: '70 kcal',
    icon: Icons.upload_rounded,
    color: AppColors.primary,
    image: login,
    instructions: [
      'Hold one weight overhead with both hands.',
      'Keep your ribs down and elbows pointing forward.',
      'Lower the weight behind your head with control.',
      'Extend your elbows to return overhead.',
    ],
  ),
  WorkoutExercise(
    id: 'triceps-bench-dips',
    category: 'Triceps',
    title: 'Bench Dips',
    focus: 'Bodyweight triceps finisher',
    sets: '3',
    reps: '12-15',
    rest: '45 sec',
    calories: '80 kcal',
    icon: Icons.airline_seat_legroom_extra_rounded,
    color: AppColors.primary,
    image: login,
    instructions: [
      'Place your hands on a stable bench beside your hips.',
      'Move your hips just off the edge with legs extended comfortably.',
      'Lower by bending your elbows straight behind you.',
      'Press through your palms to return to the top.',
    ],
  ),
  WorkoutExercise(
    id: 'legs-back-squat',
    category: 'Legs',
    title: 'Barbell Back Squat',
    focus: 'Quad and glute strength',
    sets: '5',
    reps: '8-10',
    rest: '75 sec',
    calories: '150 kcal',
    icon: Icons.fitness_center_rounded,
    color: AppColors.statCalories,
    image: onboardingImageTwo,
    imageAlignment: Alignment.bottomCenter,
    instructions: [
      'Rest the bar across your upper back and stand shoulder width.',
      'Brace your core and keep your chest tall.',
      'Sit down and back while your knees track over your toes.',
      'Drive through your whole foot to stand.',
    ],
  ),
  WorkoutExercise(
    id: 'legs-walking-lunges',
    category: 'Legs',
    title: 'Walking Lunges',
    focus: 'Balance and leg volume',
    sets: '4',
    reps: '12 each',
    rest: '60 sec',
    calories: '130 kcal',
    icon: Icons.directions_walk_rounded,
    color: AppColors.statCalories,
    image: onboardingImageTwo,
    instructions: [
      'Stand tall with space in front of you.',
      'Step forward and lower both knees under control.',
      'Push through the front foot to bring the rear leg forward.',
      'Alternate sides while keeping your torso upright.',
    ],
  ),
  WorkoutExercise(
    id: 'legs-romanian-deadlift',
    category: 'Legs',
    title: 'Romanian Deadlift',
    focus: 'Hamstrings and glutes',
    sets: '4',
    reps: '10',
    rest: '75 sec',
    calories: '140 kcal',
    icon: Icons.fitness_center_rounded,
    color: AppColors.statCalories,
    image: onboardingImageTwo,
    instructions: [
      'Hold the weight in front of your thighs with soft knees.',
      'Push your hips back while keeping your spine neutral.',
      'Lower until you feel tension through your hamstrings.',
      'Drive your hips forward to stand tall.',
    ],
  ),
  WorkoutExercise(
    id: 'shoulders-seated-press',
    category: 'Shoulders',
    title: 'Seated Shoulder Press',
    focus: 'Overhead strength',
    sets: '4',
    reps: '10-12',
    rest: '60 sec',
    calories: '95 kcal',
    icon: Icons.upload_rounded,
    color: AppColors.warning,
    image: banner,
    instructions: [
      'Sit against the backrest with weights at shoulder height.',
      'Brace your core and keep wrists above elbows.',
      'Press overhead without arching your lower back.',
      'Lower the weights smoothly to shoulder level.',
    ],
  ),
  WorkoutExercise(
    id: 'shoulders-lateral-raise',
    category: 'Shoulders',
    title: 'Lateral Raise',
    focus: 'Side delt isolation',
    sets: '4',
    reps: '12-15',
    rest: '45 sec',
    calories: '75 kcal',
    icon: Icons.open_in_full_rounded,
    color: AppColors.warning,
    image: banner,
    instructions: [
      'Stand tall with light weights at your sides.',
      'Keep a slight bend in your elbows.',
      'Raise your arms outward until near shoulder height.',
      'Lower slowly without swinging.',
    ],
  ),
  WorkoutExercise(
    id: 'shoulders-rear-delt-fly',
    category: 'Shoulders',
    title: 'Rear Delt Fly',
    focus: 'Rear shoulder balance',
    sets: '3',
    reps: '12-15',
    rest: '45 sec',
    calories: '70 kcal',
    icon: Icons.swap_horiz_rounded,
    color: AppColors.warning,
    image: banner,
    instructions: [
      'Hinge forward with a flat back and weights below your chest.',
      'Keep elbows softly bent and neck neutral.',
      'Open your arms wide while squeezing behind your shoulders.',
      'Return the weights together slowly.',
    ],
  ),
  WorkoutExercise(
    id: 'abs-cable-crunch',
    category: 'Abs',
    title: 'Cable Crunch',
    focus: 'Loaded core flexion',
    sets: '3',
    reps: '15-20',
    rest: '40 sec',
    calories: '65 kcal',
    icon: Icons.self_improvement_rounded,
    color: AppColors.statBodyFat,
    image: login,
    instructions: [
      'Kneel below a high cable and hold the rope beside your head.',
      'Keep your hips stable and brace your abdomen.',
      'Curl your ribs toward your pelvis.',
      'Return slowly without pulling with your arms.',
    ],
  ),
  WorkoutExercise(
    id: 'abs-plank',
    category: 'Abs',
    title: 'Plank Hold',
    focus: 'Core stability',
    sets: '3',
    reps: '45 sec',
    rest: '40 sec',
    calories: '55 kcal',
    icon: Icons.horizontal_rule_rounded,
    color: AppColors.statBodyFat,
    image: login,
    instructions: [
      'Place forearms beneath your shoulders and extend your legs.',
      'Create a straight line from head to heels.',
      'Squeeze your glutes and brace your abdomen.',
      'Breathe steadily without letting your hips drop.',
    ],
  ),
  WorkoutExercise(
    id: 'abs-mountain-climbers',
    category: 'Abs',
    title: 'Mountain Climbers',
    focus: 'Core and conditioning',
    sets: '4',
    reps: '30 sec',
    rest: '30 sec',
    calories: '80 kcal',
    icon: Icons.directions_run_rounded,
    color: AppColors.statBodyFat,
    image: login,
    instructions: [
      'Begin in a strong high-plank position.',
      'Drive one knee toward your chest.',
      'Switch legs quickly while keeping shoulders above hands.',
      'Keep your hips level throughout the interval.',
    ],
  ),
  WorkoutExercise(
    id: 'cardio-treadmill-intervals',
    category: 'Cardio',
    title: 'Treadmill Intervals',
    focus: 'Sprint and recovery rounds',
    sets: '6',
    reps: '45 sec',
    rest: '30 sec',
    calories: '160 kcal',
    icon: Icons.directions_run_rounded,
    color: AppColors.secondary,
    image: onboardingImageThree,
    instructions: [
      'Warm up at an easy pace for several minutes.',
      'Increase speed to a challenging but controlled sprint.',
      'Recover by walking or jogging for the rest interval.',
      'Repeat the rounds and cool down gradually.',
    ],
  ),
  WorkoutExercise(
    id: 'cardio-cycling-sprint',
    category: 'Cardio',
    title: 'Cycling Sprint',
    focus: 'Low impact conditioning',
    sets: '8',
    reps: '30 sec',
    rest: '30 sec',
    calories: '150 kcal',
    icon: Icons.directions_bike_rounded,
    color: AppColors.secondary,
    image: onboardingImageThree,
    instructions: [
      'Adjust the seat so your knee remains slightly bent at the bottom.',
      'Pedal easily to warm up.',
      'Accelerate hard while keeping your hips stable.',
      'Reduce resistance and pedal slowly during recovery.',
    ],
  ),
  WorkoutExercise(
    id: 'cardio-jump-rope',
    category: 'Cardio',
    title: 'Jump Rope',
    focus: 'Footwork and heart rate',
    sets: '5',
    reps: '60 sec',
    rest: '30 sec',
    calories: '140 kcal',
    icon: Icons.sports_gymnastics_rounded,
    color: AppColors.secondary,
    image: onboardingImageThree,
    instructions: [
      'Stand tall with the rope behind your heels.',
      'Turn the rope with small wrist movements.',
      'Jump only high enough for the rope to pass.',
      'Land softly on the balls of your feet and keep a steady rhythm.',
    ],
  ),
];

String _formatSeconds(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  String twoDigits(int value) => value.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
  return '${twoDigits(minutes)}:${twoDigits(seconds)}';
}

String _formatTotalSeconds(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
}
