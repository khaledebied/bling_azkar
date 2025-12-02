import 'package:flutter/material.dart';
import '../../data/repositories/azkar_repository.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import '../../utils/page_transitions.dart';
import '../widgets/category_card.dart';
import '../widgets/category_audio_bottom_sheet.dart';

class CategoriesGridScreen extends StatelessWidget {
  final List<String> categories;
  final Map<String, String> categoryMap;

  const CategoriesGridScreen({
    super.key,
    required this.categories,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final azkarRepo = AzkarRepository();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  l10n.categories,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.category,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${categories.length} Categories',
                              style: AppTheme.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final categoryKey = categories[index];
                    final categoryNameAr = categoryMap[categoryKey] ?? categoryKey;

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
                    );
                  },
                  childCount: categories.length,
                ),
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

