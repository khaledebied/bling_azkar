import 'package:bling_azkar/src/data/services/notification_service.dart';
import 'package:bling_azkar/src/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quran_library/quran_library.dart';
import 'src/utils/theme.dart';
import 'src/utils/localizations.dart';
import 'src/utils/app_state_provider.dart';
import 'src/presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize critical storage service before app starts
  // This is needed to read preferences immediately
  await StorageService().initialize();

  // Start app immediately - heavy initializations will happen in background
  runApp(const ProviderScope(child: BlingAzkarApp()));
  
  // Defer heavy initializations to background after app starts
  _initializeServicesInBackground();
}

/// Initialize non-critical services in background after app starts
void _initializeServicesInBackground() async {
  try {
    // Initialize notification service (needed for notifications)
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Set up notification tap handler
    notificationService.onNotificationTapped = (NotificationResponse response) {
      debugPrint('Notification tapped with payload: ${response.payload}');
      
      // If it's a zikr reminder notification, activate reminders
      if (response.payload == 'zikr_reminder') {
        _handleZikrReminderTapFromNotification(notificationService);
      }
    };
    
    // Check for initial notification (when app is opened from notification)
    final initialNotification = await notificationService.getInitialNotification();
    if (initialNotification != null) {
      debugPrint('App opened from notification: ${initialNotification.payload}');
      if (initialNotification.payload == 'zikr_reminder') {
        await _handleZikrReminderTapFromNotification(notificationService);
      }
    }
    
    // Get preferences for notification scheduling
    final storage = StorageService();
    final prefs = storage.getPreferences();
    
    // Schedule notifications in background (non-blocking)
    if (prefs.notificationsEnabled) {
      // Don't await - let it run in background
      notificationService.startPeriodicReminders().catchError((e) {
        debugPrint('Error starting periodic reminders: $e');
      });
    }
    
    // Schedule daily notifications if times are configured
    if (prefs.scheduledNotificationTimes.isNotEmpty) {
      // Don't await - let it run in background
      notificationService.scheduleDailyNotifications(
        times: prefs.scheduledNotificationTimes,
        title: 'وقت الذكر',
        body: 'لا تنسى ذكر الله ❤️',
      ).catchError((e) {
        debugPrint('Error scheduling daily notifications: $e');
      });
    }
    
    // Initialize QuranLibrary in background (needed for Quran screen)
    // This is a heavy operation, so we do it after app starts
    try {
      await QuranLibrary.init();
      debugPrint('✅ QuranLibrary initialized');
    } catch (e) {
      debugPrint('⚠️ Error initializing QuranLibrary: $e');
      // QuranLibrary will try to initialize when first accessed if this fails
    }
  } catch (e) {
    debugPrint('Error in background initialization: $e');
  }
  
  // Initialize other services lazily (they'll initialize on first use)
  // AudioPlayerService will initialize when first used
  // SharedPreferences will initialize when first accessed via FutureProvider
}

// Handle zikr reminder tap from notification (top-level function)
Future<void> _handleZikrReminderTapFromNotification(NotificationService notificationService) async {
  final storage = StorageService();
  final prefs = storage.getPreferences();
  
  // If reminders are not enabled, activate them
  if (!prefs.notificationsEnabled) {
    // Request permissions first
    final hasPermission = await notificationService.requestPermissions();
    if (hasPermission) {
      // Activate reminders
      await notificationService.startPeriodicReminders();
      
      // Update preferences
      await storage.savePreferences(prefs.copyWith(notificationsEnabled: true));
      
      debugPrint('✅ Reminders activated from notification tap');
    } else {
      debugPrint('⚠️ Permission denied - cannot activate reminders');
    }
  } else {
    debugPrint('ℹ️ Reminders already enabled');
  }
}

class BlingAzkarApp extends StatefulWidget {
  const BlingAzkarApp({super.key});

  @override
  State<BlingAzkarApp> createState() => _BlingAzkarAppState();
}

