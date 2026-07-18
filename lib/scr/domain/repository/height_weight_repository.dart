import 'package:gym/scr/data/model/heightweight_model.dart';

abstract class HeightWeightRepository {
  Future<HeightWeightModel> logHeightWeight({
    required double height,
    required double weight,
  });
}
