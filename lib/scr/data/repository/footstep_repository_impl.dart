import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/footstep_history.dart';
import 'package:gym/scr/data/model/postfootstep_model.dart';
import 'package:gym/scr/domain/repository/footstep_repository.dart';

class FootstepRepositoryImpl implements FootstepRepository {
  const FootstepRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<PostFootstepModel> postFootstep(int steps) async {
    final response = await _apiService.post(
      ApiRoutes.postFootstep,
      data: {'steps': steps},
    );
    return PostFootstepModel.fromJson(response);
  }

  @override
  Future<FootstepHistoryModel> getFootstepHistory() async {
    final response = await _apiService.get(ApiRoutes.footstepHistory);
    return FootstepHistoryModel.fromJson(response);
  }
}
