class ProfileModel {
  const ProfileModel({this.success, this.data, this.message, this.code});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return ProfileModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? ProfileData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final ProfileData? data;
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

class ProfileData {
  const ProfileData({this.user});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];

    return ProfileData(
      user: rawUser is Map
          ? ProfileUser.fromJson(Map<String, dynamic>.from(rawUser))
          : null,
    );
  }

  final ProfileUser? user;

  Map<String, dynamic> toJson() {
    return {if (user != null) 'user': user!.toJson()};
  }
}

class ProfileUser {
  const ProfileUser({
    this.id,
    this.memberId,
    this.name,
    this.email,
    this.phone,
    this.dob,
    this.gender,
    this.bloodGroup,
    this.address,
    this.height,
    this.weight,
    this.bmi,
    this.joiningDate,
    this.trainerName,
    this.fitnessGoal,
    this.profileImage,
    this.isActive,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: int.tryParse(json['id']?.toString() ?? ''),
      memberId: json['member_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      address: json['address']?.toString(),
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      bmi: json['bmi']?.toString(),
      joiningDate: json['joining_date']?.toString(),
      trainerName: json['trainer_name']?.toString(),
      fitnessGoal: json['fitness_goal']?.toString(),
      profileImage: json['profile_image']?.toString(),
      isActive: int.tryParse(json['is_active']?.toString() ?? ''),
    );
  }

  final int? id;
  final String? memberId;
  final String? name;
  final String? email;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? height;
  final String? weight;
  final String? bmi;
  final String? joiningDate;
  final String? trainerName;
  final String? fitnessGoal;
  final String? profileImage;
  final int? isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'blood_group': bloodGroup,
      'address': address,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'joining_date': joiningDate,
      'trainer_name': trainerName,
      'fitness_goal': fitnessGoal,
      'profile_image': profileImage,
      'is_active': isActive,
    };
  }
}
