import 'package:flutter/material.dart';
import 'theme.dart';

/// Extension to easily access theme-aware colors in any widget
extension ThemeExtensions on BuildContext {
  /// Returns primary text color based on current theme
  Color get textPrimary => AppTheme.getTextPrimary(this);
  
  /// Returns secondary text color based on current theme
  Color get textSecondary => AppTheme.getTextSecondary(this);
  
  /// Returns card background color based on current theme
  Color get cardColor => AppTheme.getCardColor(this);
  
  /// Returns background color based on current theme
  Color get backgroundColor => AppTheme.getBackgroundColor(this);
  
  /// Returns true if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Returns ColorScheme from current theme
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// Returns TextTheme from current theme
  TextTheme get textTheme => Theme.of(this).textTheme;
}

