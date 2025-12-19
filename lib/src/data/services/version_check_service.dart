import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:new_version_plus/new_version_plus.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import '../../presentation/widgets/update_dialog.dart';

class VersionCheckService {
  static final VersionCheckService _instance = VersionCheckService._internal();
  factory VersionCheckService() => _instance;
  VersionCheckService._internal();

  /// Check for app updates and show dialog if update is available
  /// 
  /// [context] - BuildContext to show the dialog
  /// [forceUpdate] - If true, user cannot dismiss the dialog (must update)
  Future<void> checkForUpdate(
    BuildContext context, {
    bool forceUpdate = false,
  }) async {
    // Skip update check on web or in debug mode (optional)
    if (kIsWeb) {
      debugPrint('Update check skipped: Web platform not supported');
      return;
    }

    try {
      final newVersion = NewVersionPlus(
        androidId: 'com.blingazkar.bling_azkar',
        iOSId: 'com.blingazkar.blingAzkar',
      );

      final status = await newVersion.getVersionStatus();

      if (status != null && status.canUpdate) {
        debugPrint('Update available: ${status.storeVersion} (current: ${status.localVersion})');
        if (context.mounted) {
          await _showUpdateDialog(
            context,
            status: status,
            forceUpdate: forceUpdate,
          );
        }
      } else {
        debugPrint('App is up to date (${status?.localVersion ?? 'unknown'})');
      }
    } catch (e, stackTrace) {
      debugPrint('Error checking for updates: $e');
      debugPrint('Stack trace: $stackTrace');
      // Silently fail - don't interrupt user experience
      // In production, you might want to log this to a crash reporting service
    }
  }

  Future<void> _showUpdateDialog(
    BuildContext context, {
    required VersionStatus status,
    required bool forceUpdate,
  }) async {
    final l10n = AppLocalizations.ofWithFallback(context);
    
    await showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) => UpdateDialog(
        versionStatus: status,
        forceUpdate: forceUpdate,
      ),
    );
  }
}
