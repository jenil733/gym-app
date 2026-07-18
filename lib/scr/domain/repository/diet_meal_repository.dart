import 'package:gym/scr/data/model/diet_meal_model.dart';

abstract class DietMealRepository {
  Future<DietMealModel> getMeal(int mealId);
}
