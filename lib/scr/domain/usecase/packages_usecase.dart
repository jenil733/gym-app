import 'package:gym/scr/data/model/packages_model.dart';
import 'package:gym/scr/domain/repository/packages_repository.dart';

class PackagesUseCase {
  const PackagesUseCase(this._repository);

  final PackagesRepository _repository;

  Future<PackagesModel> call() {
    return _repository.getPackages();
  }
}
