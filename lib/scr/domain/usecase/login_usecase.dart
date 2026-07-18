import 'package:gym/scr/data/model/login_model.dart';
import 'package:gym/scr/domain/repository/login_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final LoginRepository _repository;

  Future<LoginModel> call(LoginParams params) {
    return _repository.login(params);
  }
}
