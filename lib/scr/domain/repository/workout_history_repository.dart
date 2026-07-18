import 'package:gym/scr/data/model/wrk_history_model.dart';

abstract class WorkoutHistoryRepository {
  Future<WorkoutHistoryModel> getWorkoutHistory();
}
