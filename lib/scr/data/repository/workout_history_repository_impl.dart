import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/wrk_history_model.dart';
import 'package:gym/scr/domain/repository/workout_history_repository.dart';

class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  const WorkoutHistoryRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<WorkoutHistoryModel> getWorkoutHistory() async {
    final response = await _apiService.get(ApiRoutes.workoutHistory);
    return WorkoutHistoryModel.fromJson(response);
  }
}
