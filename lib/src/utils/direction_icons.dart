import 'package:flutter/material.dart';
import 'localizations.dart';

/// Utility class for direction-aware icons
class DirectionIcons {
  /// Get back arrow icon based on text direction
  /// In RTL (Arabic), returns arrow_forward, in LTR (English), returns arrow_back
  static IconData backArrow(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    return l10n.isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded;
  }

  /// Get forward arrow icon based on text direction
  /// In RTL (Arabic), returns arrow_back, in LTR (English), returns arrow_forward
  static IconData forwardArrow(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    return l10n.isArabic ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded;
  }

  /// Get arrow_forward_ios icon (for list items, settings, etc.)
  /// Automatically flips direction based on text direction
  static IconData listArrow(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    return l10n.isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios;
  }

  /// Get chevron icon based on text direction
  static IconData chevron(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    return l10n.isArabic ? Icons.chevron_left : Icons.chevron_right;
  }
}

