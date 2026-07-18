import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/data/model/heightweight_model.dart';
import 'package:gym/scr/domain/repository/height_weight_repository.dart';
import 'package:gym/scr/domain/usecase/height_weight_usecase.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';

void main() {
  test('posts height and weight through the use case', () async {
    final repository = _FakeHeightWeightRepository();
    final controller = ProgressController(HeightWeightUseCase(repository));

    final saved = await controller.postHeightWeight(height: 176, weight: 72.5);

    expect(saved, isTrue);
    expect(repository.receivedHeight, 176);
    expect(repository.receivedWeight, 72.5);
    expect(controller.latestHeightWeight.value?.bmi, 23.4);
    expect(controller.heightWeightError.value, isNull);
  });

  test('does not post invalid height or weight', () async {
    final repository = _FakeHeightWeightRepository();
    final controller = ProgressController(HeightWeightUseCase(repository));

    final saved = await controller.postHeightWeight(height: 0, weight: 72.5);

    expect(saved, isFalse);
    expect(repository.receivedHeight, isNull);
    expect(controller.heightWeightError.value, isNotNull);
  });
}

class _FakeHeightWeightRepository implements HeightWeightRepository {
  double? receivedHeight;
  double? receivedWeight;

  @override
  Future<HeightWeightModel> logHeightWeight({
    required double height,
    required double weight,
  }) async {
    receivedHeight = height;
    receivedWeight = weight;
    return const HeightWeightModel(
      success: true,
      code: 201,
      data: HeightWeightData(
        id: 1,
        height: '176',
        weight: '72.5',
        bmi: 23.4,
        date: '2026-07-16',
      ),
    );
  }
}
