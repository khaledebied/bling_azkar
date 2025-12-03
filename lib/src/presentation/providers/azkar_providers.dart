import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/azkar_repository.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/zikr.dart';
import '../../domain/models/user_preferences.dart';
import 'search_providers.dart';

/// Provider for AzkarRepository instance
final azkarRepositoryProvider = Provider<AzkarRepository>((ref) {
  return AzkarRepository();
});

/// Provider for StorageService instance
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider for user preferences
final userPreferencesProvider = Provider<UserPreferences>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getPreferences();
});

/// Provider for all azkar with caching
final allAzkarProvider = FutureProvider<List<Zikr>>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return repository.loadAzkar();
});

/// Provider for searched/filtered azkar
final searchedAzkarProvider = FutureProvider<List<Zikr>>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return repository.loadAzkar();
  }
  
  return repository.searchAzkar(searchQuery);
});

/// Provider for favorite azkar
final favoriteAzkarProvider = FutureProvider<List<Zikr>>((ref) async {
  final allAzkar = await ref.watch(allAzkarProvider.future);
  final prefs = ref.watch(userPreferencesProvider);
  
  return allAzkar.where((zikr) => prefs.favoriteZikrIds.contains(zikr.id)).toList();
});

/// Provider to check if a specific zikr is favorite
final isFavoriteProvider = Provider.family<bool, String>((ref, zikrId) {
  final prefs = ref.watch(userPreferencesProvider);
  return prefs.favoriteZikrIds.contains(zikrId);
});

/// Provider to toggle favorite status
final toggleFavoriteProvider = Provider<Future<void> Function(String)>((ref) {
  return (String zikrId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.toggleFavorite(zikrId);
    // Invalidate preferences to trigger rebuild
    ref.invalidate(userPreferencesProvider);
  };
});

/// Provider for limited categories (first 5 for home screen)
final limitedCategoriesProvider = Provider<Map<String, String>>((ref) {
  final repository = ref.watch(azkarRepositoryProvider);
  final allCategories = repository.getCategoryDisplayNames();
  
  if (allCategories.isEmpty) {
    return {};
  }
  
  final entries = allCategories.entries.take(5).toList();
  return Map.fromEntries(entries);
});

/// Provider for azkar by category
final azkarByCategoryProvider = FutureProvider.family<List<Zikr>, String>((ref, categoryKey) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return repository.getAzkarByCategory(categoryKey);
});

/// Provider for all categories
final allCategoriesProvider = FutureProvider<Map<String, String>>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  await repository.loadAzkar(); // Ensure azkar are loaded first
  return repository.getCategoryDisplayNames();
});

/// Provider for current page index (pagination)
final currentPageProvider = StateProvider<int>((ref) => 0);

/// Provider for page size
final pageSizeProvider = Provider<int>((ref) => 15);

/// Provider for paginated categories
final paginatedCategoriesProvider = FutureProvider<List<MapEntry<String, String>>>((ref) async {
  final allCategories = await ref.watch(allCategoriesProvider.future);
  final currentPage = ref.watch(currentPageProvider);
  final pageSize = ref.watch(pageSizeProvider);
  
  final entries = allCategories.entries.toList();
  final startIndex = currentPage * pageSize;
  final endIndex = (startIndex + pageSize).clamp(0, entries.length);
  
  if (startIndex >= entries.length) {
    return [];
  }
  
  return entries.sublist(startIndex, endIndex);
});

/// Provider for total pages
final totalPagesProvider = FutureProvider<int>((ref) async {
  final allCategories = await ref.watch(allCategoriesProvider.future);
  final pageSize = ref.watch(pageSizeProvider);
  
  if (allCategories.isEmpty) return 0;
  return (allCategories.length / pageSize).ceil();
});

/// Provider for has next page
final hasNextPageProvider = Provider<bool>((ref) {
  final currentPage = ref.watch(currentPageProvider);
  final totalPages = ref.watch(totalPagesProvider);
  return currentPage < totalPages - 1;
});

/// Provider for has previous page
final hasPreviousPageProvider = Provider<bool>((ref) {
  final currentPage = ref.watch(currentPageProvider);
  return currentPage > 0;
});
