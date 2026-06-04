import 'package:cookbook_app/data/api/meals_api_client.dart';
import 'package:cookbook_app/data/models/api_meal_model/meals_model.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:flutter/widgets.dart';

class RecipesRepository {
  final MealsApiClient _apiClient;
  Map<String, String> _categoryNameToIdMap = {};
  RecipesRepository(this._apiClient);

  void updateCategoryMapping(Map<String, String> newMap) =>
      _categoryNameToIdMap = newMap;

  List<String> parseIngredients(Map<String, dynamic> map) {
    final result = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = map['strIngredient$i'];
      final measure = map['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        result.add('${ingredient.trim()}: ${measure?.trim() ?? ''}');
      }
    }
    return result;
  }

  Future<RecipeModel> getRandomMeal() async {
    final data = await _apiClient.get<MealsModel>(
      '/random.php',
      fromJson: (json) => MealsModel.fromJson(json),
    );
    final meal = data.meals!.first;
    final map = meal.toJson();
    final String? categoryName = meal.strCategory;
    final String? mappedId = _categoryNameToIdMap[categoryName];

    return RecipeModel(
      id: meal.idMeal,
      author: meal.strArea ?? 'Unknown',
      title: meal.strMeal ?? 'Unknown',
      ingredients: parseIngredients(map),
      description: meal.strInstructions!,
      images: [meal.strMealThumb.toString()],
      categoryId: mappedId,
      categoryName: categoryName,
    );
  }

  Future<List<RecipeModel>> get20RandomMeals() async {
    return await Future.wait(List.generate(20, (_) => getRandomMeal()));
  }

  Stream<List<RecipeModel>> getAllMealsStream() async* {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    for (final letter in letters.split('')) {
      try {
        final data = await _apiClient.get<MealsModel>(
          '/search.php?f=$letter',
          fromJson: (json) => MealsModel.fromJson(json),
        );
        if (data.meals != null && data.meals!.isNotEmpty) {
          final recipes = data.meals!.map((e) {
            final String? categoryName = e.strCategory;
            final String? mappedId = _categoryNameToIdMap[categoryName];
            return RecipeModel(
              id: e.idMeal,
              author: e.strArea ?? 'Unknown',
              title: e.strMeal ?? 'Unknown',
              ingredients: parseIngredients(e.toJson()),
              description: e.strInstructions!,
              images: [e.strMealThumb.toString()],
              categoryId: mappedId,
              categoryName: categoryName,
            );
          }).toList();
          yield recipes;
        }
      } catch (e) {
        debugPrint('Error on a letter: $letter');
        continue;
      }
    }
  }
}
