import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/data/model/get_workout_model.dart';
import 'package:gym/scr/data/model/timing_model.dart';
import 'package:gym/scr/domain/repository/workout_timing_repository.dart';
import 'package:gym/scr/domain/usecase/workout_timing_usecase.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';

void main() {
  test('dashboard workout time comes from timing history', () async {
    final controller = HomeController(
      null,
      null,
      null,
      null,
      WorkoutTimingUseCase(_FakeWorkoutTimingRepository()),
    );

    expect(
      controller.stats.firstWhere((item) => item.title == 'Workout Time').value,
      '0',
    );

    await controller.getWorkoutHistory();

    final workoutTime = controller.stats.firstWhere(
      (item) => item.title == 'Workout Time',
    );
    expect(workoutTime.value, '17');
    expect(workoutTime.unit, 'min 00 sec');
    expect(workoutTime.history.single.value, '17');
    expect(workoutTime.history.single.unit, 'min 00 sec');
  });
}

class _FakeWorkoutTimingRepository implements WorkoutTimingRepository {
  @override
  Future<GetWorkoutTimingModel> getWorkoutTimingHistory() async {
    return const GetWorkoutTimingModel(
      success: true,
      code: 200,
      data: WorkoutTimingHistoryData(
        todayDuration: 17,
        yesterdayDuration: 15,
        percentChange: 13,
        trend: 'up',
        history: [
          WorkoutTimingHistoryItem(
            day: 'Today',
            durationMinutes: 17,
            notes: 'Completed workout',
          ),
        ],
      ),
    );
  }

  @override
  Future<WorkoutTimingModel> saveWorkoutTiming(
    WorkoutTimingParams params,
  ) async {
    return const WorkoutTimingModel(success: true, code: 201);
  }
}
