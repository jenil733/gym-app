import 'package:gym/scr/data/model/update_profile.dart';
import 'package:gym/scr/domain/repository/update_profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final UpdateProfileRepository _repository;

  Future<UpdateProfileModel> call(UpdateProfileParams params) {
    return _repository.updateProfile(params);
  }
}
