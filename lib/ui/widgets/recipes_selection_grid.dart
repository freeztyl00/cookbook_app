import 'dart:io';

import 'package:cookbook_app/core/theme/sizes.dart';
import 'package:cookbook_app/core/theme/text_styles.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:cookbook_app/ui/screens/recipe_details_screen.dart';
import 'package:cookbook_app/ui/widgets/recipe_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class RecipesSelectionGrid extends StatelessWidget {
  const RecipesSelectionGrid({super.key});

  Widget _recipeSelectionItem(BuildContext context, RecipeModel currentRecipe) {
    final String imagePath =
        currentRecipe.images?.first ?? 'assets/default_dish.png';

    return InkWell(
      key: ValueKey(currentRecipe.id),
      borderRadius: BorderRadius.circular(Sizes.m.value),
      onTap: () {
        context.goNamed(RecipeDetailsScreen.routeName, extra: currentRecipe);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: 'recipe_image_${currentRecipe.id}',
                child: RecipeImage(imagePath: imagePath),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentGeometry.topCenter,
                    end: AlignmentGeometry.bottomCenter,
                    colors: [Colors.black.withAlpha(80), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              right: 8,
              child: Text(
                currentRecipe.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTitleStyle,
              ),
            ),
            if (currentRecipe.isFavourite)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.favorite, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _recipeSelectionSkeletonItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Sizes.xs.value),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentGeometry.topCenter,
                    end: AlignmentGeometry.bottomCenter,
                    colors: [Colors.black.withAlpha(80), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: SizedBox.fromSize(size: Size(100, 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SliverGrid.builder(
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, _) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: _recipeSelectionSkeletonItem(context),
            ),
          );
        }
        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }
        if (provider.loadedRecipes.isNotEmpty) {
          return SliverGrid.builder(
            itemCount: provider.loadedRecipes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              final currentRecipe = provider.loadedRecipes[index];
              if (index + 1 < provider.loadedRecipes.length) {
                precacheImage(
                  FileImage(
                    File(provider.loadedRecipes[index + 1].images!.first),
                  ),
                  context,
                );
              }
              return Padding(
                padding: EdgeInsets.all(Sizes.xs.value),
                child: _recipeSelectionItem(context, currentRecipe),
              );
            },
          );
        }
        return const SliverToBoxAdapter(
          child: Center(child: Text("No recipes yet.")),
        );
      },
    );
  }
}
