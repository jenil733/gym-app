import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/presentation/view/splash_screen/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('saved auth token skips login flow and opens main', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'saved-token'});
    final storage = LocalStorageService();
    await storage.init();
    Get.put<LocalStorageService>(storage);

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(
            name: '/main',
            page: () => const Scaffold(body: Text('Authenticated main screen')),
          ),
        ],
        home: const SplashScreen(splashDuration: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Authenticated main screen'), findsOneWidget);
  });
}
