import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/data/model/get_workout_model.dart';
import 'package:gym/scr/data/model/timing_model.dart';
import 'package:gym/scr/domain/repository/workout_timing_repository.dart';
import 'package:gym/scr/domain/usecase/workout_timing_usecase.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('timing payload uses API datetime format and exercise identifiers', () {
    final params = WorkoutTimingParams(
      exerciseId: 10,
      categoryId: 3,
      exerciseName: 'Bench Press',
      categoryName: 'Chest',
      startTime: DateTime(2026, 7, 16, 18, 5, 2),
      endTime: DateTime(2026, 7, 16, 18, 8, 7),
      durationMinutes: 4,
    );

    expect(params.toJson(), containsPair('exercise_id', 10));
    expect(params.toJson(), containsPair('category_id', 3));
    expect(params.toJson(), containsPair('start_time', '2026-07-16 18:05:02'));
    expect(params.toJson(), containsPair('end_time', '2026-07-16 18:08:07'));
  });

  test(
    'finishing an exercise sends start and end timing to the API layer',
    () async {
      final repository = _FakeWorkoutTimingRepository();
      final controller = WorkoutController(
        null,
        null,
        WorkoutTimingUseCase(repository),
      );
      final exercise = controller.allExercises.first;

      controller.addExercise(exercise);
      controller.startExercise(exercise);
      controller.pauseWorkoutTimer();
      controller.workoutElapsedSeconds.value = 125;
      await controller.finishWorkout();

      final sent = repository.savedParams;
      expect(sent, isNotNull);
      expect(sent!.exerciseName, exercise.title);
      expect(sent.categoryName, exercise.category);
      expect(sent.durationMinutes, 2);
      expect(sent.endTime.isBefore(sent.startTime), isFalse);
      expect(controller.timingError.value, isNull);
    },
  );

  test(
    'live calories increase from the exercise estimate and elapsed time',
    () {
      final controller = WorkoutController();
      final exercise = controller.allExercises.first;

      controller.startExercise(exercise);
      controller.pauseWorkoutTimer();
      controller.workoutElapsedSeconds.value = 178;

      expect(controller.workoutCaloriesBurned, closeTo(60, 0.01));
      expect(controller.caloriesBurnedAt(356), closeTo(120, 0.01));
    },
  );

  test('completed exercise is restored after logging in again', () async {
    final original = WorkoutController().allExercises.first;
    final repository = _FakeWorkoutTimingRepository(
      history: GetWorkoutTimingModel(
        success: true,
        code: 200,
        data: WorkoutTimingHistoryData(
          todayDuration: 4,
          history: [
            WorkoutTimingHistoryItem(
              day: 'Today',
              exerciseName: original.title,
              durationMinutes: 4,
              notes: '${original.title} completed',
            ),
          ],
        ),
      ),
    );
    final controller = WorkoutController(
      null,
      null,
      WorkoutTimingUseCase(repository),
    );

    await controller.restoreTodayWorkout(now: DateTime(2026, 7, 25));

    expect(controller.selectedExercises.single.title, original.title);
    expect(
      controller.isExerciseCompleted(controller.selectedExercises.single),
      isTrue,
    );
    expect(controller.todayWorkoutElapsedSeconds.value, 240);
    expect(controller.addExercise(original), isFalse);
  });
}

class _FakeWorkoutTimingRepository implements WorkoutTimingRepository {
  _FakeWorkoutTimingRepository({
    this.history = const GetWorkoutTimingModel(
      success: true,
      code: 200,
      data: WorkoutTimingHistoryData(),
    ),
  });

  WorkoutTimingParams? savedParams;
  final GetWorkoutTimingModel history;

  @override
  Future<WorkoutTimingModel> saveWorkoutTiming(
    WorkoutTimingParams params,
  ) async {
    savedParams = params;
    return const WorkoutTimingModel(success: true, code: 201);
  }

  @override
  Future<GetWorkoutTimingModel> getWorkoutTimingHistory() async {
    return history;
  }
}
