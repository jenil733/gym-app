import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/heightweight_model.dart';
import 'package:gym/scr/domain/repository/height_weight_repository.dart';

class HeightWeightRepositoryImpl implements HeightWeightRepository {
  const HeightWeightRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<HeightWeightModel> logHeightWeight({
    required double height,
    required double weight,
  }) async {
    final response = await _apiService.post(
      ApiRoutes.height,
      data: <String, dynamic>{'height': height, 'weight': weight},
    );
    return HeightWeightModel.fromJson(response);
  }
}
