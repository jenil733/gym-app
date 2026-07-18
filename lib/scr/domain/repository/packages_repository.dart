import 'package:gym/scr/data/model/packages_model.dart';

abstract class PackagesRepository {
  Future<PackagesModel> getPackages();
}
