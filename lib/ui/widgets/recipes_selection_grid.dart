import 'package:cookbook_app/core/theme/sizes.dart';
import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:cookbook_app/ui/widgets/recipe_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class RecipesSelectionGrid extends StatelessWidget {
  const RecipesSelectionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return SliverGrid.builder(
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, _) => _buildSkeletonItem(context),
          );
        }

        if (provider.error != null) {
          return SliverFillRemaining(
            child: Center(child: Text(provider.error!)),
          );
        }

        if (provider.loadedRecipes.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text("No recipes yet.")),
          );
        }

        return SliverGrid.builder(
          itemCount: provider.loadedRecipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemBuilder: (context, index) {
            final recipe = provider.loadedRecipes[index];
            return Padding(
              padding: EdgeInsets.all(Sizes.xs.value),
              child: RecipeGridItem(recipe: recipe),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.all(Sizes.xs.value),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Shimmer.fromColors(
                baseColor: colorScheme.surfaceContainerHighest,
                highlightColor: colorScheme.surface,
                child: Container(color: Colors.white),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextLine(context, width: double.infinity),
                  const SizedBox(height: 6),
                  _buildTextLine(context, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextLine(BuildContext context, {required double width}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surface.withValues(alpha: 0.4),
      highlightColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.8,
      ),
      child: Container(
        height: 14,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
