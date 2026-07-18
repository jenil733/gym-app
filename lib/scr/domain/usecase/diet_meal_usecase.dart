import 'package:gym/scr/data/model/diet_meal_model.dart';
import 'package:gym/scr/domain/repository/diet_meal_repository.dart';

class DietMealUseCase {
  const DietMealUseCase(this._repository);

  final DietMealRepository _repository;

  Future<DietMealModel> call(int mealId) {
    return _repository.getMeal(mealId);
  }
}
