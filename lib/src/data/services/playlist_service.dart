import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../domain/models/zikr.dart';
import 'audio_player_service.dart';

enum PlaylistState {
  idle,
  playing,
  paused,
  completed,
  error,
}

class PlaylistItem {
  final Zikr zikr;
  final String audioPath;
  final int index;
  final int repetition; // Which repetition this is (1, 2, 3, etc.)
  final int totalRepetitions; // Total number of repetitions for this zikr

  PlaylistItem({
    required this.zikr,
    required this.audioPath,
    required this.index,
    required this.repetition,
    required this.totalRepetitions,
  });
}

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  final _audioService = AudioPlayerService();
  final _stateController = StreamController<PlaylistState>.broadcast();
  final _currentItemController = StreamController<PlaylistItem?>.broadcast();
  final _progressController = StreamController<PlaylistProgress>.broadcast();

  List<PlaylistItem> _playlist = [];
  int _currentIndex = -1;
  PlaylistState _state = PlaylistState.idle;
  bool _initialized = false;

  Stream<PlaylistState> get stateStream => _stateController.stream;
  Stream<PlaylistItem?> get currentItemStream => _currentItemController.stream;
  Stream<PlaylistProgress> get progressStream => _progressController.stream;

  PlaylistState get state => _state;
  PlaylistItem? get currentItem => 
      _currentIndex >= 0 && _currentIndex < _playlist.length 
          ? _playlist[_currentIndex] 
          : null;
  int get totalItems => _playlist.length;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _state == PlaylistState.playing;
  bool get hasPlaylist => _playlist.isNotEmpty;

  Future<void> initialize() async {
    if (_initialized) return;

    await _audioService.initialize();
    final handler = _audioService.audioHandler;
    if (handler == null) return;

    // Listen to handler state changes
    handler.playbackState.listen((state) {
      if (state.playing) {
        _updateState(PlaylistState.playing);
      } else if (state.processingState == AudioProcessingState.completed) {
        _updateState(PlaylistState.completed);
      } else {
        _updateState(PlaylistState.paused);
      }
    });

    // Listen to media item changes to update current index
    handler.mediaItem.listen((item) {
      if (item != null) {
        final index = _playlist.indexWhere((p) => 
            p.zikr.id == item.extras?['zikrId'] && 
            p.repetition == item.extras?['repetition']);
        if (index != -1) {
          _currentIndex = index;
          _currentItemController.add(_playlist[index]);
        }
      }
    });

    // Listen to position changes for progress updates
    handler.player.positionStream.listen((position) {
      final duration = handler.player.duration;
      if (duration != null && currentItem != null) {
        _progressController.add(PlaylistProgress(
          currentPosition: position,
          totalDuration: duration,
          currentIndex: _currentIndex,
          totalItems: _playlist.length,
        ));
      }
    });

    _initialized = true;
  }

  Future<void> loadPlaylist(List<Zikr> azkar) async {
    await initialize();
    final handler = _audioService.audioHandler;
    if (handler == null) return;

    _playlist = [];

    // Sort azkar
    final sortedAzkar = List<Zikr>.from(azkar);
    sortedAzkar.sort((a, b) {
      final aIdNum = int.tryParse(a.id.split('_').last) ?? 0;
      final bIdNum = int.tryParse(b.id.split('_').last) ?? 0;
      return aIdNum.compareTo(bIdNum);
    });

    final List<MediaItem> mediaItems = [];

    // Build playlist
    for (int zikrIndex = 0; zikrIndex < sortedAzkar.length; zikrIndex++) {
      final zikr = sortedAzkar[zikrIndex];
      if (zikr.audio.isNotEmpty) {
        final audioInfo = zikr.audio.first;
        final audioPath = audioInfo.shortFile ?? audioInfo.fullFileUrl;
        final count = zikr.defaultCount;

        for (int repetition = 1; repetition <= count; repetition++) {
          final item = PlaylistItem(
            zikr: zikr,
            audioPath: audioPath,
            index: zikrIndex,
            repetition: repetition,
            totalRepetitions: count,
          );
          _playlist.add(item);
          
          mediaItems.add(MediaItem(
            id: audioPath,
            album: zikr.category,
            title: zikr.title.ar,
            artist: 'Bling Azkar',
            extras: {
              'zikrId': zikr.id,
              'repetition': repetition,
            },
          ));
        }
      }
    }

    await handler.updateQueue(mediaItems);
    _currentIndex = -1;
    _updateState(PlaylistState.idle);
    _currentItemController.add(null);
  }

  Future<void> play() async {
    if (_playlist.isEmpty) return;
    final handler = _audioService.audioHandler;
    if (handler == null) return;

    _currentIndex = 0;
    await handler.skipToQueueItem(0);
    await handler.play();
  }

  Future<void> pause() async {
    await _audioService.audioHandler?.pause();
  }

  Future<void> resume() async {
    await _audioService.audioHandler?.play();
  }

  Future<void> stop() async {
    await _audioService.audioHandler?.stop();
    _currentIndex = -1;
    _updateState(PlaylistState.idle);
    _currentItemController.add(null);
  }

  Future<void> skipToNext() async {
    await _audioService.audioHandler?.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await _audioService.audioHandler?.skipToPrevious();
  }

  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      await _audioService.audioHandler?.skipToQueueItem(index);
    }
  }

  void _updateState(PlaylistState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Stream<Duration?> get durationStream => _audioService.audioHandler?.player.durationStream ?? const Stream.empty();
  Stream<Duration> get positionStream => _audioService.audioHandler?.player.positionStream ?? const Stream.empty();
  Duration? get duration => _audioService.audioHandler?.player.duration;
  Duration get position => _audioService.audioHandler?.player.position ?? Duration.zero;

  Future<void> dispose() async {
    await _stateController.close();
    await _currentItemController.close();
    await _progressController.close();
  }
}

class PlaylistProgress {
  final Duration currentPosition;
  final Duration totalDuration;
  final int currentIndex;
  final int totalItems;

  PlaylistProgress({
    required this.currentPosition,
    required this.totalDuration,
    required this.currentIndex,
    required this.totalItems,
  });

  double get progress => 
      totalDuration.inMilliseconds > 0 
          ? currentPosition.inMilliseconds / totalDuration.inMilliseconds 
          : 0.0;
}

