import 'package:gym/scr/data/model/wrk_history_model.dart';
import 'package:gym/scr/domain/repository/workout_history_repository.dart';

class WorkoutHistoryUseCase {
  const WorkoutHistoryUseCase(this._repository);

  final WorkoutHistoryRepository _repository;

  Future<WorkoutHistoryModel> call() {
    return _repository.getWorkoutHistory();
  }
}
