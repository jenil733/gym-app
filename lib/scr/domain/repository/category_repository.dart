import 'package:gym/scr/data/model/category_model.dart';

abstract class CategoryRepository {
  Future<CategoryModel> getCategories();
}
