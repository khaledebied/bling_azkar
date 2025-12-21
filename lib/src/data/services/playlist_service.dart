import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../domain/models/zikr.dart';

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

  final AudioPlayer _player = AudioPlayer();
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

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to player state changes
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });

    // Listen to position changes for progress updates
    _player.positionStream.listen((position) {
      final duration = _player.duration;
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

    _playlist = [];

    // Ensure azkar are in order by sorting by ID
    final sortedAzkar = List<Zikr>.from(azkar);
    sortedAzkar.sort((a, b) {
      // Extract numeric part from ID (format: categoryKey_id)
      final aIdNum = int.tryParse(a.id.split('_').last) ?? 0;
      final bIdNum = int.tryParse(b.id.split('_').last) ?? 0;
      return aIdNum.compareTo(bIdNum);
    });

    // Build playlist in strict sequential order
    for (int zikrIndex = 0; zikrIndex < sortedAzkar.length; zikrIndex++) {
      final zikr = sortedAzkar[zikrIndex];
      if (zikr.audio.isNotEmpty) {
        final audioInfo = zikr.audio.first;
        final audioPath = audioInfo.shortFile ?? audioInfo.fullFileUrl;
        final count = zikr.defaultCount;

        // Create multiple playlist items based on the count
        // Each repetition is added sequentially to maintain order
        for (int repetition = 1; repetition <= count; repetition++) {
          _playlist.add(PlaylistItem(
            zikr: zikr,
            audioPath: audioPath,
            index: zikrIndex,
            repetition: repetition,
            totalRepetitions: count,
          ));
        }
      }
    }

    _currentIndex = -1;
    _updateState(PlaylistState.idle);
    _currentItemController.add(null);
    
    debugPrint('Playlist loaded: ${_playlist.length} items in order');
    for (int i = 0; i < _playlist.length; i++) {
      debugPrint('  [$i] ${_playlist[i].zikr.id} - Repetition ${_playlist[i].repetition}/${_playlist[i].totalRepetitions}');
    }
  }

  Future<void> play() async {
    if (_playlist.isEmpty) return;

    // Always start from the beginning when play() is called
    // This ensures consistent queue order
      _currentIndex = 0;
    debugPrint('Starting playlist from beginning (index 0)');

    await _playCurrentItem();
  }

  Future<void> _playCurrentItem() async {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) {
      _updateState(PlaylistState.completed);
      return;
    }

    final item = _playlist[_currentIndex];
    _currentItemController.add(item);
    _updateState(PlaylistState.playing);

    debugPrint('Playing item ${_currentIndex + 1}/${_playlist.length}: ${item.zikr.id} (Repetition ${item.repetition}/${item.totalRepetitions})');

    try {
      await _player.setAsset(item.audioPath);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _updateState(PlaylistState.error);
      // Try to continue with next item
      _currentIndex++;
      if (_currentIndex < _playlist.length) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _playCurrentItem();
      } else {
        _updateState(PlaylistState.completed);
      }
    }
  }

  void _onTrackCompleted() {
    debugPrint('Track ${_currentIndex + 1} completed, moving to next...');
    _currentIndex++;
    if (_currentIndex < _playlist.length) {
      // Small delay before playing next track to ensure smooth transition
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_state != PlaylistState.completed) {
        _playCurrentItem();
        }
      });
    } else {
      debugPrint('Playlist completed! All ${_playlist.length} items played.');
      _updateState(PlaylistState.completed);
      _currentItemController.add(null);
    }
  }

  Future<void> pause() async {
    if (_state == PlaylistState.playing) {
      await _player.pause();
      _updateState(PlaylistState.paused);
    }
  }

  Future<void> resume() async {
    if (_state == PlaylistState.paused) {
      await _player.play();
      _updateState(PlaylistState.playing);
    } else if (_state == PlaylistState.idle || _state == PlaylistState.completed) {
      await play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentIndex = -1;
    _updateState(PlaylistState.idle);
    _currentItemController.add(null);
  }

  Future<void> skipToNext() async {
    if (_currentIndex < _playlist.length - 1) {
      await _player.stop();
      _currentIndex++;
      await _playCurrentItem();
    }
  }

  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      await _player.stop();
      _currentIndex--;
      await _playCurrentItem();
    }
  }

  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      await _player.stop();
      _currentIndex = index;
      await _playCurrentItem();
    }
  }

  void _updateState(PlaylistState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Duration? get duration => _player.duration;
  Duration get position => _player.position;

  Future<void> dispose() async {
    await _player.dispose();
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

