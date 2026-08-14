import 'package:gym/scr/data/model/fcm_model.dart';

abstract class FcmRepository {
  Future<FcmModel> updateFcmToken({
    required String token,
    String? phoneNumber,
    String? deviceId,
  });
}
