import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/diet_model.dart';
import 'package:gym/scr/domain/repository/diet_repository.dart';

class DietRepositoryImpl implements DietRepository {
  const DietRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<DietModel> getDietPlans() async {
    final response = await _apiService.get(ApiRoutes.diet);
    return DietModel.fromJson(response);
  }
}
