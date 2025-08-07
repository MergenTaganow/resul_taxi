import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdditionalSettingsService {
  AdditionalSettingsService();

  double soundLevel = 0.5;
  bool vibrationEnabled = true;
  VoidCallback? notifyListeners;
  String ringtone = 'phone.mp3';
  // bool _notificationsEnabled = true;

  addListener(VoidCallback listener) {
    notifyListeners = listener;
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    soundLevel = prefs.getDouble('sound_level') ?? 0.5;
    vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    ringtone = prefs.getString('ringtone') ?? 'funny.mp3';
    notifyListeners?.call();
    // _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_level', soundLevel);
    await prefs.setBool('vibration_enabled', vibrationEnabled);
    await prefs.setString('ringtone', ringtone);
    // await prefs.setBool('notifications_enabled', _notificationsEnabled);
  }
}
