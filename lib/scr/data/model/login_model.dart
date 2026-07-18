class LoginModel {
  const LoginModel({this.success, this.data, this.message, this.code});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return LoginModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? LoginData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final LoginData? data;
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

class LoginData {
  const LoginData({this.otp});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(otp: int.tryParse(json['otp']?.toString() ?? ''));
  }

  final int? otp;

  Map<String, dynamic> toJson() {
    return {'otp': otp};
  }
}
