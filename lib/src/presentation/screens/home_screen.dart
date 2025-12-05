import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';
import '../widgets/category_card.dart';
import '../widgets/floating_playlist_player.dart';
import '../widgets/category_audio_bottom_sheet.dart';
import '../widgets/animated_zikr_header.dart';
import '../providers/search_providers.dart';
import '../providers/azkar_providers.dart';
import '../../data/services/playlist_service.dart';
import '../widgets/zikr_list_item.dart';
import '../widgets/prayer_times_card.dart';
import '../providers/prayer_times_providers.dart';
import 'zikr_detail_screen.dart';
import 'settings_screen.dart';
import 'categories_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _playlistService = PlaylistService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playlistService.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final isDarkMode = context.isDarkMode;
    final isSearching = ref.watch(isSearchingProvider);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: AnimatedZikrHeader(
            isDarkMode: isDarkMode,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black54,
              ),
        onPressed: () {
          Navigator.push(
            context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
          flexibleSpace: Container(
              decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ]
                    : [
                        AppTheme.primaryGreen.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF0F1419)
                : const Color(0xFFF5F5F5),
              ),
              child: SafeArea(
            top: true,
            child: Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                  child: Column(
                    children: [
                            if (!isSearching) ...[
                              _buildSearchBar(ref),
                              const SizedBox(height: 16),
                              Consumer(
                                builder: (context, ref, child) {
                                  final locationAvailable = ref.watch(locationAvailableProvider);
                                  if (locationAvailable) {
                                    return const PrayerTimesCard();
                                  }
                                  return const PrayerTimesCard(); // Will show selection prompt
                                },
                              ),
                            ] else ...[
                              _buildSearchBar(ref),
                              const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
                    if (!isSearching) ...[
                      _buildCategoriesGridSection(ref),
                    ] else ...[
                      _buildSearchResults(ref),
                    ],
                  ],
                ),
                // Floating playlist player
                StreamBuilder<PlaylistState>(
                  stream: _playlistService.stateStream,
                  initialData: PlaylistState.idle,
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? PlaylistState.idle;
                    final isVisible = state == PlaylistState.playing || state == PlaylistState.paused;
                    
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      bottom: isVisible ? 0 : -100,
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
          ),
        ),
      ),
    );
  }


  Widget _buildSearchBar(WidgetRef ref) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final isDarkMode = context.isDarkMode;
    
    return Consumer(
      builder: (context, ref, child) {
        final isSearching = ref.watch(isSearchingProvider);
        
    return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
            return Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: Opacity(
            opacity: value,
              child: child,
            ),
          );
        },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1E1E1E),
                      ],
                    )
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.95),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSearching
                    ? AppTheme.primaryGreen.withValues(alpha: 0.5)
                    : (isDarkMode 
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.15)),
                width: isSearching ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSearching
                      ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                      : (isDarkMode
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.08)),
                  blurRadius: isSearching ? 20 : 12,
                  offset: Offset(0, isSearching ? 6 : 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              style: AppTheme.bodyMedium.copyWith(
                color: isDarkMode ? Colors.white : AppTheme.textPrimary,
                fontSize: 15,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                ref.read(isSearchingProvider.notifier).state = value.isNotEmpty;
              },
              decoration: InputDecoration(
                hintText: isArabic ? 'ابحث عن الأذكار...' : 'Search azkar...',
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: isDarkMode 
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.grey.shade400,
                  fontSize: 15,
                ),
                prefixIcon: isArabic ? null : AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.search_rounded,
                    color: isSearching 
                        ? AppTheme.primaryGreen
                        : (isDarkMode 
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.grey.shade600),
                    size: 22,
                  ),
                ),
                suffixIcon: isArabic 
                    ? AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.search_rounded,
                          color: isSearching 
                              ? AppTheme.primaryGreen
                              : (isDarkMode 
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.grey.shade600),
                          size: 22,
                        ),
                      )
                    : (isSearching
                        ? TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Transform.rotate(
                                  angle: value * 3.14159 / 2,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: isDarkMode 
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(searchQueryProvider.notifier).state = '';
                                      ref.read(isSearchingProvider.notifier).state = false;
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                        : null),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isArabic ? 16 : 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildCategoriesGridSection(WidgetRef ref) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final allCategoriesAsync = ref.watch(allCategoriesProvider);

    return allCategoriesAsync.when(
      loading: () => _buildShimmerLoading(),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadingCategories,
                  style: AppTheme.titleMedium.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (allCategories) {
        final categoriesList = allCategories.entries.toList();
        final displayedCategories = categoriesList.take(4).toList();
        final hasMoreCategories = categoriesList.length > 4;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.categories,
              style: AppTheme.titleMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasMoreCategories)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoriesListScreen(
                                categories: categoriesList.map((e) => e.key).toList(),
                                categoryMap: allCategories,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                    Text(
                              l10n.seeAll,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              DirectionIcons.listArrow(context),
                              size: 12,
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0, // Square cards for better grid layout
                  ),
                  itemCount: displayedCategories.length,
              itemBuilder: (context, index) {
                    final entry = displayedCategories[index];
                    final categoryKey = entry.key;
                    final categoryName = entry.value;

                return CategoryCard(
                      key: ValueKey(categoryKey),
                  title: categoryName,
                      titleAr: categoryName,
                      heroTag: 'category_$categoryKey',
                      onTap: () => _showCategoryBottomSheet(context, categoryKey, categoryName),
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

  Widget _buildShimmerLoading() {
    final isDarkMode = context.isDarkMode;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Shimmer.fromColors(
          baseColor: isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          highlightColor: isDarkMode
              ? Colors.grey.shade700
              : Colors.grey.shade100,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? context.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildSearchResults(WidgetRef ref) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final azkarAsync = ref.watch(searchedAzkarProvider);

    return azkarAsync.when(
      loading: () {
        final isDarkMode = context.isDarkMode;
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Shimmer.fromColors(
              baseColor: isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              highlightColor: isDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade100,
              child: Column(
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 100,
            decoration: BoxDecoration(
                      color: isDarkMode ? context.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
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
                  l10n.errorLoadingAzkar,
                  style: AppTheme.titleMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTheme.caption.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      data: (azkar) {
        if (azkar.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
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
                      l10n.noAzkarFound,
                  style: AppTheme.titleMedium.copyWith(
                        color: context.textSecondary,
                  ),
                ),
              ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final zikr = azkar[index];
              
              return Consumer(
                builder: (context, ref, child) {
                  final isFavorite = ref.watch(isFavoriteProvider(zikr.id));
                  
                  return RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                  ),
                );
              },
            );
          },
            childCount: azkar.length,
          ),
        );
      },
    );
  }

  void _showCategoryBottomSheet(BuildContext context, String categoryKey, String categoryName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryAudioBottomSheet(
        categoryKey: categoryKey,
        categoryName: categoryName,
      ),
    );
  }
}
