import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/weight_graph_storage.dart';
import 'package:gym/scr/data/model/getweight_model.dart';
import 'package:gym/scr/domain/repository/weight_history_repository.dart';
import 'package:gym/scr/domain/usecase/weight_history_usecase.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads API weights, caches them, and changes graph ranges', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final storage = WeightGraphStorage(LocalStorageService());
    final controller = ProgressController(
      null,
      WeightHistoryUseCase(_FakeWeightHistoryRepository()),
      storage,
    );

    await controller.loadWeightProgress();

    expect(controller.currentWeight.value, 70.5);
    expect(controller.history, hasLength(4));
    expect(controller.graphPoints, isNotEmpty);
    expect(await storage.load(), hasLength(4));

    controller.selectGraphRange(WeightGraphRange.weeks);
    expect(controller.graphPoints, isNotEmpty);
    controller.selectGraphRange(WeightGraphRange.months);
    expect(controller.graphPoints, isNotEmpty);
    controller.selectGraphRange(WeightGraphRange.annually);
    expect(controller.graphPoints, hasLength(1));

    await controller.recordWeight(70.2, date: DateTime.now());
    expect(controller.currentWeight.value, 70.2);
    expect((await storage.load()).last.weight, 70.2);
  });
}

class _FakeWeightHistoryRepository implements WeightHistoryRepository {
  @override
  Future<WeightHistoryModel> getWeightHistory() async {
    final now = DateTime.now();
    WeightHistoryItem item(int daysAgo, double weight) {
      return WeightHistoryItem(
        id: daysAgo + 1,
        weight: weight.toString(),
        date: now.subtract(Duration(days: daysAgo)).toIso8601String(),
      );
    }

    return WeightHistoryModel(
      success: true,
      code: 200,
      data: WeightHistoryData(
        currentWeight: '70.5',
        count: 4,
        history: [item(0, 70.5), item(2, 70.8), item(10, 71.2), item(40, 72.0)],
      ),
    );
  }
}
