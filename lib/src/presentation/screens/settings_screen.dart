import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import '../../data/services/storage_service.dart';
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
    setState(() {
      _prefs = newPrefs;
    });
    _storage.savePreferences(newPrefs);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              color: AppTheme.textPrimary,
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
      child: SwitchListTile(
        title: Text(l10n.enableNotifications),
        subtitle: Text(
          _prefs.notificationsEnabled
              ? (l10n.isArabic ? 'مفعل' : 'Enabled')
              : (l10n.isArabic ? 'معطل' : 'Disabled'),
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        value: _prefs.notificationsEnabled,
        onChanged: (value) {
          _updatePreferences(_prefs.copyWith(notificationsEnabled: value));
        },
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildAppearanceCard(AppLocalizations l10n) {
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
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.theme),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // Theme picker can be added here
            },
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
              // Help screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(l10n.feedback),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // Feedback screen
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
        content: Text(l10n.isArabic
            ? 'سيتم حذف جميع البيانات بما في ذلك التذكيرات والمفضلة. هل أنت متأكد؟'
            : 'This will delete all data including reminders and favorites. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _storage.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.isArabic ? 'تم حذف جميع البيانات' : 'All data cleared'),
                ),
              );
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

