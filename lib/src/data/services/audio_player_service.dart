import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

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

  Future<void> playAudio(String audioPath, {bool isLocal = true}) async {
    try {
      if (isLocal) {
        await _player.setAsset(audioPath);
      } else {
        await _player.setUrl(audioPath);
      }
      await _player.play();
    } catch (e) {
      print('Error playing audio: $e');
      rethrow;
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
