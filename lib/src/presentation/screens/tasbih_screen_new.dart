import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../domain/models/tasbih_type.dart';
import '../providers/tasbih_providers.dart';

class TasbihScreenNew extends ConsumerStatefulWidget {
  const TasbihScreenNew({super.key});

  @override
  ConsumerState<TasbihScreenNew> createState() => _TasbihScreenNewState();
}

class _TasbihScreenNewState extends ConsumerState<TasbihScreenNew>
    with TickerProviderStateMixin {
  
  // Selected tasbih type (can be changed by user)
  late TasbihType _selectedType;
  
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
    
    // Initialize with default type or last selected
    final lastSelectedId = ref.read(tasbihRepositoryProvider).getLastSelectedType();
    _selectedType = lastSelectedId != null 
        ? TasbihTypes.getById(lastSelectedId) ?? TasbihTypes.tasbih33
        : TasbihTypes.tasbih33;
    
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

  void _increment() {
    final counter = ref.read(tasbihCounterProvider(_selectedType).notifier);
    final currentState = ref.read(tasbihCounterProvider(_selectedType));
    
    if (currentState.canIncrement) {
      counter.increment();
      _scaleController.forward(from: 0);
      _rippleController.forward(from: 0);
      
      // Check if completed
      final newState = ref.read(tasbihCounterProvider(_selectedType));
      if (newState.isCompleted) {
        _bounceController.forward(from: 0);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showCompletionDialog();
          }
        });
      }
    } else {
      // Show toast that session is complete
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completed — Tap Reset to begin again'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _decrement() {
    final counter = ref.read(tasbihCounterProvider(_selectedType).notifier);
    counter.decrement();
    _scaleController.forward(from: 0);
    _rippleController.forward(from: 0);
  }

  void _reset() {
    final counter = ref.read(tasbihCounterProvider(_selectedType).notifier);
    counter.reset();
    _scaleController.forward(from: 0);
  }

  void _changeType(TasbihType newType) {
    setState(() {
      _selectedType = newType;
    });
    ref.read(tasbihRepositoryProvider).saveLastSelectedType(newType.id);
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
      
      // Calculate rotation based on drag
      _rotationAngle += details.delta.dy * 0.15;
      
      // Threshold for increment/decrement
      double threshold = 25.0;
      
      if (_dragOffset.abs() > threshold) {
        if (_dragOffset < 0) {
          // Dragging up - increment
          _increment();
          _dragOffset = 0.0;
        } else {
          // Dragging down - decrement
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

  void _showCompletionDialog() {
    final counter = ref.read(tasbihCounterProvider(_selectedType));
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.cardColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.celebration, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mabruk!',
                    style: AppTheme.titleLarge.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'مبروك',
                    style: AppTheme.arabicSmall.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _selectedType.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '${counter.targetCount}',
                    style: AppTheme.headlineLarge.copyWith(
                      color: _selectedType.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    'Session Complete',
                    style: AppTheme.bodyLarge.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'May Allah accept your dhikr',
              style: AppTheme.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Done',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _reset();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Tasbih Type',
                style: AppTheme.titleMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: TasbihTypes.all.length,
                itemBuilder: (context, index) {
                  final type = TasbihTypes.all[index];
                  final isSelected = type.id == _selectedType.id;
                  
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: type.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(type.icon, color: type.color),
                    ),
                    title: Text(
                      type.nameEn,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${type.nameAr} • Target: ${type.defaultTarget}',
                      style: TextStyle(color: context.textSecondary),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: type.color)
                        : null,
                    onTap: () {
                      _changeType(type);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(tasbihCounterProvider(_selectedType));
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _selectedType.color,
              _selectedType.color.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with type selector
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showTypeSelector,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(_selectedType.icon, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedType.nameEn,
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _selectedType.nameAr,
                                      style: AppTheme.arabicSmall.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.8)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
              
              // Progress info
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Target: ${counter.targetCount}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Progress: ${(counter.progress * 100).toInt()}%',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
                            // Completion pulse
                            if (counter.isCompleted)
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
                                            color: _selectedType.color.withOpacity(0.3),
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
                                                color: _selectedType.color.withOpacity(0.2),
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
                                              '${counter.currentCount}',
                                              key: ValueKey(counter.currentCount),
                                              style: AppTheme.headlineLarge.copyWith(
                                                fontSize: 72,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedType.color,
                                                letterSpacing: -2,
                                              ),
                                            ),
                                          ),
                                          // Drag indicator
                                          if (_isDragging)
                                            Positioned(
                                              top: 20,
                                              child: Icon(
                                                _lastDragOffset < 0 
                                                    ? Icons.arrow_upward_rounded
                                                    : Icons.arrow_downward_rounded,
                                                color: _selectedType.color.withOpacity(0.6),
                                                size: 24,
                                              ),
                                            ),
                                          // Completed badge
                                          if (counter.isCompleted)
                                            Positioned(
                                              bottom: 20,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _selectedType.color,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Done',
                                                      style: AppTheme.caption.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
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
                            // Decorative beads
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

