import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../domain/models/zikr.dart';
import '../providers/azkar_providers.dart';
import '../widgets/category_card.dart';
import '../widgets/zikr_list_item.dart';
import 'zikr_detail_screen.dart';
import 'zikr_reading_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final isDarkMode = context.isDarkMode;
    final favoritesAsync = ref.watch(favoriteAzkarProvider);
    final favoriteCategoriesAsync = ref.watch(favoriteCategoriesProvider);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            l10n.favorites,
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
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
            child: CustomScrollView(
              slivers: [
                // Favorite Categories Section
                favoriteCategoriesAsync.when(
                  skipLoadingOnReload: true,
                  data: (categories) => categories.isEmpty 
                      ? const SliverToBoxAdapter(child: SizedBox.shrink())
                      : _buildFavoriteCategoriesSection(categories),
                  loading: () => favoriteCategoriesAsync.hasValue 
                      ? (favoriteCategoriesAsync.value!.isEmpty 
                          ? const SliverToBoxAdapter(child: SizedBox.shrink())
                          : _buildFavoriteCategoriesSection(favoriteCategoriesAsync.value!))
                      : _buildShimmerLoadingSliver(),
                  error: (error, stack) => SliverToBoxAdapter(child: Text('Error: $error')),
                ),

                // Favorite Azkar Section
                favoritesAsync.when(
                  skipLoadingOnReload: true,
                  loading: () => favoritesAsync.hasValue 
                      ? _buildFavoritesList(favoritesAsync.value!) 
                      : _buildShimmerLoadingSliver(),
                  error: (error, stack) => _buildError(error),
                  data: (favorites) => _buildFavoritesList(favorites),
                ),
                
                // If both are empty
                if (favoritesAsync.hasValue && favoritesAsync.value!.isEmpty && 
                    favoriteCategoriesAsync.hasValue && favoriteCategoriesAsync.value!.isEmpty)
                  _buildEmptyState(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCategoriesSection(Map<String, String> categories) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final categoryEntries = categories.entries.toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.categories,
              style: AppTheme.titleMedium.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: categoryEntries.length,
              itemBuilder: (context, index) {
                final entry = categoryEntries[index];
                return CategoryCard(
                  categoryId: entry.key,
                  title: entry.value,
                  titleAr: entry.value,
                  heroTag: 'fav_cat_${entry.key}',
                  onTap: () => _navigateToCategoryReading(entry.key, entry.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withValues(alpha: 0.15),
                    AppTheme.primaryTeal.withValues(alpha: 0.15),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 80,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noFavoritesYet,
              style: AppTheme.titleLarge.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                l10n.addFavoritesHint,
                style: AppTheme.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<Zikr> favorites) {
    if (favorites.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withValues(alpha: 0.15),
                        AppTheme.primaryTeal.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: AppTheme.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${favorites.length} favorite azkar',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildReadAllButton(favorites, AppLocalizations.ofWithFallback(context)),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final zikr = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ZikrListItem(
                  zikr: zikr,
                  isFavorite: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ZikrDetailScreen(zikr: zikr)),
                    );
                  },
                  onFavoriteToggle: () async {
                    try {
                      await ref.read(toggleFavoriteProvider)(zikr.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReadAllButton(List<Zikr> favorites, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZikrReadingScreen(
                azkar: favorites,
                categoryName: l10n.favorites,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.readAll,
                style: AppTheme.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoadingSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: context.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Column(
            children: List.generate(3, (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 100,
              decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(16)),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return SliverToBoxAdapter(
      child: Center(child: Text('Error: $error')),
    );
  }

  Future<void> _navigateToCategoryReading(String categoryKey, String categoryName) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      final azkar = await ref.read(azkarRepositoryProvider).getAzkarByCategory(categoryKey);
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ZikrReadingScreen(azkar: azkar, categoryName: categoryName)));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
