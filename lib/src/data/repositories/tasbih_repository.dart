import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/tasbih_session.dart';

/// Repository for persisting Tasbih data
class TasbihRepository {
  static const _keyLastSelectedType = 'tasbih_last_selected_type';
  static const _keySessionPrefix = 'tasbih_session_';
  static const _keyAnimationsEnabled = 'tasbih_animations_enabled';
  static const _keySoundEnabled = 'tasbih_sound_enabled';
  static const _keyHapticEnabled = 'tasbih_haptic_enabled';

  final SharedPreferences _prefs;

  TasbihRepository(this._prefs);

  /// Get the last selected tasbih type ID
  String? getLastSelectedType() {
    return _prefs.getString(_keyLastSelectedType);
  }

  /// Save the last selected tasbih type ID
  Future<void> saveLastSelectedType(String typeId) async {
    await _prefs.setString(_keyLastSelectedType, typeId);
  }

  /// Get session for a specific tasbih type
  TasbihSession? getSession(String tasbihTypeId) {
    final json = _prefs.getString('$_keySessionPrefix$tasbihTypeId');
    if (json == null) return null;
    
    try {
      return TasbihSession.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Save session for a specific tasbih type
  Future<void> saveSession(TasbihSession session) async {
    final json = jsonEncode(session.toJson());
    await _prefs.setString('$_keySessionPrefix${session.tasbihTypeId}', json);
  }

  /// Clear session for a specific tasbih type
  Future<void> clearSession(String tasbihTypeId) async {
    await _prefs.remove('$_keySessionPrefix$tasbihTypeId');
  }

  /// Get animation preference
  bool getAnimationsEnabled() {
    return _prefs.getBool(_keyAnimationsEnabled) ?? true;
  }

  /// Save animation preference
  Future<void> setAnimationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyAnimationsEnabled, enabled);
  }

  /// Get sound preference
  bool getSoundEnabled() {
    return _prefs.getBool(_keySoundEnabled) ?? false;
  }

  /// Save sound preference
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_keySoundEnabled, enabled);
  }

  /// Get haptic preference
  bool getHapticEnabled() {
    return _prefs.getBool(_keyHapticEnabled) ?? true;
  }

  /// Save haptic preference
  Future<void> setHapticEnabled(bool enabled) async {
    await _prefs.setBool(_keyHapticEnabled, enabled);
  }
}

