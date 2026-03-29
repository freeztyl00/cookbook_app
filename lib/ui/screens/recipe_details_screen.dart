import 'package:cookbook_app/core/utils/util_functions.dart';
import 'package:cookbook_app/ui/widgets/recipe_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:cookbook_app/core/theme/sizes.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';

class RecipeDetailsScreen extends StatefulWidget {
  static const String routeName = "details";
  final RecipeModel recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  int _currentPhotoIdx = 0;

  Widget multiImagedSelector(RecipeModel currentRecipe) {
    return Stack(
      children: [
        //Photo
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: SelectedPhoto(
            key: ValueKey(_currentPhotoIdx),
            recipe: currentRecipe,
            index: _currentPhotoIdx,
          ),
        ),
        //Arrow forward
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            onPressed: () {
              setState(() {
                _currentPhotoIdx =
                    _currentPhotoIdx == currentRecipe.images!.length - 1
                    ? 0
                    : _currentPhotoIdx + 1;
              });
            },
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 0),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        //Arrow back
        Positioned(
          bottom: 8,
          left: 8,
          child: IconButton(
            onPressed: () {
              setState(() {
                _currentPhotoIdx = _currentPhotoIdx == 0
                    ? currentRecipe.images!.length - 1
                    : _currentPhotoIdx - 1;
              });
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 0),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipesProvider>(
      builder: (context, provider, child) {
        final currentRecipe = provider.loadedRecipes.firstWhere(
          (r) => r.id == widget.recipe.id,
          orElse: () => widget.recipe,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text("Recipe: ${currentRecipe.title}"),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<RecipesProvider>().toggleFavourite(
                    currentRecipe,
                  );
                  final message = currentRecipe.isFavourite
                      ? "${currentRecipe.title} removed from favourites"
                      : "${currentRecipe.title} added to favourites";
                  clearSnackBars(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    showSnackBar(context: context, message: message),
                  );
                },
                icon: currentRecipe.isFavourite
                    ? Icon(Icons.favorite, color: Colors.red)
                    : Icon(Icons.favorite_border_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  currentRecipe.images!.length <= 1
                      ? SelectedPhoto(recipe: currentRecipe, index: 0)
                      : multiImagedSelector(currentRecipe),
                  //Ingridients
                  SizedBox(height: Sizes.m.value),
                  Text(
                    "Ingridients: ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: Sizes.m.value),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: currentRecipe.ingredients
                        .map((e) => Text(e, style: TextStyle(fontSize: 14)))
                        .toList(),
                  ),
                  //Description
                  Divider(
                    height: Sizes.m.value * 3,
                    thickness: 2,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Text(
                    "Recipe: ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: Sizes.m.value),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: Sizes.m.value,
                    ),
                    child: Text(currentRecipe.description),
                  ),
                  SizedBox(height: Sizes.xs.value),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SelectedPhoto extends StatelessWidget {
  final RecipeModel recipe;
  final int index;
  final bool useHero;
  const SelectedPhoto({
    super.key,
    required this.recipe,
    required this.index,
    this.useHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = RecipeImage(
      imagePath: recipe.images![index],
      isFullSize: true,
    );

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: useHero
          ? Hero(tag: 'recipe_image_${recipe.id}', child: imageWidget)
          : imageWidget,
    );
  }
}
