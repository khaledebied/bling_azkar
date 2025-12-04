import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import '../../domain/models/tasbih_type.dart';
import '../providers/tasbih_providers.dart';
import '../widgets/tasbih_celebration_dialog.dart';
import '../widgets/progress_ring_painter.dart';

/// Detail screen for a specific Tasbih type with counter
class TasbihDetailScreen extends ConsumerStatefulWidget {
  final TasbihType tasbihType;

  const TasbihDetailScreen({
    super.key,
    required this.tasbihType,
  });

  @override
  ConsumerState<TasbihDetailScreen> createState() => _TasbihDetailScreenState();
}

class _TasbihDetailScreenState extends ConsumerState<TasbihDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late AnimationController _bounceController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _bounceAnimation;
  
  double _dragOffset = 0.0;
  double _lastDragOffset = 0.0;
  bool _isDragging = false;
  double _rotationAngle = 0.0;
  bool _celebrationShown = false;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation for drag
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeOut,
      ),
    );

    // Scale animation for tap
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Ripple animation
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );

    // Bounce animation for completion
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _rippleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _increment() {
    final counter = ref.read(tasbihCounterProvider(widget.tasbihType).notifier);
    final currentState = ref.read(tasbihCounterProvider(widget.tasbihType));
    
    if (currentState.canIncrement) {
      counter.increment();
      _scaleController.forward(from: 0);
      _rippleController.forward(from: 0);
      
      // Check if just completed
      final newState = ref.read(tasbihCounterProvider(widget.tasbihType));
      if (newState.isCompleted && !_celebrationShown) {
        _celebrationShown = true;
        _bounceController.forward(from: 0);
        
        // Show dialog after animation and frame completion
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && _celebrationShown) {
            _showCelebrationDialog();
          }
        });
      }
    } else {
      // Already completed, show toast
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completed — Tap Restart to begin again'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _decrement() {
    final counter = ref.read(tasbihCounterProvider(widget.tasbihType).notifier);
    counter.decrement();
    _scaleController.forward(from: 0);
    _rippleController.forward(from: 0);
    _celebrationShown = false; // Reset flag if user decrements
  }

  void _reset() {
    final counter = ref.read(tasbihCounterProvider(widget.tasbihType).notifier);
    counter.reset();
    _scaleController.forward(from: 0);
    _celebrationShown = false;
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _lastDragOffset = 0.0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _lastDragOffset = details.delta.dy;
      
      // Calculate rotation
      _rotationAngle += details.delta.dy * 0.15;
      
      // Threshold for increment/decrement
      double threshold = 25.0;
      
      if (_dragOffset.abs() > threshold) {
        if (_dragOffset < 0) {
          _increment();
          _dragOffset = 0.0;
        } else {
          _decrement();
          _dragOffset = 0.0;
        }
      }
    });
    
    double normalizedAngle = (_rotationAngle % (2 * math.pi)) / (2 * math.pi);
    _rotationController.value = normalizedAngle;
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragOffset = 0.0;
    });
    
    _rotationController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
    );
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _rotationAngle = 0.0;
        });
      }
    });
  }

  void _showCelebrationDialog() {
    final counter = ref.read(tasbihCounterProvider(widget.tasbihType));
    
    // Use addPostFrameCallback to ensure dialog shows after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => TasbihCelebrationDialog(
          tasbihType: widget.tasbihType,
          count: counter.currentCount,
          onRestart: () {
            Navigator.of(dialogContext).pop();
            _reset();
          },
          onDone: () {
            Navigator.of(dialogContext).pop();
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(tasbihCounterProvider(widget.tasbihType));
    final animationsEnabled = ref.watch(animationsEnabledProvider);
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.tasbihType.color,
              widget.tasbihType.color.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        isArabic ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.white,
                      ),
                      iconSize: 28,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.tasbihType.dhikrText,
                            style: AppTheme.arabicLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic ? widget.tasbihType.meaningAr : widget.tasbihType.meaningEn,
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
              
              // Progress badges
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge(
                      'Target: ${counter.targetCount}',
                      Icons.flag,
                    ),
                    const SizedBox(width: 12),
                    _buildBadge(
                      '${(counter.progress * 100).toInt()}%',
                      Icons.pie_chart,
                    ),
                  ],
                ),
              ),
              
              // Dhikr text display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  widget.tasbihType.dhikrText,
                  style: AppTheme.dhikrText.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Main Counter
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _increment,
                    onPanStart: _handleDragStart,
                    onPanUpdate: _handleDragUpdate,
                    onPanEnd: _handleDragEnd,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple effect
                        if (animationsEnabled)
                          AnimatedBuilder(
                            animation: _rippleAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 280 + (_rippleAnimation.value * 80),
                                height: 280 + (_rippleAnimation.value * 80),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: (0.2 * (1 - _rippleAnimation.value)).clamp(0.0, 1.0),
                                    ),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        // Completion pulse
                        if (counter.isCompleted && animationsEnabled)
                          AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) {
                              // Clamp opacity between 0 and 1
                              final opacity = (0.6 * (1 - (_bounceAnimation.value - 1) / 0.3)).clamp(0.0, 1.0);
                              return Container(
                                width: 240 * _bounceAnimation.value,
                                height: 240 * _bounceAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: opacity),
                                    width: 4,
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        // Progress ring
                        if (animationsEnabled)
                          CustomPaint(
                            size: const Size(250, 250),
                            painter: ProgressRingPainter(
                              progress: counter.progress,
                              color: widget.tasbihType.color,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              strokeWidth: 12,
                            ),
                          ),
                        
                        // Main bead with enhanced design
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _rotationController,
                            _scaleController,
                          ]),
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: animationsEnabled
                                  ? _rotationAnimation.value * 2 * math.pi
                                  : 0,
                              child: Transform.scale(
                                scale: animationsEnabled
                                    ? (_isDragging ? 1.1 : _scaleAnimation.value)
                                    : 1.0,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          Color(0xFFFEFEFE),
                                          Color(0xFFF8F8F8),
                                        ],
                                        stops: [0.0, 0.5, 1.0],
                                      ),
                                    shape: BoxShape.circle,
                                      boxShadow: [
                                        // Outer shadow
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 40,
                                          offset: const Offset(0, 20),
                                          spreadRadius: -5,
                                        ),
                                        // Colored glow
                                        BoxShadow(
                                          color: widget.tasbihType.color.withValues(alpha: 0.4),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                          spreadRadius: -8,
                                        ),
                                        // Inner highlight
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          blurRadius: 10,
                                          offset: const Offset(-5, -5),
                                          spreadRadius: -10,
                                        ),
                                      ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer decorative ring
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: widget.tasbihType.color.withValues(alpha: 0.15),
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      
                                      // Inner decorative ring
                                      Container(
                                        width: 170,
                                        height: 170,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: widget.tasbihType.color.withValues(alpha: 0.1),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      
                                      // Gradient overlay circle
                                      Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              widget.tasbihType.color.withValues(alpha: 0.05),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.5, 1.0],
                                          ),
                                        ),
                                      ),
                                      
                                      // Counter number with shadow
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        switchInCurve: Curves.easeOutCubic,
                                        switchOutCurve: Curves.easeInCubic,
                                        transitionBuilder: (child, animation) {
                                          return ScaleTransition(
                                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: ShaderMask(
                                          key: ValueKey(counter.currentCount),
                                            shaderCallback: (bounds) {
                                            return LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                widget.tasbihType.color,
                                                widget.tasbihType.color.withValues(alpha: 0.7),
                                              ],
                                            ).createShader(bounds);
                                          },
                                          child: Text(
                                            '${counter.currentCount}',
                                            style: AppTheme.headlineLarge.copyWith(
                                              fontSize: 80,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: -3,
                                              shadows: [
                                                Shadow(
                                                  color: widget.tasbihType.color.withValues(alpha: 0.3),
                                                  offset: const Offset(0, 4),
                                                  blurRadius: 12,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Count label
                                      Positioned(
                                        bottom: 45,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: widget.tasbihType.color.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '/ ${counter.targetCount}',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: widget.tasbihType.color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Drag indicator
                                      if (_isDragging)
                                        Positioned(
                                          top: 25,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: widget.tasbihType.color.withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _lastDragOffset < 0
                                                  ? Icons.arrow_upward_rounded
                                                  : Icons.arrow_downward_rounded,
                                              color: widget.tasbihType.color,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      
                                      // Completion badge
                                      if (counter.isCompleted)
                                        Positioned(
                                          bottom: 15,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  widget.tasbihType.color,
                                                  widget.tasbihType.color.withValues(alpha: 0.8),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: widget.tasbihType.color.withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  isArabic ? 'مكتمل' : 'Completed',
                                                  style: AppTheme.caption.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Removed decorative beads for cleaner design
                      ],
                    ),
                  ),
                ),
              ),
              
              // Instructions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInstruction(Icons.touch_app_rounded, l10n.tapToCount),
                    const SizedBox(width: 24),
                    _buildInstruction(Icons.swipe_vertical_rounded, 'Drag up/down'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

