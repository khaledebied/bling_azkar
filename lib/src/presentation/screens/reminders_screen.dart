import 'package:flutter/material.dart';
import '../../domain/models/reminder.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import '../../utils/page_transitions.dart';
import '../../data/services/reminder_service.dart';
import '../../data/repositories/azkar_repository.dart';
import 'zikr_detail_screen.dart';
import 'player_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _reminderService = ReminderService();
  final _azkarRepo = AzkarRepository();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final reminders = _reminderService.getAllReminders();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reminders),
          elevation: 0,
        ),
        body: reminders.isEmpty
            ? _buildEmptyState(l10n)
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return _buildReminderCard(context, reminder, l10n);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noReminders,
            style: AppTheme.titleLarge.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noRemindersDesc,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Reminder reminder, AppLocalizations l10n) {
    return FutureBuilder<Zikr?>(
      future: _azkarRepo.getZikrById(reminder.zikrId),
      builder: (context, snapshot) {
        final zikr = snapshot.data;
        if (zikr == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(child: ZikrDetailScreen(zikr: zikr)),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: reminder.isActive
                              ? AppTheme.primaryGradient
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade300,
                                    Colors.grey.shade400,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          reminder.isActive
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getReminderDescription(reminder, l10n),
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: reminder.isActive,
                        onChanged: (value) async {
                          await _reminderService.toggleReminder(reminder.id);
                          setState(() {});
                        },
                        activeColor: AppTheme.primaryGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ZikrDetailScreen(zikr: zikr),
                              ),
                            );
                          },
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(l10n.viewZikr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            side: BorderSide(color: AppTheme.primaryGreen),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.deleteReminder),
                              content: Text(l10n.deleteReminderConfirm),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    l10n.delete,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _reminderService.deleteReminder(reminder.id);
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getReminderDescription(Reminder reminder, AppLocalizations l10n) {
    if (reminder.type == ReminderType.fixedDaily && reminder.fixedTime != null) {
      final time = reminder.fixedTime!;
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '${l10n.dailyAtFixedTime} $hour:$minute';
    } else if (reminder.type == ReminderType.interval &&
        reminder.intervalMinutes != null) {
      final minutes = reminder.intervalMinutes!;
      if (minutes < 60) {
        return '${l10n.every} $minutes ${minutes == 1 ? l10n.minute : l10n.minutes}';
      } else {
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        if (remainingMinutes == 0) {
          return '${l10n.every} $hours ${hours == 1 ? l10n.hour : l10n.hours}';
        } else {
          return '${l10n.every} $hours ${hours == 1 ? l10n.hour : l10n.hours} $remainingMinutes ${remainingMinutes == 1 ? l10n.minute : l10n.minutes}';
        }
      }
    }
    return l10n.isArabic ? 'تذكير' : 'Reminder';
  }
}

