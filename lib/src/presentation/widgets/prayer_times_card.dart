import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../providers/prayer_times_providers.dart';
import 'location_selection_dialog.dart';
import 'dart:async';

class PrayerTimesCard extends ConsumerStatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  ConsumerState<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends ConsumerState<PrayerTimesCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();

    // Update every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        ref.invalidate(prayerTimesProvider);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isDarkMode = context.isDarkMode;
    final locationAvailable = ref.watch(locationAvailableProvider);
    final storedLocation = ref.read(storedLocationProvider);
    
    // If no location available, show selection prompt
    if (!locationAvailable) {
      return _buildLocationSelectionPrompt(context, l10n, isDarkMode);
    }
    
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.15),
                      AppTheme.primaryTeal.withValues(alpha: 0.15),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.08),
                      AppTheme.primaryTeal.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                  ),
            color: isDarkMode ? context.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode
                  ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                  : AppTheme.primaryGreen.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : AppTheme.primaryGreen.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mosque,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.isArabic ? 'أوقات الصلاة' : 'Prayer Times',
                                style: AppTheme.titleMedium.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (storedLocation != null)
                              IconButton(
                                icon: Icon(
                                  Icons.edit_location_alt,
                                  size: 20,
                                  color: AppTheme.primaryGreen,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const LocationSelectionDialog(),
                                  );
                                },
                                tooltip: l10n.isArabic ? 'تغيير الموقع' : 'Change Location',
                              ),
                          ],
                        ),
                        if (storedLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            storedLocation.name,
                            style: AppTheme.bodySmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                        if (nextPrayer != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.isArabic
                                ? '${nextPrayer.prayerNameAr} ${_formatTimeUntil(nextPrayer.timeUntil, l10n.isArabic)}'
                                : '${nextPrayer.prayerName} in ${_formatTimeUntil(nextPrayer.timeUntil, false)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Prayer Times List
              prayerTimesAsync.when(
                loading: () => _buildLoadingSkeleton(isDarkMode),
                error: (error, stack) => _buildErrorWidget(l10n, isDarkMode),
                data: (prayerTimes) {
                  if (prayerTimes == null) {
                    return _buildErrorWidget(l10n, isDarkMode);
                  }
                  return _buildPrayerTimesList(prayerTimes, nextPrayer, l10n, isDarkMode);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesList(
    PrayerTime prayerTimes,
    NextPrayer? nextPrayer,
    AppLocalizations l10n,
    bool isDarkMode,
  ) {
    final prayers = [
      ('fajr', prayerTimes.fajr),
      ('dhuhr', prayerTimes.dhuhr),
      ('asr', prayerTimes.asr),
      ('maghrib', prayerTimes.maghrib),
      ('isha', prayerTimes.isha),
    ];

    return Column(
      children: prayers.asMap().entries.map((entry) {
        final index = entry.key;
        final prayerEntry = entry.value;
        final prayer = prayerEntry.$1;
        final prayerTime = prayerEntry.$2;
        final isNext = nextPrayer?.prayer == prayer;
        final prayerName = _getPrayerName(prayer, l10n.isArabic);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isNext
                  ? AppTheme.primaryGreen.withValues(alpha: isDarkMode ? 0.2 : 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isNext
                  ? Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Prayer Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isNext
                        ? AppTheme.primaryGradient
                        : LinearGradient(
                            colors: [
                              AppTheme.primaryGreen.withValues(alpha: 0.1),
                              AppTheme.primaryTeal.withValues(alpha: 0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getPrayerIcon(prayer),
                    color: isNext
                        ? Colors.white
                        : AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Prayer Name
                Expanded(
                  child: Text(
                    prayerName,
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.textPrimary,
                      fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                // Prayer Time
                Text(
                  _formatTime(prayerTime),
                  style: AppTheme.bodyMedium.copyWith(
                    color: isNext
                        ? AppTheme.primaryGreen
                        : context.textPrimary,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingSkeleton(bool isDarkMode) {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 60,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey.shade800.withValues(alpha: 0.3)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }

  Widget _buildErrorWidget(AppLocalizations l10n, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.isArabic
                  ? 'لا يمكن تحديد الموقع'
                  : 'Unable to get location',
              style: AppTheme.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrayerName(String prayer, bool isArabic) {
    if (isArabic) {
      switch (prayer) {
        case 'fajr':
          return 'الفجر';
        case 'dhuhr':
          return 'الظهر';
        case 'asr':
          return 'العصر';
        case 'maghrib':
          return 'المغرب';
        case 'isha':
          return 'العشاء';
        default:
          return '';
      }
    } else {
      switch (prayer) {
        case 'fajr':
          return 'Fajr';
        case 'dhuhr':
          return 'Dhuhr';
        case 'asr':
          return 'Asr';
        case 'maghrib':
          return 'Maghrib';
        case 'isha':
          return 'Isha';
        default:
          return '';
      }
    }
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_twilight_outlined;
      case 'maghrib':
        return Icons.wb_twilight;
      case 'isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeUntil(Duration duration, bool isArabic) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (isArabic) {
        return '$hours س $minutes د';
      }
      return '${hours}h ${minutes}m';
    } else {
      final minutes = duration.inMinutes;
      if (isArabic) {
        return '$minutes دقيقة';
      }
      return '$minutes min';
    }
  }

  Widget _buildLocationSelectionPrompt(
    BuildContext context,
    AppLocalizations l10n,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.15),
                  AppTheme.primaryTeal.withValues(alpha: 0.15),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.08),
                  AppTheme.primaryTeal.withValues(alpha: 0.08),
                  Colors.white,
                ],
              ),
        color: isDarkMode ? context.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? AppTheme.primaryGreen.withValues(alpha: 0.2)
              : AppTheme.primaryGreen.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : AppTheme.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_off,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.isArabic
                ? 'اختر موقعك لعرض أوقات الصلاة'
                : 'Select your location to view prayer times',
            style: AppTheme.titleMedium.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.isArabic
                ? 'يجب تحديد موقعك لعرض أوقات الصلاة بدقة'
                : 'Please select your location to display accurate prayer times',
            style: AppTheme.bodySmall.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const LocationSelectionDialog(),
              );
            },
            icon: const Icon(Icons.location_on, color: Colors.white),
            label: Text(
              l10n.isArabic ? 'اختر الموقع' : 'Select Location',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }
}

