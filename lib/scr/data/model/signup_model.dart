class SignupModel {
  const SignupModel({this.success, this.data, this.message, this.code});

  factory SignupModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return SignupModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? SignupData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final SignupData? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data!.toJson(),
      'message': message,
      'code': code,
    };
  }
}

class SignupData {
  const SignupData({this.memberId, this.otp});

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      memberId: json['member_id']?.toString(),
      otp: int.tryParse(json['otp']?.toString() ?? ''),
    );
  }

  final String? memberId;
  final int? otp;

  Map<String, dynamic> toJson() {
    return {'member_id': memberId, 'otp': otp};
  }
}
