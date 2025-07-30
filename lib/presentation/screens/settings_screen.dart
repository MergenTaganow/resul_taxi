import 'package:flutter/material.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:taxi_service/core/mixins/location_warning_mixin.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with LocationWarningMixin {
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
      await getIt<AuthRepository>()
          .setDutyStatus(onDuty ? 'on_duty' : 'off_duty');
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

  Future<void> _setAutoMode(bool autoMode) async {
    setState(() {
      _dutyLoading = true;
      _error = null;
    });
    try {
      // Update duty status based on auto mode
      await getIt<AuthRepository>()
          .setDutyStatus(autoMode ? 'on_duty' : 'off_duty');
      setState(() {
        _autoMode = autoMode;
        _onDuty = autoMode;
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
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   'Статус водителя',
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 24),
              // Duty Status
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text('Статус водителя',
              //         style: TextStyle(color: Colors.white, fontSize: 16)),
              //     _dutyLoading
              //         ? const SizedBox(
              //             width: 48,
              //             height: 24,
              //             child: Center(
              //               child: SizedBox(
              //                 width: 24,
              //                 height: 24,
              //                 child: CircularProgressIndicator(
              //                   strokeWidth: 3,
              //                   valueColor: AlwaysStoppedAnimation<Color>(
              //                       Colors.greenAccent),
              //                 ),
              //               ),
              //             ),
              //           )
              //         : Switch(
              //             value: _onDuty,
              //             onChanged: (val) => _setDutyStatus(val),
              //             activeColor: Colors.greenAccent,
              //             inactiveThumbColor: Colors.redAccent,
              //           ),
              //   ],
              // ),
              // const SizedBox(height: 24),

              // Auto Mode for Order Acceptance
              const SizedBox(height: 32),
              if (_loading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ] else ...[
                ..._settings.map((setting) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        color: Colors.white.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        child: ListTile(
                          leading: _buildSettingIcon(setting['type']),
                          title: Text(
                            tr[setting['description']] ?? setting['key'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          trailing: setting['type'] == 'boolean'
                              ? Switch(
                                  value: setting['value'].toString() == 'true',
                                  onChanged: null,
                                  activeColor: Colors.greenAccent,
                                  inactiveThumbColor: Colors.redAccent,
                                )
                              : Text(
                                  setting['description'].contains('Commute')
                                      ? (int.parse(setting['value']) /
                                                  1000 /
                                                  60)
                                              .round()
                                              .toString() +
                                          ' мин'
                                      : setting['value'].toString(),
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Widget _buildSettingIcon(String? type) {
    switch (type) {
      case 'boolean':
        return const Icon(Icons.toggle_on, color: Colors.blueAccent, size: 32);
      case 'number':
        return const Icon(Icons.timer, color: Colors.orangeAccent, size: 28);
      default:
        return const Icon(Icons.settings, color: Colors.white54, size: 28);
    }
  }
}
