import 'package:gym/scr/data/model/otp_model.dart';
import 'package:gym/scr/domain/repository/otp_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final OtpRepository _repository;

  Future<OtpModel> call(OtpParams params) {
    return _repository.verifyOtp(params);
  }

  Future<OtpModel> resend(ResendOtpParams params) {
    return _repository.resendOtp(params);
  }
}
