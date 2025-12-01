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

    final String jsonString = await rootBundle.loadString('assets/azkar.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    _cachedAzkar = jsonList.map((json) => Zikr.fromJson(json)).toList();
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
          (z.translation.en.toLowerCase().contains(lowerQuery));
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
