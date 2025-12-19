import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'background_audio_handler.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  BackgroundAudioHandler? _audioHandler;
  bool _initialized = false;
  Future<void>? _initFuture;
  bool _isInitializing = false;

  /// Get the background audio handler
  BackgroundAudioHandler? get audioHandler => _audioHandler;
  
  /// Get the underlying AudioPlayer for direct access if needed
  AudioPlayer? get player => _audioHandler?.player;

  /// Lazy initialization - only initializes when first needed
  Future<void> initialize() async {
    if (_initialized) return;
    
    // If already initializing, wait for that
    if (_isInitializing && _initFuture != null) {
      return _initFuture!;
    }

    // Set flag to prevent concurrent initialization
    _isInitializing = true;
    _initFuture = _doInitialize();
    
    try {
      await _initFuture;
    } finally {
      _isInitializing = false;
    }
  }
  
  Future<void> _doInitialize() async {
    if (_initialized && _audioHandler != null) return;
    
    try {
      // Initialize audio session for both Android and iOS
      // This is critical for iOS background audio playback
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Initialize audio service for background playback
      // Works on both Android and iOS
      // Note: AudioService.init() can only be called once per app lifecycle
      // If already initialized, it should return the existing handler
      _audioHandler = await AudioService.init(
        builder: () => BackgroundAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.blingazkar.bling_azkar.audio',
          androidNotificationChannelName: 'Bling Azkar Audio',
          androidNotificationChannelDescription: 'Audio playback controls',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true, // Must be true when androidNotificationOngoing is true
          androidShowNotificationBadge: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          androidResumeOnClick: true,
        ),
      );

      _initialized = true;
    } catch (e) {
      // If AudioService is already initialized (cache manager assertion error), handle gracefully
      final errorString = e.toString();
      if (errorString.contains('_cacheManager == null') || 
          errorString.contains('already initialized') ||
          AudioService.running) {
        debugPrint('AudioService already initialized (error: $e)');
        // AudioService is running but we hit an assertion error
        // Try to get the handler by calling init() again with a try-catch
        // This is a workaround for the audio_service package limitation
        try {
          // Wait a bit and try to get handler
          await Future.delayed(const Duration(milliseconds: 100));
          // If AudioService is running, we can't get the handler directly
          // But we'll mark as initialized and let playAudio handle it
          _initialized = true;
          debugPrint('Marked as initialized - handler will be obtained on first play');
          return;
        } catch (retryError) {
          debugPrint('Error retrying initialization: $retryError');
        }
      }
      
      debugPrint('Error in _doInitialize: $e');
      // Reset flags so initialization can be retried
      _initFuture = null;
      _isInitializing = false;
      rethrow;
    }
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

  Future<void> playAudio(
    String audioPath, {
    bool isLocal = true,
    String? title,
    String? artist,
  }) async {
    if (audioPath.isEmpty) {
      throw ArgumentError('Audio path cannot be empty');
    }

    // Lazy initialize if not already done
    await initialize();

    // If handler is null but AudioService is running, try to get it
    if (_audioHandler == null && AudioService.running) {
      try {
        // Try to initialize again to get the handler
        // This should return the existing handler if AudioService is already running
        _audioHandler = await AudioService.init(
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
      } catch (e) {
        // If it fails, AudioService is already initialized but we can't get the handler
        // This is a limitation of the audio_service package
        debugPrint('Cannot get AudioService handler: $e');
        throw StateError('Audio handler not available - AudioService is already running');
      }
    }

    if (_audioHandler == null) {
      throw StateError('Audio handler not initialized');
    }

    try {
      // Load audio
      if (isLocal) {
        await _audioHandler!.loadAsset(audioPath);
      } else {
        await _audioHandler!.loadUrl(audioPath);
      }

      // Set media item for notification (iOS lock screen & Control Center)
      // Get duration if available from player
      Duration? duration;
      try {
        // Wait a bit for duration to load
        await Future.delayed(const Duration(milliseconds: 100));
        duration = _audioHandler!.player.duration;
      } catch (e) {
        debugPrint('Could not get duration: $e');
      }

      await _audioHandler!.setMediaItem(
        id: audioPath,
        title: title ?? 'Bling Azkar',
        artist: artist ?? 'Islamic Remembrance',
        duration: duration,
      );

      // Play audio (this activates iOS background audio session)
      await _audioHandler!.play();
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
            await _audioHandler!.loadAsset(audioPath);
          } else {
            await _audioHandler!.loadUrl(audioPath);
          }
          await _audioHandler!.setMediaItem(
            id: audioPath,
            title: title ?? 'Bling Azkar',
            artist: artist ?? 'Islamic Remembrance',
          );
          await _audioHandler!.play();
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
    if (_audioHandler != null) {
      await _audioHandler!.pause();
    }
  }

  Future<void> resume() async {
    if (_audioHandler != null) {
      await _audioHandler!.play();
    }
  }

  Future<void> stop() async {
    if (_audioHandler != null) {
      await _audioHandler!.stop();
    }
  }

  Future<void> seek(Duration position) async {
    if (_audioHandler != null) {
      await _audioHandler!.seek(position);
    }
  }

  Future<void> setLoopMode(LoopMode mode) async {
    if (_audioHandler?.player != null) {
      await _audioHandler!.player.setLoopMode(mode);
    }
  }

  Stream<PlayerState> get playerStateStream {
    if (_audioHandler?.player != null) {
      return _audioHandler!.player.playerStateStream;
    }
    return const Stream<PlayerState>.empty();
  }

  Stream<Duration?> get durationStream {
    if (_audioHandler?.player != null) {
      return _audioHandler!.player.durationStream;
    }
    return const Stream<Duration?>.empty();
  }

  Stream<Duration> get positionStream {
    if (_audioHandler?.player != null) {
      return _audioHandler!.player.positionStream;
    }
    return const Stream<Duration>.empty();
  }

  bool get isPlaying {
    return _audioHandler?.player.playing ?? false;
  }

  Duration? get duration {
    return _audioHandler?.player.duration;
  }

  Duration get position {
    return _audioHandler?.player.position ?? Duration.zero;
  }

  Future<void> dispose() async {
    if (_audioHandler != null) {
      await _audioHandler!.dispose();
      _audioHandler = null;
    }
    _initialized = false;
  }
}
