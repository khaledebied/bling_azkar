import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'background_audio_handler.dart';

/// Global audio handler - set once during first use
BackgroundAudioHandler? _globalAudioHandler;
bool _initializationAttempted = false;
bool _initializationInProgress = false;

/// Initialize audio service - can be called multiple times safely
/// Returns true if initialization succeeded or was already done
Future<bool> initializeAudioService() async {
  // Already have a handler
  if (_globalAudioHandler != null) {
    return true;
  }

  // Initialization in progress - wait
  if (_initializationInProgress) {
    // Wait for ongoing initialization
    for (int i = 0; i < 50; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_globalAudioHandler != null) return true;
      if (!_initializationInProgress) break;
    }
    return _globalAudioHandler != null;
  }

  // Already tried and failed - use standalone handler
  if (_initializationAttempted && _globalAudioHandler == null) {
    debugPrint('Previous initialization failed, creating standalone handler');
    return _createStandaloneHandler();
  }

  _initializationInProgress = true;
  _initializationAttempted = true;

  try {
    // Initialize audio session for both Android and iOS
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Try to initialize audio service for background playback
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

    debugPrint('✅ AudioService initialized successfully');
    _initializationInProgress = false;
    return true;
  } catch (e) {
    debugPrint('Error initializing AudioService: $e');
    _initializationInProgress = false;
    
    // Fall back to standalone handler (works without AudioService)
    return _createStandaloneHandler();
  }
}

/// Create a standalone handler that doesn't require AudioService
Future<bool> _createStandaloneHandler() async {
  try {
    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // Create standalone handler - uses just_audio directly
    _globalAudioHandler = BackgroundAudioHandler();
    debugPrint('✅ Created standalone BackgroundAudioHandler');
    return true;
  } catch (e) {
    debugPrint('Error creating standalone handler: $e');
    return false;
  }
}

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  /// Get the background audio handler
  BackgroundAudioHandler? get audioHandler => _globalAudioHandler;
  
  /// Get the underlying AudioPlayer for direct access if needed
  AudioPlayer? get player => _globalAudioHandler?.player;

  /// Check if audio service is ready
  bool get isReady => _globalAudioHandler != null;

  /// Initialize - ensures the handler is available
  Future<bool> initialize() async {
    if (_globalAudioHandler != null) return true;
    return await initializeAudioService();
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
    Duration? duration,
  }) async {
    if (audioPath.isEmpty) {
      throw ArgumentError('Audio path cannot be empty');
    }

    // Ensure initialized
    final initialized = await initialize();
    if (!initialized || _globalAudioHandler == null) {
      throw StateError('Audio service could not be initialized');
    }

    try {
      final mediaItem = MediaItem(
        id: audioPath,
        title: title ?? 'Bling Azkar',
        artist: artist ?? 'Islamic Remembrance',
        duration: duration,
        playable: true,
      );

      await _globalAudioHandler!.setMediaItem(mediaItem);
      await _globalAudioHandler!.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      rethrow;
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
  }
}
