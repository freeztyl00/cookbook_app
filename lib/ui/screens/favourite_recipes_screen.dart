import 'dart:io';

import 'package:cookbook_app/core/theme/sizes.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:cookbook_app/ui/screens/recipe_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
                if (currentRecipe.images!.first.contains("assets/"))
                  Positioned.fill(
                    child: Image.asset(
                      "assets/default_dish.png",
                      fit: BoxFit.cover,
                    ),
                  )
                else if (currentRecipe.images!.first.contains("cache"))
                  Positioned.fill(
                    child: Image.file(
                      File(currentRecipe.images!.first),
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Positioned.fill(
                    child: Image.network(
                      currentRecipe.images!.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentGeometry.topCenter,
                        end: AlignmentGeometry.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(50),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 0),
                          blurRadius: 8,
                        ),
                      ],
                    ),
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
        ),
      ),
      onTap: () {
        context.goNamed(RecipeDetailsScreen.routeName, extra: currentRecipe);
      },
    );
  }

  Widget favouriteRecipeSelectionSkeletonItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Sizes.xs.value),
      child: AspectRatio(
        aspectRatio: 16 / 9,
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
                      colors: [Colors.black.withAlpha(50), Colors.transparent],
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RecipesProvider>().init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipesProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.onForceRefresh(),
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
          EdgeInsets.symmetric(horizontal: Sizes.s.value),
        ),
        controller: controller,
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        hintText: "Search",
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
                title: Text(recipe.title),
                subtitle: Text(
                  recipe.description,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
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
