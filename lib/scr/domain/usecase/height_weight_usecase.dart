import 'package:gym/scr/data/model/heightweight_model.dart';
import 'package:gym/scr/domain/repository/height_weight_repository.dart';

class HeightWeightUseCase {
  const HeightWeightUseCase(this._repository);

  final HeightWeightRepository _repository;

  Future<HeightWeightModel> call({
    required double height,
    required double weight,
  }) {
    return _repository.logHeightWeight(height: height, weight: weight);
  }
}
