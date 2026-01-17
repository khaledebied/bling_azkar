import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran_library.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';
import '../providers/ui_providers.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _hasError = false;
  String _errorMessage = '';
  
  // For double tap detection using Listener
  DateTime? _lastPointerDownTime;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkInitialization();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _checkInitialization() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      debugPrint('Error initializing Quran screen: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to initialize Quran library: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect dark mode and localizations
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Show error state if initialization failed
    if (_hasError) {
      return _buildErrorState(context, isDarkMode);
    }

    // MediaQuery for responsive layout
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final isSystemBarsVisible = ref.watch(showBottomNavProvider);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF5F5F5),
        appBar: isSystemBarsVisible 
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                l10n.quranKareem,
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ]
                        : [
                            AppTheme.primaryGreen.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            )
          : null,
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _lastPointerDownTime = DateTime.now(),
          onPointerUp: (_) {
            if (_lastPointerDownTime != null) {
              final now = DateTime.now();
              final duration = now.difference(_lastPointerDownTime!);
              
              if (duration.inMilliseconds < 300) {
                // It's a valid tap (not a scroll/long press)
                if (_lastTapTime != null && 
                    now.difference(_lastTapTime!).inMilliseconds < 300) {
                  // It's a double tap!
                  ref.read(showBottomNavProvider.notifier).update((state) => !state);
                  _lastTapTime = null; // Reset
                } else {
                  _lastTapTime = now;
                }
              }
            }
          },
          child: _buildQuranLibrary(context, isArabic, isDarkMode, screenWidth, screenHeight),
        ),
      ),
    );
  }

  Widget _buildQuranLibrary(
    BuildContext context,
    bool isArabic,
    bool isDarkMode,
    double screenWidth,
    double screenHeight,
  ) {
    return QuranLibraryScreen(
      parentContext: context,
      appLanguageCode: isArabic ? 'ar' : 'en',
      isDark: isDarkMode,
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF5F5F5),
      textColor: isDarkMode ? Colors.white : Colors.black87,
      ayahIconColor: AppTheme.primaryGreen,
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDarkMode) {
    final l10n = AppLocalizations.ofWithFallback(context);
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F1419)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.quranKareem,
          style: AppTheme.titleMedium.copyWith(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDarkMode ? 0.4 : 0.15,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.quranLibraryError,
                  style: AppTheme.titleLarge.copyWith(
                    color: isDarkMode ? Colors.white : context.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.7)
                        : context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _errorMessage = '';
                        });
                        _checkInitialization();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(DirectionIcons.backArrow(context)),
                      label: Text(l10n.goBack),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
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
    );
  }
}
