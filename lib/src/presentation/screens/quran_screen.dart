import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import '../../utils/theme.dart';
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
    // Small delay to ensure smooth animation
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _fadeController.forward();
      _slideController.forward();
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
                // Custom App Bar
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
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
                              Icons.menu_book_rounded,
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
                                  'Quran Kareem',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'The Holy Quran',
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
                ),
                // Quran Library Screen
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: QuranLibraryScreen(
                          parentContext: context,
                          isDark: false,
                          showAyahBookmarkedIcon: true,
                          appLanguageCode: isArabic ? 'ar' : 'en',
                          ayahIconColor: AppTheme.primaryGreen,
                          backgroundColor: Colors.white,
                          textColor: Colors.black87,
                          isFontsLocal: false,
                          // Custom styling for better UI/UX
                          tafsirStyle: TafsirStyle.defaults(
                            isDark: false,
                            context: context,
                          ).copyWith(
                            widthOfBottomSheet: MediaQuery.of(context).size.width * 0.95,
                            heightOfBottomSheet: MediaQuery.of(context).size.height * 0.85,
                            changeTafsirDialogHeight: MediaQuery.of(context).size.height * 0.85,
                            changeTafsirDialogWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                        ),
                      ),
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
