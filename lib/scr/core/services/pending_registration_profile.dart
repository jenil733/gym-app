import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/domain/repository/update_profile_repository.dart';
import 'package:gym/scr/domain/usecase/update_profile_usecase.dart';

class PendingRegistrationProfile {
  const PendingRegistrationProfile(this._storage);

  static const String _phoneKey = 'pending_registration_profile_phone';
  static const String _addressKey = 'pending_registration_profile_address';
  static const String _fitnessGoalKey =
      'pending_registration_profile_fitness_goal';

  final LocalStorageService _storage;

  Future<void> save({
    required String phone,
    required String address,
    required String fitnessGoal,
  }) async {
    await _storage.saveString(_phoneKey, phone);
    await _storage.saveString(_addressKey, address);
    await _storage.saveString(_fitnessGoalKey, fitnessGoal);
  }

  Future<bool> sync({
    required String phone,
    required UpdateProfileUseCase updateProfile,
    String? temporaryAuthToken,
  }) async {
    await _storage.init();
    if (_storage.getString(_phoneKey)?.trim() != phone.trim()) {
      return false;
    }

    final address = _storage.getString(_addressKey)?.trim();
    final fitnessGoal = _storage.getString(_fitnessGoalKey)?.trim();
    if ((fitnessGoal == null || fitnessGoal.isEmpty) &&
        (address == null || address.isEmpty)) {
      await clear();
      return false;
    }

    final previousToken = _storage.getString('auth_token');
    final temporaryToken = temporaryAuthToken?.trim();
    if (temporaryToken != null && temporaryToken.isNotEmpty) {
      await _storage.saveString('auth_token', temporaryToken);
    }

    try {
      final response = await updateProfile(
        UpdateProfileParams(address: address, fitnessGoal: fitnessGoal),
      );
      final successful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      if (successful) {
        await clear();
      }
      return successful;
    } catch (_) {
      return false;
    } finally {
      if (temporaryToken != null && temporaryToken.isNotEmpty) {
        if (previousToken == null || previousToken.isEmpty) {
          await _storage.remove('auth_token');
        } else {
          await _storage.saveString('auth_token', previousToken);
        }
      }
    }
  }

  Future<void> clear() async {
    await _storage.remove(_phoneKey);
    await _storage.remove(_addressKey);
    await _storage.remove(_fitnessGoalKey);
  }
}
