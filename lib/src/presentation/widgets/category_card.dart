import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';

class CategoryCard extends StatefulWidget {
  final String title;
  final String titleAr;
  final VoidCallback onTap;
  final String? heroTag;

  const CategoryCard({
    super.key,
    required this.title,
    required this.titleAr,
    required this.onTap,
    this.heroTag,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
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
  /// All emojis are copied directly from the emojidb.org/muslim-emojis database
  String _getCategoryEmoji(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    
    // Morning categories - using emojis from the database
    if (lowerName.contains('صباح')) {
      return '☀️'; // Sun from Muslim emojis database
    }
    
    // Evening categories - using moon/crescent from the database
    if (lowerName.contains('مساء')) {
      return '🌙'; // Moon from Muslim emojis database
    }
    
    // Sleep categories - using moon from the database
    if (lowerName.contains('نوم')) {
      return '🌙'; // Moon for sleep from Muslim emojis database
    }
    if (lowerName.contains('استيقاظ')) {
      return '☀️'; // Sun for waking up from Muslim emojis database
    }
    
    // Prayer categories - using praying hands and mosque from the database
    if (lowerName.contains('صلاة') || 
        lowerName.contains('ركوع') || 
        lowerName.contains('سجود') ||
        lowerName.contains('تشهد') || 
        lowerName.contains('استفتاح')) {
      return '🤲'; // Praying hands from Muslim emojis database
    }
    if (lowerName.contains('آذان')) {
      return '🕌'; // Mosque for adhan from Muslim emojis database
    }
    if (lowerName.contains('مسجد')) {
      return '🕌'; // Mosque from Muslim emojis database
    }
    
    // Wudu/Bathroom categories
    if (lowerName.contains('وضوء') || lowerName.contains('خلاء')) {
      return '🤲'; // Praying hands from Muslim emojis database
    }
    
    // Home categories
    if (lowerName.contains('منزل') || lowerName.contains('بيت')) {
      return '🕌'; // Mosque from Muslim emojis database
    }
    
    // Food/Fasting categories
    if (lowerName.contains('طعام') || lowerName.contains('أكل')) {
      return '🌙'; // Moon from Muslim emojis database
    }
    if (lowerName.contains('صائم') || lowerName.contains('إفطار')) {
      return '🌙'; // Moon for fasting from Muslim emojis database
    }
    
    // Travel categories - using Kaaba from the database
    if (lowerName.contains('سفر') || lowerName.contains('ركوب')) {
      return '🕋'; // Kaaba from Muslim emojis database
    }
    if (lowerName.contains('سوق') || lowerName.contains('قرية')) {
      return '🕌'; // Mosque from Muslim emojis database
    }
    
    // Health categories
    if (lowerName.contains('مريض') || lowerName.contains('وجع')) {
      return '🤲'; // Praying hands for healing from Muslim emojis database
    }
    if (lowerName.contains('عين')) {
      return '🤲'; // Praying hands from Muslim emojis database
    }
    
    // Weather categories
    if (lowerName.contains('مطر') || 
        lowerName.contains('ريح') || 
        lowerName.contains('رعد')) {
      return '🌙'; // Moon from Muslim emojis database
    }
    
    // Clothing categories - using headscarf from the database
    if (lowerName.contains('ثوب') || lowerName.contains('لبس')) {
      return '🧕'; // Headscarf from Muslim emojis database
    }
    
    // Marriage categories
    if (lowerName.contains('زواج') || lowerName.contains('متزوج')) {
      return '🤲'; // Praying hands from Muslim emojis database
    }
    
    // General supplications and dhikr - using prayer beads from the database
    if (lowerName.contains('دعاء')) {
      return '🤲'; // Praying hands for dua from Muslim emojis database
    }
    if (lowerName.contains('ذكر')) {
      return '📿'; // Prayer beads for dhikr from Muslim emojis database
    }
    if (lowerName.contains('استغفار') || lowerName.contains('توبة')) {
      return '🤲'; // Praying hands for repentance from Muslim emojis database
    }
    
    // Default emoji - prayer beads from Muslim emojis database
    return '📿'; // Prayer beads from Muslim emojis database
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
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
      child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            // Gradient background matching tab header
            gradient: isDarkMode
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.3),
                      AppTheme.primaryTeal.withValues(alpha: 0.25),
                    ],
                  )
                : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
            border: isDarkMode
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  )
                : null,
          boxShadow: [
            BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : AppTheme.primaryGreen.withValues(alpha: 0.2),
                blurRadius: isDarkMode ? 15 : 12,
              offset: const Offset(0, 4),
                spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Circular emoji container on the left (like audio icon in zikr item)
              Container(
                  width: 50,
                  height: 50,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isDarkMode ? 0.2 : 0.3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Text content on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category title
                      Text(
                        widget.titleAr,
                        style: AppTheme.arabicMedium.copyWith(
                          fontSize: 15,
                  color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Explore button badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                              l10n.explore,
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ],
              ),
          ),
        ),
      ),
    );

    // Wrap in Hero if heroTag is provided
    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: cardWidget,
      );
    }
    
    return cardWidget;
  }
}
