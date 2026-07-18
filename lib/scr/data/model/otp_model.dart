class OtpModel {
  const OtpModel({this.success, this.data, this.message, this.code});

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final parsedData = rawData is Map
        ? OtpData.fromJson(Map<String, dynamic>.from(rawData))
        : (json['token'] != null ||
              json['access_token'] != null ||
              json['otp'] != null)
        ? OtpData.fromJson(json)
        : null;

    return OtpModel(
      success: json['success'] as bool?,
      data: parsedData,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final OtpData? data;
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

class OtpData {
  const OtpData({this.type, this.token, this.otp, this.user});

  factory OtpData.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];

    return OtpData(
      type: json['type']?.toString(),
      token: (json['token'] ?? json['access_token'])?.toString(),
      otp: json['otp']?.toString(),
      user: rawUser is Map
          ? OtpUser.fromJson(Map<String, dynamic>.from(rawUser))
          : null,
    );
  }

  final String? type;
  final String? token;
  final String? otp;
  final OtpUser? user;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'token': token,
      'otp': otp,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class OtpUser {
  const OtpUser({
    this.id,
    this.memberId,
    this.name,
    this.phone,
    this.gender,
    this.dob,
    this.profileImage,
    this.isActive,
  });

  factory OtpUser.fromJson(Map<String, dynamic> json) {
    return OtpUser(
      id: int.tryParse(json['id']?.toString() ?? ''),
      memberId: json['member_id']?.toString(),
      name: json['name']?.toString(),
      phone: (json['phone'] ?? json['phone_number'])?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      profileImage: json['profile_image']?.toString(),
      isActive: int.tryParse(json['is_active']?.toString() ?? ''),
    );
  }

  final int? id;
  final String? memberId;
  final String? name;
  final String? phone;
  final String? gender;
  final String? dob;
  final String? profileImage;
  final int? isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'name': name,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'profile_image': profileImage,
      'is_active': isActive,
    };
  }
}
