import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/category_model.dart';
import 'package:gym/scr/domain/repository/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<CategoryModel> getCategories() async {
    final response = await _apiService.get(ApiRoutes.category);
    return CategoryModel.fromJson(response);
  }
}
