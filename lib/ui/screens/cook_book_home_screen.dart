import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:cookbook_app/ui/screens/create_custom_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cookbook_app/providers/cook_book_provider.dart';

class CookBookHomeScreen extends StatelessWidget {
  static const String routeName = "/";
  const CookBookHomeScreen({super.key});

  void _onAddRecipePressed(BuildContext context) async {
    final recipe = await showModalBottomSheet<RecipeModel>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (_) => const CreateCustomRecipe(),
    );

    if (recipe != null && context.mounted) {
      await context.read<CookBookProvider>().saveCreatedRecipe(context, recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CookBookProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: Selector<CookBookProvider, int>(
          selector: (_, p) => p.currentPageIndex,
          builder: (context, index, _) {
            if (index != 1) return const SizedBox.shrink();

            return FloatingActionButton(
              onPressed: () => _onAddRecipePressed(context),
              child: const Icon(Icons.add_rounded),
            );
          },
        ),
        body: PageView(
          controller: provider.pageController,
          onPageChanged: (index) => provider.setPage(index, fromSlider: true),
          children: provider.pages,
        ),
        bottomNavigationBar: Selector<CookBookProvider, int>(
          selector: (_, p) => p.currentPageIndex,
          builder: (context, currentIndex, _) => NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => provider.setPage(index),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: CookBookProvider.pageLabels[0],
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: CookBookProvider.pageLabels[1],
              ),
              NavigationDestination(
                icon: const Icon(Icons.star_border_outlined),
                selectedIcon: const Icon(Icons.star),
                label: CookBookProvider.pageLabels[2],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
