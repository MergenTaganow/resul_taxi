import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playNewOrderSound() async {
    try {
      // Play a notification sound for new order using system sound
      await _audioPlayer.play(DeviceFileSource('/System/Library/Sounds/Notification.aiff'));
    } catch (e) {
      print('Error playing new order sound: $e');
    }
  }

  Future<void> playOrderStartSound() async {
    try {
      // Play a notification sound for order start
      await _audioPlayer.play(DeviceFileSource('/System/Library/Sounds/Notification.aiff'));
    } catch (e) {
      print('Error playing order start sound: $e');
    }
  }

  Future<void> playOrderCompleteSound() async {
    try {
      // Play a notification sound for order completion
      await _audioPlayer.play(DeviceFileSource('/System/Library/Sounds/Notification.aiff'));
    } catch (e) {
      print('Error playing order complete sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
