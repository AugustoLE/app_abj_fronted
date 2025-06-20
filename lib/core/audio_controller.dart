import 'package:audioplayers/audioplayers.dart';

class AudioController {
  static final AudioController _instance = AudioController._internal();
  factory AudioController() => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;
  bool isMuted = false;

  AudioController._internal();

  Future<void> init() async {
    if (_initialized) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(1.0);
    await _player.play(AssetSource('assets/audio/musica.mp3'));
    _initialized = true;
  }

  void toggleMute() {
    isMuted = !isMuted;
    _player.setVolume(isMuted ? 0.0 : 1.0);
  }

  void dispose() {
    _player.dispose();
  }
}
