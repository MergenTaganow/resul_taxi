import 'package:flutter/material.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:taxi_service/core/mixins/location_warning_mixin.dart';
import 'package:taxi_service/presentation/screens/gps_debug_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with LocationWarningMixin {
  bool _onDuty = true;
  bool _loading = false;
  bool _dutyLoading = false;
  String? _error;
  List<Map<String, dynamic>> _settings = [];
  bool? _autoMode;

  Map<String, String> tr = {
    "Commute urgent mode": "Быстрое прибытие",
    "Commute normal mode": "Обычное прибытие",
    "Commute free mode": "Свободное прибытие",
    "Alerts": "Уведомления",
    "Chats": "Сообщения",
    "Auto mode for requests": "Автоматическое принятие заказов",
  };

  @override
  void initState() {
    super.initState();
    _fetchProfileAndSettings();
    _setDutyStatus(true);
  }

  Future<void> _fetchProfileAndSettings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Fetch profile to get duty_status
      final profile = await getIt<AuthRepository>().getProfile();
      final dutyStatus = profile['duty_status'] as String?;

      // Fetch settings
      final settings = await getIt<AuthRepository>().getDriverSettings();

      settings.removeWhere((e) => e["key"] == "commute_for_waiting");
      setState(() {
        _settings = settings;
        _onDuty = dutyStatus == 'on_duty';
        _autoMode = dutyStatus == 'on_duty'; // Use duty_status for auto mode
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка при загрузке настроек';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _setDutyStatus(bool onDuty) async {
    setState(() {
      _dutyLoading = true;
      _error = null;
    });
    try {
      await getIt<AuthRepository>().setDutyStatus(onDuty ? 'on_duty' : 'off_duty');
      setState(() {
        _onDuty = onDuty;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка при обновлении статуса';
      });
    } finally {
      setState(() {
        _dutyLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text('Настройки', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchProfileAndSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Duty Status Section
                      _buildSectionHeader('Статус водителя'),
                      const SizedBox(height: 12),
                      _buildDutyStatusCard(),
                      const SizedBox(height: 24),

                      // Settings Section
                      _buildSectionHeader('Настройки приложения'),
                      const SizedBox(height: 12),
                      ..._settings.map((setting) => _buildSettingCard(setting)),
                      const SizedBox(height: 24),

                      // Debug Section
                      _buildSectionHeader('Отладка'),
                      const SizedBox(height: 12),
                      _buildDebugCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDutyStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _onDuty ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _onDuty ? Icons.directions_car : Icons.directions_car_filled,
            color: _onDuty ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          _onDuty ? 'На смене' : 'Не на смене',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _onDuty ? 'Готов принимать заказы' : 'Не принимает заказы',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing: _dutyLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              )
            : Switch(
                value: _onDuty,
                onChanged: (val) => _setDutyStatus(val),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red.withOpacity(0.3),
              ),
      ),
    );
  }

  Widget _buildSettingCard(Map<String, dynamic> setting) {
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
            color: _getSettingIconColor(setting['type']).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getSettingIcon(setting['type']),
            color: _getSettingIconColor(setting['type']),
            size: 24,
          ),
        ),
        title: Text(
          tr[setting['description']] ?? setting['key'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          _getSettingDescription(setting),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing: setting['type'] == 'boolean'
            ? Switch(
                value: setting['value'].toString() == 'true',
                onChanged: null, // Read-only for now
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red.withOpacity(0.3),
              )
            : setting['key'] == 'contacts'
                ? _buildCallButton(setting['value'])
                : _buildValueDisplay(setting),
      ),
    );
  }

  Widget _buildCallButton(String phoneNumber) {
    return GestureDetector(
      onTap: () async {
        final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        final url = 'tel:$cleanPhone';
        await launchUrl(Uri.parse(url));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.call, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildValueDisplay(Map<String, dynamic> setting) {
    String displayValue = setting['description'].contains('Commute')
        ? '${(int.parse(setting['value']) / 1000 / 60).round()} мин'
        : setting['value'].toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Text(
        displayValue,
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDebugCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.gps_fixed, color: Colors.blue, size: 24),
        ),
        title: const Text(
          'GPS Debug',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: const Text(
          'Тест точности GPS и обнаружения движения',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GpsDebugScreen(),
            ),
          );
        },
      ),
    );
  }

  IconData _getSettingIcon(String? type) {
    switch (type) {
      case 'boolean':
        return Icons.toggle_on;
      case 'number':
        return Icons.timer;
      case 'string':
        return Icons.phone;
      default:
        return Icons.settings;
    }
  }

  Color _getSettingIconColor(String? type) {
    switch (type) {
      case 'boolean':
        return Colors.blue;
      case 'number':
        return Colors.orange;
      case 'string':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getSettingDescription(Map<String, dynamic> setting) {
    switch (setting['key']) {
      case 'auto_mode':
        return 'Автоматическое принятие заказов';
      case 'commute_urgent':
        return 'Время быстрого прибытия';
      case 'commute_normal_mode':
        return 'Время обычного прибытия';
      case 'commute_free_mode':
        return 'Время свободного прибытия';
      case 'alerts':
        return 'Уведомления о заказах';
      case 'chats':
        return 'Настройки сообщений';
      case 'contacts':
        return 'Контакт администратора';
      default:
        return setting['description'] ?? '';
    }
  }


}
