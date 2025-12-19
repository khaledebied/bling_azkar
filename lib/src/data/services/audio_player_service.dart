import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'background_audio_handler.dart';

/// Global audio handler - set once during app initialization
BackgroundAudioHandler? _globalAudioHandler;

/// Initialize audio service - call this ONCE in main.dart
Future<BackgroundAudioHandler> initializeAudioService() async {
  if (_globalAudioHandler != null) {
    return _globalAudioHandler!;
  }

  // Initialize audio session for both Android and iOS
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // Initialize audio service for background playback
  _globalAudioHandler = await AudioService.init(
    builder: () => BackgroundAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.blingazkar.bling_azkar.audio',
      androidNotificationChannelName: 'Bling Azkar Audio',
      androidNotificationChannelDescription: 'Audio playback controls',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidResumeOnClick: true,
    ),
  );

  return _globalAudioHandler!;
}

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  /// Get the background audio handler (initialized in main.dart)
  BackgroundAudioHandler? get audioHandler => _globalAudioHandler;
  
  /// Get the underlying AudioPlayer for direct access if needed
  AudioPlayer? get player => _globalAudioHandler?.player;

  /// Check if audio service is ready
  bool get isReady => _globalAudioHandler != null;

  /// Initialize - ensures the global handler is available
  /// This is a no-op if already initialized in main.dart
  Future<void> initialize() async {
    if (_globalAudioHandler != null) return;
    
    try {
      await initializeAudioService();
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
      // If it's already initialized error, that's fine
      if (!e.toString().contains('_cacheManager == null')) {
        rethrow;
      }
    }
  }

  /// Clears the just_audio cache directory if it's corrupted
  Future<void> _clearCorruptedCache() async {
    try {
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
            final stat = await justAudioCacheDir.stat();
            if (stat.type != FileSystemEntityType.directory) {
              await justAudioCacheDir.delete();
              debugPrint('Deleted corrupted cache file: $cachePath');
            } else {
              final assetsDir = Directory('$cachePath/assets');
              if (await assetsDir.exists()) {
                final assetsStat = await assetsDir.stat();
                if (assetsStat.type != FileSystemEntityType.directory) {
                  await assetsDir.delete();
                  debugPrint('Deleted corrupted assets cache file: ${assetsDir.path}');
                }
              }
              await justAudioCacheDir.delete(recursive: true);
              debugPrint('Cleared cache directory: $cachePath');
            }
          } catch (e) {
            try {
              await justAudioCacheDir.delete(recursive: true);
              debugPrint('Force deleted cache: $cachePath');
            } catch (deleteError) {
              debugPrint('Could not delete cache at $cachePath: $deleteError');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<void> playAudio(
    String audioPath, {
    bool isLocal = true,
    String? title,
    String? artist,
  }) async {
    if (audioPath.isEmpty) {
      throw ArgumentError('Audio path cannot be empty');
    }

    // Ensure initialized
    await initialize();

    if (_globalAudioHandler == null) {
      throw StateError('Audio handler not initialized. Call initializeAudioService() in main.dart');
    }

    try {
      // Load audio
      if (isLocal) {
        await _globalAudioHandler!.loadAsset(audioPath);
      } else {
        await _globalAudioHandler!.loadUrl(audioPath);
      }

      // Get duration if available
      Duration? duration;
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        duration = _globalAudioHandler!.player.duration;
      } catch (e) {
        debugPrint('Could not get duration: $e');
      }

      await _globalAudioHandler!.setMediaItem(
        id: audioPath,
        title: title ?? 'Bling Azkar',
        artist: artist ?? 'Islamic Remembrance',
        duration: duration,
      );

      await _globalAudioHandler!.play();
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('Not a directory') || 
          errorString.contains('errno = 20') ||
          errorString.contains('just_audio_cache')) {
        debugPrint('Cache directory error detected, clearing cache and retrying...');
        await _clearCorruptedCache();
        
        try {
          if (isLocal) {
            await _globalAudioHandler!.loadAsset(audioPath);
          } else {
            await _globalAudioHandler!.loadUrl(audioPath);
          }
          await _globalAudioHandler!.setMediaItem(
            id: audioPath,
            title: title ?? 'Bling Azkar',
            artist: artist ?? 'Islamic Remembrance',
          );
          await _globalAudioHandler!.play();
          debugPrint('Audio playback successful after cache clear');
        } catch (retryError) {
          debugPrint('Error playing audio after cache clear: $retryError');
          rethrow;
        }
      } else {
        debugPrint('Error playing audio: $e');
        rethrow;
      }
    }
  }

  Future<void> pause() async {
    if (_globalAudioHandler != null) {
      await _globalAudioHandler!.pause();
    }
  }

  Future<void> resume() async {
    if (_globalAudioHandler != null) {
      await _globalAudioHandler!.play();
    }
  }

  Future<void> stop() async {
    if (_globalAudioHandler != null) {
      await _globalAudioHandler!.stop();
    }
  }

  Future<void> seek(Duration position) async {
    if (_globalAudioHandler != null) {
      await _globalAudioHandler!.seek(position);
    }
  }

  Future<void> setLoopMode(LoopMode mode) async {
    if (_globalAudioHandler?.player != null) {
      await _globalAudioHandler!.player.setLoopMode(mode);
    }
  }

  Stream<PlayerState> get playerStateStream {
    if (_globalAudioHandler?.player != null) {
      return _globalAudioHandler!.player.playerStateStream;
    }
    return const Stream<PlayerState>.empty();
  }

  Stream<Duration?> get durationStream {
    if (_globalAudioHandler?.player != null) {
      return _globalAudioHandler!.player.durationStream;
    }
    return const Stream<Duration?>.empty();
  }

  Stream<Duration> get positionStream {
    if (_globalAudioHandler?.player != null) {
      return _globalAudioHandler!.player.positionStream;
    }
    return const Stream<Duration>.empty();
  }

  bool get isPlaying {
    return _globalAudioHandler?.player.playing ?? false;
  }

  Duration? get duration {
    return _globalAudioHandler?.player.duration;
  }

  Duration get position {
    return _globalAudioHandler?.player.position ?? Duration.zero;
  }

  Future<void> dispose() async {
    // Don't dispose the global handler - it lasts for app lifecycle
    // Only reset if app is truly shutting down
  }
}
