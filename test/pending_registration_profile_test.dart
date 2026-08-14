import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/pending_registration_profile.dart';
import 'package:gym/scr/data/model/update_profile.dart';
import 'package:gym/scr/domain/repository/update_profile_repository.dart';
import 'package:gym/scr/domain/usecase/update_profile_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'syncs registration fitness goal through authenticated profile API',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final storage = LocalStorageService();
      await storage.init();
      final pendingProfile = PendingRegistrationProfile(storage);
      final repository = _FakeUpdateProfileRepository();

      await pendingProfile.save(
        phone: '9876543210',
        address: 'Chennai',
        fitnessGoal: 'Weight Loss',
      );
      final synced = await pendingProfile.sync(
        phone: '9876543210',
        updateProfile: UpdateProfileUseCase(repository),
        temporaryAuthToken: 'registration-token',
      );

      expect(synced, isTrue);
      expect(repository.params?.address, 'Chennai');
      expect(repository.params?.fitnessGoal, 'Weight Loss');
      expect(storage.getString('auth_token'), isNull);

      final alreadyCleared = await pendingProfile.sync(
        phone: '9876543210',
        updateProfile: UpdateProfileUseCase(repository),
      );
      expect(alreadyCleared, isFalse);
    },
  );
}

class _FakeUpdateProfileRepository implements UpdateProfileRepository {
  UpdateProfileParams? params;

  @override
  Future<UpdateProfileModel> updateProfile(UpdateProfileParams params) async {
    this.params = params;
    return const UpdateProfileModel(success: true, code: 200);
  }
}
