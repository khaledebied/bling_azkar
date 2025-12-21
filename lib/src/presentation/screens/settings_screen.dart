import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';
import '../../utils/app_state_provider.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/notification_service.dart';
import '../../domain/models/user_preferences.dart';
import 'privacy_policy_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  final _storage = StorageService();
  late UserPreferences _prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prefs = _storage.getPreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Refresh preferences when app comes to foreground
    // This catches changes made from notification taps
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          _prefs = _storage.getPreferences();
        });
        
        // Reschedule notifications if they're enabled
        if (_prefs.scheduledNotificationTimes.isNotEmpty) {
          final notificationService = NotificationService();
          notificationService.rescheduleDailyNotificationsIfNeeded(_prefs.scheduledNotificationTimes);
        }
      }
    }
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
          leading: IconButton(
            icon: Icon(DirectionIcons.backArrow(context)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          children: [
            // Language Section
            _buildSectionHeader(l10n.language, Icons.language),
            _buildLanguageCard(l10n),
            const SizedBox(height: 24),

            // Zikr Reminders Section
            _buildSectionHeader(
              l10n.zikrReminders,
              Icons.notifications_active,
            ),
            _buildRemindersCard(l10n),
            const SizedBox(height: 16),
            
            // Prayer Time Notifications
            _buildPrayerTimeNotificationsCard(l10n),
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
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
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


  Widget _buildRemindersCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.isDarkMode 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              l10n.isArabic ? 'الإشعارات المجدولة' : 'Scheduled Notifications',
              style: AppTheme.bodyMedium.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _prefs.scheduledNotificationTimes.isEmpty
                  ? (l10n.isArabic ? 'غير مفعل' : 'Disabled')
                  : (l10n.isArabic 
                      ? '${_prefs.scheduledNotificationTimes.length} ${_prefs.scheduledNotificationTimes.length == 1 ? 'وقت' : 'أوقات'}'
                      : '${_prefs.scheduledNotificationTimes.length} time${_prefs.scheduledNotificationTimes.length == 1 ? '' : 's'}'),
              style: AppTheme.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            value: _prefs.scheduledNotificationTimes.isNotEmpty,
            onChanged: (value) async {
              final notificationService = NotificationService();
              
              if (value) {
                // Request permissions first
                final hasPermission = await notificationService.requestPermissions();
                if (hasPermission) {
                  // Show time picker to add first time
                  _showAddScheduledTimeDialog(l10n);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.pleaseEnableNotificationsDevice,
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              } else {
                // Disable scheduled notifications
                await notificationService.cancelScheduledNotifications();
                final updatedPrefs = _prefs.copyWith(scheduledNotificationTimes: []);
                _updatePreferences(updatedPrefs);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.isArabic ? 'تم إلغاء الإشعارات المجدولة' : 'Scheduled notifications disabled',
                      ),
                      backgroundColor: Colors.grey,
                    ),
                  );
                }
              }
            },
            activeColor: AppTheme.primaryGreen,
          ),
          if (_prefs.scheduledNotificationTimes.isNotEmpty) ...[
            Divider(
              height: 1,
              color: context.isDarkMode 
                  ? Colors.grey.shade700
                  : Colors.grey.shade100,
            ),
            ..._prefs.scheduledNotificationTimes.map((timeStr) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: AppTheme.primaryGreen,
                    ),
                    title: Text(
                      timeStr,
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 20,
                            color: AppTheme.primaryTeal,
                          ),
                          onPressed: () => _showEditScheduledTimeDialog(l10n, timeStr),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red.shade400,
                          ),
                          onPressed: () => _removeScheduledTime(l10n, timeStr),
                        ),
                      ],
                    ),
                  ),
                  if (timeStr != _prefs.scheduledNotificationTimes.last)
                    Divider(
                      height: 1,
                      color: context.isDarkMode 
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                    ),
                ],
              );
            }).toList(),
            Divider(
              height: 1,
              color: context.isDarkMode 
                  ? Colors.grey.shade700
                  : Colors.grey.shade100,
            ),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryGreen,
              ),
              title: Text(
                l10n.isArabic ? 'إضافة وقت جديد' : 'Add New Time',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _showAddScheduledTimeDialog(l10n),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerTimeNotificationsCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.isDarkMode 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          l10n.isArabic ? 'إشعارات أوقات الصلاة' : 'Prayer Time Notifications',
          style: AppTheme.bodyMedium.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          l10n.isArabic 
              ? 'إشعار عند حلول وقت كل صلاة'
              : 'Get notified at each prayer time',
          style: AppTheme.bodySmall.copyWith(
            color: context.textSecondary,
          ),
        ),
        secondary: Icon(
          Icons.mosque_outlined,
          color: _prefs.prayerTimeNotificationsEnabled 
              ? AppTheme.primaryGreen 
              : context.textSecondary,
        ),
        value: _prefs.prayerTimeNotificationsEnabled,
        onChanged: (value) async {
          final notificationService = NotificationService();
          
          if (value) {
            // Request permissions first
            final hasPermission = await notificationService.requestPermissions();
            if (hasPermission) {
              // Enable prayer time notifications
              final updatedPrefs = _prefs.copyWith(prayerTimeNotificationsEnabled: true);
              _updatePreferences(updatedPrefs);
              
              // Schedule prayer time notifications
              await _schedulePrayerTimeNotifications();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.isArabic 
                          ? 'تم تفعيل إشعارات أوقات الصلاة'
                          : 'Prayer time notifications enabled',
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.pleaseEnableNotificationsDevice,
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } else {
            // Disable prayer time notifications
            await notificationService.cancelPrayerTimeNotifications();
            final updatedPrefs = _prefs.copyWith(prayerTimeNotificationsEnabled: false);
            _updatePreferences(updatedPrefs);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.isArabic 
                        ? 'تم إلغاء إشعارات أوقات الصلاة'
                        : 'Prayer time notifications disabled',
                  ),
                  backgroundColor: Colors.grey,
                ),
              );
            }
          }
        },
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Future<void> _schedulePrayerTimeNotifications() async {
    try {
      // Get prayer times from storage
      final storage = StorageService();
      final prefs = storage.getPreferences();
      
      // Check if we have a location
      if (prefs.selectedLocationLatitude == null || prefs.selectedLocationLongitude == null) {
        debugPrint('No location set, cannot schedule prayer time notifications');
        return;
      }
      
      // Get prayer times using MuslimRepository
      final repository = MuslimRepository();
      final location = Location(
        id: prefs.selectedLocationId ?? 0,
        name: prefs.selectedLocationName ?? 'Unknown',
        latitude: prefs.selectedLocationLatitude!,
        longitude: prefs.selectedLocationLongitude!,
        countryCode: prefs.selectedLocationCountryCode ?? '',
        countryName: prefs.selectedLocationCountryName ?? '',
        hasFixedPrayerTime: false,
      );
      
      final prayerAttribute = PrayerAttribute(
        calculationMethod: CalculationMethod.mwl,
        asrMethod: AsrMethod.shafii,
        higherLatitudeMethod: HigherLatitudeMethod.midNight,
        offset: [0, 0, 0, 0, 0, 0],
      );
      
      final prayerTime = await repository.getPrayerTimes(
        location: location,
        date: DateTime.now(),
        attribute: prayerAttribute,
      );
      
      if (prayerTime == null) {
        debugPrint('Could not get prayer times');
        return;
      }
      
      // Create prayer times map
      final prayerTimes = {
        'fajr': prayerTime.fajr,
        'dhuhr': prayerTime.dhuhr,
        'asr': prayerTime.asr,
        'maghrib': prayerTime.maghrib,
        'isha': prayerTime.isha,
      };
      
      // Schedule notifications
      final notificationService = NotificationService();
      await notificationService.schedulePrayerTimeNotifications(
        prayerTimes: prayerTimes,
        isArabic: prefs.language == 'ar',
      );
    } catch (e) {
      debugPrint('Error scheduling prayer time notifications: $e');
    }
  }

  void _showAddScheduledTimeDialog(AppLocalizations l10n) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      
      // Check if time already exists
      if (_prefs.scheduledNotificationTimes.contains(timeStr)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.isArabic ? 'هذا الوقت موجود بالفعل' : 'This time already exists',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Add the new time
      final updatedTimes = List<String>.from(_prefs.scheduledNotificationTimes)..add(timeStr);
      updatedTimes.sort(); // Sort times chronologically
      
      final updatedPrefs = _prefs.copyWith(scheduledNotificationTimes: updatedTimes);
      _updatePreferences(updatedPrefs);
      
      // Schedule notifications
      await _scheduleNotifications(updatedTimes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.isArabic 
                  ? 'تم إضافة الوقت بنجاح'
                  : 'Time added successfully',
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  void _showEditScheduledTimeDialog(AppLocalizations l10n, String currentTime) async {
    final timeParts = currentTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newTimeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      
      // Check if new time already exists (and it's not the current one)
      if (_prefs.scheduledNotificationTimes.contains(newTimeStr) && newTimeStr != currentTime) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.isArabic ? 'هذا الوقت موجود بالفعل' : 'This time already exists',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Update the time
      final updatedTimes = List<String>.from(_prefs.scheduledNotificationTimes);
      final index = updatedTimes.indexOf(currentTime);
      if (index != -1) {
        updatedTimes[index] = newTimeStr;
        updatedTimes.sort(); // Sort times chronologically
        
        final updatedPrefs = _prefs.copyWith(scheduledNotificationTimes: updatedTimes);
        _updatePreferences(updatedPrefs);
        
        // Reschedule notifications
        await _scheduleNotifications(updatedTimes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.isArabic 
                    ? 'تم تحديث الوقت بنجاح'
                    : 'Time updated successfully',
              ),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeScheduledTime(AppLocalizations l10n, String timeStr) async {
    final updatedTimes = List<String>.from(_prefs.scheduledNotificationTimes)..remove(timeStr);
    
    final updatedPrefs = _prefs.copyWith(scheduledNotificationTimes: updatedTimes);
    _updatePreferences(updatedPrefs);
    
    // Reschedule notifications
    await _scheduleNotifications(updatedTimes);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isArabic 
                ? 'تم حذف الوقت'
                : 'Time removed',
          ),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  Future<void> _scheduleNotifications(List<String> times) async {
    final notificationService = NotificationService();
    final l10n = AppLocalizations.ofWithFallback(context);
    
    // Request permissions first
    final hasPermission = await notificationService.requestPermissions();
    if (hasPermission) {
      await notificationService.scheduleDailyNotifications(
        times: times,
        title: l10n.isArabic ? 'وقت الذكر' : 'Time for Zikr',
        body: l10n.isArabic ? 'لا تنسى ذكر الله ❤️' : 'Don\'t forget to remember Allah ❤️',
      );
    }
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
                Text(l10n.light),
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
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.dark_mode, size: 20),
                const SizedBox(width: 12),
                Text(l10n.dark),
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
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.brightness_auto, size: 20),
                const SizedBox(width: 12),
                Text(l10n.system),
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
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(l10n.textSize),
            subtitle: Text('${(_prefs.textScale * 100).toInt()}%'),
            trailing: Icon(DirectionIcons.listArrow(context), size: 16, color: Colors.grey),
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
            trailing: Icon(DirectionIcons.listArrow(context), size: 16, color: Colors.grey),
            onTap: () {
              _showClearCacheDialog(l10n);
            },
          ),
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(l10n.clearAllData),
            trailing: Icon(DirectionIcons.listArrow(context), size: 16, color: Colors.grey),
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
            trailing: Icon(DirectionIcons.listArrow(context), size: 16, color: Colors.grey),
          ),
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.help),
            trailing: Icon(DirectionIcons.listArrow(context), size: 16, color: Colors.grey),
            onTap: () {
              _showHelpDialog(l10n);
            },
          ),
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: Icon(DirectionIcons.listArrow(context), size: 16, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
          ListTile(
            leading: const Icon(Icons.star_rate_outlined),
            title: Text(l10n.rateApp),
            trailing: Icon(DirectionIcons.listArrow(context), size: 16, color: Colors.grey),
            onTap: () {
              _launchStore(l10n);
            },
          ),
          Divider(
            height: 1,
            color: context.isDarkMode 
                ? Colors.grey.shade700
                : Colors.grey.shade100,
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(l10n.feedback),
            trailing: Icon(DirectionIcons.listArrow(context), size: 16, color: Colors.grey),
            onTap: () {
              _showFeedbackDialog(l10n);
            },
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog(AppLocalizations l10n) {
    double tempTextScale = _prefs.textScale;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          l10n.textSize,
          style: AppTheme.titleMedium.copyWith(
            color: context.textPrimary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(tempTextScale * 100).toInt()}%',
                style: AppTheme.headlineMedium.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: tempTextScale,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: '${(tempTextScale * 100).toInt()}%',
                onChanged: (value) {
                  setState(() {
                    tempTextScale = value;
                  });
                },
                activeColor: AppTheme.primaryGreen,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // Update preferences
              _updatePreferences(_prefs.copyWith(textScale: tempTextScale));
              
              // Notify app state to rebuild immediately
              final appState = ref.read(appStateProvider);
              appState.updateTextScale(tempTextScale);
              
              // Update local state
              setState(() {
                _prefs = _prefs.copyWith(textScale: tempTextScale);
              });
              
              Navigator.pop(dialogContext);
            },
            child: Text(
              l10n.done,
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                SnackBar(content: Text(l10n.cacheCleared)),
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
                    '• اختر بين الوضع الفاتح والداكن'
                : 'Bling Azkar helps you remember daily supplications.\n\n'
                    '• Browse azkar by categories\n'
                    '• Add azkar to favorites\n'
                    '• Listen to azkar with audio\n'
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

  Future<void> _launchStore(AppLocalizations l10n) async {
    const packageName = 'com.blingazkar.bling_azkar';
    
    final Uri uri;
    if (Platform.isAndroid) {
      uri = Uri.parse('market://details?id=$packageName');
    } else {
      uri = Uri.parse('https://apps.apple.com/search?term=Bling%20Azkar');
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final webUri = Uri.parse(
          Platform.isAndroid 
              ? 'https://play.google.com/store/apps/details?id=$packageName'
              : 'https://apps.apple.com/search?term=Bling%20Azkar'
        );
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOpeningStore),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

