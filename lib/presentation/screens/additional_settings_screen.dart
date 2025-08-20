import 'package:flutter/material.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/services/additional_settings_service.dart';

class AdditionalSettingsScreen extends StatefulWidget {
  const AdditionalSettingsScreen({super.key});

  @override
  State<AdditionalSettingsScreen> createState() =>
      _AdditionalSettingsScreenState();
}

class _AdditionalSettingsScreenState extends State<AdditionalSettingsScreen> {
  final AdditionalSettingsService _additionalSettingsService =
      getIt<AdditionalSettingsService>();

  @override
  void initState() {
    super.initState();
    getIt<AdditionalSettingsService>().addListener(stateChanger);
    getIt<AdditionalSettingsService>().loadSettings();
  }

  stateChanger() {
    setState(() {});
  }

  @override
  dispose() {
    _additionalSettingsService.saveSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text('Дополнительно', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Звук и уведомления'),
            const SizedBox(height: 12),
            _buildSoundLevelCard(),
            _buildVibrationCard(),
            _buildRingtoneCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Приложение'),
            const SizedBox(height: 12),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSoundLevelCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Громкость звука',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(_additionalSettingsService.soundLevel * 100).round()}%',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Slider(
                  value: _additionalSettingsService.soundLevel,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  activeColor: Colors.orange,
                  inactiveColor: Colors.grey[600],
                  onChanged: (value) {
                    setState(() {
                      _additionalSettingsService.soundLevel = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Тихо',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      'Громко',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibrationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.vibration,
            color: Colors.blue,
            size: 24,
          ),
        ),
        title: const Text(
          'Вибрация',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _additionalSettingsService.vibrationEnabled ? 'Включена' : 'Выключена',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: _additionalSettingsService.vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _additionalSettingsService.vibrationEnabled = value;
            });
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
          inactiveTrackColor: Colors.red.withOpacity(0.3),
        ),
      ),
    );
  }

  // Widget _buildNotificationsCard() {
  //   return _buildSettingsCard(
  //     icon: Icons.notifications,
  //     title: 'Уведомления',
  //     subtitle: _notificationsEnabled ? 'Включены' : 'Выключены',
  //     child: Switch(
  //       value: _notificationsEnabled,
  //       onChanged: (value) {
  //         setState(() {
  //           _notificationsEnabled = value;
  //         });
  //         _saveSettings();
  //       },
  //       activeColor: const Color(0xFF7C3AED),
  //       inactiveThumbColor: Colors.white.withOpacity(0.3),
  //       inactiveTrackColor: Colors.white.withOpacity(0.1),
  //     ),
  //   );
  // }

  // Widget _buildDarkModeCard() {
  //   return _buildSettingsCard(
  //     icon: Icons.dark_mode,
  //     title: 'Темная тема',
  //     subtitle: _darkModeEnabled ? 'Включена' : 'Выключена',
  //     child: Switch(
  //       value: _darkModeEnabled,
  //       onChanged: (value) {
  //         setState(() {
  //           _darkModeEnabled = value;
  //         });
  //         _saveSettings();
  //       },
  //       activeColor: const Color(0xFF7C3AED),
  //       inactiveThumbColor: Colors.white.withOpacity(0.3),
  //       inactiveTrackColor: Colors.white.withOpacity(0.1),
  //     ),
  //   );
  // }

  // Widget _buildFontSizeCard() {
  //   return _buildSettingsCard(
  //     icon: Icons.text_fields,
  //     title: 'Размер шрифта',
  //     subtitle: _getFontSizeLabel(),
  //     child: Column(
  //       children: [
  //         Slider(
  //           value: _fontSize,
  //           min: 0.8,
  //           max: 1.4,
  //           divisions: 6,
  //           activeColor: const Color(0xFF7C3AED),
  //           inactiveColor: Colors.white.withOpacity(0.2),
  //           onChanged: (value) {
  //             setState(() {
  //               _fontSize = value;
  //             });
  //             _saveSettings();
  //           },
  //         ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text(
  //               'Маленький',
  //               style: TextStyle(color: Colors.white54, fontSize: 12),
  //             ),
  //             const Text(
  //               'Большой',
  //               style: TextStyle(color: Colors.white54, fontSize: 12),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRingtoneCard() {
    String getRingtoneName() {
      switch (_additionalSettingsService.ringtone) {
        case 'funny.mp3':
          return 'Funny';
        case 'phone.mp3':
          return 'Default';
        default:
          return 'Simple';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.purple,
            size: 24,
          ),
        ),
        title: const Text(
          'Рингтон',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          getRingtoneName(),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing: PopupMenuButton<String>(
          color: Colors.grey[800],
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: const Icon(Icons.arrow_drop_down, color: Colors.purple, size: 20),
          ),
          onSelected: (value) {
            setState(() {
              _additionalSettingsService.ringtone = value;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ringtone.mp3',
              child: Text('Simple', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'phone.mp3',
              child: Text('Default', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'funny.mp3',
              child: Text('Funny', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAutoStartCard() {
  //   return _buildSettingsCard(
  //     icon: Icons.play_arrow,
  //     title: 'Автозапуск',
  //     subtitle: _autoStartEnabled ? 'Включен' : 'Выключен',
  //     child: Switch(
  //       value: _autoStartEnabled,
  //       onChanged: (value) {
  //         setState(() {
  //           _autoStartEnabled = value;
  //         });
  //         _saveSettings();
  //       },
  //       activeColor: const Color(0xFF7C3AED),
  //       inactiveThumbColor: Colors.white.withOpacity(0.3),
  //       inactiveTrackColor: Colors.white.withOpacity(0.1),
  //     ),
  //   );
  // }

  Widget _buildAboutCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 24,
          ),
        ),
        title: const Text(
          'О приложении',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: const Text(
          'Версия 1.0.0',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: _showAboutDialog,
      ),
    );
  }



  // String _getFontSizeLabel() {
  //   if (_fontSize <= 0.9) return 'Маленький';
  //   if (_fontSize <= 1.1) return 'Средний';
  //   if (_fontSize <= 1.3) return 'Большой';
  //   return 'Очень большой';
  // }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'О приложении',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_taxi, color: Colors.orange, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'Resul Taxi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.info_outline, 'Версия', '1.0.0'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.code, 'Разработчик', 'Resul Taxi'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.copyright, 'Права', '© 2025 Все права защищены'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange.withOpacity(0.2),
              foregroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Закрыть', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
