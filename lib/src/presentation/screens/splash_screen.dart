import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late AnimationController _gradientController;
  late AnimationController _shimmerController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _gradientAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    _initializeAnimations();
    _startAnimations();
    _navigateToHome();
  }

  void _setupSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // System UI will be set in build method to react to theme changes
  }

  void _initializeAnimations() {
    // Fade animation (0-1)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Scale animation (0.3 -> 1.0 -> 0.95)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.1)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_scaleController);

    // Rotation animation (continuous)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    // Particle animation (floating circles)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _particleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.easeInOut,
      ),
    );

    // Gradient animation (shifting colors)
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _gradientAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: Curves.easeInOut,
      ),
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
    _rotationController.repeat();
    _particleController.repeat();
    _gradientController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _fadeController.reverse();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MainNavigationScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _gradientController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    // Update system UI based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeAnimation,
          _scaleAnimation,
          _rotationAnimation,
          _particleAnimation,
          _gradientAnimation,
          _shimmerAnimation,
        ]),
        builder: (context, child) {
          return Container(
        decoration: BoxDecoration(
              gradient: _buildBackgroundGradient(isDarkMode),
            ),
            child: Stack(
              children: [
                // Animated particles/background elements
                _buildAnimatedParticles(isDarkMode),
                // Main content
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with multiple animations
                        _buildAnimatedLogo(isDarkMode),
                        const SizedBox(height: 40),
                        // App name
                        _buildAppName(isDarkMode),
                        const SizedBox(height: 60),
                        // Loading indicator
                        _buildLoadingIndicator(isDarkMode),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  LinearGradient _buildBackgroundGradient(bool isDarkMode) {
    if (isDarkMode) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0A0E1A),
          const Color(0xFF0F1419),
          Color.lerp(
            const Color(0xFF0F1419),
            AppTheme.primaryGreen.withOpacity(0.15),
            _gradientAnimation.value,
          )!,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    } else {
      return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
          Color.lerp(
            Colors.white,
            AppTheme.primaryGreen.withOpacity(0.08),
            _gradientAnimation.value,
          )!,
          Color.lerp(
            Colors.white,
            AppTheme.primaryTeal.withOpacity(0.12),
            _gradientAnimation.value,
          )!,
                  ],
                  stops: const [0.0, 0.5, 1.0],
      );
    }
  }

  Widget _buildAnimatedParticles(bool isDarkMode) {
    return Stack(
      children: List.generate(8, (index) {
        final size = 60.0 + (index * 20.0);
        final delay = index * 0.2;
        final animationValue = (_particleAnimation.value + delay) % 1.0;

        return Positioned(
          left: (MediaQuery.of(context).size.width / 8) * index,
          top: MediaQuery.of(context).size.height *
              (0.2 + (animationValue * 0.6)),
          child: Transform.scale(
            scale: 0.3 + (animationValue * 0.7),
            child: Opacity(
              opacity: 0.15 - (animationValue * 0.1),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryGreen.withOpacity(0.3),
                      AppTheme.primaryTeal.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedLogo(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glowing ring
        Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.3),
                  AppTheme.primaryTeal.withOpacity(0.2),
                  AppTheme.primaryGreen.withOpacity(0.3),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Main logo container
        ScaleTransition(
                  scale: _scaleAnimation,
                    child: Container(
            width: 160,
            height: 160,
                      decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryTeal,
                ],
              ),
                        boxShadow: [
                          BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shimmer effect
                ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(_shimmerAnimation.value - 1, 0),
                        end: Alignment(_shimmerAnimation.value, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                          ),
                  ),
                      ),
                // Logo image
                Padding(
                  padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/icon/splash.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.mosque,
                        size: 80,
                        color: Colors.white,
                            );
                          },
                        ),
                      ),
              ],
                    ),
                  ),
                ),
      ],
    );
  }

  Widget _buildAppName(bool isDarkMode) {
    return Column(
      children: [
        // English name
        Text(
          'Noor',
          style: AppTheme.headlineLarge.copyWith(
            color: isDarkMode
                ? Colors.white
                : AppTheme.textPrimary,
            fontSize: 42,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Arabic name
        Text(
          'نُور',
          style: AppTheme.arabicLarge.copyWith(
            color: isDarkMode
                ? Colors.white.withOpacity(0.9)
                : AppTheme.textPrimary,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: AppTheme.primaryTeal.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
            );
  }

  Widget _buildLoadingIndicator(bool isDarkMode) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring
          Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen.withOpacity(0.3),
                ),
                value: null,
              ),
            ),
          ),
          // Inner pulsing dot
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.2).animate(
              CurvedAnimation(
                parent: _particleController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
