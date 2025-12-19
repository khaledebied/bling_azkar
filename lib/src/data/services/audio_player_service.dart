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

  /// Get the background audio handler
  BackgroundAudioHandler? get audioHandler => _audioHandler;
  
  /// Get the underlying AudioPlayer for direct access if needed
  AudioPlayer? get player => _audioHandler?.player;

  /// Lazy initialization - only initializes when first needed
  Future<void> initialize() async {
    if (_initialized) return;
    
    // If already initializing, wait for that
    if (_initFuture != null) {
      return _initFuture!;
    }

    _initFuture = _doInitialize();
    await _initFuture;
  }
  
  Future<void> _doInitialize() async {
    if (_initialized) return;
    
    // Initialize audio session for both Android and iOS
    // This is critical for iOS background audio playback
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration.music(
        avAudioSessionCategoryOptions: [
          // Allow audio to continue when screen is locked
          AudioSessionCategoryOption.allowBluetooth,
          AudioSessionCategoryOption.allowBluetoothA2DP,
          AudioSessionCategoryOption.defaultToSpeaker,
        ],
        avAudioSessionMode: AudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: [],
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: [],
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );

    // Initialize audio service for background playback
    // Works on both Android and iOS
    _audioHandler = await AudioService.init(
      builder: () => BackgroundAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.blingazkar.bling_azkar.audio',
        androidNotificationChannelName: 'Bling Azkar Audio',
        androidNotificationChannelDescription: 'Audio playback controls',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: false,
        androidShowNotificationBadge: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: false,
        androidResumeOnClick: true,
        // iOS-specific: Enable remote command center controls
        iosShowNotificationControls: true,
      ),
    );

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
