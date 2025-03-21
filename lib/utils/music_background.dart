import 'package:audioplayers/audioplayers.dart';

class MusicPlayerService {
  static final MusicPlayerService _instance = MusicPlayerService._internal();
  factory MusicPlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  MusicPlayerService._internal();

  void play() {
    _player.play(AssetSource('audio/musicbackground.mp3'));
  }

 void playCongrats() async {
  await _player.play(AssetSource('audio/Congrats.mp3'));
  await Future.delayed(Duration(milliseconds: 1000)); // Ensuring playback starts
  _player.seek(Duration(seconds: 7)); // Skip 5 seconds
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
