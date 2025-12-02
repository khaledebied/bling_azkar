import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import '../../data/services/storage_service.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  final _storage = StorageService();
  int _count = 0;
  int _roundCount = 0;
  final int _roundTarget = 33;
  
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

  @override
  void initState() {
    super.initState();
    _loadCount();
    
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

    // Bounce animation for round completion
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

  void _loadCount() {
    setState(() {
      _count = _storage.getTasbihCount();
      _roundCount = _count % _roundTarget;
    });
  }

  void _saveCount() {
    _storage.updateTasbihCount(_count);
  }

  void _increment() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count++;
      _roundCount = _count % _roundTarget;
    });
    _saveCount();

    // Animate
    _scaleController.forward(from: 0);
    _rippleController.forward(from: 0);
    
    if (_roundCount == 0 && _count > 0) {
      HapticFeedback.heavyImpact();
      _bounceController.forward(from: 0);
    }
  }

  void _decrement() {
    if (_count > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _count--;
        _roundCount = _count % _roundTarget;
      });
      _saveCount();

      // Animate
      _scaleController.forward(from: 0);
      _rippleController.forward(from: 0);
    }
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
      
      // Calculate rotation based on drag (smooth rotation)
      _rotationAngle += details.delta.dy * 0.15;
      
      // Determine if we should increment/decrement based on drag distance
      // Use a threshold to prevent too frequent updates
      double threshold = 25.0; // pixels per increment/decrement
      
      if (_dragOffset.abs() > threshold) {
        if (_dragOffset < 0) {
          // Dragging up (forward) - increment
          _increment();
          _dragOffset = 0.0; // Reset after increment
        } else {
          // Dragging down (reverse) - decrement
          _decrement();
          _dragOffset = 0.0; // Reset after decrement
        }
      }
    });
    
    // Animate rotation smoothly
    double normalizedAngle = (_rotationAngle % (2 * math.pi)) / (2 * math.pi);
    _rotationController.value = normalizedAngle;
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragOffset = 0.0;
    });
    
    // Smooth return rotation with spring effect
    _rotationController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
    );
    
    // Reset angle after animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _rotationAngle = 0.0;
        });
      }
    });
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _count = 0;
      _roundCount = 0;
    });
    _saveCount();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryGreen,
                AppTheme.primaryTeal,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Electronic Tasbih',
                              style: AppTheme.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tap or drag to count',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Round Counter
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'Round: $_roundCount / $_roundTarget',
                            style: AppTheme.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Interactive Tasbih Bead
                        GestureDetector(
                          onTap: _increment,
                          onPanStart: _handleDragStart,
                          onPanUpdate: _handleDragUpdate,
                          onPanEnd: _handleDragEnd,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ripple effect
                              AnimatedBuilder(
                                animation: _rippleAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 280 + (_rippleAnimation.value * 80),
                                    height: 280 + (_rippleAnimation.value * 80),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(
                                          0.2 * (1 - _rippleAnimation.value),
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Pulse ring for round completion
                              if (_roundCount == 0 && _count > 0)
                                AnimatedBuilder(
                                  animation: _bounceAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: 240 * _bounceAnimation.value,
                                      height: 240 * _bounceAnimation.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(
                                            0.6 * (1 - (_bounceAnimation.value - 1) / 0.3),
                                          ),
                                          width: 4,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              // Main rotating bead
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  _rotationController,
                                  _scaleController,
                                ]),
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationAnimation.value * 2 * math.pi,
                                    child: Transform.scale(
                                      scale: _isDragging 
                                          ? 1.1 
                                          : _scaleAnimation.value,
                                      child: Container(
                                        width: 220,
                                        height: 220,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Colors.white.withOpacity(0.95),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 40,
                                              offset: const Offset(0, 15),
                                              spreadRadius: 5,
                                            ),
                                            BoxShadow(
                                              color: AppTheme.primaryGreen.withOpacity(0.3),
                                              blurRadius: 30,
                                              offset: const Offset(0, 10),
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Decorative inner circle
                                            Container(
                                              width: 180,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppTheme.primaryGreen.withOpacity(0.2),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            // Counter text
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 200),
                                              transitionBuilder: (child, animation) {
                                                return ScaleTransition(
                                                  scale: animation,
                                                  child: FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                '$_count',
                                                key: ValueKey(_count),
                                                style: AppTheme.headlineLarge.copyWith(
                                                  fontSize: 72,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryGreen,
                                                  letterSpacing: -2,
                                                ),
                                              ),
                                            ),
                                            // Drag indicator (shows when dragging)
                                            if (_isDragging)
                                              Positioned(
                                                top: 20,
                                                child: Icon(
                                                  _lastDragOffset < 0 
                                                      ? Icons.arrow_upward_rounded
                                                      : Icons.arrow_downward_rounded,
                                                  color: AppTheme.primaryGreen.withOpacity(0.6),
                                                  size: 24,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Decorative beads around the main bead
                              ...List.generate(8, (index) {
                                final angle = (index * 2 * math.pi / 8) - math.pi / 2;
                                final radius = 140.0;
                                return Positioned(
                                  left: 110 + radius * math.cos(angle) - 15,
                                  top: 110 + radius * math.sin(angle) - 15,
                                  child: AnimatedBuilder(
                                    animation: _rippleAnimation,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: 0.3 + (_rippleAnimation.value * 0.2),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Instructions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tap to count',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Icon(
                                Icons.swipe_vertical_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Drag up/down',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Reset Button
                        ElevatedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reset'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
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
      ),
    );
  }
}
