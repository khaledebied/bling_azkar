import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
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
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _counterAnimationController;
  late Animation<double> _counterScaleAnimation;
  
  final Map<String, int> _counts = {};
  int _currentPageIndex = 0;
  bool _isAutoAdvancing = false;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    for (var zikr in widget.azkar) {
      _counts[zikr.id] = 0;
    }
    
    _counterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _counterScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _counterAnimationController,
      curve: Curves.easeInOut,
    ));
    
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
    if ((_counts[zikrId] ?? 0) >= targetCount) return;

    setState(() {
      _counts[zikrId] = (_counts[zikrId] ?? 0) + 1;
      _counterAnimationController.forward(from: 0);
      
      if (_counts[zikrId] == targetCount && !_isAutoAdvancing) {
        _autoAdvanceToNext();
      }
    });
    
    HapticFeedback.mediumImpact();
  }

  void _resetCount(String zikrId) {
    setState(() {
      _counts[zikrId] = 0;
    });
    HapticFeedback.heavyImpact();
  }

  Future<void> _autoAdvanceToNext() async {
    if (_isAutoAdvancing || _currentPageIndex >= widget.azkar.length - 1) {
      return;
    }
    
    _isAutoAdvancing = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted && _currentPageIndex < widget.azkar.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
    
    if (mounted) {
      _isAutoAdvancing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8FAF9),
      body: Stack(
        children: [
          // Background Decorative Elements
          _buildBackground(isDarkMode),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.azkar.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildZikrPage(widget.azkar[index]);
                    },
                  ),
                ),
                _buildBottomControls(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDarkMode) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: isDarkMode ? 0.05 : 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: isDarkMode ? 0.05 : 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              DirectionIcons.backArrow(context),
              color: context.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.categoryName,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPageIndex + 1} / ${widget.azkar.length}',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildZikrPage(Zikr zikr) {
    final isDarkMode = context.isDarkMode;
    final l10n = AppLocalizations.ofWithFallback(context);
    final currentCount = _counts[zikr.id] ?? 0;
    final targetCount = zikr.defaultCount;
    final isCompleted = currentCount >= targetCount;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Content Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  zikr.title.ar,
                  textAlign: TextAlign.center,
                  style: AppTheme.arabicMedium.copyWith(
                    fontSize: 18,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  zikr.text,
                  textAlign: TextAlign.center,
                  style: AppTheme.arabicLarge.copyWith(
                    fontSize: 26,
                    height: 1.8,
                    color: context.textPrimary,
                  ),
                ),
                if (zikr.translation?.en.isNotEmpty ?? false) ...[
                  const SizedBox(height: 32),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  Text(
                    zikr.translation!.en,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Elegant Counter Interaction
          GestureDetector(
            onTap: () => _incrementCount(zikr.id, targetCount),
            onLongPress: () => _resetCount(zikr.id),
            child: ScaleTransition(
              scale: _counterScaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Progress Ring
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: currentCount / targetCount,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppTheme.primaryTeal : AppTheme.primaryGreen,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  
                  // Counter Body
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isCompleted
                            ? [AppTheme.primaryTeal, AppTheme.primaryGreen]
                            : [AppTheme.primaryGreen, AppTheme.primaryTeal],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$currentCount',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'of $targetCount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            isCompleted 
                ? l10n.completed.toUpperCase() 
                : l10n.tapToCount.toUpperCase(),
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: isCompleted ? AppTheme.primaryTeal : context.textSecondary,
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            icon: DirectionIcons.backArrow(context),
            enabled: _currentPageIndex > 0,
            onTap: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            ),
          ),
          
          // Reset button in middle
          TextButton.icon(
            onPressed: () => _resetCount(widget.azkar[_currentPageIndex].id),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(AppLocalizations.ofWithFallback(context).reset),
            style: TextButton.styleFrom(
              foregroundColor: context.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          _buildNavButton(
            icon: DirectionIcons.forwardArrow(context),
            enabled: _currentPageIndex < widget.azkar.length - 1,
            onTap: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: enabled ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            color: enabled ? AppTheme.primaryGreen : context.textSecondary.withValues(alpha: 0.3),
            size: 20,
          ),
        ),
      ),
    );
  }
}

