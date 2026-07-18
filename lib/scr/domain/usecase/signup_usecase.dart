import 'package:gym/scr/data/model/signup_model.dart';
import 'package:gym/scr/domain/repository/signup_repository.dart';

class SignupUseCase {
  const SignupUseCase(this._repository);

  final SignupRepository _repository;

  Future<SignupModel> call(SignupParams params) {
    return _repository.signup(params);
  }
}
