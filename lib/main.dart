import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/utils/theme.dart';
import 'src/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService().initialize();
  await NotificationService().initialize();
  await AudioPlayerService().initialize();

  runApp(const ProviderScope(child: BlingAzkarApp()));
}

class BlingAzkarApp extends StatelessWidget {
  const BlingAzkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bling Azkar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
