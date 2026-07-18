import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/packages_model.dart';
import 'package:gym/scr/domain/repository/packages_repository.dart';

class PackagesRepositoryImpl implements PackagesRepository {
  const PackagesRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<PackagesModel> getPackages() async {
    final response = await _apiService.get(ApiRoutes.packages);
    return PackagesModel.fromJson(response);
  }
}
