import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/azkar_repository.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/playlist_service.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import '../../utils/page_transitions.dart';
import 'zikr_detail_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';
import 'categories_grid_screen.dart';
import '../widgets/category_card.dart';
import '../widgets/zikr_list_item.dart';
import '../widgets/floating_playlist_player.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final _azkarRepo = AzkarRepository();
  final _storage = StorageService();
  final _playlistService = PlaylistService();
  
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _playlistService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            NestedScrollView(
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
            // Floating playlist player
            StreamBuilder<bool>(
              stream: _playlistService.stateStream.map((state) => 
                  state == PlaylistState.playing || state == PlaylistState.paused),
              initialData: false,
              builder: (context, snapshot) {
                final isVisible = snapshot.data ?? false;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  bottom: isVisible ? 0 : -120,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isVisible ? 1.0 : 0.0,
                    child: FloatingPlaylistPlayer(
                      playlistService: _playlistService,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: _selectedCategory != null
            ? null
            : FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    CustomPageRoute(child: const RemindersScreen()),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
                label: Text(l10n.reminders),
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: _isSearching ? 120 : 200,
      collapsedHeight: 70,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final l10n = AppLocalizations.ofWithFallback(context);
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
                        _buildGreeting(),
                        const SizedBox(height: 12),
                      ],
                      _buildSearchBar(l10n),
                      if (_selectedCategory != null && !_isSearching) ...[
                        const SizedBox(height: 8),
                        _buildSelectedCategoryChip(l10n),
                      ],
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
              Navigator.push(
                context,
                CustomPageRoute(child: const SettingsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Text(
              'SALAM 👋',
              style: AppTheme.titleLarge.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            _selectedCategory = null; // Clear category when searching
          });
        },
        decoration: InputDecoration(
          hintText: l10n.searchAzkar,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching || _selectedCategory != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                      _selectedCategory = null;
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

  Widget _buildSelectedCategoryChip(AppLocalizations l10n) {
    if (_selectedCategory == null) return const SizedBox.shrink();
    
    final categoryName = _azkarRepo.getCategoryDisplayName(_selectedCategory!);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              categoryName,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = null;
              });
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    final l10n = AppLocalizations.ofWithFallback(context);
    
    return SliverToBoxAdapter(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentGold,
                  AppTheme.accentGold.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                        l10n.dailyAzkar,
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.keepHeartClose,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final l10n = AppLocalizations.ofWithFallback(context);
    
    return FutureBuilder<List<String>>(
      future: _azkarRepo.getAllCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final categories = snapshot.data!;
        final categoryMap = _azkarRepo.getCategoryDisplayNamesAr();

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.categories,
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${categories.length}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // See All button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            child: CategoriesGridScreen(
                              categories: categories,
                              categoryMap: categoryMap,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'See All',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppTheme.primaryGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length > 5 ? 5 : categories.length,
                  itemBuilder: (context, index) {
                    final categoryKey = categories[index];
                    final categoryNameAr = categoryMap[categoryKey] ?? categoryKey;

                    return CategoryCard(
                      title: categoryNameAr,
                      titleAr: categoryNameAr,
                      onTap: () {
                        _tabController.animateTo(0);
                        setState(() {
                          _selectedCategory = categoryKey;
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.ofWithFallback(context);
        return SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: [
                    Tab(text: l10n.all),
                    Tab(text: l10n.favorites),
                    Tab(text: l10n.recent),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildAllAzkarTab() {
    final l10n = AppLocalizations.ofWithFallback(context);
    
    return FutureBuilder<List<Zikr>>(
      future: _selectedCategory != null
          ? _azkarRepo.getAzkarByCategory(_selectedCategory!)
          : (_isSearching && _searchQuery.isNotEmpty
              ? _azkarRepo.searchAzkar(_searchQuery)
              : _azkarRepo.loadAzkar()),
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
                  _selectedCategory != null
                      ? l10n.noAzkarInCategory
                      : l10n.noAzkarFound,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (_selectedCategory != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: Text(l10n.clearFilter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        final azkar = snapshot.data!;
        final prefs = _storage.getPreferences();
        final hasAudio = azkar.any((z) => z.audio.isNotEmpty);

        return Column(
          children: [
            // Play All Button - only show when category is selected and has audio
            if (_selectedCategory != null && hasAudio)
              _buildPlayAllButton(azkar),
            Expanded(
              child: ListView.builder(
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
                        CustomPageRoute(child: ZikrDetailScreen(zikr: zikr)),
                      );
                    },
                    onFavoriteToggle: () async {
                      await _storage.toggleFavorite(zikr.id);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
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
                  CustomPageRoute(child: ZikrDetailScreen(zikr: favorites[index])),
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
    final l10n = AppLocalizations.ofWithFallback(context);
    
    return Center(
      child: Text(
        l10n.isArabic ? 'ستظهر الأذكار الأخيرة هنا' : 'Recent azkar will appear here',
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPlayAllButton(List<Zikr> azkar) {
    final categoryName = _selectedCategory != null
        ? _azkarRepo.getCategoryDisplayName(_selectedCategory!)
        : '';
    final audioCount = azkar.where((z) => z.audio.isNotEmpty).length;
    // Calculate total count including repetitions
    final totalPlaylistItems = azkar
        .where((z) => z.audio.isNotEmpty)
        .fold<int>(0, (sum, z) => sum + z.defaultCount);

    return StreamBuilder<PlaylistState>(
      stream: _playlistService.stateStream,
      initialData: PlaylistState.idle,
      builder: (context, snapshot) {
        final state = snapshot.data ?? PlaylistState.idle;
        final isPlaying = state == PlaylistState.playing;
        final isPaused = state == PlaylistState.paused;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryTeal,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (isPlaying) {
                    await _playlistService.pause();
                  } else if (isPaused) {
                    await _playlistService.resume();
                  } else {
                    await _playlistService.loadPlaylist(azkar);
                    await _playlistService.play();
                  }
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Animated play/pause icon
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: isPlaying ? 0.0 : 1.0,
                          end: isPlaying ? 1.0 : 0.0,
                        ),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.9 + (0.1 * value),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pause icon
                                  Opacity(
                                    opacity: value,
                                    child: const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  // Play icon
                                  Opacity(
                                    opacity: 1 - value,
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPlaying || isPaused
                                  ? (isPlaying ? 'Playing' : 'Paused')
                                  : 'Play All',
                              style: AppTheme.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              categoryName.isNotEmpty
                                  ? '$categoryName • $totalPlaylistItems items'
                                  : '$totalPlaylistItems items',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Wave animation when playing
                      if (isPlaying)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeInOut,
                          onEnd: () {
                            if (mounted && isPlaying) {
                              setState(() {});
                            }
                          },
                          builder: (context, value, child) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: 4,
                                  height: 20 * (0.5 + 0.5 * (0.5 + 0.5 * (value + index * 0.3) % 1.0)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
