import 'dart:async';

import 'package:cookbook_app/providers/recipes_provider.dart';
import 'package:cookbook_app/providers/theme_provider.dart';
import 'package:cookbook_app/ui/widgets/category_chip.dart';
import 'package:cookbook_app/ui/widgets/recipes_selection_grid.dart';
import 'package:flutter/material.dart';
import 'package:cookbook_app/core/theme/sizes.dart';
import 'package:provider/provider.dart';

class RecipesScreen extends StatefulWidget {
  static const String pageLabel = "Recipes";
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with AutomaticKeepAliveClientMixin {
  final _recipeScrollController = ScrollController();
  final _categoryScrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipesProvider>().init();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _recipeScrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const double expandedHeight = 200.0;
    const double toolbarHeight = kToolbarHeight;
    final double topSafeOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return RefreshIndicator(
      displacement: 60,
      onRefresh: _handleRefresh,
      child: RawScrollbar(
        controller: _recipeScrollController,
        thumbVisibility: true,
        interactive: true,
        thickness: 4,
        radius: const Radius.circular(20),
        thumbColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.8),
        minThumbLength: 40,
        padding: EdgeInsets.only(
          top: topSafeOffset,
          bottom: MediaQuery.of(context).padding.bottom + 10,
          right: 2,
        ),
        notificationPredicate: (notification) => notification.depth == 0,
        child: CustomScrollView(
          controller: _recipeScrollController,
          cacheExtent: 500,
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              stretch: true,
              toolbarHeight: toolbarHeight,
              expandedHeight: expandedHeight,
              title: const Text(RecipesScreen.pageLabel),
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final double currentHeight = constraints.maxHeight;
                  final double delta = expandedHeight - toolbarHeight;
                  final double expandRatio =
                      ((currentHeight - toolbarHeight) / delta).clamp(0.0, 1.0);
                  return FlexibleSpaceBar(
                    background: SafeArea(
                      child: Opacity(
                        opacity: expandRatio,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: Sizes.m.value,
                              ),
                              child: _buildSearchBar(context),
                            ),
                            const SizedBox(height: 12),
                            _buildCategoriesList(context),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              actions: _buildPopUpActions(context),
            ),
            SliverPadding(
              padding: EdgeInsets.all(Sizes.s.value),
              sliver: RecipesSelectionGrid(),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<T> _buildSortItem<T>({
    required T value,
    required String label,
    required IconData icon,
    T? currentOption,
  }) {
    final isSelected = value == currentOption;

    return PopupMenuItem<T>(
      value: value,
      padding: EdgeInsets.zero,
      mouseCursor: SystemMouseCursors.click,
      enabled: true,
      height: kMinInteractiveDimension,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPopUpActions(BuildContext context) {
    final provider = context.watch<RecipesProvider>();

    return [
      PopupMenuButton<dynamic>(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.sort_rounded),
        onSelected: (option) {
          _searchFocusNode.unfocus();
          if (option is AlphabeticalOder) {
            provider.toggleAlphaOrder();
          } else if (option is CustomPriority) {
            provider.setCustomPriority(option);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            enabled: false,
            child: Text(
              'Alphabetical',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          CheckedPopupMenuItem(
            value: AlphabeticalOder.asc,
            checked: provider.alphaOder == AlphabeticalOder.asc,
            child: const Text('Title: A-Z'),
          ),
          CheckedPopupMenuItem(
            value: AlphabeticalOder.desc,
            checked: provider.alphaOder == AlphabeticalOder.desc,
            child: const Text("Title: Z-A"),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            enabled: false,
            child: Text(
              "Custom Recipes",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          CheckedPopupMenuItem(
            value: CustomPriority.first,
            checked: provider.customPriority == CustomPriority.first,
            child: const Text("Custom first"),
          ),
          CheckedPopupMenuItem(
            value: CustomPriority.last,
            checked: provider.customPriority == CustomPriority.last,
            child: const Text("Custom last"),
          ),
        ],
      ),
      PopupMenuButton<String>(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.more_vert_rounded),
        onSelected: (String option) {
          if (option == 'theme') {
            _searchFocusNode.unfocus();
            context.read<ThemeProvider>().toggleTheme();
          } else if (option == 'settings') {
            _searchFocusNode.unfocus();
          }
        },
        itemBuilder: (context) {
          return [
            _buildSortItem<String>(
              value: 'theme',
              label:
                  'Switch to ${context.read<ThemeProvider>().isDarkMode ? 'light theme' : 'dark theme'}',
              icon: context.read<ThemeProvider>().isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            _buildSortItem<String>(
              value: 'settings',
              label: 'Settings',
              icon: Icons.settings,
            ),
          ];
        },
      ),
    ];
  }

  Widget _buildCategoriesList(BuildContext context) {
    return Consumer<RecipesProvider>(
      builder: (context, provider, child) {
        final bool isfullLoading = provider.isFullLoading;
        final int itemCount = provider.allCategories.length + 2;
        return SizedBox(
          height: 50,
          child: ListView.separated(
            controller: _categoryScrollController,
            padding: EdgeInsets.symmetric(horizontal: Sizes.m.value),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (isfullLoading) return const CategoryChip.skeleton();

              if (index == 0) {
                return CategoryChip(
                  label: 'All',
                  isSelected: provider.selectedCategoryId == 'all',
                  onTap: () => _handleCategoryTap(context, 'all'),
                );
              }

              if (index == itemCount - 1) {
                return CategoryChip(
                  label: "Add new",
                  icon: Icon(Icons.add_rounded),
                  isSelected: false,
                  onTap: () {},
                );
              }

              final category = provider.allCategories[index - 1];
              return CategoryChip(
                label: category.name,
                isSelected: provider.selectedCategoryId == category.id,
                onTap: () => _handleCategoryTap(context, category.id),
              );
            },
          ),
        );
      },
    );
  }

  SearchBar _buildSearchBar(BuildContext context) {
    return SearchBar(
      focusNode: _searchFocusNode,
      controller: _searchController,
      hintText: 'Search recipes...',
      leading: Padding(
        padding: EdgeInsets.only(left: Sizes.s.value),
        child: const Icon(Icons.search),
      ),
      trailing: [
        if (_searchController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: Sizes.s.value),
            child: IconButton(
              onPressed: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
              },
              icon: Icon(Icons.clear),
            ),
          ),
      ],
    );
  }

  void _onSearchChanged() {
    setState(() {});
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<RecipesProvider>().searchRecipes(_searchController.text);
      }
    });
  }

  Future<void> _handleRefresh() async {
    final provider = context.read<RecipesProvider>();
    double offset = _categoryScrollController.hasClients
        ? _categoryScrollController.offset
        : 0.0;
    await provider.onRefresh(silent: true);
    if (_categoryScrollController.hasClients) {
      _categoryScrollController.jumpTo(offset);
    }
  }

  void _handleCategoryTap(BuildContext context, String id) {
    _searchFocusNode.unfocus();
    final provider = context.read<RecipesProvider>();
    provider.selectCategory(id);
    if (_recipeScrollController.hasClients) {
      _recipeScrollController.jumpTo(0);
    }
  }
}
