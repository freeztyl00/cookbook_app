import 'package:cookbook_app/data/api/meals_api_client.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/data/repository/categories_repository.dart';
import 'package:cookbook_app/data/repository/recipes_repository.dart';
import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:cookbook_app/providers/theme_provider.dart';
import 'package:cookbook_app/ui/screens/recipe_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cookbook_app/core/theme/color_schemes.dart';
import 'package:cookbook_app/providers/cook_book_provider.dart';
import 'package:cookbook_app/ui/screens/cook_book_home_screen.dart';
import 'package:http/http.dart' as http;

void main() {
  final httpClient = http.Client();
  final apiBaseClient = MealsApiClient(httpClient);
  final recipesRepo = RecipesRepository(apiBaseClient);
  final categoriesRepo = CategoriesRepository(apiBaseClient);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CookBookProvider()),
        ChangeNotifierProvider(
          create: (_) => RecipesProvider(recipesRepo, categoriesRepo),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const CookBookApp(),
    ),
  );
}

class CookBookApp extends StatelessWidget {
  const CookBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) => MaterialApp.router(
        theme: ThemeData.from(colorScheme: lightColorScheme),
        darkTheme: ThemeData.from(colorScheme: darkColorScheme),
        themeMode: provider.themeMode,
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: CookBookHomeScreen.routeName,
      name: CookBookHomeScreen.routeName,
      builder: (context, state) => CookBookHomeScreen(),
      routes: [
        GoRoute(
          path: RecipeDetailsScreen.routeName,
          name: RecipeDetailsScreen.routeName,
          builder: (context, state) =>
              RecipeDetailsScreen(recipe: state.extra as RecipeModel),
        ),
      ],
    ),
  ],
);
