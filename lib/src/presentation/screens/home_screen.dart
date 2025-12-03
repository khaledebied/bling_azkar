import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import 'zikr_detail_screen.dart';
import '../widgets/category_card.dart';
import '../widgets/zikr_list_item.dart';
import '../providers/search_providers.dart';
import '../providers/azkar_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSearching = ref.watch(isSearchingProvider);
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(ref),
            if (!isSearching) ...[ 
              _buildWelcomeBanner(),
              _buildCategoriesSection(ref),
            ],
            _buildTabBar(ref),
          ];
        },
        body: _buildTabBarView(ref),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to reminders screen
        },
        icon: const Icon(Icons.notifications_outlined),
        label: const Text('Reminders'),
      ),
    );
  }

  Widget _buildAppBar(WidgetRef ref) {
    final isSearching = ref.watch(isSearchingProvider);
    
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: isSearching ? 120 : 200,
      collapsedHeight: 70,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 60, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isSearching) ...[ 
                        Text(
                          'السلام عليكم',
                          style: AppTheme.arabicMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Peace be upon you',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildSearchBar(ref),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final isSearching = ref.watch(isSearchingProvider);
          
          return TextField(
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
              ref.read(isSearchingProvider.notifier).state = value.isNotEmpty;
            },
            decoration: InputDecoration(
              hintText: 'Search azkar...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(isSearchingProvider.notifier).state = false;
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Azkar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Keep your heart close to Allah',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(WidgetRef ref) {
    final repository = ref.watch(azkarRepositoryProvider);
    final categories = repository.getCategoryDisplayNames();
    final categoriesAr = repository.getCategoryDisplayNamesAr();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Categories',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryKey = categories.keys.elementAt(index);
                final categoryName = categories[categoryKey]!;
                final categoryNameAr = categoriesAr[categoryKey]!;

                return CategoryCard(
                  title: categoryName,
                  titleAr: categoryNameAr,
                  onTap: () {
                    ref.read(selectedTabIndexProvider.notifier).state = 0;
                    ref.read(searchQueryProvider.notifier).state = categoryKey;
                    ref.read(isSearchingProvider.notifier).state = true;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(WidgetRef ref) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        child: Consumer(
          builder: (context, ref, child) {
            final selectedIndex = ref.watch(selectedTabIndexProvider);
            
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(ref, 'All', 0, selectedIndex),
                    ),
                    Expanded(
                      child: _buildTabButton(ref, 'Favorites', 1, selectedIndex),
                    ),
                    Expanded(
                      child: _buildTabButton(ref, 'Recent', 2, selectedIndex),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(WidgetRef ref, String label, int index, int selectedIndex) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        ref.read(selectedTabIndexProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView(WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabIndexProvider);
    
    return IndexedStack(
      index: selectedIndex,
      children: [
        _buildAllAzkarTab(ref),
        _buildFavoritesTab(ref),
        _buildRecentTab(),
      ],
    );
  }

  Widget _buildAllAzkarTab(WidgetRef ref) {
    final isSearching = ref.watch(isSearchingProvider);
    final azkarAsync = isSearching 
        ? ref.watch(searchedAzkarProvider)
        : ref.watch(allAzkarProvider);

    return azkarAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading azkar',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      data: (azkar) {
        if (azkar.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No azkar found',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: azkar.length,
          // Performance optimization: provide item extent for better scrolling
          itemExtent: 100,
          // Performance optimization: increase cache extent for smoother scrolling
          cacheExtent: 500,
          itemBuilder: (context, index) {
            final zikr = azkar[index];
            
            return Consumer(
              builder: (context, ref, child) {
                final isFavorite = ref.watch(isFavoriteProvider(zikr.id));
                
                return RepaintBoundary(
                  child: ZikrListItem(
                    zikr: zikr,
                    isFavorite: isFavorite,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ZikrDetailScreen(zikr: zikr),
                        ),
                      );
                    },
                    onFavoriteToggle: () async {
                      try {
                        final toggleFavorite = ref.read(toggleFavoriteProvider);
                        await toggleFavorite(zikr.id);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab(WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteAzkarProvider);

    return favoritesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading favorites',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      data: (favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemExtent: 100,
          cacheExtent: 500,
          itemBuilder: (context, index) {
            final zikr = favorites[index];
            
            return RepaintBoundary(
              child: ZikrListItem(
                zikr: zikr,
                isFavorite: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZikrDetailScreen(zikr: zikr),
                    ),
                  );
                },
                onFavoriteToggle: () async {
                  try {
                    final toggleFavorite = ref.read(toggleFavoriteProvider);
                    await toggleFavorite(zikr.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentTab() {
    return Center(
      child: Text(
        'Recent azkar will appear here',
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// Delegate for the persistent tab bar header
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
