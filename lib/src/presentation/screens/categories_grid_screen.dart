import 'package:flutter/material.dart';
import '../../data/repositories/azkar_repository.dart';
import '../../data/services/playlist_service.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/page_transitions.dart';
import '../widgets/category_card.dart';
import '../widgets/category_audio_bottom_sheet.dart';
import '../widgets/floating_playlist_player.dart';

class CategoriesGridScreen extends StatefulWidget {
  final List<String> categories;
  final Map<String, String> categoryMap;

  const CategoriesGridScreen({
    super.key,
    required this.categories,
    required this.categoryMap,
  });

  @override
  State<CategoriesGridScreen> createState() => _CategoriesGridScreenState();
}

class _CategoriesGridScreenState extends State<CategoriesGridScreen> {
  final _playlistService = PlaylistService();
  final _azkarRepo = AzkarRepository();

  @override
  void initState() {
    super.initState();
    _playlistService.initialize();
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final crossAxisCount = _getCrossAxisCount(context);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:  Icon(
                        Icons.arrow_back,
                        color: context.textPrimary,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    l10n.categories,
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final categoryKey = widget.categories[index];
                        final categoryNameAr = widget.categoryMap[categoryKey] ?? categoryKey;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.9 + (0.1 * value),
                                child: child,
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'category_$categoryKey',
                            child: Material(
                              color: Colors.transparent,
                              child: CategoryCard(
                                title: categoryNameAr,
                                titleAr: categoryNameAr,
                                onTap: () {
                                  _showCategoryAudioSheet(
                                    context,
                                    categoryKey,
                                    categoryNameAr,
                                  );
                                },
                              ),
                            ),
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StreamBuilder<PlaylistState>(
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
