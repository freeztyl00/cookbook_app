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

class FavouriteRecipesScreen extends StatefulWidget {
  static const String pageLabel = "Favourites";
  const FavouriteRecipesScreen({super.key});

  @override
  State<FavouriteRecipesScreen> createState() => _FavouriteRecipesScreenState();
}

class _FavouriteRecipesScreenState extends State<FavouriteRecipesScreen> {
  Widget _favouriteRecipeSelectionItem(
    BuildContext context,
    RecipeModel currentRecipe,
  ) {
    return InkWell(
      key: ValueKey(currentRecipe.id),
      borderRadius: BorderRadius.circular(Sizes.m.value),
      child: Padding(
        padding: EdgeInsets.all(Sizes.xs.value),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RecipeImage(imagePath: currentRecipe.images!.first),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(
                            alpha:
                                Theme.brightnessOf(context) == Brightness.dark
                                ? 0.8
                                : 0.6,
                          ),
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
                    currentRecipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTitleStyle,
                  ),
                ),
                if (currentRecipe.isFavourite)
                  const Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(Icons.favorite, color: Colors.red, size: 30),
                  ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        context.goNamed(RecipeDetailsScreen.routeName, extra: currentRecipe);
      },
    );
  }

  Widget favouriteRecipeSelectionSkeletonItem(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.all(Sizes.xs.value),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Padding(
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

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipesProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.onRefresh(),
          displacement: 60,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(title: Text(FavouriteRecipesScreen.pageLabel)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(Sizes.m.value),
                  child: RecipesSearch(recipes: provider.loadedFavourites),
                ),
              ),
              SliverPadding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: Sizes.s.value,
                ),
                sliver: provider.isLoading
                    ? SliverList.builder(
                        itemCount: 4,
                        itemBuilder: (context, _) =>
                            favouriteRecipeSelectionSkeletonItem(context),
                      )
                    : provider.error != null
                    ? SliverToBoxAdapter(
                        child: Center(child: Text(provider.error!)),
                      )
                    : provider.loadedFavourites.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text("No favourite recipe so far..."),
                        ),
                      )
                    : SliverList.builder(
                        itemCount: provider.loadedFavourites.length,
                        itemBuilder: (context, index) =>
                            _favouriteRecipeSelectionItem(
                              context,
                              provider.loadedFavourites[index],
                            ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RecipesSearch extends StatelessWidget {
  final List<RecipeModel> recipes;
  const RecipesSearch({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (context, controller) => SearchBar(
        padding: WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: Sizes.m.value),
        ),
        controller: controller,
        leading: Icon(Icons.search),
        trailing: [
          IconButton(
            onPressed: controller.clear,
            icon: const Icon(Icons.clear),
          ),
        ],
        hintText: "Search favourites...",
        onTap: () {
          controller.openView();
        },
      ),
      suggestionsBuilder: (context, controller) {
        final query = controller.text.toLowerCase();
        final matches = recipes
            .where(
              (recipe) =>
                  recipe.title.toLowerCase().contains(query) ||
                  recipe.description.toLowerCase().contains(query),
            )
            .take(10)
            .map(
              (recipe) => ListTile(
                leading: CircleAvatar(
                  key: ValueKey(recipe.id),
                  child: RecipeImage(imagePath: recipe.images!.first),
                ),
                title: Text(recipe.title),
                subtitle: Text(
                  recipe.ingredients.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  controller.closeView(recipe.title);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailsScreen(recipe: recipe),
                    ),
                  );
                },
              ),
            );
        return matches.isNotEmpty
            ? matches
            : [ListTile(title: Text("Nothing was found..."))];
      },
    );
  }
}
