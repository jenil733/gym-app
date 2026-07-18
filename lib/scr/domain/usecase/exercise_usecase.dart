import 'package:gym/scr/data/model/exercise_model.dart';
import 'package:gym/scr/domain/repository/exercise_repository.dart';

class ExerciseUseCase {
  const ExerciseUseCase(this._repository);

  final ExerciseRepository _repository;

  Future<ExerciseModel> call(int categoryId) {
    return _repository.getExercises(categoryId);
  }
}
