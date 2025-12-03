import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../domain/models/tasbih_type.dart';

/// Celebration dialog shown when Tasbih session completes
class TasbihCelebrationDialog extends StatefulWidget {
  final TasbihType tasbihType;
  final int count;
  final VoidCallback onRestart;
  final VoidCallback onDone;

  const TasbihCelebrationDialog({
    super.key,
    required this.tasbihType,
    required this.count,
    required this.onRestart,
    required this.onDone,
  });

  @override
  State<TasbihCelebrationDialog> createState() => _TasbihCelebrationDialogState();
}

class _TasbihCelebrationDialogState extends State<TasbihCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    
    return Material(
      type: MaterialType.transparency,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: widget.tasbihType.color.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie animation or fallback
                  SizedBox(
                    height: 120,
                    child: _buildCelebrationAnimation(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mabruk title
                  Container(
                    padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.tasbihType.color.withValues(alpha: 0.1),
                        widget.tasbihType.color.withValues(alpha: 0.05),
                      ],
                    ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: widget.tasbihType.color,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isArabic ? 'مبروك!' : 'Mabruk!',
                          style: AppTheme.headlineMedium.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic ? 'جلسة مكتملة' : 'Session Complete',
                          style: AppTheme.titleMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Dhikr text
                  Container(
                    padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.tasbihType.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                    child: Column(
                      children: [
                        Text(
                          widget.tasbihType.dhikrText,
                          style: AppTheme.arabicLarge.copyWith(
                            color: widget.tasbihType.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.count}×',
                          style: AppTheme.headlineLarge.copyWith(
                            color: widget.tasbihType.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 42,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Benefit
                  Container(
                    padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isArabic ? widget.tasbihType.benefitAr : widget.tasbihType.benefitEn,
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.textPrimary,
                            ),
                            textAlign: isArabic ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Message
                  Text(
                    isArabic 
                        ? 'تقبل الله منا ومنك'
                        : 'May Allah accept your dhikr',
                    style: AppTheme.bodyLarge.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onDone,
                          icon: const Icon(Icons.check),
                          label: Text(isArabic ? 'تم' : 'Done'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          side: BorderSide(
                            color: context.textSecondary.withValues(alpha: 0.3),
                          ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: widget.onRestart,
                          icon: const Icon(Icons.refresh),
                          label: Text(isArabic ? 'إعادة' : 'Restart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.tasbihType.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCelebrationAnimation() {
    // Try to load Lottie animation, fallback to custom animation
    try {
      return Lottie.asset(
        'assets/lottie/celebration.json',
        repeat: true,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAnimation();
        },
      );
    } catch (e) {
      return _buildFallbackAnimation();
    }
  }

  Widget _buildFallbackAnimation() {
    // Beautiful fallback animation without Lottie
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing circles
            ...List.generate(3, (index) {
              final delay = index * 0.2;
              final animValue = ((value - delay) % 1.0).clamp(0.0, 1.0);
              return Container(
                width: 80 + (animValue * 60),
                height: 80 + (animValue * 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                  color: widget.tasbihType.color.withValues(
                    alpha: 0.3 * (1 - animValue),
                  ),
                    width: 3,
                  ),
                ),
              );
            }),
            
            // Center icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                colors: [
                  widget.tasbihType.color,
                  widget.tasbihType.color.withValues(alpha: 0.7),
                ],
                ),
                boxShadow: [
                BoxShadow(
                  color: widget.tasbihType.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                ],
              ),
              child: Transform.rotate(
                angle: value * 2 * 3.14159,
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

