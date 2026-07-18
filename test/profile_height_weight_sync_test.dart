import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/data/model/heightweight_model.dart';
import 'package:gym/scr/domain/repository/height_weight_repository.dart';
import 'package:gym/scr/domain/usecase/height_weight_usecase.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/view/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('saved measurements update Home and show a success message', (
    tester,
  ) async {
    final homeController = Get.put(HomeController());
    final profileController = Get.put(
      ProfileController(
        null,
        null,
        HeightWeightUseCase(_FakeHeightWeightRepository()),
      ),
    );
    await tester.pumpWidget(const GetMaterialApp(home: ProfileScreen()));

    await tester.tap(find.text('Height'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '180');
    await tester.tap(find.text('Save'));
    for (var attempt = 0; attempt < 20; attempt += 1) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Updated successfully').evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.text('Updated successfully'), findsOneWidget);
    expect(profileController.height, '180 cm');
    expect(homeController.bodyMetrics, hasLength(1));
    expect(homeController.bodyMetrics.single.title, 'Weight');

    await tester.pumpAndSettle();
    await tester.tap(find.text('Weight'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '70.5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(homeController.bodyMetrics[0].value, '70.5');
    expect(profileController.height, '180 cm');

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  test('daily streak increments after a consecutive-day visit', () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    SharedPreferences.setMockInitialValues({
      'profile_daily_streak_count': 3,
      'profile_daily_streak_last_visit': yesterdayKey,
    });
    final storage = LocalStorageService();
    await storage.init();

    final controller = Get.put(
      ProfileController(null, null, null, null, storage),
    );
    for (var attempt = 0; attempt < 20; attempt += 1) {
      if (controller.streak == '4 days') {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    expect(controller.streak, '4 days');
  });
}

class _FakeHeightWeightRepository implements HeightWeightRepository {
  @override
  Future<HeightWeightModel> logHeightWeight({
    required double height,
    required double weight,
  }) async {
    return HeightWeightModel(
      success: true,
      code: 201,
      data: HeightWeightData(
        height: height.toString(),
        weight: weight.toString(),
      ),
    );
  }
}
