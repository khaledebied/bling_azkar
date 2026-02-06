import 'package:flutter/material.dart';
import '../../data/repositories/azkar_repository.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';
import '../widgets/category_card.dart';
import 'zikr_reading_screen.dart';

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
  final _azkarRepo = AzkarRepository();

  @override
  void initState() {
    super.initState();
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
                  child: Icon(
                    DirectionIcons.backArrow(context),
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
                      child: CategoryCard(
                        categoryId: categoryKey,
                        title: categoryNameAr,
                        titleAr: categoryNameAr,
                        onTap: () {
                          _navigateToZikrReading(
                            context,
                            categoryKey,
                            categoryNameAr,
                          );
                        },
                      ),
                    );
                  },
                  childCount: widget.categories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToZikrReading(
    BuildContext context,
    String categoryKey,
    String categoryName,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final azkar = await _azkarRepo.getAzkarByCategory(categoryKey);
      if (context.mounted) {
        Navigator.pop(context); // Remove loading indicator
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZikrReadingScreen(
              azkar: azkar,
              categoryName: categoryName,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading azkar: $e')),
        );
      }
    }
  }
}
