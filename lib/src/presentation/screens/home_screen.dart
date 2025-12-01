import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/azkar_repository.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import 'zikr_detail_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';
import '../widgets/category_card.dart';
import '../widgets/zikr_list_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final _azkarRepo = AzkarRepository();
  final _storage = StorageService();
  
  late TabController _tabController;
  late AnimationController _greetingController;
  late Animation<double> _greetingAnimation;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isSearching = false;
  
  final List<String> _greetings = [
    'السلام عليكم',
    'Peace be upon you',
    'May Allah bless you',
    'بارك الله فيك',
  ];
  int _currentGreetingIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Greeting animation controller
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _greetingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _greetingController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start greeting animation
    _greetingController.forward();
    
    // Auto-scroll greetings every 4 seconds
    _startGreetingTimer();
  }

  void _startGreetingTimer() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _changeGreeting();
        _startGreetingTimer(); // Continue the cycle
      }
    });
  }

  void _changeGreeting() {
    if (!mounted) return;
    
    _greetingController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentGreetingIndex = (_currentGreetingIndex + 1) % _greetings.length;
        });
        _greetingController.forward();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _greetingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RemindersScreen(),
            ),
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
                        Builder(
                          builder: (context) => _buildAnimatedGreeting(
                            AppLocalizations.of(context),
                          ),
                        ),
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
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedGreeting(AppLocalizations? l10n) {
    final localizations = l10n ?? AppLocalizations.ofWithFallback(context);
    final greeting = _greetings[_currentGreetingIndex];
    final isArabicGreeting = greeting.contains('ال') || greeting.contains('ب');
    
    return AnimatedBuilder(
      animation: _greetingAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _greetingAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _greetingAnimation.value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    greeting,
                    key: ValueKey(greeting),
                    style: isArabicGreeting
                        ? AppTheme.arabicMedium.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : AppTheme.titleLarge.copyWith(
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
                ),
                const SizedBox(height: 6),
                // Decorative dots indicator
                Row(
                  children: List.generate(
                    _greetings.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentGreetingIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
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
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
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
