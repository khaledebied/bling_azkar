import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../widgets/category_card.dart';
import '../widgets/category_audio_bottom_sheet.dart';
import '../widgets/floating_playlist_player.dart';
import '../../data/services/playlist_service.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  final List<String> categories;
  final Map<String, String> categoryMap;

  const CategoriesListScreen({
    super.key,
    required this.categories,
    required this.categoryMap,
  });

  @override
  ConsumerState<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> {
  final _playlistService = PlaylistService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _playlistService.initialize();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<String> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return widget.categories;
    }
    return widget.categories.where((categoryKey) {
      final categoryName = (widget.categoryMap[categoryKey] ?? categoryKey).toLowerCase();
      return categoryName.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final isDarkMode = context.isDarkMode;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDarkMode
            ? const Color(0xFF0F1419)
            : const Color(0xFFF5F5F5),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: isDarkMode
                      ? const Color(0xFF0F1419)
                      : const Color(0xFFF5F5F5),
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
                        color: context.textPrimary,
                        size: 16,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    l10n.categories,
                    style: AppTheme.titleLarge.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(80),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _buildSearchBar(isDarkMode, isArabic),
                    ),
                  ),
                ),
                if (_filteredCategories.isEmpty && _searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isArabic ? 'لا توجد نتائج' : 'No results found',
                            style: AppTheme.titleMedium.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isArabic
                                ? 'جرب البحث بكلمات مختلفة'
                                : 'Try searching with different words',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0, // Square cards for better grid layout
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final categoryKey = _filteredCategories[index];
                          final categoryName = widget.categoryMap[categoryKey] ?? categoryKey;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 200 + (index * 30)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: child,
                              ),
                            );
                          },
                          child: CategoryCard(
                            title: categoryName,
                            titleAr: categoryName,
                            heroTag: 'category_grid_$categoryKey',
                            onTap: () {
                              _showCategoryAudioSheet(
                                context,
                                categoryKey,
                                categoryName,
                              );
                            },
                          ),
                        );
                      },
                      childCount: _filteredCategories.length,
                    ),
                  ),
                  ),
                // Add bottom padding for floating player
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
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
    );
  }

  Widget _buildSearchBar(bool isDarkMode, bool isArabic) {
    final isSearching = _searchQuery.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: isSearching
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.1),
                  AppTheme.primaryTeal.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isSearching ? null : (isDarkMode ? context.cardColor : Colors.white),
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
        decoration: InputDecoration(
          hintText: isArabic ? 'ابحث عن الفئات...' : 'Search categories...',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.grey.shade400,
            fontSize: 15,
          ),
          prefixIcon: isArabic ? null : Icon(
            Icons.search_rounded,
            color: isSearching
                ? AppTheme.primaryGreen
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.grey.shade600),
            size: 22,
          ),
          suffixIcon: isArabic
              ? Icon(
                  Icons.search_rounded,
                  color: isSearching
                      ? AppTheme.primaryGreen
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.grey.shade600),
                  size: 22,
                )
              : (isSearching
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
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
    );
  }

  void _showCategoryAudioSheet(
    BuildContext context,
    String categoryKey,
    String categoryName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => CategoryAudioBottomSheet(
        categoryKey: categoryKey,
        categoryName: categoryName,
      ),
    );
  }
}

