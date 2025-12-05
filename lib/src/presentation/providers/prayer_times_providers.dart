import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Provider for MuslimRepository instance
final muslimRepositoryProvider = Provider((ref) => MuslimRepository());

/// Provider for current location
final locationProvider = FutureProvider.autoDispose<Location?>((ref) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _getDefaultLocation();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _getDefaultLocation();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return _getDefaultLocation();
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    final repository = ref.read(muslimRepositoryProvider);
    final location = await repository.reverseGeocoder(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    return location ?? _getDefaultLocation();
  } catch (e) {
    return _getDefaultLocation();
  }
});

/// Default location (Makkah)
Location _getDefaultLocation() {
  return Location(
    id: 1,
    name: 'Makkah',
    countryName: 'Saudi Arabia',
    countryCode: 'SA',
    latitude: 21.4225,
    longitude: 39.8262,
    hasFixedPrayerTime: false,
  );
}

/// Provider for prayer times based on location
final prayerTimesProvider = FutureProvider.autoDispose<PrayerTime?>((ref) async {
  final location = await ref.watch(locationProvider.future);
  final repository = ref.read(muslimRepositoryProvider);
  
  if (location == null) {
    return null;
  }

  try {
    final prayerAttribute = PrayerAttribute(
      calculationMethod: CalculationMethod.mwl,
      asrMethod: AsrMethod.shafii,
      higherLatitudeMethod: HigherLatitudeMethod.midNight,
      offset: [0, 0, 0, 0, 0, 0],
    );

    return await repository.getPrayerTimes(
      location: location,
      date: DateTime.now(),
      attribute: prayerAttribute,
    );
  } catch (e) {
    return null;
  }
});

/// Model for next prayer
class NextPrayer {
  final String prayer;
  final DateTime time;

  NextPrayer({
    required this.prayer,
    required this.time,
  });

  Duration get timeUntil => time.difference(DateTime.now());
  
  String get prayerName {
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
  
  String get prayerNameAr {
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
  }
}

/// Provider for next prayer time
final nextPrayerProvider = Provider.autoDispose<NextPrayer?>((ref) {
  final prayerTimesAsync = ref.watch(prayerTimesProvider);
  
  return prayerTimesAsync.when(
    data: (prayerTime) {
      if (prayerTime == null) return null;
      
      final now = DateTime.now();
      final prayers = [
        ('fajr', prayerTime.fajr),
        ('dhuhr', prayerTime.dhuhr),
        ('asr', prayerTime.asr),
        ('maghrib', prayerTime.maghrib),
        ('isha', prayerTime.isha),
      ];
      
      for (var (prayer, time) in prayers) {
        if (time.isAfter(now)) {
          return NextPrayer(
            prayer: prayer,
            time: time,
          );
        }
      }
      
      // If all prayers have passed, return Fajr for tomorrow
      return NextPrayer(
        prayer: 'fajr',
        time: prayerTime.fajr.add(const Duration(days: 1)),
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
