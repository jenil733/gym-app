import 'package:gym/scr/data/model/diet_by_plan_model.dart';

abstract class DietByPlanRepository {
  Future<DietByPlanModel> getMeals(int planId);
}
