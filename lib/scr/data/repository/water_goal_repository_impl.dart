import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/water_set_model.dart';
import 'package:gym/scr/domain/repository/water_goal_repository.dart';

class WaterGoalRepositoryImpl implements WaterGoalRepository {
  const WaterGoalRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<WaterGoalModel> setWaterGoal(double dailyGoalLiters) async {
    final response = await _apiService.post(
      ApiRoutes.setWater,
      data: {'daily_goal_liters': dailyGoalLiters},
    );
    return WaterGoalModel.fromJson(response);
  }
}
