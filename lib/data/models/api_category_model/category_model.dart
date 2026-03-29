import 'category.dart';

class CategoriesModel {
  List<Category>? categories;

  CategoriesModel({this.categories});

  factory CategoriesModel.fromJson(Map<String, dynamic> json) =>
      CategoriesModel(
        categories: (json['categories'] as List<dynamic>?)
            ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'categories': categories?.map((e) => e.toJson()).toList(),
  };

  CategoriesModel copyWith({List<Category>? categories}) {
    return CategoriesModel(categories: categories ?? this.categories);
  }
}
