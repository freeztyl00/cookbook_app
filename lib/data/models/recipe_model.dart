import 'dart:convert';
import 'package:uuid/uuid.dart';

const String tableRecipes = 'tbl_recipes';
const String tblRecipesColId = 'id';
const String tblRecipesColAuthor = 'author';
const String tblRecipesColTitle = 'title';
const String tblRecipesColIngredients = 'ingridients';
const String tblRecipesColDescription = 'description';
const String tblRecipesColImages = 'images';
const String tblRecipesColCategoryId = 'categoryId';
const String tblRecipesColCategoryName = 'categoryName';
const String tblRecipesColIsFavourite = 'isFavourite';

class RecipeModel {
  final String id;
  final String author;
  final String title;
  final List<String> ingredients;
  final String description;
  final List<String>? images;
  final String? categoryId;
  final String? categoryName;
  bool isFavourite;

  RecipeModel({
    String? id,
    required this.author,
    required this.title,
    required this.ingredients,
    required this.description,
    this.images,
    this.categoryId,
    this.categoryName,
    this.isFavourite = false,
  }) : id = id ?? Uuid().v4();

  RecipeModel copyWith({
    String? id,
    String? author,
    String? title,
    List<String>? ingredients,
    String? description,
    List<String>? images,
    String? categoryId,
    String? categoryName,
    bool? isFavourite,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      description: description ?? this.description,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  factory RecipeModel.fromMap(Map<String, dynamic> recipe) => RecipeModel(
    id: recipe[tblRecipesColId] as String,
    author: recipe[tblRecipesColAuthor] as String,
    title: recipe[tblRecipesColTitle] as String,
    ingredients: List<String>.from(
      jsonDecode(recipe[tblRecipesColIngredients].toString()),
    ),
    description: recipe[tblRecipesColDescription] as String,
    images: recipe[tblRecipesColImages] != null
        ? List<String>.from(jsonDecode(recipe[tblRecipesColImages].toString()))
        : null,
    categoryId: recipe[tblRecipesColCategoryId] as String?,
    categoryName: recipe[tblRecipesColCategoryName] as String?,
    isFavourite: recipe[tblRecipesColIsFavourite] == 1 ? true : false,
  );

  Map<String, dynamic> toMap() {
    return {
      tblRecipesColId: id,
      tblRecipesColAuthor: author,
      tblRecipesColTitle: title,
      tblRecipesColIngredients: jsonEncode(ingredients),
      tblRecipesColDescription: description,
      tblRecipesColImages: images != null ? jsonEncode(images) : null,
      tblRecipesColCategoryId: categoryId,
      tblRecipesColIsFavourite: isFavourite ? 1 : 0,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
