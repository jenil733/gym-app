import 'package:gym/scr/data/model/signup_model.dart';

class SignupParams {
  const SignupParams({
    required this.name,
    required this.phone,
    required this.gender,
    required this.place,
    required this.dob,
  });

  final String name;
  final String phone;
  final String gender;
  final String place;
  final String dob;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phone,
      'gender': gender,
      'place': place,
      'dob': dob,
    };
  }
}

abstract class SignupRepository {
  Future<SignupModel> signup(SignupParams params);
}
