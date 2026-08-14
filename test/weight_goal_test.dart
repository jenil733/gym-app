import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/weight_goal_storage.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('six-month goal is locked and progresses with daily weight', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final goalStorage = WeightGoalStorage(LocalStorageService());
    final controller = ProgressController(null, null, null, goalStorage);
    controller.currentWeight.value = 100;

    expect(await controller.setSixMonthGoal(80), isTrue);
    expect(controller.canChangeGoal, isFalse);
    expect(controller.goalProgress, 0);

    await controller.recordWeight(90);
    expect(controller.goalProgress, closeTo(0.5, 0.001));
    expect(controller.goalRemaining, 10);
    expect(controller.isGoalCompleted, isFalse);

    await controller.recordWeight(80);
    expect(controller.goalProgress, 1);
    expect(controller.isGoalCompleted, isTrue);

    final saved = await goalStorage.load();
    expect(saved?.targetWeight, 80);
    expect(
      saved!.lockedUntil.difference(saved.startedAt).inDays,
      greaterThan(180),
    );
  });
}
