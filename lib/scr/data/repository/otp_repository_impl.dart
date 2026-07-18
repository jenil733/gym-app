import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/otp_model.dart';
import 'package:gym/scr/domain/repository/otp_repository.dart';

class OtpRepositoryImpl implements OtpRepository {
  const OtpRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<OtpModel> verifyOtp(OtpParams params) async {
    final response = await _apiService.post(
      ApiRoutes.verifyOtp,
      data: params.toJson(),
      isAuthRequest: true,
    );

    return OtpModel.fromJson(response);
  }

  @override
  Future<OtpModel> resendOtp(ResendOtpParams params) async {
    final response = await _apiService.post(
      ApiRoutes.resendOtp,
      data: params.toJson(),
      isAuthRequest: true,
    );

    return OtpModel.fromJson(response);
  }
}
