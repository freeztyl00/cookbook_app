import 'package:cookbook_app/data/api/meals_api_client.dart';
import 'package:cookbook_app/data/models/api_category_model/category_model.dart';
import 'package:cookbook_app/data/models/category_model.dart';

class CategoriesRepository {
  final MealsApiClient _apiClient;
  CategoriesRepository(this._apiClient);

  Future<List<CategoryModel>> getAllCategories() async {
    final data = await _apiClient.get<CategoriesModel>(
      "/categories.php",
      fromJson: (json) => CategoriesModel.fromJson(json),
    );
    return data.categories!.map((e) {
      return CategoryModel(id: e.idCategory, name: e.strCategory ?? "Unknown");
    }).toList();
  }
}
