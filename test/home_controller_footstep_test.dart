import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/step_tracking_service.dart';
import 'package:gym/scr/data/model/footstep_history.dart';
import 'package:gym/scr/data/model/postfootstep_model.dart';
import 'package:gym/scr/domain/repository/footstep_repository.dart';
import 'package:gym/scr/domain/usecase/footstep_usecase.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads footstep history and posts the latest step total', () async {
    final repository = _FakeFootstepRepository();
    final controller = HomeController(
      null,
      null,
      null,
      null,
      null,
      FootstepUseCase(repository),
    );

    await controller.getFootstepHistory();

    final stepStat = controller.stats.firstWhere(
      (item) => item.title == 'Steps',
    );
    expect(stepStat.value, '1250');
    expect(stepStat.history.map((item) => item.label), ['Today', 'Yesterday']);

    await controller.postFootstep(1300);

    expect(repository.postedSteps, [1300]);
    expect(controller.footstepError.value, isNull);
  });

  test(
    'dashboard continues from saved steps without using the raw total',
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
      await service.processRawStepCount(8420, now: now);
      final controller = HomeController(
        null,
        null,
        service,
        null,
        null,
        FootstepUseCase(_FakeFootstepRepository()),
      );
      await controller.getFootstepHistory();

      expect(
        controller.stats.firstWhere((item) => item.title == 'Steps').value,
        '1250',
      );

      await service.processRawStepCount(8432, now: now);
      await controller.getFootstepHistory();

      expect(
        controller.stats.firstWhere((item) => item.title == 'Steps').value,
        '1262',
      );
    },
  );
}

class _FakeFootstepRepository implements FootstepRepository {
  final List<int> postedSteps = [];

  @override
  Future<FootstepHistoryModel> getFootstepHistory() async {
    return FootstepHistoryModel(
      success: true,
      code: 200,
      data: FootstepHistoryData(
        todaySteps: 1250,
        history: [
          History(label: 'Today', subLabel: 'Daily footsteps', steps: 1250),
          History(
            label: 'Yesterday',
            subLabel: 'Previous day steps',
            steps: 1100,
          ),
        ],
      ),
    );
  }

  @override
  Future<PostFootstepModel> postFootstep(int steps) async {
    postedSteps.add(steps);
    return PostFootstepModel(success: true, code: 200);
  }
}
