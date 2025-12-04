import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _hasError = false;
  String _errorMessage = '';

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
      // Verify QuranLibrary is initialized
      // Small delay to ensure smooth animation
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
    // Safe MediaQuery access
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    
    // Detect dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Show error state if initialization failed
    if (_hasError) {
      return _buildErrorState(context, isDarkMode);
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            isArabic ? 'القرآن الكريم' : 'Quran Kareem',
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
        ),
        body: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF0F1419)
                : const Color(0xFFF5F5F5),
          ),
          child: SafeArea(
            top: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildQuranLibrary(
                context,
                isArabic,
                isDarkMode,
                screenWidth,
                screenHeight,
              ),
            ),
          ),
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
    try {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: isDarkMode
            ? const Color(0xFF0F1419)
            : const Color(0xFFF5F5F5),
        child: QuranLibraryScreen(
          parentContext: context,
          isDark: isDarkMode,
          showAyahBookmarkedIcon: true,
          appLanguageCode: isArabic ? 'ar' : 'en',
          ayahIconColor: AppTheme.primaryGreen,
          backgroundColor: isDarkMode
              ? const Color(0xFF0F1419)
              : const Color(0xFFF5F5F5),
          textColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.black87,
          isFontsLocal: false,
          // Custom styling for better UI/UX - full screen
          tafsirStyle: TafsirStyle.defaults(
            isDark: isDarkMode,
            context: context,
          ).copyWith(
            widthOfBottomSheet: screenWidth * 0.95,
            heightOfBottomSheet: screenHeight * 0.85,
            changeTafsirDialogHeight: screenHeight * 0.85,
            changeTafsirDialogWidth: screenWidth * 0.9,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error building QuranLibrary: $e');
      return _buildQuranError(e.toString(), isDarkMode);
    }
  }

  Widget _buildQuranError(String error, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Quran',
              style: AppTheme.titleLarge.copyWith(
                color: isDarkMode ? Colors.white : context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTheme.bodyMedium.copyWith(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.7)
                    : context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                });
                _checkInitialization();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDarkMode) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F1419)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Quran Kareem',
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
                  'Quran Library Error',
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
                      label: const Text('Retry'),
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
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
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
