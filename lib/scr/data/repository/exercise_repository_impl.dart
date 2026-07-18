import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/exercise_model.dart';
import 'package:gym/scr/domain/repository/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  const ExerciseRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<ExerciseModel> getExercises(int categoryId) async {
    final response = await _apiService.get(ApiRoutes.exercises(categoryId));
    return ExerciseModel.fromJson(response);
  }
}
