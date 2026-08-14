import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/repository/fcm_repository_impl.dart';

void main() {
  test('associates the FCM token with the account and device', () async {
    final api = _RecordingApiService();
    final repository = FcmRepositoryImpl(api);

    await repository.updateFcmToken(
      token: 'install-specific-token',
      phoneNumber: ' 9876543210 ',
      deviceId: ' device-2 ',
    );

    expect(api.data, <String, dynamic>{
      'fcm_token': 'install-specific-token',
      'phone_number': '9876543210',
      'device_id': 'device-2',
    });
  });
}

class _RecordingApiService extends ApiService {
  Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    bool isAuthRequest = false,
  }) async {
    this.data = Map<String, dynamic>.from(data as Map);
    return <String, dynamic>{'success': true, 'code': 200};
  }
}
