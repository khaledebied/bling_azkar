import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  AudioPlayer get player => _player;

  Future<void> initialize() async {
    if (_initialized) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _initialized = true;
  }

  /// Clears the just_audio cache directory if it's corrupted
  Future<void> _clearCorruptedCache() async {
    try {
      // Try both temporary directory and application cache directory
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();
      
      final cachePaths = [
        '${tempDir.path}/just_audio_cache',
        '${cacheDir.path}/just_audio_cache',
      ];
      
      for (final cachePath in cachePaths) {
        final justAudioCacheDir = Directory(cachePath);
        
        if (await justAudioCacheDir.exists()) {
          try {
            // Check if it's a file instead of a directory (corrupted state)
            final stat = await justAudioCacheDir.stat();
            if (stat.type != FileSystemEntityType.directory) {
              // It's a file, delete it
              await justAudioCacheDir.delete();
              print('Deleted corrupted cache file: $cachePath');
            } else {
              // It's a directory, but might have corrupted subdirectories
              // Check for nested "assets" directory that might be corrupted
              final assetsDir = Directory('$cachePath/assets');
              if (await assetsDir.exists()) {
                final assetsStat = await assetsDir.stat();
                if (assetsStat.type != FileSystemEntityType.directory) {
                  // The assets path is a file, delete it
                  await assetsDir.delete();
                  print('Deleted corrupted assets cache file: ${assetsDir.path}');
                }
              }
              // Delete the entire cache to be safe
              await justAudioCacheDir.delete(recursive: true);
              print('Cleared cache directory: $cachePath');
            }
          } catch (e) {
            // If we can't check/delete, try to delete recursively anyway
            try {
              await justAudioCacheDir.delete(recursive: true);
              print('Force deleted cache: $cachePath');
            } catch (deleteError) {
              print('Could not delete cache at $cachePath: $deleteError');
            }
          }
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
      // Continue anyway - the cache clear is best effort
    }
  }

  Future<void> playAudio(String audioPath, {bool isLocal = true}) async {
    if (audioPath.isEmpty) {
      throw ArgumentError('Audio path cannot be empty');
    }

    try {
      if (isLocal) {
        await _player.setAsset(audioPath);
      } else {
        await _player.setUrl(audioPath);
      }
      await _player.play();
    } catch (e) {
      // Check if it's a cache directory error
      final errorString = e.toString();
      if (errorString.contains('Not a directory') || 
          errorString.contains('errno = 20') ||
          errorString.contains('just_audio_cache')) {
        print('Cache directory error detected, clearing cache and retrying...');
        await _clearCorruptedCache();
        
        // Retry after clearing cache
        try {
          if (isLocal) {
            await _player.setAsset(audioPath);
          } else {
            await _player.setUrl(audioPath);
          }
          await _player.play();
          print('Audio playback successful after cache clear');
        } catch (retryError) {
          print('Error playing audio after cache clear: $retryError');
          rethrow;
        }
      } else {
        print('Error playing audio: $e');
        rethrow;
      }
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<Duration> get positionStream => _player.positionStream;

  bool get isPlaying => _player.playing;

  Duration? get duration => _player.duration;

  Duration get position => _player.position;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
