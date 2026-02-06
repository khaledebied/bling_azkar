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

/// Provider for user preferences (with auto-refresh)
final userPreferencesProvider = StateProvider<UserPreferences>((ref) {
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
  final favoriteIds = ref.watch(userPreferencesProvider.select((p) => p.favoriteZikrIds));
  
  return allAzkar.where((zikr) => favoriteIds.contains(zikr.id)).toList();
});

/// Provider to check if a specific zikr is favorite
final isFavoriteProvider = Provider.family<bool, String>((ref, zikrId) {
  return ref.watch(userPreferencesProvider.select((p) => p.favoriteZikrIds.contains(zikrId)));
});

/// Provider to toggle favorite status
final toggleFavoriteProvider = Provider<Future<void> Function(String)>((ref) {
  return (String zikrId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.toggleFavorite(zikrId);
    
    // Update the preferences provider with fresh data immediately
    final newPrefs = storage.getPreferences();
    ref.read(userPreferencesProvider.notifier).state = newPrefs;
    
    // Only invalidate the specific zikr favorite status
    ref.invalidate(isFavoriteProvider(zikrId));
    ref.invalidate(favoriteAzkarProvider);
  };
});

/// Provider for favorite categories
final favoriteCategoriesProvider = FutureProvider<Map<String, String>>((ref) async {
  final allCategories = await ref.watch(allCategoriesProvider.future);
  final favoriteIds = ref.watch(userPreferencesProvider.select((p) => p.favoriteCategoryIds));
  
  final favorites = <String, String>{};
  for (var categoryId in favoriteIds) {
    if (allCategories.containsKey(categoryId)) {
      favorites[categoryId] = allCategories[categoryId]!;
    }
  }
  return favorites;
});

/// Provider to check if a category is favorite
final isCategoryFavoriteProvider = Provider.family<bool, String>((ref, categoryId) {
  return ref.watch(userPreferencesProvider.select((p) => p.favoriteCategoryIds.contains(categoryId)));
});

/// Provider to toggle category favorite status
final toggleCategoryFavoriteProvider = Provider<Future<void> Function(String)>((ref) {
  return (String categoryId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.toggleCategoryFavorite(categoryId);
    
    // Update the preferences provider with fresh data immediately
    final newPrefs = storage.getPreferences();
    ref.read(userPreferencesProvider.notifier).state = newPrefs;
    
    // Invalidate dependent providers
    ref.invalidate(favoriteCategoriesProvider);
    ref.invalidate(isCategoryFavoriteProvider(categoryId));
  };
});

/// Provider for limited categories (first 5 for home screen)
final limitedCategoriesProvider = Provider<Map<String, String>>((ref) {
  final repository = ref.watch(azkarRepositoryProvider);
  final language = ref.watch(userPreferencesProvider.select((p) => p.language));
  final allCategories = repository.getCategoryDisplayNames(language);
  
  if (allCategories.isEmpty) {
    return {};
  }
  
  // Prioritize Morning and Evening Azkar (IDs 27 and 28)
  final sortedEntries = _sortCategories(allCategories.entries.toList());
  final entries = sortedEntries.take(5).toList();
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
  final language = ref.watch(userPreferencesProvider.select((p) => p.language));
  await repository.loadAzkar(); // Ensure azkar are loaded first
  final allCategories = repository.getCategoryDisplayNames(language);
  
  final sortedEntries = _sortCategories(allCategories.entries.toList());
  return Map.fromEntries(sortedEntries);
});

/// Helper to sort categories with Morning/Evening first
List<MapEntry<String, String>> _sortCategories(List<MapEntry<String, String>> entries) {
  final morningIds = ['27']; // Common IDs for Morning Azkar
  final eveningIds = ['28']; // Common IDs for Evening Azkar
  
  final morningEntries = <MapEntry<String, String>>[];
  final eveningEntries = <MapEntry<String, String>>[];
  final otherEntries = <MapEntry<String, String>>[];
  
  for (var entry in entries) {
    final name = entry.value.toLowerCase();
    if (morningIds.contains(entry.key) || name.contains('صباح') || name.contains('morning')) {
      morningEntries.add(entry);
    } else if (eveningIds.contains(entry.key) || name.contains('مساء') || name.contains('evening')) {
      eveningEntries.add(entry);
    } else {
      otherEntries.add(entry);
    }
  }
  
  return [...morningEntries, ...eveningEntries, ...otherEntries];
}

/// Provider for current page index (pagination)
final currentPageProvider = StateProvider<int>((ref) => 0);

/// Provider for page size
final pageSizeProvider = Provider<int>((ref) => 15);

/// Provider for paginated categories (shows all items up to current page)
final paginatedCategoriesProvider = FutureProvider<List<MapEntry<String, String>>>((ref) async {
  final allCategories = await ref.watch(allCategoriesProvider.future);
  final currentPage = ref.watch(currentPageProvider);
  final pageSize = ref.watch(pageSizeProvider);
  
  final entries = allCategories.entries.toList();
  final endIndex = ((currentPage + 1) * pageSize).clamp(0, entries.length);
  
  return entries.sublist(0, endIndex);
});

/// Provider for total pages
final totalPagesProvider = FutureProvider<int>((ref) async {
  final allCategories = await ref.watch(allCategoriesProvider.future);
  final pageSize = ref.watch(pageSizeProvider);
  
  if (allCategories.isEmpty) return 0;
  return (allCategories.length / pageSize).ceil();
});

/// Provider for has next page
final hasNextPageProvider = FutureProvider<bool>((ref) async {
  final currentPage = ref.watch(currentPageProvider);
  final totalPages = await ref.watch(totalPagesProvider.future);
  return currentPage < totalPages - 1;
});

/// Provider for has previous page
final hasPreviousPageProvider = Provider<bool>((ref) {
  final currentPage = ref.watch(currentPageProvider);
  return currentPage > 0;
});
