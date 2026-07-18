import 'package:gym/scr/data/model/exercise_model.dart';

abstract class ExerciseRepository {
  Future<ExerciseModel> getExercises(int categoryId);
}
