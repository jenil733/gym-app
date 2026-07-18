import 'package:gym/scr/data/model/login_model.dart';

class LoginParams {
  const LoginParams({required this.phoneNumber});

  final String phoneNumber;

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber};
  }
}

abstract class LoginRepository {
  Future<LoginModel> login(LoginParams params);
}
