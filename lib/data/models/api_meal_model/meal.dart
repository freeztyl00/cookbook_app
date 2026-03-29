class Meal {
  String? idMeal;
  String? strMeal;
  dynamic strMealAlternate;
  String? strCategory;
  String? strArea;
  String? strInstructions;
  String? strMealThumb;
  dynamic strTags;
  String? strYoutube;
  String? strIngredient1;
  String? strIngredient2;
  String? strIngredient3;
  String? strIngredient4;
  String? strIngredient5;
  String? strIngredient6;
  String? strIngredient7;
  String? strIngredient8;
  String? strIngredient9;
  String? strIngredient10;
  String? strIngredient11;
  String? strIngredient12;
  String? strIngredient13;
  String? strIngredient14;
  String? strIngredient15;
  String? strIngredient16;
  String? strIngredient17;
  String? strIngredient18;
  String? strIngredient19;
  String? strIngredient20;
  String? strMeasure1;
  String? strMeasure2;
  String? strMeasure3;
  String? strMeasure4;
  String? strMeasure5;
  String? strMeasure6;
  String? strMeasure7;
  String? strMeasure8;
  String? strMeasure9;
  String? strMeasure10;
  String? strMeasure11;
  String? strMeasure12;
  String? strMeasure13;
  String? strMeasure14;
  String? strMeasure15;
  String? strMeasure16;
  String? strMeasure17;
  String? strMeasure18;
  String? strMeasure19;
  String? strMeasure20;
  String? strSource;
  dynamic strImageSource;
  dynamic strCreativeCommonsConfirmed;
  String? dateModified;

  Meal({
    this.idMeal,
    this.strMeal,
    this.strMealAlternate,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strTags,
    this.strYoutube,
    this.strIngredient1,
    this.strIngredient2,
    this.strIngredient3,
    this.strIngredient4,
    this.strIngredient5,
    this.strIngredient6,
    this.strIngredient7,
    this.strIngredient8,
    this.strIngredient9,
    this.strIngredient10,
    this.strIngredient11,
    this.strIngredient12,
    this.strIngredient13,
    this.strIngredient14,
    this.strIngredient15,
    this.strIngredient16,
    this.strIngredient17,
    this.strIngredient18,
    this.strIngredient19,
    this.strIngredient20,
    this.strMeasure1,
    this.strMeasure2,
    this.strMeasure3,
    this.strMeasure4,
    this.strMeasure5,
    this.strMeasure6,
    this.strMeasure7,
    this.strMeasure8,
    this.strMeasure9,
    this.strMeasure10,
    this.strMeasure11,
    this.strMeasure12,
    this.strMeasure13,
    this.strMeasure14,
    this.strMeasure15,
    this.strMeasure16,
    this.strMeasure17,
    this.strMeasure18,
    this.strMeasure19,
    this.strMeasure20,
    this.strSource,
    this.strImageSource,
    this.strCreativeCommonsConfirmed,
    this.dateModified,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    idMeal: json['idMeal'] as String?,
    strMeal: json['strMeal'] as String?,
    strMealAlternate: json['strMealAlternate'] as dynamic,
    strCategory: json['strCategory'] as String?,
    strArea: json['strArea'] as String?,
    strInstructions: json['strInstructions'] as String?,
    strMealThumb: json['strMealThumb'] as String?,
    strTags: json['strTags'] as dynamic,
    strYoutube: json['strYoutube'] as String?,
    strIngredient1: json['strIngredient1'] as String?,
    strIngredient2: json['strIngredient2'] as String?,
    strIngredient3: json['strIngredient3'] as String?,
    strIngredient4: json['strIngredient4'] as String?,
    strIngredient5: json['strIngredient5'] as String?,
    strIngredient6: json['strIngredient6'] as String?,
    strIngredient7: json['strIngredient7'] as String?,
    strIngredient8: json['strIngredient8'] as String?,
    strIngredient9: json['strIngredient9'] as String?,
    strIngredient10: json['strIngredient10'] as String?,
    strIngredient11: json['strIngredient11'] as String?,
    strIngredient12: json['strIngredient12'] as String?,
    strIngredient13: json['strIngredient13'] as String?,
    strIngredient14: json['strIngredient14'] as String?,
    strIngredient15: json['strIngredient15'] as String?,
    strIngredient16: json['strIngredient16'] as String?,
    strIngredient17: json['strIngredient17'] as String?,
    strIngredient18: json['strIngredient18'] as String?,
    strIngredient19: json['strIngredient19'] as String?,
    strIngredient20: json['strIngredient20'] as String?,
    strMeasure1: json['strMeasure1'] as String?,
    strMeasure2: json['strMeasure2'] as String?,
    strMeasure3: json['strMeasure3'] as String?,
    strMeasure4: json['strMeasure4'] as String?,
    strMeasure5: json['strMeasure5'] as String?,
    strMeasure6: json['strMeasure6'] as String?,
    strMeasure7: json['strMeasure7'] as String?,
    strMeasure8: json['strMeasure8'] as String?,
    strMeasure9: json['strMeasure9'] as String?,
    strMeasure10: json['strMeasure10'] as String?,
    strMeasure11: json['strMeasure11'] as String?,
    strMeasure12: json['strMeasure12'] as String?,
    strMeasure13: json['strMeasure13'] as String?,
    strMeasure14: json['strMeasure14'] as String?,
    strMeasure15: json['strMeasure15'] as String?,
    strMeasure16: json['strMeasure16'] as String?,
    strMeasure17: json['strMeasure17'] as String?,
    strMeasure18: json['strMeasure18'] as String?,
    strMeasure19: json['strMeasure19'] as String?,
    strMeasure20: json['strMeasure20'] as String?,
    strSource: json['strSource'] as String?,
    strImageSource: json['strImageSource'] as dynamic,
    strCreativeCommonsConfirmed: json['strCreativeCommonsConfirmed'] as dynamic,
    dateModified: json['dateModified'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'idMeal': idMeal,
    'strMeal': strMeal,
    'strMealAlternate': strMealAlternate,
    'strCategory': strCategory,
    'strArea': strArea,
    'strInstructions': strInstructions,
    'strMealThumb': strMealThumb,
    'strTags': strTags,
    'strYoutube': strYoutube,
    'strIngredient1': strIngredient1,
    'strIngredient2': strIngredient2,
    'strIngredient3': strIngredient3,
    'strIngredient4': strIngredient4,
    'strIngredient5': strIngredient5,
    'strIngredient6': strIngredient6,
    'strIngredient7': strIngredient7,
    'strIngredient8': strIngredient8,
    'strIngredient9': strIngredient9,
    'strIngredient10': strIngredient10,
    'strIngredient11': strIngredient11,
    'strIngredient12': strIngredient12,
    'strIngredient13': strIngredient13,
    'strIngredient14': strIngredient14,
    'strIngredient15': strIngredient15,
    'strIngredient16': strIngredient16,
    'strIngredient17': strIngredient17,
    'strIngredient18': strIngredient18,
    'strIngredient19': strIngredient19,
    'strIngredient20': strIngredient20,
    'strMeasure1': strMeasure1,
    'strMeasure2': strMeasure2,
    'strMeasure3': strMeasure3,
    'strMeasure4': strMeasure4,
    'strMeasure5': strMeasure5,
    'strMeasure6': strMeasure6,
    'strMeasure7': strMeasure7,
    'strMeasure8': strMeasure8,
    'strMeasure9': strMeasure9,
    'strMeasure10': strMeasure10,
    'strMeasure11': strMeasure11,
    'strMeasure12': strMeasure12,
    'strMeasure13': strMeasure13,
    'strMeasure14': strMeasure14,
    'strMeasure15': strMeasure15,
    'strMeasure16': strMeasure16,
    'strMeasure17': strMeasure17,
    'strMeasure18': strMeasure18,
    'strMeasure19': strMeasure19,
    'strMeasure20': strMeasure20,
    'strSource': strSource,
    'strImageSource': strImageSource,
    'strCreativeCommonsConfirmed': strCreativeCommonsConfirmed,
    'dateModified': dateModified,
  };
}
