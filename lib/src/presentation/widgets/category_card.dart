import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class CategoryCard extends StatefulWidget {
  final String title;
  final String titleAr;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.titleAr,
    required this.onTap,
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

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    
    // Morning/Evening categories
    if (lowerName.contains('صباح') || lowerName.contains('صباح')) {
      return Icons.wb_sunny;
    }
    if (lowerName.contains('مساء') || lowerName.contains('مساء')) {
      return Icons.nightlight_round;
    }
    
    // Sleep categories
    if (lowerName.contains('نوم') || lowerName.contains('نوم')) {
      return Icons.bedtime;
    }
    if (lowerName.contains('استيقاظ') || lowerName.contains('استيقاظ')) {
      return Icons.wb_twilight;
    }
    
    // Prayer categories
    if (lowerName.contains('صلاة') || lowerName.contains('صلاة') || 
        lowerName.contains('ركوع') || lowerName.contains('سجود') ||
        lowerName.contains('تشهد')) {
      return Icons.mosque;
    }
    if (lowerName.contains('آذان') || lowerName.contains('آذان')) {
      return Icons.volume_up;
    }
    
    // Food categories
    if (lowerName.contains('طعام') || lowerName.contains('طعام') ||
        lowerName.contains('أكل') || lowerName.contains('أكل')) {
      return Icons.restaurant;
    }
    if (lowerName.contains('صائم') || lowerName.contains('صائم') ||
        lowerName.contains('إفطار') || lowerName.contains('إفطار')) {
      return Icons.fastfood;
    }
    
    // Travel categories
    if (lowerName.contains('سفر') || lowerName.contains('سفر') ||
        lowerName.contains('ركوب') || lowerName.contains('ركوب')) {
      return Icons.flight;
    }
    if (lowerName.contains('سوق') || lowerName.contains('سوق') ||
        lowerName.contains('قرية') || lowerName.contains('قرية')) {
      return Icons.location_city;
    }
    
    // Home categories
    if (lowerName.contains('منزل') || lowerName.contains('منزل') ||
        lowerName.contains('بيت') || lowerName.contains('بيت')) {
      return Icons.home;
    }
    if (lowerName.contains('مسجد') || lowerName.contains('مسجد')) {
      return Icons.account_balance;
    }
    
    // Health categories
    if (lowerName.contains('مريض') || lowerName.contains('مريض') ||
        lowerName.contains('وجع') || lowerName.contains('وجع')) {
      return Icons.medical_services;
    }
    if (lowerName.contains('عين') || lowerName.contains('عين')) {
      return Icons.remove_red_eye;
    }
    
    // Weather categories
    if (lowerName.contains('مطر') || lowerName.contains('مطر') ||
        lowerName.contains('ريح') || lowerName.contains('ريح') ||
        lowerName.contains('رعد') || lowerName.contains('رعد')) {
      return Icons.wb_cloudy;
    }
    
    // Clothing categories
    if (lowerName.contains('ثوب') || lowerName.contains('ثوب') ||
        lowerName.contains('لبس') || lowerName.contains('لبس')) {
      return Icons.checkroom;
    }
    
    // Marriage categories
    if (lowerName.contains('زواج') || lowerName.contains('زواج') ||
        lowerName.contains('متزوج') || lowerName.contains('متزوج')) {
      return Icons.favorite;
    }
    
    // Death/Funeral categories
    if (lowerName.contains('ميت') || lowerName.contains('ميت') ||
        lowerName.contains('قبر') || lowerName.contains('قبر') ||
        lowerName.contains('مصيبة') || lowerName.contains('مصيبة')) {
      return Icons.celebration;
    }
    
    // General supplications
    if (lowerName.contains('دعاء') || lowerName.contains('دعاء')) {
      return Icons.mosque;
    }
    
    // Default icons based on keywords
    if (lowerName.contains('ذكر') || lowerName.contains('ذكر')) {
      return Icons.auto_awesome;
    }
    if (lowerName.contains('استغفار') || lowerName.contains('استغفار') ||
        lowerName.contains('توبة') || lowerName.contains('توبة')) {
      return Icons.self_improvement;
    }
    
    // Default icon
    return Icons.menu_book;
  }

  LinearGradient _getCategoryGradient(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    final hash = categoryName.hashCode;
    
    // Create consistent gradients based on category - More attractive colors
    final gradients = [
      // Vibrant Emerald gradients
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10B981), Color(0xFF059669)],
      ),
      // Bright Teal/Cyan gradients
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
      ),
      // Rich Blue gradients
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      ),
      // Warm Amber/Gold gradients
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ),
      // Purple gradients
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      ),
      // Rose/Pink gradients
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
      ),
      // Indigo gradients
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
      ),
      // Emerald to Teal gradients
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
      ),
    ];
    
    // Use hash to consistently pick a gradient for each category
    return gradients[hash.abs() % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getCategoryIcon(widget.titleAr);
    final gradient = _getCategoryGradient(widget.titleAr);

    return GestureDetector(
      onTapDown: (_) {
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
          width: 170,
          height: 140, // Fixed height to match ListView height
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  left: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
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
                      // Icon container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 28,
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
                                  color: Colors.white,
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
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 10,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Explore',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
