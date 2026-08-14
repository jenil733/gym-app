class FcmModel {
  const FcmModel({this.success, this.data, this.message, this.code});

  factory FcmModel.fromJson(Map<String, dynamic> json) => FcmModel(
    success: json['success'] as bool?,
    data: json['data'] is Map
        ? FcmData.fromJson(Map<String, dynamic>.from(json['data'] as Map))
        : null,
    message: json['message']?.toString(),
    code: int.tryParse(json['code']?.toString() ?? ''),
  );

  final bool? success;
  final FcmData? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() => {
    'success': success,
    if (data != null) 'data': data!.toJson(),
    'message': message,
    'code': code,
  };
}

class FcmData {
  const FcmData({this.fcmToken});

  factory FcmData.fromJson(Map<String, dynamic> json) =>
      FcmData(fcmToken: json['fcm_token']?.toString());

  final String? fcmToken;

  Map<String, dynamic> toJson() => {'fcm_token': fcmToken};
}
