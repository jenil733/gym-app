import 'package:gym/scr/data/model/fcm_model.dart';
import 'package:gym/scr/domain/repository/fcm_repository.dart';

class FcmUseCase {
  const FcmUseCase(this._repository);

  final FcmRepository _repository;

  Future<FcmModel> call({
    required String token,
    String? phoneNumber,
    String? deviceId,
  }) => _repository.updateFcmToken(
    token: token,
    phoneNumber: phoneNumber,
    deviceId: deviceId,
  );
}
