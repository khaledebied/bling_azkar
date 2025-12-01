import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/azkar_repository.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import 'zikr_detail_screen.dart';
import '../widgets/category_card.dart';
import '../widgets/zikr_list_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _azkarRepo = AzkarRepository();
  final _storage = StorageService();
  
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(),
            if (!_isSearching) ...[
              _buildWelcomeBanner(),
              _buildCategoriesSection(),
            ],
            _buildTabBar(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAllAzkarTab(),
            _buildFavoritesTab(),
            _buildRecentTab(),
          ],
        ),
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

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: _isSearching ? 100 : 140,
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
                      if (!_isSearching) ...[
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
                      _buildSearchBar(),
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

  Widget _buildSearchBar() {
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
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _isSearching = value.isNotEmpty;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search azkar...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Azkar',
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep your heart close to Allah',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
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

  Widget _buildCategoriesSection() {
    final categories = _azkarRepo.getCategoryDisplayNames();
    final categoriesAr = _azkarRepo.getCategoryDisplayNamesAr();

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
                    _tabController.animateTo(0);
                    setState(() {
                      _searchQuery = categoryKey;
                      _isSearching = true;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Favorites'),
                Tab(text: 'Recent'),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAllAzkarTab() {
    return FutureBuilder<List<Zikr>>(
      future: _isSearching && _searchQuery.isNotEmpty
          ? _azkarRepo.searchAzkar(_searchQuery)
          : _azkarRepo.loadAzkar(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

        final azkar = snapshot.data!;
        final prefs = _storage.getPreferences();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: azkar.length,
          itemBuilder: (context, index) {
            final zikr = azkar[index];
            final isFavorite = prefs.favoriteZikrIds.contains(zikr.id);

            return ZikrListItem(
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
                await _storage.toggleFavorite(zikr.id);
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    final prefs = _storage.getPreferences();
    
    return FutureBuilder<List<Zikr>>(
      future: _azkarRepo.loadAzkar(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final favorites = snapshot.data!
            .where((z) => prefs.favoriteZikrIds.contains(z.id))
            .toList();

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
          itemBuilder: (context, index) {
            return ZikrListItem(
              zikr: favorites[index],
              isFavorite: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ZikrDetailScreen(zikr: favorites[index]),
                  ),
                );
              },
              onFavoriteToggle: () async {
                await _storage.toggleFavorite(favorites[index].id);
                setState(() {});
              },
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
