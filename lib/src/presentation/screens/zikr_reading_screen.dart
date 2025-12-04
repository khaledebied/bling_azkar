import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';

class ZikrReadingScreen extends StatefulWidget {
  final List<Zikr> azkar;
  final String categoryName;
  final int initialIndex;

  const ZikrReadingScreen({
    super.key,
    required this.azkar,
    required this.categoryName,
    this.initialIndex = 0,
  });

  @override
  State<ZikrReadingScreen> createState() => _ZikrReadingScreenState();
}

class _ZikrReadingScreenState extends State<ZikrReadingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _counterAnimationController;
  late Animation<double> _counterScaleAnimation;
  late Animation<double> _counterPulseAnimation;
  
  final Map<String, int> _counts = {};
  int _currentPageIndex = 0;
  bool _isAutoAdvancing = false;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Initialize counts for all azkar
    for (var zikr in widget.azkar) {
      _counts[zikr.id] = 0;
    }
    
    _counterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _counterScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _counterPulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? _currentPageIndex;
      if (newIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _counterAnimationController.dispose();
    super.dispose();
  }

  void _incrementCount(String zikrId, int targetCount) {
    setState(() {
      final currentCount = _counts[zikrId] ?? 0;
      if (currentCount < targetCount) {
        _counts[zikrId] = currentCount + 1;
        
        // Animate counter
        _counterAnimationController.forward().then((_) {
          _counterAnimationController.reverse();
        });
        
        // Auto-advance if count is reached
        if (_counts[zikrId] == targetCount && !_isAutoAdvancing) {
          _autoAdvanceToNext();
        }
      }
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _resetCount(String zikrId) {
    setState(() {
      _counts[zikrId] = 0;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _autoAdvanceToNext() async {
    if (_isAutoAdvancing || _currentPageIndex >= widget.azkar.length - 1) {
      return;
    }
    
    setState(() {
      _isAutoAdvancing = true;
    });
    
    // Wait a bit before auto-advancing
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted && _currentPageIndex < widget.azkar.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    
    if (mounted) {
      setState(() {
        _isAutoAdvancing = false;
      });
    }
  }

  Widget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isDarkMode = context.isDarkMode;
    
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          DirectionIcons.backArrow(context),
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        children: [
          Text(
            widget.categoryName,
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_currentPageIndex + 1} / ${widget.azkar.length}',
            style: AppTheme.caption.copyWith(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black54,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildZikrPage(Zikr zikr, int index) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isDarkMode = context.isDarkMode;
    final isArabic = l10n.isArabic;
    final currentCount = _counts[zikr.id] ?? 0;
    final targetCount = zikr.defaultCount;
    final isCompleted = currentCount >= targetCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Zikr Text Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withValues(alpha: 0.15),
                        AppTheme.primaryTeal.withValues(alpha: 0.15),
                      ],
                    )
                  : null,
              color: isCompleted ? null : (isDarkMode 
                  ? const Color(0xFF2A2A2A)
                  : Colors.grey.shade50),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCompleted
                    ? AppTheme.primaryGreen.withValues(alpha: 0.5)
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200),
                width: isCompleted ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  zikr.title.ar,
                  style: AppTheme.arabicMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? AppTheme.primaryGreen
                        : context.textPrimary,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 24),
                
                // Zikr Text
                Text(
                  zikr.text,
                  style: AppTheme.arabicLarge.copyWith(
                    fontSize: 24,
                    height: 2.0,
                    color: context.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Translation if available
                if (zikr.translation?.en.isNotEmpty ?? false) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      zikr.translation!.en,
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.textSecondary,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Counter Button
          Center(
            child: GestureDetector(
              onTap: () => _incrementCount(zikr.id, targetCount),
              onLongPress: () => _resetCount(zikr.id),
              child: AnimatedBuilder(
                animation: _counterAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _counterScaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? AppTheme.primaryGradient
                            : LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen.withValues(alpha: 0.8),
                                  AppTheme.primaryTeal.withValues(alpha: 0.8),
                                ],
                              ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted 
                                    ? AppTheme.primaryGreen 
                                    : AppTheme.primaryTeal)
                                .withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              '$currentCount',
                              key: ValueKey(currentCount),
                              style: AppTheme.headlineLarge.copyWith(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '/ $targetCount',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Counter Instructions
          Center(
            child: Text(
              isCompleted
                  ? '✅ ${l10n.completed}'
                  : '${l10n.tapToCount} • ${l10n.longPressToReset}',
              style: AppTheme.caption.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 20,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: currentCount / targetCount,
                    backgroundColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${((currentCount / targetCount) * 100).toInt()}%',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: _buildAppBar(context),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.azkar.length,
        itemBuilder: (context, index) {
          return _buildZikrPage(widget.azkar[index], index);
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 8,
          left: 16,
          right: 16,
          top: 8,
        ),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.black
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  DirectionIcons.backArrow(context),
                  color: _currentPageIndex == 0
                      ? Colors.grey
                      : AppTheme.primaryGreen,
                ),
                onPressed: _currentPageIndex == 0
                    ? null
                    : () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
              ),
              Text(
                '${_currentPageIndex + 1} / ${widget.azkar.length}',
                style: AppTheme.titleMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(
                  DirectionIcons.forwardArrow(context),
                  color: _currentPageIndex >= widget.azkar.length - 1
                      ? Colors.grey
                      : AppTheme.primaryGreen,
                ),
                onPressed: _currentPageIndex >= widget.azkar.length - 1
                    ? null
                    : () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

