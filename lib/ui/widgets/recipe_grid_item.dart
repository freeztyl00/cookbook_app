import 'package:cookbook_app/core/theme/sizes.dart';
import 'package:cookbook_app/core/theme/text_styles.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/ui/screens/recipe_details_screen.dart';
import 'package:cookbook_app/ui/widgets/recipe_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecipeGridItem extends StatelessWidget {
  final RecipeModel recipe;
  const RecipeGridItem({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Sizes.m.value),
      onTap: () =>
          context.goNamed(RecipeDetailsScreen.routeName, extra: recipe),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: 'recipe_image_${recipe.id}',
                child: RecipeImage(imagePath: recipe.images?.first ?? ''),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              right: 8,
              child: Text(
                recipe.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTitleStyle,
              ),
            ),
            if (recipe.isFavourite)
              const Positioned(
                bottom: 8,
                right: 8,
                child: Icon(Icons.favorite, color: Colors.red, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
