import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:cookbook_app/ui/screens/favourite_recipes_screen.dart';
import 'package:cookbook_app/ui/screens/recipes_screen.dart';
import 'package:cookbook_app/ui/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CookBookProvider extends ChangeNotifier {
  static const List<String> pageLabels = [
    UserScreen.pageLabel,
    RecipesScreen.pageLabel,
    FavouriteRecipesScreen.pageLabel,
  ];

  List<Widget> get pages => const [
    UserScreen(),
    RecipesScreen(),
    FavouriteRecipesScreen(),
  ];

  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void setPage(int index, {bool fromSlider = false}) {
    if (_currentPageIndex == index) return;

    _currentPageIndex = index;
    notifyListeners();

    if (!fromSlider && _pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  Future<void> saveCreatedRecipe(
    BuildContext context,
    RecipeModel recipe,
  ) async {
    await context.read<RecipesProvider>().insertRecipe(recipe);
  }
}
