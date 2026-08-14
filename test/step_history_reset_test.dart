import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/step_tracking_service.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/view/home/stat_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('refresh button resets today steps in history', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final stream = StreamController<int>();
    addTearDown(stream.close);
    final storage = LocalStorageService();
    await storage.clear();
    final service = StepTrackingService(
      storage,
      stream.stream,
      () async => true,
    );
    addTearDown(service.onClose);
    await service.start();
    await service.processRawStepCount(1000, now: DateTime.now());
    await service.processRawStepCount(1120, now: DateTime.now());

    final controller = Get.put(HomeController(null, null, service));
    final stepStat = controller.stats.firstWhere(
      (item) => item.title == 'Steps',
    );

    await tester.pumpWidget(
      GetMaterialApp(home: StatHistoryScreen(stat: stepStat)),
    );
    await tester.pump();

    expect(find.text('120 steps'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('reset-steps-button')));
    await tester.pumpAndSettle();

    expect(service.todaySteps.value, 0);
    expect(find.text('0 steps'), findsWidgets);
    await tester.pump(const Duration(seconds: 3));
    service.onClose();
  });
}
