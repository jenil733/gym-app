import 'package:gym/scr/data/model/category_model.dart';
import 'package:gym/scr/domain/repository/category_repository.dart';

class CategoryUseCase {
  const CategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<CategoryModel> call() {
    return _repository.getCategories();
  }
}
