import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMusicOn = true;
  bool _initialized = false;

  bool get isMusicOn => _isMusicOn;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('music_on') ?? true;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.6);

    if (_isMusicOn) {
      await _play();
    }
  }

  Future<void> _play() async {
    try {
      await _player.play(AssetSource('music.mp3'));
    } catch (e) {
      // Audio file not found - silently fail
    }
  }

  Future<void> toggleMusic() async {
    _isMusicOn = !_isMusicOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_on', _isMusicOn);

    if (_isMusicOn) {
      await _play();
    } else {
      await _player.pause();
    }
  }

  Future<void> pauseMusic() async {
    await _player.pause();
  }

  Future<void> resumeMusic() async {
    if (_isMusicOn) {
      await _player.resume();
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
