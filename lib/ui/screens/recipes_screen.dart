import 'package:cookbook_app/providers/recipes_provider.dart';
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
  final _scrollController = ScrollController();
  final _searchController = SearchController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipesProvider>().init();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      displacement: topSafeOffset + 20,
      onRefresh: () async => context.read<RecipesProvider>().onForceRefresh(),
      child: RawScrollbar(
        controller: _scrollController,
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
          controller: _scrollController,
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
                              child: SearchBar(
                                controller: _searchController,
                                hintText: 'Search recipes...',
                                leading: const Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildCategoriesList(context),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
              actions: [
                IconButton(onPressed: () {}, icon: Icon(Icons.sort)),
                IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
              ],
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

  Widget _buildCategoriesList(BuildContext context) {
    return Consumer<RecipesProvider>(
      builder: (context, provider, child) {
        final bool loading = provider.isLoading;
        final int itemCount = loading ? 4 : provider.allCategories.length + 1;
        return SizedBox(
          height: 50,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: Sizes.m.value),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (loading) return const CategoryChip.skeleton();

              if (index == 0) {
                return CategoryChip(
                  label: 'All',
                  isSelected: provider.selectedCategoryId == 'all',
                  onTap: () => _handleCategoryTap(context, 'all'),
                );
              }

              final cat = provider.allCategories[index - 1];
              return CategoryChip(
                label: cat.name,
                isSelected: provider.selectedCategoryId == cat.id,
                onTap: () => _handleCategoryTap(context, cat.id),
              );
            },
          ),
        );
      },
    );
  }

  void _handleCategoryTap(BuildContext context, String id) {
    final provider = context.read<RecipesProvider>();
    provider.selectCategory(id);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }
}
