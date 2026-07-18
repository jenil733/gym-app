import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/data/model/getweight_model.dart';
import 'package:gym/scr/domain/repository/weight_history_repository.dart';
import 'package:gym/scr/domain/usecase/weight_history_usecase.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';

void main() {
  test('maps API weight history into the Home body metric', () async {
    final controller = HomeController(
      null,
      WeightHistoryUseCase(_FakeWeightHistoryRepository()),
    );

    await controller.getWeightHistory();

    final metric = controller.bodyMetrics.first;
    expect(metric.value, '71.8');
    expect(metric.tag, '2 records');
    expect(metric.history, hasLength(2));
    expect(metric.history!.first.label, '16/07/2026');
    expect(metric.history!.first.value, '71.8');
    expect(metric.history!.first.note, 'Morning measurement');
    expect(controller.weightHistoryError.value, isNull);
  });
}

class _FakeWeightHistoryRepository implements WeightHistoryRepository {
  @override
  Future<WeightHistoryModel> getWeightHistory() async {
    return const WeightHistoryModel(
      success: true,
      code: 200,
      data: WeightHistoryData(
        currentWeight: '71.8',
        count: 2,
        history: [
          WeightHistoryItem(
            id: 2,
            weight: '71.8',
            note: 'Morning measurement',
            date: '2026-07-16',
          ),
          WeightHistoryItem(id: 1, weight: '72.5', date: '2026-07-09'),
        ],
      ),
    );
  }
}
