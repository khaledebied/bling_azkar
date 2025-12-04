import 'package:flutter/material.dart';
import 'localizations.dart';

/// Utility class for direction-aware icons
/// Returns icons that point correctly in both LTR and RTL
/// Note: Material Icons with _ios suffix are NOT auto-mirrored by Flutter
/// So we manually select the correct icon based on direction
class DirectionIcons {
  /// Get back arrow icon based on text direction
  /// In LTR (English): points left (arrow_back)
  /// In RTL (Arabic): points right (arrow_forward, which visually points right)
  static IconData backArrow(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    // In RTL, back navigation goes right, so use arrow_forward (points right)
    // In LTR, back navigation goes left, so use arrow_back (points left)
    return l10n.isArabic 
        ? Icons.arrow_forward_ios_rounded 
        : Icons.arrow_back_ios_rounded;
  }

  /// Get forward arrow icon based on text direction
  /// In LTR (English): points right (arrow_forward)
  /// In RTL (Arabic): points left (arrow_back, which visually points left)
  static IconData forwardArrow(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    // In RTL, forward goes left, so use arrow_back (points left)
    // In LTR, forward goes right, so use arrow_forward (points right)
    return l10n.isArabic 
        ? Icons.arrow_back_ios_rounded 
        : Icons.arrow_forward_ios_rounded;
  }

  /// Get arrow for list items, settings, etc.
  /// Points in the reading direction
  static IconData listArrow(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    // In RTL, reading goes left, so use arrow_back (points left)
    // In LTR, reading goes right, so use arrow_forward (points right)
    return l10n.isArabic 
        ? Icons.arrow_back_ios 
        : Icons.arrow_forward_ios;
  }

  /// Get chevron icon based on text direction
  static IconData chevron(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    // In RTL, use chevron_left (points left)
    // In LTR, use chevron_right (points right)
    return l10n.isArabic ? Icons.chevron_left : Icons.chevron_right;
  }
}

