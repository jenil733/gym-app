import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/profile_model.dart';
import 'package:gym/scr/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<ProfileModel> getProfile() async {
    final response = await _apiService.get(ApiRoutes.profile);
    return ProfileModel.fromJson(response);
  }
}
