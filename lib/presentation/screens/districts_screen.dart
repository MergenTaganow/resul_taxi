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
  bool _autoModeEnabled = false;
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
          SnackBar(content: Text('Район успешно изменён')),
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
          SnackBar(content: Text('Ошибка при изменении района')),
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
          SnackBar(content: Text('Вы снялись с отметок района')),
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
          SnackBar(content: Text('Ошибка при снятии с отметок')),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              top: kToolbarHeight + 4, left: 16, right: 16, bottom: 16),
          child: !_profileLoaded
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Title
                    const Text(
                      'Районы',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Auto switch checkbox
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _autoModeEnabled ? true : _autoSwitchRegions,
                            onChanged: (_autoModeEnabled ||
                                    _isAutoSwitchForcedByBackend)
                                ? null
                                : (value) async {
                                    final newValue = value ?? false;
                                    setState(() {
                                      _autoSwitchRegions = newValue;
                                    });

                                    // Save to local storage
                                    final settingsService =
                                        getIt<SettingsService>();
                                    await settingsService
                                        .setAutoSwitchRegions(newValue);

                                    // Start or stop location monitoring based on new value
                                    if (newValue == true) {
                                      print(
                                          '[DISTRICTS] Auto-switch enabled, starting location monitoring...');
                                      _startLocationMonitoring();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Автоматическое переключение регионов включено'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      print(
                                          '[DISTRICTS] Auto-switch disabled, stopping location monitoring...');
                                      _stopLocationMonitoring();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Автоматическое переключение регионов отключено'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                            activeColor: (_autoModeEnabled ||
                                    _isAutoSwitchForcedByBackend)
                                ? Colors.grey
                                : Colors.green,
                            checkColor: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Автоматически переключать регионы',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_autoModeEnabled)
                                  const Text(
                                    '(включено автоматически)',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  )
                                else if (_isAutoSwitchForcedByBackend)
                                  const Text(
                                    '(включено сервером)',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
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
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is DistrictsError) {
                            return Center(
                                child: Text('Ошибка загрузки районов'));
                          } else if (state is DistrictsLoaded) {
                            final districts = state.districts;
                            if (districts.isEmpty) {
                              return Center(
                                  child: Text('Нет данных о районах'));
                            }
                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                              padding: const EdgeInsets.only(top: 15),
                              itemCount: districts.length,
                              itemBuilder: (context, index) {
                                final district = districts[index];
                                final slug = district['slug'] ?? '';
                                final districtId = district['id'] as int?;
                                final isDriverDistrict =
                                    _driverDistrict == slug;

                                // Fetch stats for this district
                                // if (districtId != null) {
                                //   _fetchDistrictStats(districtId, district);
                                // }

                                // final stats = districtId != null
                                //     ? _districtStats[districtId]
                                //     : null;

                                return GestureDetector(
                                  onTap: _isRegistering
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 10),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            24),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Text(
                                                          slug.isNotEmpty
                                                              ? slug
                                                              : 'Район',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                            height: 24),
                                                        // Only show register button if auto-switch regions is disabled
                                                        if (!_autoSwitchRegions) ...[
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              if (isDriverDistrict) {
                                                                _unregisterDistrict(
                                                                    district[
                                                                        'id'],
                                                                    slug);
                                                              } else {
                                                                _registerDistrict(
                                                                    district[
                                                                        'id'],
                                                                    slug);
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  isDriverDistrict
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .green,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              minimumSize:
                                                                  const Size
                                                                      .fromHeight(
                                                                      48),
                                                            ),
                                                            child: Text(isDriverDistrict
                                                                ? 'Сняться с отметок'
                                                                : 'Зарегистрироваться'),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),
                                                        ] else ...[
                                                          // Show info message when auto-switch is enabled
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .blue
                                                                    .withOpacity(
                                                                        0.3),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .info_outline,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  size: 20,
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Автоматическое переключение регионов включено. Регистрация происходит автоматически.',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),
                                                        ],
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            _showCarList(
                                                                district['id']);
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.blue,
                                                            foregroundColor:
                                                                Colors.white,
                                                            minimumSize:
                                                                const Size
                                                                    .fromHeight(
                                                                    48),
                                                          ),
                                                          child: const Text(
                                                              'Список машин'),
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    FreeRequestsScreen(
                                                                        districtId:
                                                                            district['id']),
                                                              ),
                                                            );
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.08),
                                                            foregroundColor:
                                                                Colors.white,
                                                            minimumSize:
                                                                const Size
                                                                    .fromHeight(
                                                                    48),
                                                          ),
                                                          child: const Text(
                                                              'Свободные заказы'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                  child: Stack(
                                    children: [
                                      Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        color: isDriverDistrict
                                            ? Colors.green
                                            : null,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                slug.isNotEmpty
                                                    ? slug
                                                    : 'Район',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDriverDistrict
                                                      ? Colors.white
                                                      : null,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  _StatItem(
                                                    icon: Icons.queue,
                                                    value:
                                                        '${district['driver_current_queue'] ?? 0}',
                                                    color: Colors.white,
                                                  ),
                                                  _StatItem(
                                                    icon: Icons.local_taxi,
                                                    value:
                                                        '${district['queue_count'] ?? 0}',
                                                    color: Colors.white,
                                                  ),
                                                  _StatItem(
                                                    icon: Icons.assignment,
                                                    value:
                                                        '${district['not_accepted_request_count'] ?? 0}',
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // if (_isRegistering && !isDriverDistrict)
                                      //   Positioned.fill(
                                      //     child: Container(
                                      //       decoration: BoxDecoration(
                                      //         color:
                                      //             Colors.black.withOpacity(0.2),
                                      //         borderRadius:
                                      //             BorderRadius.circular(16),
                                      //       ),
                                      //       child: const Center(
                                      //         child:
                                      //             CircularProgressIndicator(),
                                      //       ),
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                          // Initial state: trigger fetch
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? label;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.value,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 14, color: color),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 2),
          Text(
            label!,
            style: TextStyle(
              fontSize: 10,
              color: color?.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
