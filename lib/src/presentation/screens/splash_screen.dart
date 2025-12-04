import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Scale up animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Pulse animation for continuous effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Start pulse animation and repeat it
    _pulseController.repeat(reverse: true);

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
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
                transitionDuration: const Duration(milliseconds: 600),
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkBackgroundGradient
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppTheme.primaryGreen.withOpacity(0.05),
                    AppTheme.primaryTeal.withOpacity(0.08),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _fadeAnimation,
            _scaleAnimation,
            _pulseAnimation,
          ]),
          builder: (context, child) {
            return Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                        maxHeight: MediaQuery.of(context).size.width * 0.6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.4),
                            blurRadius: 50,
                            spreadRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: AppTheme.primaryTeal.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/icon/splash.png',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
