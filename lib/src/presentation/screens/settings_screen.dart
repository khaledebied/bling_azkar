import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/app_state_provider.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/notification_service.dart';
import '../../domain/models/user_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _storage = StorageService();
  late UserPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = _storage.getPreferences();
  }

  void _updatePreferences(UserPreferences newPrefs) {
    final oldPrefs = _prefs;
    setState(() {
      _prefs = newPrefs;
    });
    _storage.savePreferences(newPrefs);
    
    // Immediately update app state
    final appState = AppStateNotifier();
    if (newPrefs.language != oldPrefs.language) {
      appState.updateLocale(Locale(newPrefs.language));
    }
    if (newPrefs.themeMode != oldPrefs.themeMode) {
      switch (newPrefs.themeMode) {
        case 'light':
          appState.updateThemeMode(ThemeMode.light);
          break;
        case 'dark':
          appState.updateThemeMode(ThemeMode.dark);
          break;
        default:
          appState.updateThemeMode(ThemeMode.system);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          elevation: 0,
        ),
        body: ListView(
          children: [
            // Language Section
            _buildSectionHeader(l10n.language, Icons.language),
            _buildLanguageCard(l10n),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader(l10n.notifications, Icons.notifications),
            _buildNotificationCard(l10n),
            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader(l10n.appearance, Icons.palette),
            _buildAppearanceCard(l10n),
            const SizedBox(height: 24),

            // Storage Section
            _buildSectionHeader(l10n.storage, Icons.storage),
            _buildStorageCard(l10n),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(l10n.about, Icons.info),
            _buildAboutCard(l10n),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Row(
              children: [
                const Text('🇬🇧'),
                const SizedBox(width: 12),
                Text(l10n.english),
              ],
            ),
            value: 'en',
            groupValue: _prefs.language,
            onChanged: (value) {
              if (value != null && value != _prefs.language) {
                _updatePreferences(_prefs.copyWith(language: value));
                // The app will reload on next build
              }
            },
            activeColor: AppTheme.primaryGreen,
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: Row(
              children: [
                const Text('🇸🇦'),
                const SizedBox(width: 12),
                Text(l10n.arabic),
              ],
            ),
            value: 'ar',
            groupValue: _prefs.language,
            onChanged: (value) {
              if (value != null && value != _prefs.language) {
                _updatePreferences(_prefs.copyWith(language: value));
                // The app will reload on next build
              }
            },
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(l10n.enableNotifications),
            subtitle: Text(
              _prefs.notificationsEnabled
                  ? (l10n.isArabic ? 'مفعل' : 'Enabled')
                  : (l10n.isArabic ? 'معطل' : 'Disabled'),
              style: AppTheme.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            value: _prefs.notificationsEnabled,
            onChanged: (value) {
              _updatePreferences(_prefs.copyWith(notificationsEnabled: value));
            },
            activeColor: AppTheme.primaryGreen,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notification_important, color: AppTheme.primaryGreen),
            title: Text(l10n.isArabic ? 'اختبار الإشعار' : 'Test Notification'),
            subtitle: Text(l10n.isArabic 
                ? 'إرسال إشعار تجريبي الآن'
                : 'Send a test notification now'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final notificationService = NotificationService();
              final hasPermission = await notificationService.requestPermissions();
              if (hasPermission) {
                await notificationService.showTestNotification(
                  l10n.isArabic ? 'اختبار الإشعار' : 'Test Notification',
                  l10n.isArabic 
                      ? 'هذا إشعار تجريبي من تطبيق بلينج أذكار'
                      : 'This is a test notification from Bling Azkar',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.isArabic 
                          ? 'تم إرسال الإشعار التجريبي'
                          : 'Test notification sent'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.pleaseEnableNotifications),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.schedule, color: AppTheme.primaryTeal),
            title: Text(l10n.isArabic ? 'اختبار بعد 10 ثواني' : 'Test in 10 seconds'),
            subtitle: Text(l10n.isArabic 
                ? 'جدولة إشعار تجريبي بعد 10 ثواني (للمحاكي)'
                : 'Schedule a test notification in 10 seconds (for simulator)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final notificationService = NotificationService();
              final hasPermission = await notificationService.requestPermissions();
              if (hasPermission) {
                await notificationService.scheduleTestNotificationInSeconds(
                  l10n.isArabic ? 'اختبار الإشعار' : 'Test Notification',
                  l10n.isArabic 
                      ? 'هذا إشعار مجدول من تطبيق بلينج أذكار'
                      : 'This is a scheduled test notification from Bling Azkar',
                  10,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.isArabic 
                          ? 'سيتم إرسال الإشعار بعد 10 ثواني'
                          : 'Notification will be sent in 10 seconds'),
                      backgroundColor: AppTheme.primaryTeal,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.pleaseEnableNotifications),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(AppLocalizations l10n) {
    final currentThemeMode = _prefs.themeMode;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.light_mode, size: 20),
                const SizedBox(width: 12),
                Text(l10n.isArabic ? 'فاتح' : 'Light'),
              ],
            ),
            value: 'light',
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                _updatePreferences(_prefs.copyWith(themeMode: value));
              }
            },
            activeColor: AppTheme.primaryGreen,
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.dark_mode, size: 20),
                const SizedBox(width: 12),
                Text(l10n.isArabic ? 'داكن' : 'Dark'),
              ],
            ),
            value: 'dark',
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                _updatePreferences(_prefs.copyWith(themeMode: value));
              }
            },
            activeColor: AppTheme.primaryGreen,
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.brightness_auto, size: 20),
                const SizedBox(width: 12),
                Text(l10n.isArabic ? 'نظام' : 'System'),
              ],
            ),
            value: 'system',
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                _updatePreferences(_prefs.copyWith(themeMode: value));
              }
            },
            activeColor: AppTheme.primaryGreen,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(l10n.textSize),
            subtitle: Text('${(_prefs.textScale * 100).toInt()}%'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              _showTextSizeDialog(l10n);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.orange),
            title: Text(l10n.clearCache),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              _showClearCacheDialog(l10n);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(l10n.clearAllData),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              _showClearAllDataDialog(l10n);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: const Text('1.0.0'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.help),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              _showHelpDialog(l10n);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(l10n.feedback),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              _showFeedbackDialog(l10n);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.licenses),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              showLicensePage(context: context);
            },
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.textSize),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(_prefs.textScale * 100).toInt()}%'),
              Slider(
                value: _prefs.textScale,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: '${(_prefs.textScale * 100).toInt()}%',
                onChanged: (value) {
                  setState(() {
                    _updatePreferences(_prefs.copyWith(textScale: value));
                  });
                },
                activeColor: AppTheme.primaryGreen,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.isArabic
            ? 'هل أنت متأكد من مسح الذاكرة المؤقتة؟'
            : 'Are you sure you want to clear the cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // Clear cache logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.isArabic ? 'تم مسح الذاكرة المؤقتة' : 'Cache cleared')),
              );
            },
            child: Text(l10n.clear, style: const TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.confirmClearAllData),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _storage.clearAllData();
              if (!mounted) return;
              setState(() {
                _prefs = _storage.getPreferences();
              });
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.allDataCleared),
                  ),
                );
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.help),
        content: SingleChildScrollView(
          child: Text(
            l10n.isArabic
                ? 'تطبيق بلينج أذكار يساعدك على تذكر الأذكار اليومية.\n\n'
                    '• تصفح الأذكار حسب الفئات\n'
                    '• أضف الأذكار إلى المفضلة\n'
                    '• استمع إلى الأذكار بصوت\n'
                    '• اضبط التذكيرات اليومية\n'
                    '• اختر بين الوضع الفاتح والداكن'
                : 'Bling Azkar helps you remember daily supplications.\n\n'
                    '• Browse azkar by categories\n'
                    '• Add azkar to favorites\n'
                    '• Listen to azkar with audio\n'
                    '• Set daily reminders\n'
                    '• Choose between light and dark theme',
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(AppLocalizations l10n) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.feedback),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: l10n.isArabic
                ? 'اكتب ملاحظاتك أو اقتراحاتك هنا...'
                : 'Write your feedback or suggestions here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // In a real app, you would send this to a server
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.isArabic
                        ? 'شكراً لملاحظاتك!'
                        : 'Thank you for your feedback!'),
                  ),
                );
              }
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }
}

