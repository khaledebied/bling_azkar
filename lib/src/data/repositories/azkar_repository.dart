import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/zikr.dart';

class AzkarRepository {
  static final AzkarRepository _instance = AzkarRepository._internal();
  factory AzkarRepository() => _instance;
  AzkarRepository._internal();

  List<Zikr>? _cachedAzkar;

  Future<List<Zikr>> loadAzkar() async {
    if (_cachedAzkar != null) {
      return _cachedAzkar!;
    }

    final String jsonString = await rootBundle.loadString('assets/adhkar.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    
    final List<Zikr> azkar = [];
    final categoryMap = getCategoryDisplayNamesAr();
    // Reverse map for lookup
    final reverseCategoryMap = categoryMap.map((k, v) => MapEntry(v, k));
    final englishCategoryMap = getCategoryDisplayNames();

    for (var categoryJson in jsonList) {
      final String categoryNameAr = categoryJson['category'];
      final String categoryKey = reverseCategoryMap[categoryNameAr] ?? 'general';
      final String categoryNameEn = englishCategoryMap[categoryKey] ?? 'General';
      
      final List<dynamic> zikrArray = categoryJson['array'];
      
      for (var zikrJson in zikrArray) {
        final int id = zikrJson['id'];
        final String text = zikrJson['text'];
        final int count = zikrJson['count'];
        final String audioPath = zikrJson['audio'];
        
        // Construct remote URL
        final String fullAudioUrl = 'https://raw.githubusercontent.com/rn0x/Adhkar-json/main/audio/$audioPath';
        
        azkar.add(Zikr(
          id: '${categoryKey}_$id',
          title: LocalizedText(en: categoryNameEn, ar: categoryNameAr),
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
    return azkar.where((z) => z.category == category).toList();
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

  Future<List<String>> getAllCategories() async {
    final azkar = await loadAzkar();
    return azkar.map((z) => z.category).toSet().toList();
  }

  Map<String, String> getCategoryDisplayNames() {
    return {
      'morning': 'Morning',
      'evening': 'Evening',
      'after_prayer': 'After Prayer',
      'before_sleep': 'Before Sleep',
      'general': 'General',
    };
  }

  Map<String, String> getCategoryDisplayNamesAr() {
    return {
      'morning': 'أذكار الصباح',
      'evening': 'أذكار المساء',
      'after_prayer': 'أذكار بعد الصلاة',
      'before_sleep': 'أذكار قبل النوم',
      'general': 'أذكار عامة',
    };
  }
}
