import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/diet_meal_model.dart';
import 'package:gym/scr/domain/repository/diet_meal_repository.dart';

class DietMealRepositoryImpl implements DietMealRepository {
  const DietMealRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<DietMealModel> getMeal(int mealId) async {
    final response = await _apiService.get(ApiRoutes.dietMeal(mealId));
    return DietMealModel.fromJson(response);
  }
}
