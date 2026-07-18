import 'dart:typed_data';

import 'package:gym/scr/data/model/update_profile.dart';

class UpdateProfileParams {
  const UpdateProfileParams({
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
    this.fitnessGoal,
    this.profileImageBytes,
    this.profileImageName,
  });

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
  final String? fitnessGoal;
  final Uint8List? profileImageBytes;
  final String? profileImageName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
      'fitness_goal': fitnessGoal,
    }..removeWhere((_, value) => value == null);
  }
}

abstract class UpdateProfileRepository {
  Future<UpdateProfileModel> updateProfile(UpdateProfileParams params);
}
