import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class BackgroundAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  BackgroundAudioHandler() {
    _init();
  }

  void _init() {
    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      _updatePlaybackState();
    });

    // Listen to current index changes to update media item
    _player.currentIndexStream.listen((index) {
      if (index != null && index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });

    // Listen to position changes
    _player.positionStream.listen((_) => _updatePlaybackState());

    // Listen to buffered position changes
    _player.bufferedPositionStream.listen((_) => _updatePlaybackState());

    // Listen to duration changes
    _player.durationStream.listen((_) => _updatePlaybackState());

    // Set initial audio source
    _player.setAudioSource(_playlist);
  }

  void _updatePlaybackState() {
    final playing = _player.playing;
    final processingState = _player.processingState;
    final index = _player.currentIndex;
    
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
      queueIndex: index,
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
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) => _player.seek(Duration.zero, index: index);

  @override
  Future<void> addQueueItems(List<MediaItem> items) async {
    final sources = items.map(_itemToSource).toList();
    await _playlist.addAll(sources);
    final newQueue = List<MediaItem>.from(queue.value)..addAll(items);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    await _playlist.add(_itemToSource(item));
    queue.add([...queue.value, item]);
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    await _playlist.clear();
    await _playlist.addAll(newQueue.map(_itemToSource).toList());
    queue.add(newQueue);
  }

  AudioSource _itemToSource(MediaItem item) {
    final url = item.id;
    if (url.startsWith('assets/')) {
      return AudioSource.asset(url, tag: item);
    } else if (url.startsWith('http')) {
      return AudioSource.uri(Uri.parse(url), tag: item);
    } else {
      return AudioSource.file(url, tag: item);
    }
  }

  /// Set the current media item (convenience for single playback)
  Future<void> setMediaItem(MediaItem item) async {
    await updateQueue([item]);
    mediaItem.add(item);
  }

  AudioPlayer get player => _player;

  @override
  Future<void> onTaskRemoved() {
    stop();
    return super.onTaskRemoved();
  }
}

