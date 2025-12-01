import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'src/utils/theme.dart';
import 'src/utils/localizations.dart';
import 'src/utils/page_transitions.dart';
import 'src/utils/app_state_provider.dart';
import 'src/presentation/screens/splash_screen.dart';
import 'src/data/services/storage_service.dart';
import 'src/data/services/notification_service.dart';
import 'src/data/services/audio_player_service.dart';
import 'src/data/services/reminder_service.dart';
import 'src/data/repositories/azkar_repository.dart';
import 'src/presentation/screens/player_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService().initialize();
  final notificationService = NotificationService();
  await notificationService.initialize();
  await AudioPlayerService().initialize();

  // Reschedule all active reminders
  final reminderService = ReminderService();
  await reminderService.rescheduleAllActiveReminders();

  runApp(const ProviderScope(child: BlingAzkarApp()));
}

class BlingAzkarApp extends StatefulWidget {
  const BlingAzkarApp({super.key});

  @override
  State<BlingAzkarApp> createState() => _BlingAzkarAppState();
}

class _BlingAzkarAppState extends State<BlingAzkarApp> {
  final _storage = StorageService();
  final _appState = AppStateNotifier();
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadThemeMode();
    _appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (_appState.locale != null) {
      setState(() {
        _locale = _appState.locale!;
      });
    }
    if (_appState.themeMode != null) {
      setState(() {
        _themeMode = _appState.themeMode!;
      });
    }
  }

  void _loadLanguage() {
    final prefs = _storage.getPreferences();
    final newLocale = Locale(prefs.language);
    if (_locale != newLocale) {
      setState(() {
        _locale = newLocale;
      });
    }
  }

  void _loadThemeMode() {
    final prefs = _storage.getPreferences();
    setState(() {
      switch (prefs.themeMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check for language and theme changes
    final prefs = _storage.getPreferences();
    final currentLocale = Locale(prefs.language);
    ThemeMode currentThemeMode;
    switch (prefs.themeMode) {
      case 'light':
        currentThemeMode = ThemeMode.light;
        break;
      case 'dark':
        currentThemeMode = ThemeMode.dark;
        break;
      default:
        currentThemeMode = ThemeMode.system;
    }

    if (_locale != currentLocale || _themeMode != currentThemeMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _locale = currentLocale;
            _themeMode = currentThemeMode;
          });
        }
      });
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Bling Azkar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      builder: (context, child) {
        final l10n = AppLocalizations.ofWithFallback(context);
        return Directionality(
          textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
