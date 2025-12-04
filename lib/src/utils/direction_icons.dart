import 'package:flutter/material.dart';
import 'localizations.dart';

/// Utility class for direction-aware icons
/// Returns icons that point correctly in both LTR and RTL
/// Note: Material Icons with _ios suffix are NOT auto-mirrored by Flutter
/// So we manually select the correct icon based on direction
class DirectionIcons {
  /// Get the text direction from context
  static bool _isRTL(BuildContext context) {
    try {
      final l10n = AppLocalizations.ofWithFallback(context);
      final textDirection = Directionality.of(context);
      var res = !l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;
      return textDirection == res;

    } catch (e) {
      // Fallback to checking directionality only
      return Directionality.of(context) == TextDirection.rtl;
    }
  }

  /// Get back arrow icon based on text direction
  /// In LTR (English): points left (arrow_back)
  /// In RTL (Arabic): points right (back navigation in RTL points right)
  static IconData backArrow(BuildContext context) {
    // In RTL, back navigation should point right, so use arrow_forward_ios_rounded
    // In LTR, back navigation should point left, so use arrow_back_ios_rounded
    return _isRTL(context)
        ? Icons.arrow_forward_ios_rounded  // Points right in RTL
        : Icons.arrow_back_ios_rounded;    // Points left in LTR
  }

  /// Get forward arrow icon based on text direction
  /// In LTR (English): points right (arrow_forward)
  /// In RTL (Arabic): points left (forward navigation in RTL points left)
  static IconData forwardArrow(BuildContext context) {
    // In RTL, forward navigation should point left, so use arrow_back_ios_rounded
    // In LTR, forward navigation should point right, so use arrow_forward_ios_rounded
    return _isRTL(context)
        ? Icons.arrow_back_ios_rounded     // Points left in RTL
        : Icons.arrow_forward_ios_rounded; // Points right in LTR
  }

  /// Get arrow for list items, settings, etc.
  /// Points in the reading direction (left in RTL, right in LTR)
  static IconData listArrow(BuildContext context) {
    // In RTL, reading direction is left, so use arrow_back_ios (points left)
    // In LTR, reading direction is right, so use arrow_forward_ios (points right)
    return _isRTL(context)
        ? Icons.arrow_back_ios
        : Icons.arrow_forward_ios;
  }

  /// Get chevron icon based on text direction
  /// Points in the reading direction
  static IconData chevron(BuildContext context) {
    // In RTL, reading goes left, so use chevron_left (points left)
    // In LTR, reading goes right, so use chevron_right (points right)
    return _isRTL(context) ? Icons.chevron_left : Icons.chevron_right;
  }
}
