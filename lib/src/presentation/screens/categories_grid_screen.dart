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
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppTheme.textPrimary,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
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

