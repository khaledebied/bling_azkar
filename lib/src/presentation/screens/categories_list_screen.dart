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

  @override
  void initState() {
    super.initState();
    _playlistService.initialize();
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
                ),
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
                        final categoryKey = widget.categories[index];
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
                      childCount: widget.categories.length,
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

