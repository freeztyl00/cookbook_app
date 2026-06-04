import 'dart:async';

import 'package:cookbook_app/data/db/db_helper.dart';
import 'package:cookbook_app/data/models/category_model.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/data/repository/categories_repository.dart';
import 'package:cookbook_app/data/repository/recipes_repository.dart';
import 'package:flutter/material.dart';

enum AlphabeticalOder { asc, desc }

enum CustomPriority { none, first, last }

class RecipesProvider extends ChangeNotifier {
  final RecipesRepository _recipesRepo;
  final CategoriesRepository _categoriesRepo;
  final DbHelper _db = DbHelper.instance;
  StreamSubscription? _apiSubscription;

  //State
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isFullLoading = false;
  String? _error;

  List<RecipeModel> _loadedRecipes = [];
  List<RecipeModel> _loadedFavourites = [];
  List<CategoryModel> _allCategories = [];
  String _selectedCategoryId = 'all';
  String _currentSearchQuery = '';
  AlphabeticalOder _alphaOrder = AlphabeticalOder.asc;
  CustomPriority _customPriority = CustomPriority.none;

  RecipesProvider(this._recipesRepo, this._categoriesRepo);

  //Getters
  bool get isLoading => _isLoading;
  bool get isFullLoading => _isFullLoading;
  String? get error => _error;
  List<RecipeModel> get loadedRecipes => _loadedRecipes;
  List<RecipeModel> get loadedFavourites => _loadedFavourites;
  List<CategoryModel> get allCategories => _allCategories;
  String get selectedCategoryId => _selectedCategoryId;
  AlphabeticalOder get alphaOder => _alphaOrder;
  CustomPriority get customPriority => _customPriority;

  //State-management helpers
  void _setLoading({bool? main, bool? full, bool notify = true}) {
    if (main != null) _isLoading = main;
    if (full != null) _isFullLoading = full;
    if (notify) notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiSubscription?.cancel();
    super.dispose();
  }

  //Logic methods

  Future<void> init() async {
    if (_isInitialized) return;
    _setLoading(main: true, full: true);

    try {
      await fetchCategories();
      final existing = await _db.getAllRecipes();

      if (existing.isEmpty) {
        _startBackgroundLoading();
      } else {
        await _refreshUiState(showLoader: false);
        _loadedFavourites = await _db.getAllFavourites();
        _isInitialized = true;
      }
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(main: false, full: false);
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
      _setError('Failed to fetch categories: $e');
      rethrow;
    }
  }

  Future<void> onRefresh({bool silent = false}) async {
    _setLoading(main: true, full: true);
    try {
      await fetchCategories();
      await _refreshUiState(showLoader: false);
      _loadedFavourites = await _db.getAllFavourites();
      await Future.delayed(const Duration(milliseconds: 800));
      _error = null;
    } catch (e) {
      _setError('Failed to refresh recipes: $e');
    } finally {
      _setLoading(main: false, full: false, notify: !silent);
    }
  }

  void selectCategory(String categoryId) async {
    if (_selectedCategoryId == categoryId) return;

    _selectedCategoryId = categoryId;
    _setLoading(main: true);

    try {
      await _refreshUiState();
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(main: false);
    }
  }

  Future<void> searchRecipes(String query) async {
    final trimmed = query.trim();
    if (_currentSearchQuery == trimmed) return;

    _currentSearchQuery = trimmed;
    _setLoading(main: true);
    await _refreshUiState();
  }

  void toggleFavourite(RecipeModel recipe) async {
    final updatedRecipe = recipe.copyWith(isFavourite: !recipe.isFavourite);
    await _db.updateFavourite(updatedRecipe);

    final index = _loadedRecipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) _loadedRecipes[index] = updatedRecipe;

    _loadedFavourites = await _db.getAllFavourites();
    notifyListeners();
  }

  void _applySorting() {
    if (_loadedRecipes.isEmpty) return;

    _loadedRecipes.sort((a, b) {
      if (_customPriority != CustomPriority.none) {
        bool aIsCustom = _isUuid(a.id);
        bool bIsCustom = _isUuid(b.id);

        if (aIsCustom != bIsCustom) {
          if (_customPriority == CustomPriority.first) {
            return aIsCustom ? -1 : 1;
          } else {
            return aIsCustom ? 1 : -1;
          }
        }
      }

      int alphaResult = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      return _alphaOrder == AlphabeticalOder.asc ? alphaResult : -alphaResult;
    });
  }

  void toggleAlphaOrder() {
    _alphaOrder = (_alphaOrder == AlphabeticalOder.asc)
        ? AlphabeticalOder.desc
        : AlphabeticalOder.asc;
    _applySorting();
    notifyListeners();
  }

  void setCustomPriority(CustomPriority priority) {
    _customPriority = (_customPriority == priority)
        ? CustomPriority.none
        : priority;
    _applySorting();
    notifyListeners();
  }

  bool _isUuid(String id) => id.length == 36 && id.contains('-');

  //Private DB-helpers

  Future<void> _refreshUiState({bool showLoader = true}) async {
    if (showLoader) _setLoading(main: true);
    try {
      if (_currentSearchQuery.isEmpty) {
        if (_selectedCategoryId == 'all') {
          _loadedRecipes = await _db.getAllRecipes();
        } else {
          _loadedRecipes = await _db.getAllRecipesByCategoryId(
            _selectedCategoryId,
          );
        }
      } else {
        _loadedRecipes = await _db.searchRecipesInCategory(
          _currentSearchQuery,
          _selectedCategoryId,
        );
      }
      _applySorting();
      _error = null;
    } catch (e) {
      _setError('Data load failed: $e');
    } finally {
      if (showLoader) _setLoading(main: false);
    }
  }

  void _startBackgroundLoading() {
    _apiSubscription?.cancel();
    _apiSubscription = _recipesRepo.getAllMealsStream().listen((
      newBatch,
    ) async {
      await _db.insertMultipleRecipes(newBatch);
      _loadedRecipes = await _db.getAllRecipes();
      _loadedFavourites = await _db.getAllFavourites();
      _applySorting();
      notifyListeners();
    }, onError: (e) => debugPrint('Background loading error: $e'));
  }

  Future<void> insertRecipe(RecipeModel recipe) async {
    await _db.insertRecipe(recipe);
    await _refreshUiState();
    notifyListeners();
  }
}
