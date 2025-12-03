import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/theme.dart';
import '../widgets/category_card.dart';
import '../widgets/floating_playlist_player.dart';
import '../widgets/category_audio_bottom_sheet.dart';
import '../providers/search_providers.dart';
import '../providers/azkar_providers.dart';
import '../../data/services/playlist_service.dart';
import '../widgets/zikr_list_item.dart';
import 'zikr_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final _playlistService = PlaylistService();
  late AnimationController _pageChangeController;

  @override
  void initState() {
    super.initState();
    _playlistService.initialize();
    _pageChangeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageChangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = ref.watch(isSearchingProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(ref),
              if (!isSearching) ...[
                _buildWelcomeBanner(),
                _buildCategoriesGridSection(ref),
                _buildPaginationControls(ref),
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

  Widget _buildCategoriesGridSection(WidgetRef ref) {
    final paginatedCategoriesAsync = ref.watch(paginatedCategoriesProvider);
    final totalPagesAsync = ref.watch(totalPagesProvider);

    return paginatedCategoriesAsync.when(
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
                  'Error loading categories',
                  style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (paginatedCategories) {
        return totalPagesAsync.when(
          loading: () => _buildShimmerLoading(),
          error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (totalPages) {
            final currentPage = ref.watch(currentPageProvider);
            
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Page ${currentPage + 1} of $totalPages',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(currentPage),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
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
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: paginatedCategories.length,
                        itemBuilder: (context, index) {
                          final entry = paginatedCategories[index];
                          final categoryKey = entry.key;
                          final categoryName = entry.value;

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 200 + (index * 50)),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: CategoryCard(
                              title: categoryName,
                              titleAr: categoryName,
                              heroTag: 'category_$categoryKey',
                              onTap: () => _showCategoryBottomSheet(context, categoryKey, categoryName),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(WidgetRef ref) {
    final hasNextAsync = ref.watch(hasNextPageProvider);
    final hasPrevious = ref.watch(hasPreviousPageProvider);

    return hasNextAsync.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (hasNext) {
        if (!hasNext && !hasPrevious) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hasPrevious ? 1.0 : 0.3,
                    child: ElevatedButton.icon(
                      onPressed: hasPrevious
                          ? () {
                              _pageChangeController.forward(from: 0);
                              ref.read(currentPageProvider.notifier).state--;
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: hasPrevious ? 4 : 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Next button
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hasNext ? 1.0 : 0.3,
                    child: ElevatedButton.icon(
                      onPressed: hasNext
                          ? () {
                              _pageChangeController.forward(from: 0);
                              ref.read(currentPageProvider.notifier).state++;
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: hasNext ? 4 : 0,
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

  Widget _buildSearchResults(WidgetRef ref) {
    final azkarAsync = ref.watch(searchedAzkarProvider);

    return azkarAsync.when(
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: List.generate(
                5,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
                      'No azkar found',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.textSecondary,
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
