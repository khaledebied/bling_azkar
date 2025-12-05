import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hisn_el_muslim_repository.dart';
import '../../domain/models/zikr.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/user_preferences.dart';
import 'azkar_providers.dart';

/// Provider for HisnElMuslimRepository instance
final hisnElMuslimRepositoryProvider = Provider<HisnElMuslimRepository>((ref) {
  return HisnElMuslimRepository();
});

/// Provider for all Hisn el Muslim azkar with caching
final allHisnElMuslimAzkarProvider = FutureProvider<List<Zikr>>((ref) async {
  final repository = ref.watch(hisnElMuslimRepositoryProvider);
  return repository.loadHisnElMuslimAzkar();
});

/// Provider for searched/filtered Hisn el Muslim azkar
final searchedHisnElMuslimAzkarProvider = FutureProvider<List<Zikr>>((ref) async {
  final repository = ref.watch(hisnElMuslimRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return repository.loadHisnElMuslimAzkar();
  }
  
  return repository.searchAzkar(searchQuery);
});

/// Provider for favorite Hisn el Muslim azkar
final favoriteHisnElMuslimAzkarProvider = FutureProvider<List<Zikr>>((ref) async {
  final allAzkar = await ref.watch(allHisnElMuslimAzkarProvider.future);
  final prefs = ref.watch(userPreferencesProvider);
  
  return allAzkar.where((zikr) => prefs.favoriteZikrIds.contains(zikr.id)).toList();
});

/// Provider to check if a specific Hisn el Muslim zikr is favorite
final isHisnElMuslimFavoriteProvider = Provider.family<bool, String>((ref, zikrId) {
  final prefs = ref.watch(userPreferencesProvider);
  return prefs.favoriteZikrIds.contains(zikrId);
});

/// Provider to toggle favorite status for Hisn el Muslim
final toggleHisnElMuslimFavoriteProvider = Provider<Future<void> Function(String)>((ref) {
  return (String zikrId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.toggleFavorite(zikrId);
    
    // Update the preferences provider with fresh data immediately
    final newPrefs = storage.getPreferences();
    ref.read(userPreferencesProvider.notifier).state = newPrefs;
    
    // Force immediate refresh of all dependent providers
    ref.invalidate(userPreferencesProvider);
    ref.invalidate(favoriteHisnElMuslimAzkarProvider);
    ref.invalidate(isHisnElMuslimFavoriteProvider(zikrId));
    
    // Refresh to trigger immediate rebuild
    ref.refresh(favoriteHisnElMuslimAzkarProvider);
  };
});

/// Provider for Hisn el Muslim zikr by ID
final hisnElMuslimZikrByIdProvider = FutureProvider.family<Zikr?, String>((ref, zikrId) async {
  final repository = ref.watch(hisnElMuslimRepositoryProvider);
  return repository.getZikrById(zikrId);
});

