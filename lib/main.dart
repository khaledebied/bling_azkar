import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'src/utils/theme.dart';
import 'src/utils/localizations.dart';
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

  // Handle notification taps
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();
  notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        final zikrId = response.payload!;
        final azkarRepo = AzkarRepository();
        final zikr = await azkarRepo.getZikrById(zikrId);
        if (zikr != null && navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => PlayerScreen(zikr: zikr),
            ),
          );
        }
      }
    },
  );

  runApp(const ProviderScope(child: BlingAzkarApp()));
}

class BlingAzkarApp extends StatefulWidget {
  const BlingAzkarApp({super.key});

  @override
  State<BlingAzkarApp> createState() => _BlingAzkarAppState();
}

class _BlingAzkarAppState extends State<BlingAzkarApp> {
  final _storage = StorageService();
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLanguage();
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

  @override
  Widget build(BuildContext context) {
    // Check for language changes
    final prefs = _storage.getPreferences();
    final currentLocale = Locale(prefs.language);
    if (_locale != currentLocale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _locale = currentLocale;
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
      themeMode: ThemeMode.system,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        return Directionality(
          textDirection: l10n?.isArabic == true ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
