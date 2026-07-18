import 'package:gym/scr/data/model/diet_by_plan_model.dart';
import 'package:gym/scr/domain/repository/diet_by_plan_repository.dart';

class DietByPlanUseCase {
  const DietByPlanUseCase(this._repository);

  final DietByPlanRepository _repository;

  Future<DietByPlanModel> call(int planId) {
    return _repository.getMeals(planId);
  }
}
