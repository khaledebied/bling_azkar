import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../providers/azkar_providers.dart';

class CategoryCard extends ConsumerStatefulWidget {
  final String categoryId;
  final String title;
  final String titleAr;
  final VoidCallback onTap;
  final String? heroTag;

  const CategoryCard({
    super.key,
    required this.categoryId,
    required this.title,
    required this.titleAr,
    required this.onTap,
    this.heroTag,
  });

  @override
  ConsumerState<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends ConsumerState<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Get emoji for category - using Muslim emojis from https://emojidb.org/muslim-emojis
  String _getCategoryEmoji(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    
    if (lowerName.contains('صباح')) return '☀️';
    if (lowerName.contains('مساء')) return '🌙';
    if (lowerName.contains('نوم')) return '🌙';
    if (lowerName.contains('استيقاظ')) return '☀️';
    if (lowerName.contains('صلاة') || 
        lowerName.contains('ركوع') || 
        lowerName.contains('سجود') ||
        lowerName.contains('تشهد') || 
        lowerName.contains('استفتاح')) return '🤲';
    if (lowerName.contains('آذان')) return '🕌';
    if (lowerName.contains('مسجد')) return '🕌';
    if (lowerName.contains('وضوء') || lowerName.contains('خلاء')) return '🤲';
    if (lowerName.contains('منزل') || lowerName.contains('بيت')) return '🕌';
    if (lowerName.contains('طعام') || lowerName.contains('أكل')) return '🌙';
    if (lowerName.contains('صائم') || lowerName.contains('إفطار')) return '🌙';
    if (lowerName.contains('سفر') || lowerName.contains('ركوب')) return '🕋';
    if (lowerName.contains('سوق') || lowerName.contains('قرية')) return '🕌';
    if (lowerName.contains('مريض') || lowerName.contains('وجع')) return '🤲';
    if (lowerName.contains('عين')) return '🤲';
    if (lowerName.contains('مطر') || lowerName.contains('ريح') || lowerName.contains('رعد')) return '🌙';
    if (lowerName.contains('ثوب') || lowerName.contains('لبس')) return '🧕';
    if (lowerName.contains('زواج') || lowerName.contains('متزوج')) return '🤲';
    if (lowerName.contains('دعاء')) return '🤲';
    if (lowerName.contains('ذكر')) return '📿';
    if (lowerName.contains('استغفار') || lowerName.contains('توبة')) return '🤲';
    
    return '📿';
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getCategoryEmoji(widget.titleAr);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardWidget = GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 100,
              ),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          Colors.grey.shade700.withValues(alpha: 0.8),
                          Colors.grey.shade800.withValues(alpha: 0.9),
                        ]
                      : [
                          Colors.white,
                          Colors.grey.shade100,
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: isDarkMode
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      )
                    : Border.all(
                        color: Colors.grey.shade300.withValues(alpha: 0.5),
                        width: 1,
                      ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isDarkMode ? 0.2 : 0.3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(
                            fontSize: 32,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.titleAr,
                      style: AppTheme.arabicMedium.copyWith(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Favorite Button
            Positioned(
              top: 8,
              right: 8,
              child: Consumer(
                builder: (context, ref, child) {
                  final isFavorite = ref.watch(isCategoryFavoriteProvider(widget.categoryId));
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(toggleCategoryFavoriteProvider)(widget.categoryId);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isDarkMode ? 0.1 : 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.red : (isDarkMode ? Colors.white70 : Colors.grey),
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

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: cardWidget,
      );
    }
    
    return cardWidget;
  }
}
