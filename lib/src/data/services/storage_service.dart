import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/sheikh.dart';
import '../../domain/models/user_preferences.dart';


class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _preferencesBox = 'preferences';
  static const String _sheikhsBox = 'sheikhs';
  static const String _downloadedAudioBox = 'downloaded_audio';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Only open critical preferences box initially for fast startup
    // Other boxes will be opened lazily when first accessed
    await Hive.openBox(_preferencesBox);

    _initialized = true;
  }
  
  /// Lazy initialization for non-critical boxes
  Future<void> _ensureSheikhsBox() async {
    if (!Hive.isBoxOpen(_sheikhsBox)) {
      await Hive.openBox(_sheikhsBox);
    }
  }
  
  Future<void> _ensureDownloadedAudioBox() async {
    if (!Hive.isBoxOpen(_downloadedAudioBox)) {
      await Hive.openBox(_downloadedAudioBox);
    }
  }

  Box get _preferences => Hive.box(_preferencesBox);
  
  Future<Box> get _sheikhs async {
    await _ensureSheikhsBox();
    return Hive.box(_sheikhsBox);
  }
  
  Future<Box> get _downloadedAudio async {
    await _ensureDownloadedAudioBox();
    return Hive.box(_downloadedAudioBox);
  }

  // User Preferences
  Future<void> savePreferences(UserPreferences prefs) async {
    await _preferences.put('user_prefs', prefs.toJson());
  }

  UserPreferences getPreferences() {
    final json = _preferences.get('user_prefs');
    if (json == null) return const UserPreferences();
    return UserPreferences.fromJson(Map<String, dynamic>.from(json));
  }

  // Favorites
  Future<void> toggleFavorite(String zikrId) async {
    final prefs = getPreferences();
    final favorites = List<String>.from(prefs.favoriteZikrIds);

    if (favorites.contains(zikrId)) {
      favorites.remove(zikrId);
    } else {
      favorites.add(zikrId);
    }

    await savePreferences(prefs.copyWith(favoriteZikrIds: favorites));
  }

  // Sheikhs
  Future<void> saveSheikh(Sheikh sheikh) async {
    await _ensureSheikhsBox();
    final box = await _sheikhs;
    await box.put(sheikh.id, sheikh.toJson());
  }

  Future<List<Sheikh>> getAllSheikhs() async {
    await _ensureSheikhsBox();
    final box = await _sheikhs;
    return box.values
        .map((json) => Sheikh.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<Sheikh?> getSheikh(String id) async {
    await _ensureSheikhsBox();
    final box = await _sheikhs;
    final json = box.get(id);
    if (json == null) return null;
    return Sheikh.fromJson(Map<String, dynamic>.from(json));
  }

  // Tasbih Count
  Future<void> updateTasbihCount(int count) async {
    await _preferences.put('tasbih_count', count);
  }

  int getTasbihCount() {
    return _preferences.get('tasbih_count', defaultValue: 0) as int;
  }

  // Downloaded Audio
  Future<void> saveDownloadedAudio(DownloadedAudio audio) async {
    final box = await _downloadedAudio;
    await box.put(audio.id, audio.toJson());
  }

  Future<void> deleteDownloadedAudio(String id) async {
    final box = await _downloadedAudio;
    await box.delete(id);
  }

  Future<List<DownloadedAudio>> getAllDownloadedAudio() async {
    final box = await _downloadedAudio;
    return box.values
        .map((json) => DownloadedAudio.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<DownloadedAudio?> getDownloadedAudio(String zikrId, String sheikhId) async {
    final box = await _downloadedAudio;
    final key = '${zikrId}_$sheikhId';
    final json = box.get(key);
    if (json == null) return null;
    return DownloadedAudio.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> clearAllData() async {
    await _preferences.clear();
    final sheikhsBox = await _sheikhs;
    await sheikhsBox.clear();
    await _downloadedAudio.clear();
  }
}
