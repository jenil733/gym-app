import 'package:gym/scr/data/model/get_workout_model.dart';
import 'package:gym/scr/data/model/timing_model.dart';
import 'package:gym/scr/domain/repository/workout_timing_repository.dart';

class WorkoutTimingUseCase {
  const WorkoutTimingUseCase(this._repository);

  final WorkoutTimingRepository _repository;

  Future<WorkoutTimingModel> save(WorkoutTimingParams params) {
    return _repository.saveWorkoutTiming(params);
  }

  Future<GetWorkoutTimingModel> getHistory() {
    return _repository.getWorkoutTimingHistory();
  }
}
