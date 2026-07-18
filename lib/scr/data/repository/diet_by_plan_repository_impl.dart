import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/diet_by_plan_model.dart';
import 'package:gym/scr/domain/repository/diet_by_plan_repository.dart';

class DietByPlanRepositoryImpl implements DietByPlanRepository {
  const DietByPlanRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<DietByPlanModel> getMeals(int planId) async {
    final response = await _apiService.get(ApiRoutes.dietByPlan(planId));
    return DietByPlanModel.fromJson(response);
  }
}
