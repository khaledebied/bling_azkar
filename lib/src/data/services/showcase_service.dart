import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final showcaseServiceProvider = Provider<ShowcaseService>((ref) {
  return ShowcaseService();
});

class ShowcaseService {
  static const String _quranTabShowcaseKey = 'showcase_quran_tab_shown';
  static const String _quranContentShowcaseKey = 'showcase_quran_content_shown';
  static const String _homeShowcaseKey = 'showcase_home_shown';
  static const String _tasbihShowcaseKey = 'showcase_tasbih_shown';
  static const String _favoritesShowcaseKey = 'showcase_favorites_shown';

  Future<bool> hasSeenQuranTabShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_quranTabShowcaseKey) ?? false;
  }

  Future<void> markQuranTabShowcaseAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quranTabShowcaseKey, true);
  }
  
  Future<bool> hasSeenQuranContentShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_quranContentShowcaseKey) ?? false;
  }

  Future<void> markQuranContentShowcaseAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quranContentShowcaseKey, true);
  }

  Future<bool> hasSeenHomeShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_homeShowcaseKey) ?? false;
  }

  Future<void> markHomeShowcaseAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeShowcaseKey, true);
  }

  Future<bool> hasSeenTasbihShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tasbihShowcaseKey) ?? false;
  }

  Future<void> markTasbihShowcaseAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tasbihShowcaseKey, true);
  }

  Future<bool> hasSeenFavoritesShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_favoritesShowcaseKey) ?? false;
  }

  Future<void> markFavoritesShowcaseAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_favoritesShowcaseKey, true);
  }

  Future<void> resetAllShowcases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quranTabShowcaseKey);
    await prefs.remove(_quranContentShowcaseKey);
    await prefs.remove(_homeShowcaseKey);
    await prefs.remove(_tasbihShowcaseKey);
    await prefs.remove(_favoritesShowcaseKey);
  }
}
