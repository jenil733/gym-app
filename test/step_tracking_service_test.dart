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
    final service = StepTrackingService(
      storage,
      stream.stream,
      () async => true,
    );
    await service.start();

    final today = DateTime(2026, 7, 16, 12);
    await service.processRawStepCount(100, now: today);
    await service.processRawStepCount(125, now: today);
    await service.processRawStepCount(5, now: today);

    expect(service.todaySteps.value, 130);
    expect(storage.getInt('step_tracking_today'), 130);

    final tomorrow = today.add(const Duration(days: 1));
    await service.processRawStepCount(10, now: tomorrow);
    await service.processRawStepCount(18, now: tomorrow);

    expect(service.yesterdaySteps.value, 130);
    expect(service.todaySteps.value, 8);
    expect(storage.getInt('step_tracking_today'), 8);
  });
}
