import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Helper class for managing icons in the app
/// Supports both Material Icons and custom Flaticon icons
class IconHelper {
  /// Get icon widget for a category
  /// First tries to load custom Flaticon icon, falls back to Material icon
  static Widget getCategoryIcon({
    required String categoryName,
    required IconData materialIcon,
    String? customIconPath,
    Color? color,
    double? size,
  }) {
    // If custom icon path is provided, try to load it
    if (customIconPath != null) {
      try {
        // Try SVG first
        if (customIconPath.endsWith('.svg')) {
          return SvgPicture.asset(
            customIconPath,
            colorFilter: color != null
                ? ColorFilter.mode(color, BlendMode.srcIn)
                : null,
            width: size ?? 32,
            height: size ?? 32,
          );
        }
        // Try PNG
        else if (customIconPath.endsWith('.png')) {
          return Image.asset(
            customIconPath,
            width: size ?? 32,
            height: size ?? 32,
            color: color,
          );
        }
      } catch (e) {
        debugPrint('Could not load custom icon: $customIconPath, using Material icon');
      }
    }

    // Fallback to Material icon
    return Icon(
      materialIcon,
      color: color,
      size: size ?? 32,
    );
  }

  /// Map category names to custom icon paths
  /// Add your Flaticon icons here after downloading them
  static String? getCustomIconPath(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    
    // Example mappings - update these with your actual Flaticon icon paths
    // if (lowerName.contains('مسجد')) {
    //   return 'assets/icons/mosque.svg';
    // }
    // if (lowerName.contains('صلاة')) {
    //   return 'assets/icons/prayer.svg';
    // }
    
    // Return null to use Material icons
    return null;
  }
}

