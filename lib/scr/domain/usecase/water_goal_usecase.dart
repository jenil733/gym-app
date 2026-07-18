import 'package:gym/scr/data/model/water_set_model.dart';
import 'package:gym/scr/domain/repository/water_goal_repository.dart';

class WaterGoalUseCase {
  const WaterGoalUseCase(this._repository);

  final WaterGoalRepository _repository;

  Future<WaterGoalModel> call(double dailyGoalLiters) {
    return _repository.setWaterGoal(dailyGoalLiters);
  }
}
