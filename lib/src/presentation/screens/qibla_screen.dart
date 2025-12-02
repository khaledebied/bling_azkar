import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  double _qiblaDirection = 0.0;
  double _deviceHeading = 0.0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  LocationStatus? _locationStatus;
  
  late AnimationController _compassController;
  late Animation<double> _compassRotation;
  late Animation<double> _qiblaArrowRotation;

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
    _qiblaArrowRotation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _compassController,
        curve: Curves.easeOutCubic,
      ),
    );
    _initializeQibla();
  }

  @override
  void dispose() {
    _compassController.dispose();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _initializeQibla() async {
    try {
      // Check location permission
      _locationStatus = await FlutterQiblah.checkLocationStatus();
      
      if (_locationStatus == LocationStatus.disabled) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoading = false;
        });
        return;
      }

      if (_locationStatus == LocationStatus.denied) {
        // Request permission
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Location permission denied. Please grant permission.';
            _isLoading = false;
          });
          return;
        }
      }

      // Initialize Qibla
      await FlutterQiblah().init();

      // Listen to Qibla direction changes
      FlutterQiblah.qiblahStream.listen((direction) {
        if (mounted) {
          setState(() {
            _qiblaDirection = direction;
            _isLoading = false;
          });
          _updateCompassRotation();
        }
      });

      // Listen to device heading (compass)
      FlutterQiblah.headingStream.listen((heading) {
        if (mounted) {
          setState(() {
            _deviceHeading = heading;
          });
          _updateCompassRotation();
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error initializing Qibla: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _updateCompassRotation() {
    // Calculate the angle between device heading and Qibla direction
    final angle = _qiblaDirection - _deviceHeading;
    
    // Animate compass rotation
    _compassRotation = Tween<double>(
      begin: _compassRotation.value,
      end: -_deviceHeading,
    ).animate(
      CurvedAnimation(
        parent: _compassController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animate Qibla arrow (relative to compass)
    _qiblaArrowRotation = Tween<double>(
      begin: _qiblaArrowRotation.value,
      end: angle,
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
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Initializing Qibla...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          )
                        : _hasError
                            ? Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _errorMessage,
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: _initializeQibla,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppTheme.primaryGreen,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Compass Circle
                                  AnimatedBuilder(
                                    animation: _compassController,
                                    builder: (context, child) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Compass background (rotates with device)
                                          Transform.rotate(
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
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      Colors.white,
                                                      Colors.white.withOpacity(0.8),
                                                    ],
                                                  ),
                                                ),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    // Direction indicators (N, E, S, W)
                                                    ...['N', 'E', 'S', 'W'].asMap().entries.map((entry) {
                                                      final index = entry.key;
                                                      final label = entry.value;
                                                      final angle = (index * 90) * math.pi / 180;
                                                      return Positioned(
                                                        top: 20,
                                                        left: 0,
                                                        right: 0,
                                                        child: Transform.rotate(
                                                          angle: angle,
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                label,
                                                                style: AppTheme.bodySmall.copyWith(
                                                                  color: AppTheme.primaryGreen,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 2,
                                                                height: 30,
                                                                color: Colors.grey.shade400,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                    // Additional markers
                                                    ...List.generate(8, (index) {
                                                      if (index % 2 == 0) return const SizedBox.shrink();
                                                      final angle = (index * 45) * math.pi / 180;
                                                      return Positioned(
                                                        top: 20,
                                                        left: 0,
                                                        right: 0,
                                                        child: Transform.rotate(
                                                          angle: angle,
                                                          child: Container(
                                                            width: 1,
                                                            height: 15,
                                                            color: Colors.grey.shade300,
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Qibla arrow (rotates relative to compass)
                                          Transform.rotate(
                                            angle: _qiblaArrowRotation.value * math.pi / 180,
                                            child: Container(
                                              width: 6,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    AppTheme.primaryGreen,
                                                    AppTheme.primaryTeal,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(3),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.primaryGreen.withOpacity(0.5),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  // Arrow head
                                                  Positioned(
                                                    top: 0,
                                                    left: -8,
                                                    right: -8,
                                                    child: Container(
                                                      width: 22,
                                                      height: 22,
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.primaryGreen,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.navigation,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Center dot
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryGreen,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 40),
                                  // Direction Info
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 20,
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.explore,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '${_qiblaDirection.toStringAsFixed(1)}°',
                                              style: AppTheme.headlineMedium.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Direction to Kaaba',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Device Heading: ${_deviceHeading.toStringAsFixed(1)}°',
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
      ),
    );
  }
}

