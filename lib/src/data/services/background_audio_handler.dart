import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class BackgroundAudioHandler extends BaseAudioHandler
    with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  
  // Current media item
  MediaItem? _currentMediaItem;
  
  BackgroundAudioHandler() {
    _init();
  }

  void _init() {
    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      _updatePlaybackState();
    });

    // Listen to position changes (updates every second for iOS lock screen)
    _player.positionStream.listen((_) {
      _updatePlaybackState();
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      // Update media item with duration when available
      if (duration != null && _currentMediaItem != null) {
        _currentMediaItem = _currentMediaItem!.copyWith(duration: duration);
        mediaItem.add(_currentMediaItem);
      }
      _updatePlaybackState();
    });

    // Listen to processing state changes
    _player.processingStateStream.listen((state) {
      _updatePlaybackState();
    });

    // Handle audio interruptions (calls, other apps) - important for iOS
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Audio completed - update state
        _updatePlaybackState();
      }
    });
  }

  void _updatePlaybackState() {
    final playing = _player.playing;
    final processingState = _player.processingState;
    
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(processingState),
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: 0,
    ));
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.idle,
      playing: false,
      updatePosition: Duration.zero,
      bufferedPosition: Duration.zero,
      speed: 1.0,
      queueIndex: 0,
    ));
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    // Implement if you have a playlist
    // For now, just restart current track
    await _player.seek(Duration.zero);
    await _player.play();
  }

  @override
  Future<void> skipToPrevious() async {
    // Implement if you have a playlist
    // For now, just restart current track
    await _player.seek(Duration.zero);
    await _player.play();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Set the current media item and update notification
  /// This is critical for iOS lock screen and control center
  Future<void> setMediaItem({
    required String id,
    required String title,
    String? artist,
    String? album,
    String? artUri,
    Duration? duration,
  }) async {
    _currentMediaItem = MediaItem(
      id: id,
      title: title,
      artist: artist ?? 'Bling Azkar',
      album: album,
      artUri: artUri != null ? Uri.parse(artUri) : null,
      duration: duration,
      playable: true,
      // iOS-specific: Enable remote control
      extras: {
        'url': id, // Store the audio path for reference
      },
    );
    
    // Update media item (triggers iOS lock screen update)
    mediaItem.add(_currentMediaItem);
    _updatePlaybackState();
  }

  /// Load audio from asset
  /// Important for iOS: This ensures audio session is active before loading
  Future<void> loadAsset(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      
      // Wait for duration to be available (important for iOS lock screen)
      if (_currentMediaItem != null) {
        // Update media item with actual duration when available
        _player.durationStream.first.then((duration) {
          if (duration != null && _currentMediaItem != null) {
            _currentMediaItem = _currentMediaItem!.copyWith(duration: duration);
            mediaItem.add(_currentMediaItem);
          }
        });
      }
      
      _updatePlaybackState();
    } catch (e) {
      debugPrint('Error loading asset: $e');
      rethrow;
    }
  }

  /// Load audio from URL
  /// Important for iOS: This ensures audio session is active before loading
  Future<void> loadUrl(String url) async {
    try {
      await _player.setUrl(url);
      
      // Wait for duration to be available (important for iOS lock screen)
      if (_currentMediaItem != null) {
        // Update media item with actual duration when available
        _player.durationStream.first.then((duration) {
          if (duration != null && _currentMediaItem != null) {
            _currentMediaItem = _currentMediaItem!.copyWith(duration: duration);
            mediaItem.add(_currentMediaItem);
          }
        });
      }
      
      _updatePlaybackState();
    } catch (e) {
      debugPrint('Error loading URL: $e');
      rethrow;
    }
  }

  /// Get the underlying AudioPlayer for direct access if needed
  AudioPlayer get player => _player;

  @override
  Future<void> dispose() async {
    await _player.dispose();
    await super.dispose();
  }
}
