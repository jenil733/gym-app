import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/get_workout_model.dart';
import 'package:gym/scr/data/model/timing_model.dart';
import 'package:gym/scr/domain/repository/workout_timing_repository.dart';

class WorkoutTimingRepositoryImpl implements WorkoutTimingRepository {
  const WorkoutTimingRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<WorkoutTimingModel> saveWorkoutTiming(
    WorkoutTimingParams params,
  ) async {
    final response = await _apiService.post(
      ApiRoutes.timing,
      data: params.toJson(),
    );
    return WorkoutTimingModel.fromJson(response);
  }

  @override
  Future<GetWorkoutTimingModel> getWorkoutTimingHistory() async {
    final response = await _apiService.get(ApiRoutes.gettiming);
    return GetWorkoutTimingModel.fromJson(response);
  }
}
