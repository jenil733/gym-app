import 'package:dio/dio.dart';
import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/update_profile.dart';
import 'package:gym/scr/domain/repository/update_profile_repository.dart';

class UpdateProfileRepositoryImpl implements UpdateProfileRepository {
  const UpdateProfileRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<UpdateProfileModel> updateProfile(UpdateProfileParams params) async {
    final requestData = params.toJson();
    final imageBytes = params.profileImageBytes;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      requestData['profile_image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: params.profileImageName ?? 'profile.jpg',
      );
    }

    final response = await _apiService.post(
      ApiRoutes.updateProfile,
      data: FormData.fromMap(requestData),
    );
    return UpdateProfileModel.fromJson(response);
  }
}
