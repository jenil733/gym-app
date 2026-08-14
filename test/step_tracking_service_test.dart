import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/step_tracking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores sensor deltas locally and resets at a new day', () async {
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
    await service.start();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 12);
    await service.processRawStepCount(100, now: today);
    await service.processRawStepCount(125, now: today);
    await service.processRawStepCount(5, now: today);

    expect(service.todaySteps.value, 30);
    expect(storage.getInt('step_tracking_today'), 30);

    final tomorrow = today.add(const Duration(days: 1));
    await service.processRawStepCount(10, now: tomorrow);
    await service.processRawStepCount(18, now: tomorrow);

    expect(service.yesterdaySteps.value, 30);
    expect(service.todaySteps.value, 8);
    expect(storage.getInt('step_tracking_today'), 8);
  });

  test('uses the first raw sensor value as a baseline', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final storage = LocalStorageService();
    await storage.clear();
    final service = StepTrackingService(
      storage,
      const Stream<int>.empty(),
      () async => true,
    );
    await service.start();

    final now = DateTime.now();
    await service.processRawStepCount(8420, now: now);
    expect(service.todaySteps.value, 0);

    await service.processRawStepCount(8432, now: now);
    expect(service.todaySteps.value, 12);
  });

  test('continues counting from a larger saved dashboard total', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final storage = LocalStorageService();
    await storage.clear();
    final service = StepTrackingService(
      storage,
      const Stream<int>.empty(),
      () async => true,
    );
    await service.start();

    final now = DateTime.now();
    await service.processRawStepCount(8420, now: now);
    await service.reconcileTodaySteps(1250, now: now);
    await service.processRawStepCount(8432, now: now);

    expect(service.todaySteps.value, 1262);
    expect(storage.getInt('step_tracking_today'), 1262);
  });

  test('reset persists zero and counts only new sensor steps', () async {
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
    await service.start();

    final now = DateTime.now();
    await service.processRawStepCount(100, now: now);
    await service.processRawStepCount(120, now: now);
    await service.resetTodaySteps(now: now);

    expect(service.todaySteps.value, 0);
    expect(storage.getInt('step_tracking_today'), 0);

    await service.processRawStepCount(125, now: now);
    expect(service.todaySteps.value, 5);
    expect(storage.getInt('step_tracking_today'), 5);
  });

  test(
    'rolls the displayed total at midnight without a sensor event',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final storage = LocalStorageService();
      await storage.clear();
      final service = StepTrackingService(
        storage,
        const Stream<int>.empty(),
        () async => true,
      );
      await service.start();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 23, 59);
      await service.processRawStepCount(100, now: today);
      await service.processRawStepCount(175, now: today);

      final tomorrow = today.add(const Duration(minutes: 2));
      await service.ensureCurrentDay(now: tomorrow);

      expect(service.todaySteps.value, 0);
      expect(service.yesterdaySteps.value, 75);
      expect(service.trackingDate.value, isNotEmpty);
      expect(storage.getInt('step_tracking_today'), 0);
    },
  );
}
