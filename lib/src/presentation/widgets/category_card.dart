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
  bool _isPressed = false;

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

  /// Get icon for category - supports both Material icons and custom assets
  /// For Flaticon icons, place them in assets/icons/ and reference by name
  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    
    // Morning/Evening categories - use sun/moon icons
    if (lowerName.contains('صباح') || lowerName.contains('صباح')) {
      return Icons.wb_sunny_outlined;
    }
    if (lowerName.contains('مساء') || lowerName.contains('مساء')) {
      return Icons.nightlight_round;
    }
    
    // Sleep categories - use moon/bed icons
    if (lowerName.contains('نوم') || lowerName.contains('نوم')) {
      return Icons.bedtime_outlined;
    }
    if (lowerName.contains('استيقاظ') || lowerName.contains('استيقاظ')) {
      return Icons.wb_twilight;
    }
    
    // Prayer categories - use mosque/prayer icons
    if (lowerName.contains('صلاة') || lowerName.contains('صلاة') || 
        lowerName.contains('ركوع') || lowerName.contains('سجود') ||
        lowerName.contains('تشهد') || lowerName.contains('استفتاح')) {
      return Icons.mosque;
    }
    if (lowerName.contains('آذان') || lowerName.contains('آذان')) {
      return Icons.volume_up_outlined;
    }
    if (lowerName.contains('مسجد') || lowerName.contains('مسجد')) {
      return Icons.account_balance;
    }
    
    // Wudu/Bathroom categories
    if (lowerName.contains('وضوء') || lowerName.contains('وضوء') ||
        lowerName.contains('خلاء') || lowerName.contains('خلاء')) {
      return Icons.water_drop_outlined;
    }
    
    // Home categories
    if (lowerName.contains('منزل') || lowerName.contains('منزل') ||
        lowerName.contains('بيت') || lowerName.contains('بيت')) {
      return Icons.home_outlined;
    }
    
    // Food/Fasting categories
    if (lowerName.contains('طعام') || lowerName.contains('طعام') ||
        lowerName.contains('أكل') || lowerName.contains('أكل')) {
      return Icons.restaurant_outlined;
    }
    if (lowerName.contains('صائم') || lowerName.contains('صائم') ||
        lowerName.contains('إفطار') || lowerName.contains('إفطار')) {
      return Icons.fastfood_outlined;
    }
    
    // Travel categories
    if (lowerName.contains('سفر') || lowerName.contains('سفر') ||
        lowerName.contains('ركوب') || lowerName.contains('ركوب')) {
      return Icons.flight_outlined;
    }
    if (lowerName.contains('سوق') || lowerName.contains('سوق') ||
        lowerName.contains('قرية') || lowerName.contains('قرية')) {
      return Icons.location_city_outlined;
    }
    
    // Health categories
    if (lowerName.contains('مريض') || lowerName.contains('مريض') ||
        lowerName.contains('وجع') || lowerName.contains('وجع')) {
      return Icons.medical_services_outlined;
    }
    if (lowerName.contains('عين') || lowerName.contains('عين')) {
      return Icons.remove_red_eye_outlined;
    }
    
    // Weather categories
    if (lowerName.contains('مطر') || lowerName.contains('مطر') ||
        lowerName.contains('ريح') || lowerName.contains('ريح') ||
        lowerName.contains('رعد') || lowerName.contains('رعد')) {
      return Icons.wb_cloudy_outlined;
    }
    
    // Clothing categories
    if (lowerName.contains('ثوب') || lowerName.contains('ثوب') ||
        lowerName.contains('لبس') || lowerName.contains('لبس')) {
      return Icons.checkroom_outlined;
    }
    
    // Marriage categories
    if (lowerName.contains('زواج') || lowerName.contains('زواج') ||
        lowerName.contains('متزوج') || lowerName.contains('متزوج')) {
      return Icons.favorite_outline;
    }
    
    // General supplications and dhikr
    if (lowerName.contains('دعاء') || lowerName.contains('دعاء')) {
      return Icons.auto_awesome_outlined;
    }
    if (lowerName.contains('ذكر') || lowerName.contains('ذكر')) {
      return Icons.auto_awesome_outlined;
    }
    if (lowerName.contains('استغفار') || lowerName.contains('استغفار') ||
        lowerName.contains('توبة') || lowerName.contains('توبة')) {
      return Icons.self_improvement_outlined;
    }
    
    // Default icon - book/prayer beads
    return Icons.menu_book_outlined;
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
    final icon = _getCategoryIcon(widget.titleAr);
    final gradient = _getCategoryGradient(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardWidget = GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
        child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 140, // Fixed height to match ListView height
          margin: const EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
            gradient: gradient, // Always use gradient for consistency
            borderRadius: BorderRadius.circular(20),
            border: isDarkMode
                ? Border.all(
                    color: gradient.colors[1].withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              if (isDarkMode)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                )
              else ...[
                BoxShadow(
                  color: gradient.colors[1].withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Elegant decorative elements
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDarkMode ? Colors.white : Colors.white)
                          .withValues(alpha: isDarkMode ? 0.05 : 0.15),
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
                      color: (isDarkMode ? Colors.white : Colors.white)
                          .withValues(alpha: isDarkMode ? 0.05 : 0.12),
                    ),
                  ),
                ),
                // Subtle pattern overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.transparent,
                          (isDarkMode ? Colors.black : Colors.white)
                              .withValues(alpha: 0.03),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon container with elegant design
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (isDarkMode ? Colors.white : Colors.white)
                              .withValues(alpha: isDarkMode ? 0.15 : 0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isDarkMode ? Colors.white : Colors.white)
                                .withValues(alpha: isDarkMode ? 0.2 : 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: isDarkMode
                              ? Colors.white
                              : gradient.colors[1], // Use middle gradient color
                          size: 32,
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
                                      : Colors.white,
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
                                color: (isDarkMode ? Colors.white : Colors.white)
                                    .withValues(alpha: isDarkMode ? 0.15 : 0.25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: (isDarkMode ? Colors.white : Colors.white)
                                      .withValues(alpha: isDarkMode ? 0.2 : 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.explore,
                                    style: AppTheme.bodySmall.copyWith(
                                      color: isDarkMode
                                          ? Colors.white
                                          : gradient.colors[1],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: isDarkMode
                                        ? Colors.white
                                        : gradient.colors[1],
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
