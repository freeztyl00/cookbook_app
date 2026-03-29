import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cookbook_app/providers/cook_book_provider.dart';

class CookBookHomeScreen extends StatefulWidget {
  static const String routeName = "/";
  const CookBookHomeScreen({super.key});

  @override
  State<CookBookHomeScreen> createState() => _CookBookHomeScreenState();
}

class _CookBookHomeScreenState extends State<CookBookHomeScreen> {
  @override
  void dispose() {
    Provider.of<CookBookProvider>(context).disposePageController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CookBookProvider>(
      builder: (context, provider, child) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          floatingActionButton: provider.currentPageIndex == 1
              ? FloatingActionButton(
                  onPressed: () => provider.createRecipe(context),
                  backgroundColor: Theme.of(
                    context,
                  ).floatingActionButtonTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(30),
                  ),
                  child: const Icon(Icons.add_rounded),
                )
              : null,
          body: PageView(
            controller: provider.pageController,
            onPageChanged: provider.onPageChanged,
            children: provider.pages,
          ),
          bottomNavigationBar: NavigationBar(
            destinations: <Widget>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: provider.pageLabels[0],
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: provider.pageLabels[1],
              ),
              NavigationDestination(
                icon: Icon(Icons.star_border_outlined),
                selectedIcon: Icon(Icons.star),
                label: provider.pageLabels[2],
              ),
            ],
            selectedIndex: provider.currentPageIndex,
            onDestinationSelected: provider.changePage,
          ),
        ),
      ),
    );
  }
}
