import 'package:gym/scr/data/model/profile_model.dart';
import 'package:gym/scr/domain/repository/profile_repository.dart';

class ProfileUseCase {
  const ProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileModel> call() {
    return _repository.getProfile();
  }
}
