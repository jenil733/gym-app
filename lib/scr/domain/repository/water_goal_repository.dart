import 'package:gym/scr/data/model/water_set_model.dart';

abstract class WaterGoalRepository {
  Future<WaterGoalModel> setWaterGoal(double dailyGoalLiters);
}
