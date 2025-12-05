import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';
import '../widgets/hisn_el_muslim_grid_item.dart';
import '../providers/hisn_el_muslim_providers.dart';
import '../providers/search_providers.dart';
import 'zikr_detail_screen.dart';

class HisnElMuslimScreen extends ConsumerStatefulWidget {
  const HisnElMuslimScreen({super.key});

  @override
  ConsumerState<HisnElMuslimScreen> createState() => _HisnElMuslimScreenState();
}

class _HisnElMuslimScreenState extends ConsumerState<HisnElMuslimScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
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
        backgroundColor: isDarkMode
            ? const Color(0xFF0F1419)
            : const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: isDarkMode
              ? const Color(0xFF1C2128)
              : Colors.white,
          elevation: 0,
          title: Text(
            isArabic ? 'حصن المسلم' : 'Hisn el Muslim',
            style: AppTheme.titleMedium.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              DirectionIcons.backArrow(context),
              color: context.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSearchBar(isDarkMode, isArabic),
              ),
              // Grid View
              Expanded(
                child: _buildGridView(isDarkMode, isSearching),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode, bool isArabic) {
    final isSearching = ref.watch(isSearchingProvider);

    return AnimatedContainer(
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
          hintText: isArabic ? 'ابحث في حصن المسلم...' : 'Search Hisn el Muslim...',
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
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(isSearchingProvider.notifier).state = false;
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

  Widget _buildGridView(bool isDarkMode, bool isSearching) {
    final azkarAsync = isSearching
        ? ref.watch(searchedHisnElMuslimAzkarProvider)
        : ref.watch(allHisnElMuslimAzkarProvider);

    return azkarAsync.when(
      loading: () => _buildShimmerLoading(isDarkMode),
      error: (error, stack) => _buildErrorWidget(error, isDarkMode),
      data: (azkar) {
        if (azkar.isEmpty) {
          return _buildEmptyWidget(isDarkMode);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75, // Adjust based on content
          ),
          itemCount: azkar.length,
          itemBuilder: (context, index) {
            final zikr = azkar[index];
            final isFavorite = ref.watch(isHisnElMuslimFavoriteProvider(zikr.id));

            return HisnElMuslimGridItem(
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
                  final toggleFavorite = ref.read(toggleHisnElMuslimFavoriteProvider);
                  await toggleFavorite(zikr.id);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade300,
        highlightColor: isDarkMode
            ? Colors.grey.shade700
            : Colors.grey.shade100,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1C2128) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error, bool isDarkMode) {
    return Center(
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
              'Error loading Hisn el Muslim',
              style: AppTheme.titleMedium.copyWith(
                color: isDarkMode ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.caption.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No azkar found',
              style: AppTheme.titleMedium.copyWith(
                color: isDarkMode ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

