import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists session, notification, and step-tracking state', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'legacy_profile': 'remove-me',
    });
    final storage = LocalStorageService();
    await storage.init();

    await storage.saveString('auth_token', 'auth-value');
    await storage.saveString('fcm_token', 'fcm-value');
    await storage.saveString('screen_state', 'runtime-only');
    await storage.saveInt('step_tracking_today', 42);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), <String>{
      'auth_token',
      'fcm_token',
      'step_tracking_today',
    });
    expect(preferences.getString('auth_token'), 'auth-value');
    expect(preferences.getString('fcm_token'), 'fcm-value');
    expect(storage.getString('screen_state'), 'runtime-only');
    expect(storage.getInt('step_tracking_today'), 42);
  });
}
