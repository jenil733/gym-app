import 'package:gym/scr/data/model/getweight_model.dart';
import 'package:gym/scr/domain/repository/weight_history_repository.dart';

class WeightHistoryUseCase {
  const WeightHistoryUseCase(this._repository);

  final WeightHistoryRepository _repository;

  Future<WeightHistoryModel> call() => _repository.getWeightHistory();
}
