import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/getweight_model.dart';
import 'package:gym/scr/domain/repository/weight_history_repository.dart';

class WeightHistoryRepositoryImpl implements WeightHistoryRepository {
  const WeightHistoryRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<WeightHistoryModel> getWeightHistory() async {
    final response = await _apiService.get(ApiRoutes.weight);
    return WeightHistoryModel.fromJson(response);
  }
}
