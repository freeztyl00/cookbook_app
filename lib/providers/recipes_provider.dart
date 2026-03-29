import 'dart:async';

import 'package:cookbook_app/data/db/db_helper.dart';
import 'package:cookbook_app/data/models/category_model.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/data/repository/categories_repository.dart';
import 'package:cookbook_app/data/repository/recipes_repository.dart';
import 'package:flutter/material.dart';

class RecipesProvider extends ChangeNotifier {
  final RecipesRepository _recipesRepo;
  final CategoriesRepository _categoriesRepo;
  final DbHelper _db = DbHelper.instance;
  StreamSubscription? _apiSubscription;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  List<RecipeModel> _loadedRecipes = [];
  List<RecipeModel> _loadedFavourites = [];
  List<CategoryModel> _allCategories = [];
  String _selectedCategoryId = 'all';

  RecipesProvider(this._recipesRepo, this._categoriesRepo);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RecipeModel> get loadedRecipes => _loadedRecipes;
  List<RecipeModel> get loadedFavourites => _loadedFavourites;
  List<CategoryModel> get allCategories => _allCategories;
  String get selectedCategoryId => _selectedCategoryId;

  @override
  void dispose() {
    _apiSubscription?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      await fetchCategories();
      final existing = await getAllRecipes();
      if (existing.isEmpty) {
        _startBackgroundLoading();
      } else {
        await onRefresh();
        _isInitialized = true;
      }
    } catch (e) {
      _error = 'Failed to initialize recipes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      _allCategories = await _db.getAllCategories();
      if (_allCategories.isEmpty) {
        final apiCategories = await _categoriesRepo.getAllCategories();
        await _db.insertMultipleCategories(apiCategories);
        _allCategories = await _db.getAllCategories();
      }

      final mapping = {for (var c in _allCategories) c.name: c.id};
      _recipesRepo.updateCategoryMapping(mapping);
    } catch (e) {
      _error = 'Failed to fetch categories: ${e.toString()}';
      rethrow;
    }
  }

  void _startBackgroundLoading() {
    _apiSubscription?.cancel();
    _apiSubscription = _recipesRepo.getAllMealsStream().listen(
      (newBatch) async {
        await _db.insertMultipleRecipes(newBatch);
        await _loadDataFromDb();
      },
      onError: (e) => debugPrint('Background loading error: $e'),
      onDone: () => debugPrint('All letters loaded!'),
    );
  }

  Future<void> _loadDataFromDb() async {
    _loadedRecipes = await _db.getAllRecipes();
    _loadedFavourites = await _db.getAllFavourites();
    notifyListeners();
  }

  Future<void> onRefresh() async {
    try {
      await _loadDataFromDb();
    } catch (e) {
      _error = 'Refresh failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> onForceRefresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(Duration(seconds: 2));
      await getAllRecipesByCategoryId(_selectedCategoryId);
    } catch (e) {
      _error = 'Failed to refresh recipes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> insertRecipe(RecipeModel recipe) async {
    await _db.insertRecipe(recipe);
    _loadedRecipes.add(recipe);
    notifyListeners();
  }

  void toggleFavourite(RecipeModel recipe) async {
    final updatedRecipe = recipe.copyWith(isFavourite: !recipe.isFavourite);
    await _db.updateFavourite(updatedRecipe);
    final index = _loadedRecipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _loadedRecipes[index] = updatedRecipe;
      _loadedFavourites = await getAllFavourites();
      notifyListeners();
    }
  }

  void selectCategory(String categoryId) async {
    if (_selectedCategoryId == categoryId) return;

    _selectedCategoryId = categoryId;
    _isLoading = true;
    notifyListeners();

    try {
      if (categoryId == 'all') {
        _loadedRecipes = await getAllRecipes();
      } else {
        _loadedRecipes = await getAllRecipesByCategoryId(categoryId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<RecipeModel>> getAllRecipes() async {
    return await _db.getAllRecipes();
  }

  Future<List<RecipeModel>> getAllRecipesByCategoryId(String category) async {
    return await _db.getAllRecipesByCategoryId(category);
  }

  Future<List<RecipeModel>> getAllFavourites() async {
    return await _db.getAllFavourites();
  }
}
