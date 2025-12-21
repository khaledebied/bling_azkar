import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final showcaseServiceProvider = Provider<ShowcaseService>((ref) {
  return ShowcaseService();
});

class ShowcaseService {
  static const String _quranTabShowcaseKey = 'showcase_quran_tab_shown';
  static const String _quranContentShowcaseKey = 'showcase_quran_content_shown';

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

  Future<void> resetAllShowcases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quranTabShowcaseKey);
    await prefs.remove(_quranContentShowcaseKey);
  }
}
