import 'package:gym/scr/data/model/diet_model.dart';
import 'package:gym/scr/domain/repository/diet_repository.dart';

class DietUseCase {
  const DietUseCase(this._repository);

  final DietRepository _repository;

  Future<DietModel> call() {
    return _repository.getDietPlans();
  }
}
