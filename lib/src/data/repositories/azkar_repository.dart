import 'package:flutter/foundation.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import '../../domain/models/zikr.dart';

class AzkarRepository {
  static final AzkarRepository _instance = AzkarRepository._internal();
  factory AzkarRepository() => _instance;
  AzkarRepository._internal();

  final _muslimRepo = MuslimRepository();
  List<Zikr>? _cachedAzkar;
  final Map<String, String> _categoryNamesAr = {};
  final Map<String, String> _categoryNamesEn = {};
  
  Future<List<Zikr>>? _loadingFuture;

  Future<List<Zikr>> loadAzkar() async {
    if (_cachedAzkar != null) {
      return _cachedAzkar!;
    }

    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = _performLoad();
    try {
      final result = await _loadingFuture!;
      return result;
    } finally {
      _loadingFuture = null;
    }
  }

  Future<List<Zikr>> _performLoad() async {
    final List<Zikr> allAzkar = [];
    _categoryNamesAr.clear();
    _categoryNamesEn.clear();

    try {
      // In muslim_data_flutter 1.4.1:
      // AzkarChapter uses: id, name
      // AzkarItem uses: id, item, translation, reference
      // Language is an enum: Language.ar, Language.en
      
      final chaptersAr = await _muslimRepo.getAzkarChapters(language: Language.ar);
      final chaptersEn = await _muslimRepo.getAzkarChapters(language: Language.en);
      
      final Map<int, String> enNames = {for (var c in chaptersEn) c.id: c.name};
      
      for (var chapter in chaptersAr) {
        final chapterIdStr = chapter.id.toString();
        final chapterAr = chapter.name;
        final chapterEn = enNames[chapter.id] ?? 'Zikr';
        
        _categoryNamesAr[chapterIdStr] = chapterAr;
        _categoryNamesEn[chapterIdStr] = chapterEn;
        
        // Fetch items for this chapter. 
        // Using Language.en fetches item.item in Arabic and item.translation in English.
        final items = await _muslimRepo.getAzkarItems(
          chapterId: chapter.id,
          language: Language.en,
        );
        
        for (var item in items) {
          allAzkar.add(Zikr(
            id: '${chapter.id}_${item.id}',
            title: LocalizedText(
              en: chapterEn,
              ar: chapterAr,
            ),
            text: item.item ?? '',
            translation: (item.translation != null && item.translation.isNotEmpty)
                ? LocalizedText(
                    en: item.translation, 
                    ar: item.item ?? '',
                  )
                : null,
            category: chapterIdStr,
            defaultCount: 1, // Repeat count is not explicitly in this package version
            reference: item.reference,
          ));
        }
      }

      _cachedAzkar = allAzkar;
      return _cachedAzkar!;
    } catch (e) {
      debugPrint('Error loading Azkar from muslim_data_flutter: $e');
      return [];
    }
  }

  Future<List<Zikr>> getAzkarByCategory(String categoryId) async {
    final azkar = await loadAzkar();
    return azkar.where((z) => z.category == categoryId).toList();
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

  Future<List<String>> getAllCategoryKeys() async {
    await loadAzkar();
    return _categoryNamesAr.keys.toList();
  }

  Map<String, String> getCategoryDisplayNames(String language) {
    return language.startsWith('ar') ? _categoryNamesAr : _categoryNamesEn;
  }

  Map<String, String> getCategoryDisplayNamesAr() {
    return _categoryNamesAr;
  }
}
