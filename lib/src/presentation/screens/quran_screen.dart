import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:quran_library/quran_library.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';
import '../../data/services/showcase_service.dart';
import '../widgets/custom_showcase_tooltip.dart';
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

  // Showcase Keys
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkInitialization();
    
    // Check immediately if we are already on tab 3 (for hot reload or initial state)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(currentTabProvider) == 3) {
        _checkAndStartShowcase();
      }
    });
  }
  
  Future<void> _checkAndStartShowcase() async {
    // Small delay to ensure UI is ready
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final showcaseService = ref.read(showcaseServiceProvider);
    
    // Only show content showcase if tab showcase is already seen
    final hasSeenTab = await showcaseService.hasSeenQuranTabShowcase();
    if (hasSeenTab) {
      final hasSeenContent = await showcaseService.hasSeenQuranContentShowcase();
      if (!hasSeenContent) {
        ShowCaseWidget.of(context).startShowCase([_titleKey, _contentKey]);
      }
    }
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
    // Listen to tab changes to trigger showcase
    ref.listen(currentTabProvider, (previous, next) {
      if (next == 3) {
        _checkAndStartShowcase();
      }
    });

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
          title: Showcase.withWidget(
            key: _titleKey,
            targetBorderRadius: BorderRadius.circular(12),
            container: SizedBox(
              width: 300,
              height: 160,
              child: CustomShowcaseTooltip(
                title: l10n.showcaseQuranTitle,
                description: l10n.showcaseQuranTab,
                icon: Icons.menu_book_rounded,
                onNext: () {
                  ShowCaseWidget.of(context).next();
                },
              ),
            ),
            child: Text(
              l10n.quranKareem,
              style: AppTheme.titleMedium.copyWith(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
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
      final l10n = AppLocalizations.ofWithFallback(context);
      return Showcase.withWidget(
        key: _contentKey,
        targetBorderRadius: BorderRadius.circular(20),
        container: SizedBox(
          width: 300,
          height: 180,
          child: CustomShowcaseTooltip(
            title: l10n.quranKareem,
            description: l10n.showcaseQuranFeatures,
            isLastStep: true,
            icon: Icons.search_rounded,
            onNext: () {
              ref.read(showcaseServiceProvider).markQuranContentShowcaseAsSeen();
              ShowCaseWidget.of(context).dismiss();
            },
          ),
        ),
        child: Container(
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
        ),
      );
    } catch (e) {
      debugPrint('Error building QuranLibrary: $e');
      return _buildQuranError(e.toString(), isDarkMode);
    }
  }

  Widget _buildQuranError(String error, bool isDarkMode) {
    final l10n = AppLocalizations.ofWithFallback(context);
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
              l10n.errorLoadingQuran,
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
              label: Text(l10n.retry),
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
