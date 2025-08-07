import 'package:audioplayers/audioplayers.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/services/additional_settings_service.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  // Future<void> playNewOrderSound() async {
  //   try {
  //     // Play a notification sound for new order using system sound
  //     await _audioPlayer
  //         .play(DeviceFileSource('/System/Library/Sounds/Notification.aiff'));
  //   } catch (e) {
  //     print('Error playing new order sound: $e');
  //   }
  // }

  // Future<void> playOrderStartSound() async {
  //   try {
  //     // Play a notification sound for order start
  //     await _audioPlayer
  //         .play(DeviceFileSource('/System/Library/Sounds/Notification.aiff'));
  //   } catch (e) {
  //     print('Error playing order start sound: $e');
  //   }
  // }

  // Future<void> playOrderCompleteSound() async {
  //   try {
  //     // Play a notification sound for order completion
  //     await _audioPlayer
  //         .play(DeviceFileSource('/System/Library/Sounds/Notification.aiff'));
  //   } catch (e) {
  //     print('Error playing order complete sound: $e');
  //   }
  // }

  Future<void> playNewRequestWarningSound() async {
    try {
      // Play a warning sound for new request from socket
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      if (getIt<AdditionalSettingsService>().vibrationEnabled) {
        Vibration.vibrate(duration: 1000, repeat: 14, amplitude: 255);
      }
      await _audioPlayer.play(
          AssetSource('sounds/${getIt<AdditionalSettingsService>().ringtone}'),
          volume: getIt<AdditionalSettingsService>().soundLevel);
    } catch (e) {
      print('Error playing new request warning sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
