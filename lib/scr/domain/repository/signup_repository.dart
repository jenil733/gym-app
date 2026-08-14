import 'package:gym/scr/data/model/signup_model.dart';

class SignupParams {
  const SignupParams({
    required this.name,
    required this.phone,
    required this.gender,
    required this.address,
    required this.dob,
    required this.fitnessGoal,
  });

  final String name;
  final String phone;
  final String gender;
  final String address;
  final String dob;
  final String fitnessGoal;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phone,
      'gender': gender,
      'address': address,
      'dob': dob,
      'fitness_goal': fitnessGoal,
    };
  }
}

abstract class SignupRepository {
  Future<SignupModel> signup(SignupParams params);
}
