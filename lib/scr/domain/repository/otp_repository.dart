import 'package:gym/scr/data/model/otp_model.dart';

class OtpParams {
  const OtpParams({
    required this.phoneNumber,
    required this.otp,
    required this.type,
  });

  final String phoneNumber;
  final String otp;
  final String type;

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber, 'otp': otp, 'type': type};
  }
}

class ResendOtpParams {
  const ResendOtpParams({required this.phoneNumber, required this.type});

  final String phoneNumber;
  final String type;

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber, 'type': type};
  }
}

abstract class OtpRepository {
  Future<OtpModel> verifyOtp(OtpParams params);
  Future<OtpModel> resendOtp(ResendOtpParams params);
}