class _BlingAzkarAppState extends State<BlingAzkarApp> with WidgetsBindingObserver {
  final _storage = StorageService();
  final _appState = AppStateNotifier();
  final _notificationService = NotificationService();
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.system;
  double _textScale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLanguage();
    _loadThemeMode();
    _loadTextScale();
    _appState.addListener(_onAppStateChanged);
    _setupNotificationTapHandler();
  }

  void _setupNotificationTapHandler() {
    // Set up notification tap handler (for when app is already running)
    _notificationService.onNotificationTapped = (NotificationResponse response) {
      debugPrint('Notification tapped with payload: ${response.payload}');
      
      // If it's a zikr reminder notification, activate reminders
      if (response.payload == 'zikr_reminder') {
        _handleZikrReminderTap();
      }
    };
    
    // Check for initial notification (when app is opened from notification)
    _checkInitialNotification();
  }

  Future<void> _checkInitialNotification() async {
    final initialNotification = await _notificationService.getInitialNotification();
    if (initialNotification != null) {
      debugPrint('App opened from notification: ${initialNotification.payload}');
      if (initialNotification.payload == 'zikr_reminder') {
        await _handleZikrReminderTap();
      }
    }
  }

  Future<void> _handleZikrReminderTap() async {
    final prefs = _storage.getPreferences();
    
    // If reminders are not enabled, activate them
    if (!prefs.notificationsEnabled) {
      // Request permissions first
      final hasPermission = await _notificationService.requestPermissions();
      if (hasPermission) {
        // Activate reminders
        await _notificationService.startPeriodicReminders();
        
        // Update preferences
        final updatedPrefs = prefs.copyWith(notificationsEnabled: true);
        await _storage.savePreferences(updatedPrefs);
        
        debugPrint('✅ Reminders activated from notification tap');
        
        // Show a message to user if app is in foreground
        if (mounted && navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Reminders activated - Every 10 minutes ❤️',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // Trigger UI update if needed
        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint('⚠️ Permission denied - cannot activate reminders');
      }
    } else {
      debugPrint('ℹ️ Reminders already enabled');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app comes to foreground, check and reschedule notifications if needed
    if (state == AppLifecycleState.resumed) {
      final prefs = _storage.getPreferences();
      if (prefs.notificationsEnabled) {
        _notificationService.rescheduleIfNeeded();
      }
      
      // Reschedule daily notifications if times are configured
      if (prefs.scheduledNotificationTimes.isNotEmpty) {
        _notificationService.rescheduleDailyNotificationsIfNeeded(
          prefs.scheduledNotificationTimes,
        ).catchError((e) {
          debugPrint('Error rescheduling daily notifications: $e');
        });
      }
    }
  }

  void _onAppStateChanged() {
    if (!mounted) return;
    
    if (_appState.locale != null && _appState.locale != _locale) {
      setState(() {
        _locale = _appState.locale!;
      });
    }
    if (_appState.themeMode != null && _appState.themeMode != _themeMode) {
      setState(() {
        _themeMode = _appState.themeMode!;
      });
    }
    if (_appState.textScale != null && _appState.textScale != _textScale) {
      setState(() {
        _textScale = _appState.textScale!;
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

  void _loadTextScale() {
    final prefs = _storage.getPreferences();
    setState(() {
      _textScale = prefs.textScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check for language, theme, and text scale changes
    final prefs = _storage.getPreferences();
    final currentLocale = Locale(prefs.language);
    final currentTextScale = _appState.textScale ?? prefs.textScale;
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

    // Sync state with preferences and app state
    if (_locale != currentLocale || 
        _themeMode != currentThemeMode || 
        _textScale != currentTextScale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _locale = currentLocale;
            _themeMode = currentThemeMode;
            _textScale = currentTextScale;
          });
        }
      });
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Noor - نُور',
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
        Locale('ar', ''),
        Locale('en', ''),
      ],
      builder: (context, child) {
        final l10n = AppLocalizations.ofWithFallback(context);
        
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_textScale),
          ),
          child: Directionality(
            textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
