import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'src/utils/theme.dart';
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

class BlingAzkarApp extends StatelessWidget {
  const BlingAzkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Bling Azkar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
