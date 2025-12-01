import 'package:flutter/material.dart';
import '../../domain/models/zikr.dart';
import '../../domain/models/reminder.dart';
import '../../utils/theme.dart';
import '../../data/services/audio_player_service.dart';
import '../../data/services/reminder_service.dart';
import '../../data/services/notification_service.dart';
import 'player_screen.dart';

class ZikrDetailScreen extends StatefulWidget {
  final Zikr zikr;

  const ZikrDetailScreen({super.key, required this.zikr});

  @override
  State<ZikrDetailScreen> createState() => _ZikrDetailScreenState();
}

class _ZikrDetailScreenState extends State<ZikrDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final _audioService = AudioPlayerService();
  final _reminderService = ReminderService();
  final _notificationService = NotificationService();
  bool _hasActiveReminder = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _checkReminderStatus();
  }

  Future<void> _checkReminderStatus() async {
    final hasReminder = _reminderService.hasActiveReminder(widget.zikr.id);
    setState(() {
      _hasActiveReminder = hasReminder;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildTitleSection(),
                  _buildArabicTextSection(),
                  _buildTranslationSection(),
                  _buildRepetitionSection(),
                  _buildAudioSection(),
                  _buildReminderSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerScreen(zikr: widget.zikr),
            ),
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Play Full Audio'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.zikr.title.en,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Hero(
          tag: 'zikr_${widget.zikr.id}',
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    widget.zikr.title.ar,
                    style: AppTheme.arabicLarge.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            widget.zikr.title.ar,
            style: AppTheme.arabicLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.zikr.title.en,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArabicTextSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.book_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Arabic Text',
                style: AppTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.zikr.text,
            style: AppTheme.arabicLarge.copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationSection() {
    if (widget.zikr.translation?.en.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.translate,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Translation',
                style: AppTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.zikr.translation!.en,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepetitionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.repeat,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Repetitions',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.zikr.defaultCount}x',
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Audio Preview',
              style: AppTheme.titleMedium,
            ),
          ),
          ...widget.zikr.audio.map((audio) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.headphones,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: const Text('Audio Recitation'),
                subtitle: const Text('Tap to play'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  color: AppTheme.primaryGreen,
                  onPressed: () async {
                    try {
                      await _audioService.playAudio(
                        audio.fullFileUrl,
                        isLocal: true,
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error playing audio: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () async {
          final hasPermission = await _notificationService.requestPermissions();
          if (!hasPermission) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enable notifications in settings'),
                ),
              );
            }
            return;
          }
          _showReminderDialog(context);
        },
        icon: Icon(_hasActiveReminder ? Icons.notifications_active : Icons.notifications_outlined),
        label: Text(_hasActiveReminder ? 'Manage Reminder' : 'Set Reminder'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    final existingReminders = _reminderService.getRemindersForZikr(widget.zikr.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Set Reminder',
                style: AppTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if (existingReminders.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Active Reminders:',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...existingReminders.map((reminder) => _buildReminderListItem(context, reminder)),
              const Divider(),
            ],
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule, color: Colors.white, size: 20),
              ),
              title: const Text('Daily at Fixed Time'),
              subtitle: const Text('Get reminded at the same time every day'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showTimePicker(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timer, color: Colors.white, size: 20),
              ),
              title: const Text('Every X Minutes'),
              subtitle: const Text('Get reminded at regular intervals'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showIntervalPicker(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderListItem(BuildContext context, Reminder reminder) {
    return ListTile(
      leading: Icon(
        reminder.isActive ? Icons.notifications_active : Icons.notifications_off,
        color: reminder.isActive ? AppTheme.primaryGreen : Colors.grey,
      ),
      title: Text(
        reminder.type == ReminderType.fixedDaily
            ? 'Daily at ${_formatTime(reminder.fixedTime)}'
            : 'Every ${reminder.intervalMinutes} minutes',
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        reminder.isActive ? 'Active' : 'Inactive',
        style: AppTheme.caption.copyWith(
          color: reminder.isActive ? AppTheme.primaryGreen : Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              reminder.isActive ? Icons.toggle_on : Icons.toggle_off,
              color: reminder.isActive ? AppTheme.primaryGreen : Colors.grey,
            ),
            onPressed: () async {
              await _reminderService.toggleReminder(reminder.id);
              if (mounted) {
                Navigator.pop(context);
                _checkReminderStatus();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Reminder'),
                  content: const Text('Are you sure you want to delete this reminder?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await _reminderService.deleteReminder(reminder.id);
                Navigator.pop(context);
                _checkReminderStatus();
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      try {
        await _reminderService.createReminder(
          zikrId: widget.zikr.id,
          type: ReminderType.fixedDaily,
          fixedTime: scheduledTime,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder set for ${_formatTime(scheduledTime)}'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          _checkReminderStatus();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating reminder: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showIntervalPicker(BuildContext context) async {
    int selectedMinutes = 30;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Interval'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Every $selectedMinutes minutes',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: selectedMinutes.toDouble(),
                min: 5,
                max: 480,
                divisions: 95,
                label: '$selectedMinutes minutes',
                onChanged: (value) {
                  setState(() {
                    selectedMinutes = value.round();
                  });
                },
                activeColor: AppTheme.primaryGreen,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [15, 30, 60, 120, 240]
                    .map((minutes) => ChoiceChip(
                          label: Text('${minutes}m'),
                          selected: selectedMinutes == minutes,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedMinutes = minutes;
                              });
                            }
                          },
                          selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _reminderService.createReminder(
                  zikrId: widget.zikr.id,
                  type: ReminderType.interval,
                  intervalMinutes: selectedMinutes,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminder set for every $selectedMinutes minutes'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                  _checkReminderStatus();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating reminder: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Set', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
