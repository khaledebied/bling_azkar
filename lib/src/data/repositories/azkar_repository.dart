import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/zikr.dart';

class AzkarRepository {
  static final AzkarRepository _instance = AzkarRepository._internal();
  factory AzkarRepository() => _instance;
  AzkarRepository._internal();

  List<Zikr>? _cachedAzkar;
  Map<String, String>? _categoryMap; // Maps category Arabic name to itself (for consistency)

  Future<List<Zikr>> loadAzkar() async {
    if (_cachedAzkar != null) {
      return _cachedAzkar!;
    }

    final String jsonString = await rootBundle.loadString('assets/adhkar.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    
    final List<Zikr> azkar = [];
    _categoryMap = {};

    for (var categoryJson in jsonList) {
      final String categoryNameAr = categoryJson['category'];
      // Use the Arabic category name as the category key
      final String categoryKey = categoryNameAr;
      // Store category in map
      _categoryMap![categoryKey] = categoryNameAr;
      
      final List<dynamic> zikrArray = categoryJson['array'];
      
      for (var zikrJson in zikrArray) {
        final int id = zikrJson['id'];
        final String text = zikrJson['text'];
        final int count = zikrJson['count'];
        final String audioPath = zikrJson['audio'];
        
        // Construct local asset path
        final String audioFilename = audioPath.split('/').last;
        final String fullAudioUrl = 'assets/audio/$audioFilename';
        
        azkar.add(Zikr(
          id: '${categoryKey}_$id',
          title: LocalizedText(en: categoryNameAr, ar: categoryNameAr), // Use Arabic for both for now
          text: text,
          translation: null,
          category: categoryKey,
          defaultCount: count,
          audio: [
            AudioInfo(
              fullFileUrl: fullAudioUrl,
            ),
          ],
        ));
      }
    }

    _cachedAzkar = azkar;
    return _cachedAzkar!;
  }

  Future<List<Zikr>> getAzkarByCategory(String category) async {
    final azkar = await loadAzkar();
    // Filter by category and sort by ID to maintain consistent order
    final categoryAzkar = azkar.where((z) => z.category == category).toList();
    // Sort by ID to ensure consistent order (IDs contain category and number)
    categoryAzkar.sort((a, b) {
      // Extract numeric part from ID (format: categoryKey_id)
      final aIdNum = int.tryParse(a.id.split('_').last) ?? 0;
      final bIdNum = int.tryParse(b.id.split('_').last) ?? 0;
      return aIdNum.compareTo(bIdNum);
    });
    return categoryAzkar;
  }

  Future<Zikr?> getZikrById(String id) async {
    final azkar = await loadAzkar();
    try {
      return azkar.firstWhere((z) => z.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Zikr>> searchAzkar(String query) async {
    final azkar = await loadAzkar();
    final lowerQuery = query.toLowerCase();

    return azkar.where((z) {
      return z.title.en.toLowerCase().contains(lowerQuery) ||
          z.title.ar.contains(query) ||
          z.text.contains(query) ||
          (z.translation?.en.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get all unique categories from the JSON
  Future<List<String>> getAllCategories() async {
    await loadAzkar();
    return _categoryMap?.keys.toList() ?? [];
  }

  /// Get category display name (Arabic)
  String getCategoryDisplayName(String categoryKey) {
    return _categoryMap?[categoryKey] ?? categoryKey;
  }

  /// Get all categories as a map (for backward compatibility)
  Map<String, String> getCategoryDisplayNames() {
    return _categoryMap ?? {};
  }

  /// Get all categories as a map (Arabic names)
  Map<String, String> getCategoryDisplayNamesAr() {
    return _categoryMap ?? {};
  }
}
