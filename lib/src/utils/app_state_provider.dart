import 'package:flutter/material.dart';

/// Global app state notifier for immediate updates
class AppStateNotifier extends ChangeNotifier {
  static final AppStateNotifier _instance = AppStateNotifier._internal();
  factory AppStateNotifier() => _instance;
  AppStateNotifier._internal();

  Locale? _locale;
  ThemeMode? _themeMode;

  Locale? get locale => _locale;
  ThemeMode? get themeMode => _themeMode;

  void updateLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }

  void updateThemeMode(ThemeMode themeMode) {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      notifyListeners();
    }
  }

  void reset() {
    _locale = null;
    _themeMode = null;
    notifyListeners();
  }
}

