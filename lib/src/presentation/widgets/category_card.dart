import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';

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
            // White to gray gradient
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
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: isDarkMode ? 20 : 15,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: isDarkMode ? 10 : 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular emoji container in the center
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
                      // Category title below the icon
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
