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

final List<RecipeModel> exampleRecipes = [
  RecipeModel(
    author: 'Daniil A.',
    title: 'Chicken Kyiv',
    ingredients: ['Chicken breast', 'Oil', 'Cornflakes', 'Seasoning', 'Garlic'],
    description:
        'Popular ukrainian dish, invented in 19 century. Tastes better with mashed potato, grilled vegetables and kvas.',
    images: [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Chicken_Kiev_-_Ukrainian_East_Village_restaurant.jpg/500px-Chicken_Kiev_-_Ukrainian_East_Village_restaurant.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNpOGz80hli0k0a2VcCASIAI1b6Ip77jOpPw&s',
    ],
  ),
  RecipeModel(
    author: 'Alexander F.',
    title: 'Borshch',
    ingredients: [
      'Potato',
      'Beef',
      'Beetroot',
      'Carrot',
      'Cabbage',
      'Tomato sauce',
      'Pepper',
      'Oil',
    ],
    description:
        'Iconic ukrainian nutritious soup, which reflects the whole culture of it\'s Land.',
    images: [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Borscht_served.jpg/500px-Borscht_served.jpg',
      'https://img.delo-vcusa.ru/2024/11/ukrainskij-borshh-s-pomidorami-i-pertsem.jpg',
    ],
  ),
  RecipeModel(
    author: 'Walter U.',
    title: 'Bretzel',
    ingredients: ['Flavour', 'Water', 'Salt', 'Sugar', 'Eggs'],
    description: 'Just a nice tasteful german bakery.',
    images: [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Muenchner_Brezn.jpg/250px-Muenchner_Brezn.jpg',
      'https://brotdoc.com/wp-content/uploads/2018/11/Bre3-1-scaled.jpg',
    ],
  ),
  RecipeModel(
    author: 'Bill J.',
    title: 'Rootbeer',
    ingredients: ['Sarsaparilla', 'Sugar', 'Water'],
    description: 'Beverage without alcohol.',
    images: [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Root_beer_in_glass_mug.jpg/1280px-Root_beer_in_glass_mug.jpg',
      'https://m.media-amazon.com/images/I/91S78g+YgBL._AC_UF894,1000_QL80_.jpg',
    ],
  ),
  RecipeModel(
    author: 'Carolina S.',
    title: 'Pasta carbonara',
    ingredients: [
      'Flavour',
      'Water',
      'Salt',
      'Sugar',
      'Eggs',
      'Butter',
      'Parmesan',
    ],
    description:
        '''Carbonara is a pasta dish made with fatty cured pork, hard cheese, eggs, salt, and black pepper. It is typical of the Lazio region of Italy. The dish took its modern form and name in the middle of the 20th century.
        The cheese used is usually pecorino romano. Some variations use Parmesan, Grana Padano, or a combination of cheeses. Spaghetti is the most common pasta, but bucatini or rigatoni are also used. While guanciale, a cured pork jowl, is traditional, some variations use pancetta, and lardons of smoked bacon are a common substitute outside Italy. 
        Add bacon and water to a skillet and bring to a simmer.
Continue simmering until the water is evaporated, then continue to cook the bacon until crispy.
Remove bacon from the pan and reserve the drippings.
Saute garlic in that same skillet until golden brown, then add to a bowl with 1 tablespoon bacon fat, eggs, egg yolk, Parmesan, and pepper. Mix well.
Meanwhile, cook the spaghetti or linguine pasta until al dente. Once cooked, drain the pasta and reserve 1 cup of the cooking water.
Slowly pour the hot cooking water into the egg mixture. Then pour over the hot pasta and toss to coat. Add crumbled bacon.
Let pasta rest for a few minutes, tossing frequently until the carbonara sauce thickens. Serve immediately with a sprinkle of fresh parsley.''',
    images: [
      'https://assets.tmecosys.com/image/upload/t_web_rdp_recipe_584x480/img/recipe/ras/Assets/0346a29a89ef229b1a0ff9697184f944/Derivates/cb5051204f4a4525c8b013c16418ae2904e737b7.jpg',
      'https://cdn.gutekueche.de/media/recipe/33636/pasta-carbonara.jpg',
    ],
  ),
  RecipeModel(
    author: 'Xian X.',
    title: 'Peking duck',
    ingredients: ['Duck', 'Soy sauce', 'Seasoning', 'Chili'],
    description: 'Delicious chinese meat dish.',
    images: [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSP4VRtvFKzGVBX_lmz_wDSo8AvU0HEMLdXaw&s',
      'https://www.thespruceeats.com/thmb/ggHafkpSpJqI3zs6o92DusfEeC4=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-145059660-59b1a84edafc47269db2062015b80c05.jpg',
    ],
  ),
  RecipeModel(
    author: 'Uwuwewe Ubwemubwem Osas',
    title: 'Jolof',
    ingredients: ['Rice', 'Tomatoes', 'Onions', 'Chili'],
    description: 'Basic african dinner.',
    images: [
      'https://upload.wikimedia.org/wikipedia/commons/0/0a/Jollof_Rice_with_Stew.jpg',
      'https://i.ytimg.com/vi/cUDa8-AP59M/maxresdefault.jpg',
    ],
  ),
  RecipeModel(
    author: 'Julio P.',
    title: 'Guacamole',
    ingredients: ['Avocado', 'Salt', 'Pepper', 'Tomatoes'],
    description: 'Nutritious vegetarian paste.',
    images: [
      'https://www.giallozafferano.com/images/255-25549/Guacamole_1200x800.jpg',
      'https://assets.tmecosys.com/image/upload/t_web_rdp_recipe_584x480_1_5x/img/recipe/ras/Assets/7DD941F0-7E17-4DBB-A778-90328C0AC000/Derivates/254D6349-1A37-47B1-A490-BC4B5013AECA.jpg',
    ],
  ),
];
