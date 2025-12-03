import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Rich Emerald/Teal + Gold Accent (More Attractive)
  static const primaryGreen = Color(0xFF10B981); // Vibrant emerald green
  static const primaryTeal = Color(0xFF14B8A6); // Bright teal
  static const accentGold = Color(0xFFF59E0B); // Warm amber gold
  static const darkGreen = Color(0xFF059669); // Deep emerald
  static const lightGreen = Color(0xFF34D399); // Light emerald
  static const gradientStart = Color(0xFF10B981); // Emerald
  static const gradientEnd = Color(0xFF06B6D4); // Cyan
  
  static const backgroundLight = Color(0xFFF8F9FA);
  static const backgroundDark = Color(0xFF0F1419);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1C2128);
  
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFFFFFFF);
  
  // Dark mode text colors
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFB3B3B3);
  
  // Theme-aware text colors
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textPrimaryDark 
        : textPrimary;
  }
  
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textSecondaryDark 
        : textSecondary;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? cardDark 
        : cardLight;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? backgroundDark 
        : backgroundLight;
  }

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
  
  static const emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
  
  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
  );

  // English Text Styles (Poppins)
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Arabic Text Styles (Cairo)
  static TextStyle arabicLarge = GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.8,
  );

  static TextStyle arabicMedium = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.8,
  );

  static TextStyle arabicSmall = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.8,
  );

  // Quran/Dhikr Text Styles (Amiri - elegant)
  static TextStyle quranLarge = GoogleFonts.amiri(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 2.0,
  );

  static TextStyle quranMedium = GoogleFonts.amiri(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.8,
  );

  static TextStyle dhikrText = GoogleFonts.amiri(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.9,
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Background color
  static const backgroundColor = backgroundLight;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: primaryTeal,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.fixed,
    ),
    textTheme: TextTheme(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelSmall: caption,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryGreen,
      secondary: primaryTeal,
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: headlineLarge.copyWith(color: textPrimaryDark),
      headlineMedium: headlineMedium.copyWith(color: textPrimaryDark),
      titleLarge: titleLarge.copyWith(color: textPrimaryDark),
      titleMedium: titleMedium.copyWith(color: textPrimaryDark),
      bodyLarge: bodyLarge.copyWith(color: textPrimaryDark),
      bodyMedium: bodyMedium.copyWith(color: textPrimaryDark),
      bodySmall: bodySmall.copyWith(color: textSecondaryDark),
      labelSmall: caption.copyWith(color: textSecondaryDark),
    ),
  );
}
