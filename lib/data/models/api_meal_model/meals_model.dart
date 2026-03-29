import 'meal.dart';

class MealsModel {
  List<Meal>? meals;

  MealsModel({this.meals});

  factory MealsModel.fromJson(Map<String, dynamic> json) {
    return MealsModel(
      meals: (json['meals'] as List<dynamic>?)
          ?.map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'meals': meals?.map((e) => e.toJson()).toList(),
  };
}
