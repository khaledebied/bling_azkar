import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../utils/theme.dart';
import '../../utils/localizations.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  // Kaaba coordinates (Mecca)
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;
  
  double _currentLat = 0.0;
  double _currentLng = 0.0;
  double _qiblaDirection = 0.0;
  bool _isLoading = true;
  
  late AnimationController _compassController;
  late Animation<double> _compassRotation;

  @override
  void initState() {
    super.initState();
    _compassController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _compassRotation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _compassController,
        curve: Curves.easeOutCubic,
      ),
    );
    _initializeLocation();
  }

  @override
  void dispose() {
    _compassController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // In a real app, you would use geolocator package
    // For now, using a default location (example: Cairo, Egypt)
    setState(() {
      _currentLat = 30.0444;
      _currentLng = 31.2357;
      _isLoading = false;
    });
    _calculateQiblaDirection();
  }

  void _calculateQiblaDirection() {
    final lat1 = _currentLat * math.pi / 180;
    final lat2 = kaabaLat * math.pi / 180;
    final deltaLng = (kaabaLng - _currentLng) * math.pi / 180;

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = math.atan2(y, x);
    final direction = (bearing * 180 / math.pi + 360) % 360;

    setState(() {
      _qiblaDirection = direction;
    });

    // Animate compass rotation
    _compassRotation = Tween<double>(
      begin: _compassRotation.value,
      end: direction,
    ).animate(
      CurvedAnimation(
        parent: _compassController,
        curve: Curves.easeOutCubic,
      ),
    );
    _compassController.forward(from: 0);
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
                AppTheme.primaryTeal,
                AppTheme.primaryGreen,
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
                          Icons.explore_rounded,
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
                              'Qibla Finder',
                              style: AppTheme.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Find the direction to Mecca',
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
                // Compass
                Expanded(
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Compass Circle
                              AnimatedBuilder(
                                animation: _compassRotation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _compassRotation.value * math.pi / 180,
                                    child: Container(
                                      width: 280,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Compass background
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  Colors.white,
                                                  Colors.white.withOpacity(0.8),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Qibla arrow
                                          Transform.rotate(
                                            angle: _qiblaDirection * math.pi / 180,
                                            child: Container(
                                              width: 4,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    AppTheme.primaryGreen,
                                                    AppTheme.primaryTeal,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          // Center dot
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryGreen,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          // Direction indicators
                                          ...List.generate(8, (index) {
                                            final angle = (index * 45) * math.pi / 180;
                                            final isMain = index % 2 == 0;
                                            return Positioned(
                                              top: 20,
                                              left: 0,
                                              right: 0,
                                              child: Transform.rotate(
                                                angle: angle,
                                                child: Container(
                                                  width: 2,
                                                  height: isMain ? 30 : 15,
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 40),
                              // Direction Info
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${_qiblaDirection.toStringAsFixed(1)}°',
                                      style: AppTheme.headlineMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Direction to Kaaba',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

