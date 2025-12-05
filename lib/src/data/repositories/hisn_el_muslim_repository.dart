import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import '../../domain/models/zikr.dart';

class HisnElMuslimRepository {
  static final HisnElMuslimRepository _instance = HisnElMuslimRepository._internal();
  factory HisnElMuslimRepository() => _instance;
  HisnElMuslimRepository._internal();

  List<Zikr>? _cachedAzkar;
  final _repository = MuslimRepository();

  /// Load all Hisn el Muslim azkar
  Future<List<Zikr>> loadHisnElMuslimAzkar() async {
    if (_cachedAzkar != null) {
      return _cachedAzkar!;
    }

    try {
      // Get all azkar categories
      final categories = await _repository.getAzkarCategories(language: Language.en);
      
      final List<Zikr> azkar = [];
      int itemCounter = 0;

      // Process all categories (Hisn el Muslim may be one of them or all azkar)
      for (var category in categories) {
        try {
          // Get chapters for this category
          final chapters = await _repository.getAzkarChapters(
            language: Language.en,
            categoryId: category.id,
          );
          
          for (var chapter in chapters) {
            try {
              // Get azkar items for this chapter
              final items = await _repository.getAzkarItems(
                language: Language.en,
                chapterId: chapter.id,
              );
              
              for (var item in items) {
                itemCounter++;
                // Access properties using dynamic access
                final itemTitle = _extractTitle(item);
                final itemContent = _extractContent(item);
                final categoryName = _extractCategoryName(category);
                
                azkar.add(Zikr(
                  id: 'hisn$itemCounter',
                  title: LocalizedText(
                    en: itemTitle.en,
                    ar: itemTitle.ar,
                  ),
                  text: itemContent.ar,
                  translation: LocalizedText(
                    en: itemContent.en,
                    ar: itemContent.ar,
                  ),
                  category: categoryName,
                  defaultCount: 1,
                  audio: [],
                ));
              }
            } catch (e) {
              // Continue if items fail
              continue;
            }
          }
        } catch (e) {
          // Continue if chapters fail
          continue;
        }
      }

      _cachedAzkar = azkar;
      return _cachedAzkar!;
    } catch (e) {
      // Return empty list if API fails
      // This will be adjusted based on actual package API
      return [];
    }
  }

  /// Get azkar by chapter/category
  Future<List<Zikr>> getAzkarByChapter(String chapterId) async {
    final allAzkar = await loadHisnElMuslimAzkar();
    return allAzkar.where((z) => z.id.contains('hisn_${chapterId}_')).toList();
  }

  /// Extract title from AzkarItem using dynamic access
  LocalizedText _extractTitle(dynamic item) {
    try {
      // Try to access common property names
      final titleEn = (item as dynamic).titleEn?.toString() ?? 
                     (item as dynamic).title?.toString() ?? '';
      final titleAr = (item as dynamic).titleAr?.toString() ?? 
                     (item as dynamic).title?.toString() ?? '';
      return LocalizedText(en: titleEn, ar: titleAr);
    } catch (e) {
      return const LocalizedText(en: '', ar: '');
    }
  }

  /// Extract content from AzkarItem
  LocalizedText _extractContent(dynamic item) {
    try {
      final contentEn = (item as dynamic).contentEn?.toString() ?? 
                       (item as dynamic).content?.toString() ?? '';
      final contentAr = (item as dynamic).contentAr?.toString() ?? 
                       (item as dynamic).content?.toString() ?? '';
      return LocalizedText(en: contentEn, ar: contentAr);
    } catch (e) {
      return const LocalizedText(en: '', ar: '');
    }
  }

  /// Extract category name
  String _extractCategoryName(dynamic category) {
    try {
      return (category as dynamic).titleAr?.toString() ?? 
             (category as dynamic).titleEn?.toString() ?? 
             (category as dynamic).title?.toString() ?? 
             'حصن المسلم';
    } catch (e) {
      return 'حصن المسلم';
    }
  }

  /// Search azkar
  Future<List<Zikr>> searchAzkar(String query) async {
    final azkar = await loadHisnElMuslimAzkar();
    final lowerQuery = query.toLowerCase();

    return azkar.where((z) {
      return z.title.en.toLowerCase().contains(lowerQuery) ||
          z.title.ar.contains(query) ||
          z.text.contains(query) ||
          (z.translation?.en.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get zikr by ID
  Future<Zikr?> getZikrById(String id) async {
    final azkar = await loadHisnElMuslimAzkar();
    try {
      return azkar.firstWhere((z) => z.id == id);
    } catch (e) {
      return null;
    }
  }
}

