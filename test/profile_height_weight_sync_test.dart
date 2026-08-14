import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gym/scr/data/model/get_attendance_model.dart';
import 'package:gym/scr/data/model/heightweight_model.dart';
import 'package:gym/scr/domain/repository/height_weight_repository.dart';
import 'package:gym/scr/domain/usecase/height_weight_usecase.dart';
import 'package:gym/scr/presentation/controller/attendance_controller.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/view/profile/profile.dart';

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

  test('profile streak uses consecutive attendance days', () {
    final now = DateTime.now();
    String key(DateTime date) =>
        '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final attendanceController = Get.put(AttendanceController());
    attendanceController.attendance.value = AttendanceData(
      todayMarked: true,
      history: [
        AttendanceHistory(date: key(now), status: 'Present'),
        AttendanceHistory(
          date: key(now.subtract(const Duration(days: 1))),
          status: 'Present',
        ),
        AttendanceHistory(
          date: key(now.subtract(const Duration(days: 2))),
          status: 'Present',
        ),
      ],
    );
    final controller = Get.put(ProfileController());

    expect(controller.streak, '3 days');
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
