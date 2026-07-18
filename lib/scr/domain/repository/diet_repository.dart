import 'package:gym/scr/data/model/diet_model.dart';

abstract class DietRepository {
  Future<DietModel> getDietPlans();
}
