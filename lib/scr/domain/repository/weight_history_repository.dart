import 'package:gym/scr/data/model/getweight_model.dart';

abstract class WeightHistoryRepository {
  Future<WeightHistoryModel> getWeightHistory();
}
