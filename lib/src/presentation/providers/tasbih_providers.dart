import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/tasbih_type.dart';
import '../../data/repositories/tasbih_repository.dart';
import '../state/tasbih_counter_state.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for TasbihRepository
final tasbihRepositoryProvider = Provider<TasbihRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return TasbihRepository(prefs);
});

/// Provider for selected Tasbih type
final selectedTasbihTypeProvider = StateProvider<TasbihType?>((ref) {
  final repository = ref.watch(tasbihRepositoryProvider);
  final lastSelectedId = repository.getLastSelectedType();
  
  if (lastSelectedId != null) {
    return TasbihTypes.getById(lastSelectedId);
  }
  
  return null;
});

/// Provider for counter state (family provider for each tasbih type)
final tasbihCounterProvider = StateNotifierProvider.family<
    TasbihCounterNotifier,
    tasbih_session,
    TasbihType>((ref, tasbihType) {
  final repository = ref.watch(tasbihRepositoryProvider);
  final hapticEnabled = ref.watch(hapticEnabledProvider);
  
  return TasbihCounterNotifier(
    repository,
    tasbihType,
    hapticEnabled: hapticEnabled,
  );
});

/// Provider for animations enabled preference
final animationsEnabledProvider = StateProvider<bool>((ref) {
  final repository = ref.watch(tasbihRepositoryProvider);
  return repository.getAnimationsEnabled();
});

/// Provider for sound enabled preference
final soundEnabledProvider = StateProvider<bool>((ref) {
  final repository = ref.watch(tasbihRepositoryProvider);
  return repository.getSoundEnabled();
});

/// Provider for haptic enabled preference
final hapticEnabledProvider = StateProvider<bool>((ref) {
  final repository = ref.watch(tasbihRepositoryProvider);
  return repository.getHapticEnabled();
});

/// Provider for all tasbih types
final tasbihTypesProvider = Provider<List<TasbihType>>((ref) {
  return TasbihTypes.all;
});

