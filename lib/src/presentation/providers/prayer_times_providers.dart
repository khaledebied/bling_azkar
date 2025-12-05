import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/storage_service.dart';

/// Provider for StorageService instance
final storageServiceProvider = Provider((ref) => StorageService());

/// Provider for stored location from preferences
final storedLocationProvider = Provider<Location?>((ref) {
  final storage = ref.read(storageServiceProvider);
  final prefs = storage.getPreferences();
  
  if (prefs.selectedLocationId != null &&
      prefs.selectedLocationLatitude != null &&
      prefs.selectedLocationLongitude != null) {
    return Location(
      id: prefs.selectedLocationId!,
      name: prefs.selectedLocationName ?? 'Unknown',
      latitude: prefs.selectedLocationLatitude!,
      longitude: prefs.selectedLocationLongitude!,
      countryCode: prefs.selectedLocationCountryCode ?? '',
      countryName: prefs.selectedLocationCountryName ?? '',
      hasFixedPrayerTime: false,
    );
  }
  
  return null;
});

/// Provider for GPS location (only if permission granted)
final gpsLocationProvider = FutureProvider.autoDispose<Location?>((ref) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    final repository = MuslimRepository();
    final location = await repository.reverseGeocoder(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    return location;
  } catch (e) {
    return null;
  }
});

/// Provider for current location (stored first, then GPS, then null)
final locationProvider = FutureProvider.autoDispose<Location?>((ref) async {
  // First check stored location
  final storedLocation = ref.read(storedLocationProvider);
  if (storedLocation != null) {
    return storedLocation;
  }
  
  // Then try GPS
  final gpsLocation = await ref.watch(gpsLocationProvider.future);
  if (gpsLocation != null) {
    return gpsLocation;
  }
  
  // No location available
  return null;
});

/// Provider for location availability status
final locationAvailableProvider = Provider<bool>((ref) {
  final storedLocation = ref.read(storedLocationProvider);
  if (storedLocation != null) return true;
  
  final gpsLocationAsync = ref.watch(gpsLocationProvider);
  return gpsLocationAsync.when(
    data: (location) => location != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for prayer times based on location
final prayerTimesProvider = FutureProvider.autoDispose<PrayerTime?>((ref) async {
  final location = await ref.watch(locationProvider.future);
  final repository = MuslimRepository();
  
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
