import 'package:gym/scr/data/model/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
}
