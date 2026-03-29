import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:cookbook_app/ui/screens/create_custom_recipe_screen.dart';
import 'package:cookbook_app/ui/screens/favourite_recipes_screen.dart';
import 'package:cookbook_app/ui/screens/recipes_screen.dart';
import 'package:cookbook_app/ui/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CookBookProvider extends ChangeNotifier {
  int currentPageIndex = 0;
  late final List<Widget> pages;
  final List<String> pageLabels = [
    UserScreen.pageLabel,
    RecipesScreen.pageLabel,
    FavouriteRecipesScreen.pageLabel,
  ];

  CookBookProvider() {
    pages = [
      const UserScreen(),
      RecipesScreen(),
      const FavouriteRecipesScreen(),
    ];
  }

  final PageController _pageController = PageController();

  PageController get pageController => _pageController;

  //for buttons
  void changePage(int index) {
    if (index != currentPageIndex) {
      currentPageIndex = index;
      notifyListeners();
      _pageController.jumpToPage(currentPageIndex);
    }
  }

  //for swipes
  void onPageChanged(int index) {
    if (index != currentPageIndex) {
      currentPageIndex = index;
      notifyListeners();
    }
  }

  void disposePageController() {
    _pageController.dispose();
  }

  void createRecipe(BuildContext context) async {
    final recipesProvider = Provider.of<RecipesProvider>(
      context,
      listen: false,
    );
    RecipeModel? recipe = await _openCreateCustomRecipeBottomSheet(context);
    if (recipe != null) {
      await recipesProvider.insertRecipe(recipe);
      notifyListeners();
    }
  }

  Future<RecipeModel?> _openCreateCustomRecipeBottomSheet(
    BuildContext context,
  ) async {
    final result = await showModalBottomSheet<RecipeModel>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (_) => CreateCustomRecipe(),
    );
    return result;
  }
}
