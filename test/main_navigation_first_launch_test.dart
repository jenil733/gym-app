import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/presentation/controller/main_navigation_controller.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('first home launch asks for profile setup instead of weight', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final storage = LocalStorageService();
    await storage.clear();
    Get.put<LocalStorageService>(storage);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) {
            final controller = Get.put(MainNavigationController());
            return Scaffold(
              body: Obx(
                () => Text(
                  'selected-${controller.selectedIndex.value}',
                  textDirection: TextDirection.ltr,
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set up your profile'), findsOneWidget);
    expect(find.byKey(const ValueKey('set-up-profile-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('morning-weight-input')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('set-up-profile-button')));
    await tester.pumpAndSettle();

    expect(find.text('selected-3'), findsOneWidget);
    expect(find.text('Set up your profile'), findsNothing);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('initial_profile_setup_prompt_shown'), isTrue);
  });

  testWidgets('returning home launch does not show a daily weight popup', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'initial_profile_setup_prompt_shown': true,
    });
    final storage = LocalStorageService();
    Get.put<LocalStorageService>(storage);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) {
            Get.put(MainNavigationController());
            return const Scaffold(body: Text('Home'));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  });
}
