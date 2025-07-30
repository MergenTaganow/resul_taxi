import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdditionalSettingsScreen extends StatefulWidget {
  const AdditionalSettingsScreen({super.key});

  @override
  State<AdditionalSettingsScreen> createState() =>
      _AdditionalSettingsScreenState();
}

class _AdditionalSettingsScreenState extends State<AdditionalSettingsScreen> {
  double _soundLevel = 0.5;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  bool _autoStartEnabled = false;
  bool _darkModeEnabled = true;
  String _language = 'Русский';
  double _fontSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundLevel = prefs.getDouble('sound_level') ?? 0.5;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoStartEnabled = prefs.getBool('auto_start_enabled') ?? false;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? true;
      _language = prefs.getString('language') ?? 'Русский';
      _fontSize = prefs.getDouble('font_size') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_level', _soundLevel);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('auto_start_enabled', _autoStartEnabled);
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setString('language', _language);
    await prefs.setDouble('font_size', _fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232526),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232526),
        elevation: 0,
        title: const Text(
          'Дополнительно',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Звук и уведомления'),
            _buildSoundLevelCard(),
            _buildVibrationCard(),
            _buildNotificationsCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Внешний вид'),
            _buildDarkModeCard(),
            _buildFontSizeCard(),
            _buildLanguageCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Приложение'),
            _buildAutoStartCard(),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSoundLevelCard() {
    return _buildSettingsCard(
      icon: Icons.volume_up,
      title: 'Громкость звука',
      subtitle: '${(_soundLevel * 100).round()}%',
      child: Column(
        children: [
          Slider(
            value: _soundLevel,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            activeColor: const Color(0xFF7C3AED),
            inactiveColor: Colors.white.withOpacity(0.2),
            onChanged: (value) {
              setState(() {
                _soundLevel = value;
              });
              _saveSettings();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Тихо',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const Text(
                'Громко',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationCard() {
    return _buildSettingsCard(
      icon: Icons.vibration,
      title: 'Вибрация',
      subtitle: _vibrationEnabled ? 'Включена' : 'Выключена',
      child: Switch(
        value: _vibrationEnabled,
        onChanged: (value) {
          setState(() {
            _vibrationEnabled = value;
          });
          _saveSettings();
        },
        activeColor: const Color(0xFF7C3AED),
        inactiveThumbColor: Colors.white.withOpacity(0.3),
        inactiveTrackColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return _buildSettingsCard(
      icon: Icons.notifications,
      title: 'Уведомления',
      subtitle: _notificationsEnabled ? 'Включены' : 'Выключены',
      child: Switch(
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
          _saveSettings();
        },
        activeColor: const Color(0xFF7C3AED),
        inactiveThumbColor: Colors.white.withOpacity(0.3),
        inactiveTrackColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildDarkModeCard() {
    return _buildSettingsCard(
      icon: Icons.dark_mode,
      title: 'Темная тема',
      subtitle: _darkModeEnabled ? 'Включена' : 'Выключена',
      child: Switch(
        value: _darkModeEnabled,
        onChanged: (value) {
          setState(() {
            _darkModeEnabled = value;
          });
          _saveSettings();
        },
        activeColor: const Color(0xFF7C3AED),
        inactiveThumbColor: Colors.white.withOpacity(0.3),
        inactiveTrackColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildFontSizeCard() {
    return _buildSettingsCard(
      icon: Icons.text_fields,
      title: 'Размер шрифта',
      subtitle: _getFontSizeLabel(),
      child: Column(
        children: [
          Slider(
            value: _fontSize,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            activeColor: const Color(0xFF7C3AED),
            inactiveColor: Colors.white.withOpacity(0.2),
            onChanged: (value) {
              setState(() {
                _fontSize = value;
              });
              _saveSettings();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Маленький',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const Text(
                'Большой',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    return _buildSettingsCard(
      icon: Icons.language,
      title: 'Язык',
      subtitle: _language,
      child: PopupMenuButton<String>(
        color: const Color(0xFF2A2A2A),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _language,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        onSelected: (value) {
          setState(() {
            _language = value;
          });
          _saveSettings();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'Русский',
            child: Text('Русский', style: TextStyle(color: Colors.white)),
          ),
          const PopupMenuItem(
            value: 'English',
            child: Text('English', style: TextStyle(color: Colors.white)),
          ),
          const PopupMenuItem(
            value: 'O\'zbekcha',
            child: Text('O\'zbekcha', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoStartCard() {
    return _buildSettingsCard(
      icon: Icons.play_arrow,
      title: 'Автозапуск',
      subtitle: _autoStartEnabled ? 'Включен' : 'Выключен',
      child: Switch(
        value: _autoStartEnabled,
        onChanged: (value) {
          setState(() {
            _autoStartEnabled = value;
          });
          _saveSettings();
        },
        activeColor: const Color(0xFF7C3AED),
        inactiveThumbColor: Colors.white.withOpacity(0.3),
        inactiveTrackColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildAboutCard() {
    return _buildSettingsCard(
      icon: Icons.info_outline,
      title: 'О приложении',
      subtitle: 'Версия 1.0.0',
      child: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
        onPressed: () {
          _showAboutDialog();
        },
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7C3AED),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  String _getFontSizeLabel() {
    if (_fontSize <= 0.9) return 'Маленький';
    if (_fontSize <= 1.1) return 'Средний';
    if (_fontSize <= 1.3) return 'Большой';
    return 'Очень большой';
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'О приложении',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Такси Водитель',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Версия: 1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 4),
            Text(
              'Разработчик: Taxi Service Team',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 4),
            Text(
              '© 2024 Все права защищены',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Color(0xFF7C3AED)),
            ),
          ),
        ],
      ),
    );
  }
}
