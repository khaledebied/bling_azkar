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

  /// Get consistent, elegant gradient for all category cards
  /// Using a beautiful emerald-to-teal gradient that works for all categories
  LinearGradient _getCategoryGradient(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Elegant gradient for light mode - consistent across all cards
    if (!isDarkMode) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF059669), // Deep emerald
          Color(0xFF10B981), // Vibrant emerald
          Color(0xFF14B8A6), // Bright teal
        ],
        stops: [0.0, 0.5, 1.0],
      );
    }
    
    // Elegant gradient for dark mode - subtle and sophisticated
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF059669).withValues(alpha: 0.25), // Deep emerald
        const Color(0xFF10B981).withValues(alpha: 0.2), // Vibrant emerald
        const Color(0xFF14B8A6).withValues(alpha: 0.15), // Bright teal
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final emoji = _getCategoryEmoji(widget.titleAr);
    final gradient = _getCategoryGradient(context);
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
          height: 140, // Fixed height to match ListView height
          margin: const EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
            // White background in light mode, gradient in dark mode
            color: isDarkMode ? null : Colors.white,
            gradient: isDarkMode ? gradient : null,
            borderRadius: BorderRadius.circular(20),
            border: isDarkMode
                ? Border.all(
                    color: gradient.colors[1].withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: isDarkMode ? 15 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Decorative elements - only in dark mode
                if (isDarkMode) ...[
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],
                // Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji container with elegant design
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // In light mode: use gradient background, in dark mode: subtle white
                          gradient: isDarkMode
                              ? null
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    gradient.colors[0].withValues(alpha: 0.1),
                                    gradient.colors[1].withValues(alpha: 0.15),
                                  ],
                                ),
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.15)
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.2)
                                : gradient.colors[1].withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : gradient.colors[1].withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(
                            fontSize: 36,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text content - flexible to prevent overflow
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                widget.titleAr,
                                style: AppTheme.arabicSmall.copyWith(
                                  color: isDarkMode
                                      ? Theme.of(context).textTheme.bodyLarge?.color
                                      : AppTheme.textPrimary, // Use primary text color in light mode
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                // In light mode: use gradient, in dark mode: subtle white
                                gradient: isDarkMode
                                    ? null
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          gradient.colors[0],
                                          gradient.colors[1],
                                        ],
                                      ),
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                                border: isDarkMode
                                    ? Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.explore,
                                    style: AppTheme.bodySmall.copyWith(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.white,
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
