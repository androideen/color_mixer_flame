import 'package:flame_audio/flame_audio.dart';

class SoundHelper {
  static void bgm() {
    FlameAudio.bgm.play('bgm.wav');
  }
  static void bgmStop(){
    FlameAudio.bgm.stop();
  }

  static void shoot() {
    FlameAudio.play('shoot.wav');
  }

  static void dead() {
    FlameAudio.play('explosion.wav');
  }

}
