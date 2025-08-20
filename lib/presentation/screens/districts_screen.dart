import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/presentation/blocs/districts/districts_cubit.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:taxi_service/presentation/screens/free_requests_screen.dart';
import 'package:taxi_service/presentation/screens/cars_list_screen.dart';
import 'package:taxi_service/core/services/settings_service.dart';
import 'package:taxi_service/core/services/location_district_service.dart';
import 'package:taxi_service/core/mixins/location_warning_mixin.dart';
import 'dart:ui';
import 'dart:async';

class DistrictsScreen extends StatefulWidget {
  const DistrictsScreen({Key? key}) : super(key: key);

  @override
  State<DistrictsScreen> createState() => _DistrictsScreenState();
}

class _DistrictsScreenState extends State<DistrictsScreen>
    with LocationWarningMixin {
  String? _driverDistrict = '';
  bool _profileLoaded = false;
  bool _isRegistering = false;
  bool _autoSwitchRegions = false;
  bool _isAutoSwitchForcedByBackend = false;
  final bool _autoModeEnabled = false;
  // Map<int, Map<String, dynamic>> _districtStats = {};
  StreamSubscription<Map<String, dynamic>?>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _fetchProfileDistricts();
    _loadAutoModeSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistrictsCubit>().fetchDistricts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh settings when screen is focused
    _loadAutoModeSettings();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  // Future<void> _fetchDistrictStats(
  //     int districtId, Map<String, dynamic> district) async {
  //   if (_districtStats.containsKey(districtId)) return;

  //   try {
  //     setState(() {
  //       _districtStats[districtId] = {
  //         'free_orders': district['not_accepted_request_count'] ?? 0,
  //         'queue': district['driver_current_queue'] ?? 0,
  //         'cars': district['queue_count'] ?? 0,
  //       };
  //     });
  //   } catch (e) {
  //     print('Error fetching district stats: $e');
  //   }
  // }

  Future<void> _fetchProfileDistricts() async {
    final profile = await getIt<AuthRepository>().getProfile();
    // The response is a map, so extract slug directly
    String? driverDistrict;
    final districts = profile['districts'];
    if (districts is Map && districts['slug'] != null) {
      driverDistrict = districts['slug'] as String;
    }
    setState(() {
      _driverDistrict = driverDistrict;
      _profileLoaded = true;
    });
  }

  Future<void> _loadAutoModeSettings() async {
    final settingsService = getIt<SettingsService>();

    // Reset autoSwitchRegions to ensure fresh start (especially on app restart)
    settingsService.resetAutoSwitchRegions();

    // Get profile data to check backend auto-switch district setting
    List<Map<String, dynamic>>? backendSettings;

    try {
      // Fetch driver settings from backend
      final settings = await getIt<AuthRepository>().getDriverSettings();
      backendSettings = settings;

      // Look for auto_switch_regions setting in the backend settings
      Map<String, dynamic>? autoSwitchSetting;
      if (settings.isNotEmpty) {
        for (final setting in settings) {
          if (setting['key'] == 'auto_mode') {
            autoSwitchSetting = setting;
            break;
          }
        }
      }

      print('[DISTRICTS] Backend settings: $settings');
      print(
          '[DISTRICTS] Found auto_switch_regions setting: $autoSwitchSetting');
    } catch (e) {
      print(
          '[DISTRICTS] Error fetching profile/settings for auto-switch sync: $e');
    }

    // Get auto-switch setting with backend sync
    final result = await settingsService
        .getAutoSwitchDistrictWithBackendSync(backendSettings);

    setState(() {
      _autoSwitchRegions = result['enabled'] as bool;
      _isAutoSwitchForcedByBackend = result['forcedByBackend'] as bool;
    });

    // Start or stop location monitoring based on auto mode
    if (result['enabled'] as bool) {
      print('[DISTRICTS] Starting location monitoring...');
      _startLocationMonitoring();
    } else {
      print('[DISTRICTS] Stopping location monitoring...');
      _stopLocationMonitoring();
    }
  }

  void _startLocationMonitoring() {
    _stopLocationMonitoring(); // Cancel any existing subscription

    print('[DISTRICTS] Starting location monitoring...');
    print('[DISTRICTS] Current driver district: $_driverDistrict');
    print('[DISTRICTS] Auto mode enabled: $_autoModeEnabled');
    print('[DISTRICTS] Auto switch regions: $_autoSwitchRegions');

    final locationService = getIt<LocationDistrictService>();
    _locationSubscription = locationService.startLocationMonitoring().listen(
      (district) async {
        print('[DISTRICTS] Location update - detected district: $district');
        print('[DISTRICTS] Current driver district: $_driverDistrict');

        if (district != null && mounted) {
          final districtId = district['id'] as int?;
          final slug = district['slug'] as String?;

          print('[DISTRICTS] District ID: $districtId, Slug: $slug');
          print(
              '[DISTRICTS] Should switch: ${districtId != null && slug != null && slug != _driverDistrict}');

          if (districtId != null && slug != null && slug != _driverDistrict) {
            print('[DISTRICTS] Auto-switching to district: $slug');
            print('[DISTRICTS] Switching from: $_driverDistrict to: $slug');
            // Auto-switch to the new district
            await _registerDistrict(districtId, slug);
          } else {
            print(
                '[DISTRICTS] No switch needed - same district or invalid data');
          }
        } else {
          print('[DISTRICTS] No district detected or widget not mounted');
        }
      },
      onError: (error) {
        print('[DISTRICTS] Location monitoring error: $error');
      },
    );
  }

  void _stopLocationMonitoring() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _registerDistrict(int districtId, String slug) async {
    setState(() {
      _isRegistering = true;
    });
    try {
      await getIt<AuthRepository>().registerDistrict(districtId);
      setState(() {
        _driverDistrict = slug;
        _isRegistering = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Район успешно изменён')),
        );
        // Fetch districts data again to update the UI
        context.read<DistrictsCubit>().fetchDistricts();
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при изменении района')),
        );
      }
    }
  }

  Future<void> _unregisterDistrict(int districtId, String slug) async {
    setState(() {
      _isRegistering = true;
    });
    try {
      await getIt<AuthRepository>().unregisterDistrict(districtId);
      setState(() {
        _driverDistrict = null;
        _isRegistering = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вы снялись с отметок района')),
        );
        // Fetch districts data again to update the UI
        context.read<DistrictsCubit>().fetchDistricts();
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при снятии с отметок')),
        );
      }
    }
  }

  void _showCarList(int districtId) {
    // Find the district name from the current districts list
    final districts = context.read<DistrictsCubit>().state;
    String districtName = 'Район';

    if (districts is DistrictsLoaded) {
      final district = districts.districts.firstWhere(
        (d) => d['id'] == districtId,
        orElse: () => {'slug': 'Район'},
      );
      districtName = district['slug'] ?? 'Район';
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CarsListScreen(
          districtId: districtId,
          districtName: districtName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text('Районы', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: !_profileLoaded
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Column(
              children: [
                // Auto switch toggle
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Switch(
                        value: _autoModeEnabled ? true : _autoSwitchRegions,
                        onChanged: (_autoModeEnabled || _isAutoSwitchForcedByBackend)
                            ? null
                            : (value) async {
                                final newValue = value;
                                setState(() {
                                  _autoSwitchRegions = newValue;
                                });

                                // Save to local storage
                                final settingsService = getIt<SettingsService>();
                                await settingsService.setAutoSwitchRegions(newValue);

                                // Start or stop location monitoring based on new value
                                if (newValue == true) {
                                  _startLocationMonitoring();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Автопереключение включено'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  _stopLocationMonitoring();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Автопереключение отключено'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                        activeColor: Colors.orange,
                        inactiveThumbColor: Colors.grey[600],
                        inactiveTrackColor: Colors.grey[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Автопереключение районов',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_autoModeEnabled)
                              const Text(
                                'Включено автоматически',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              )
                            else if (_isAutoSwitchForcedByBackend)
                              const Text(
                                'Включено сервером',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Districts grid
                Expanded(
                  child: BlocBuilder<DistrictsCubit, DistrictsState>(
                    builder: (context, state) {
                      if (state is DistrictsLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.orange));
                      } else if (state is DistrictsError) {
                        return const Center(
                          child: Text(
                            'Ошибка загрузки районов',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else if (state is DistrictsLoaded) {
                        final districts = state.districts;
                        if (districts.isEmpty) {
                          return const Center(
                            child: Text(
                              'Нет данных о районах',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                          ),
                          padding: const EdgeInsets.all(16),
                          itemCount: districts.length,
                          itemBuilder: (context, index) {
                            final district = districts[index];
                            final slug = district['slug'] ?? '';
                            final districtId = district['id'] as int?;
                            final isDriverDistrict = _driverDistrict == slug;

                            return _DistrictCard(
                              district: district,
                              slug: slug,
                              isDriverDistrict: isDriverDistrict,
                              isRegistering: _isRegistering,
                              autoSwitchRegions: _autoSwitchRegions,
                              onTap: () => _showDistrictDialog(district, slug, isDriverDistrict),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator(color: Colors.orange));
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showDistrictDialog(Map<String, dynamic> district, String slug, bool isDriverDistrict) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          slug.isNotEmpty ? slug : 'Район',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  icon: Icons.queue,
                  label: 'Очередь',
                  value: '${district['driver_current_queue'] ?? 0}',
                ),
                _StatColumn(
                  icon: Icons.local_taxi,
                  label: 'Машины',
                  value: '${district['queue_count'] ?? 0}',
                ),
                _StatColumn(
                  icon: Icons.assignment,
                  label: 'Заказы',
                  value: '${district['not_accepted_request_count'] ?? 0}',
                ),
              ],
            ),
            if (_autoSwitchRegions) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Автопереключение включено',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Register/Unregister button (only if auto-switch is disabled)
          if (!_autoSwitchRegions)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (isDriverDistrict) {
                    _unregisterDistrict(district['id'], slug);
                  } else {
                    _registerDistrict(district['id'], slug);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDriverDistrict ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  isDriverDistrict ? 'Сняться с отметок' : 'Зарегистрироваться',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Car list button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showCarList(district['id']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Список машин', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          // Free requests button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreeRequestsScreen(districtId: district['id']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Свободные заказы', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistrictCard extends StatelessWidget {
  final Map<String, dynamic> district;
  final String slug;
  final bool isDriverDistrict;
  final bool isRegistering;
  final bool autoSwitchRegions;
  final VoidCallback onTap;

  const _DistrictCard({
    required this.district,
    required this.slug,
    required this.isDriverDistrict,
    required this.isRegistering,
    required this.autoSwitchRegions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isRegistering ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDriverDistrict
                ? const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey[700]!, Colors.grey[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDriverDistrict 
                  ? Colors.green.withOpacity(0.3) 
                  : Colors.orange.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDriverDistrict 
                    ? Colors.green.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // District name
                Text(
                  slug.isNotEmpty ? slug : 'Район',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      icon: Icons.queue,
                      value: '${district['driver_current_queue'] ?? 0}',
                    ),
                    _StatItem(
                      icon: Icons.local_taxi,
                      value: '${district['queue_count'] ?? 0}',
                    ),
                    _StatItem(
                      icon: Icons.assignment,
                      value: '${district['not_accepted_request_count'] ?? 0}',
                    ),
                  ],
                ),
                // Active indicator
                if (isDriverDistrict) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'АКТИВЕН',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatItem({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
