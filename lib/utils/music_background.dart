import 'package:audioplayers/audioplayers.dart';

class MusicPlayerService {
  static final MusicPlayerService _instance = MusicPlayerService._internal();
  factory MusicPlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  MusicPlayerService._internal();

  void play() {
    _player.play(AssetSource('audio/musicbackground.mp3'));
  }

  void stop() {
    _player.stop();
  }

  void pause() {
    _player.pause();
  }

  void resume() {
    _player.resume();
  }
}