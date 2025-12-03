import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global app state notifier for immediate updates
class AppStateNotifier extends ChangeNotifier {
  static final AppStateNotifier _instance = AppStateNotifier._internal();
  factory AppStateNotifier() => _instance;
  AppStateNotifier._internal();

  Locale? _locale;
  ThemeMode? _themeMode;
  double? _textScale;

  Locale? get locale => _locale;
  ThemeMode? get themeMode => _themeMode;
  double? get textScale => _textScale;

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

  void updateTextScale(double scale) {
    if (_textScale != scale) {
      _textScale = scale;
      notifyListeners();
    }
  }

  void reset() {
    _locale = null;
    _themeMode = null;
    _textScale = null;
    notifyListeners();
  }
}

final appStateProvider = Provider<AppStateNotifier>((ref) {
  return AppStateNotifier();
});
