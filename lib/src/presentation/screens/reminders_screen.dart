import 'package:flutter/material.dart';
import '../../domain/models/reminder.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
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
    final reminders = _reminderService.getAllReminders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        elevation: 0,
      ),
      body: reminders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return _buildReminderCard(reminder);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
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
            'No Reminders',
            style: AppTheme.titleLarge.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set reminders to get notified about your daily Azkar',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
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
                MaterialPageRoute(
                  builder: (context) => ZikrDetailScreen(zikr: zikr),
                ),
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
                              _getReminderDescription(reminder),
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
                          label: const Text('View Zikr'),
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
                              title: const Text('Delete Reminder'),
                              content: const Text(
                                  'Are you sure you want to delete this reminder?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
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

  String _getReminderDescription(Reminder reminder) {
    if (reminder.type == ReminderType.fixedDaily && reminder.fixedTime != null) {
      final time = reminder.fixedTime!;
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return 'Daily at $hour:$minute';
    } else if (reminder.type == ReminderType.interval &&
        reminder.intervalMinutes != null) {
      final minutes = reminder.intervalMinutes!;
      if (minutes < 60) {
        return 'Every $minutes minutes';
      } else {
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        if (remainingMinutes == 0) {
          return 'Every $hours ${hours == 1 ? 'hour' : 'hours'}';
        } else {
          return 'Every $hours h $remainingMinutes m';
        }
      }
    }
    return 'Reminder';
  }
}

