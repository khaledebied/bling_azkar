import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import '../../../utils/theme.dart';
import '../../../utils/theme_extensions.dart';
import '../../../utils/localizations.dart';

class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF5F5F5),
        body: SafeArea(
          child: QuranLibraryScreen(
            parentContext: context,
            isDark: isDarkMode,
            showAyahBookmarkedIcon: true,
            appLanguageCode: isArabic ? 'ar' : 'en',
            ayahIconColor: AppTheme.primaryGreen,
            backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF5F5F5),
            textColor: isDarkMode ? Colors.white.withValues(alpha: 0.95) : Colors.black87,
            isFontsLocal: false,
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
      ),
    );
  }
}
