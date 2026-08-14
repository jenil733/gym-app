import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/fcm_model.dart';
import 'package:gym/scr/domain/repository/fcm_repository.dart';

class FcmRepositoryImpl implements FcmRepository {
  const FcmRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<FcmModel> updateFcmToken({
    required String token,
    String? phoneNumber,
    String? deviceId,
  }) async {
    final normalizedPhone = phoneNumber?.trim();
    final normalizedDeviceId = deviceId?.trim();
    final response = await _apiService.post(
      ApiRoutes.fcm,
      data: {
        'fcm_token': token,
        if (normalizedPhone != null && normalizedPhone.isNotEmpty)
          'phone_number': normalizedPhone,
        if (normalizedDeviceId != null && normalizedDeviceId.isNotEmpty)
          'device_id': normalizedDeviceId,
      },
    );
    return FcmModel.fromJson(response);
  }
}
