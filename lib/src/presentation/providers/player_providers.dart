import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/audio_player_service.dart';

/// Provider for AudioPlayerService instance
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});

/// Provider for current count in player screen
final currentCountProvider = StateProvider.family<int, String>((ref, zikrId) => 0);

/// Provider for target count in player screen
final targetCountProvider = StateProvider.family<int, String>((ref, zikrId) => 0);

/// Provider for calculating progress
final progressProvider = Provider.family<double, String>((ref, zikrId) {
  final current = ref.watch(currentCountProvider(zikrId));
  final target = ref.watch(targetCountProvider(zikrId));
  
  if (target == 0) return 0.0;
  return current / target;
});
