import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/core/services/taxometer_service.dart';
import 'package:taxi_service/presentation/screens/districts_screen.dart';
import 'package:taxi_service/presentation/screens/taxometer_screen.dart';
import 'package:taxi_service/presentation/screens/notifications_screen.dart';
import 'package:taxi_service/presentation/screens/messages_screen.dart';
import 'package:taxi_service/presentation/screens/payments_screen.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:taxi_service/presentation/screens/settings_screen.dart';
import 'package:taxi_service/core/services/gps_service.dart';
import 'package:taxi_service/presentation/screens/additional_settings_screen.dart';
import 'package:taxi_service/core/services/profile_service.dart';
import 'package:taxi_service/core/mixins/location_warning_mixin.dart';
import 'package:taxi_service/core/services/connectivity_service.dart';
import '../../core/services/queued_requests_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver, LocationWarningMixin {
  late ProfileService _profileService;
  late GpsService _gpsService;
  late ConnectivityService _connectivityService;
  bool _isGpsEnabled = false;
  bool _isConnected = false;
  double _currentBalance = 0.0;
  late TaxometerService _taxometerService;
  Timer? _ttsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _profileService = getIt<ProfileService>();
    _gpsService = getIt<GpsService>();
    _connectivityService = getIt<ConnectivityService>();
    _taxometerService = getIt<TaxometerService>();
    _loadProfile();
    _initializeGpsMonitoring();
    _initializeConnectivityMonitoring();
    _initializeBalanceMonitoring();
    listenToConnectivity();
    _taxometerService.addStateChangeListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh balance when app is resumed (e.g., returning from taxometer)
      _loadProfile();
    }
  }

  void listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      final isConnected = result != ConnectivityResult.none;

      if (isConnected) {
        // ✅ Internet is back — stop TTS loop and retry requests
        _ttsTimer?.cancel();
        _ttsTimer = null;
        getIt<QueuedRequestsService>().retryQueuedRequests();
      } else {
        // 📡 No internet — start TTS loop every 10 seconds
        _ttsTimer ??= Timer.periodic(const Duration(seconds: 10), (timer) async {
            try {
              await _taxometerService.speakSentence("Включите интернет!");
            } catch (e) {
              print('Error speaking message: $e');
            }
          });
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      await _profileService.loadProfile();
    } catch (e) {
      print('[MAIN SCREEN] Error loading profile: $e');
    }
  }

  void _initializeGpsMonitoring() {
    _gpsService.gpsStatusStream.listen((isEnabled) {
      if (mounted) {
        setState(() {
          _isGpsEnabled = isEnabled;
        });
      }
    });

    // Get initial GPS status
    setState(() {
      _isGpsEnabled = _gpsService.isGpsEnabled;
    });
  }

  void _initializeConnectivityMonitoring() {
    _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });

    // Get initial connectivity status
    setState(() {
      _isConnected = _connectivityService.isConnected;
    });
  }

  void _initializeBalanceMonitoring() {
    // Listen to balance changes
    _profileService.balanceStream.listen((newBalance) {
      print('[MAIN SCREEN] Balance updated: $_currentBalance -> $newBalance');
      if (mounted) {
        setState(() {
          _currentBalance = newBalance;
        });
        print('[MAIN SCREEN] UI updated with new balance: $_currentBalance');
      }
    });

    // Set initial balance
    _currentBalance = _profileService.balance;
    print('[MAIN SCREEN] Initial balance set: $_currentBalance');
  }

  Future<void> _checkGpsStatus() async {
    await _gpsService.checkAndShowDialog(context);
  }

  Future<Map<String, String>> _getDriverData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'first_name': prefs.getString('first_name') ?? '',
      'last_name': prefs.getString('last_name') ?? '',
      'vehicle_type': prefs.getString('vehicle_type') ?? '',
      'vehicle_number': prefs.getString('vehicle_number') ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.microtask(() => false),
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          title: Row(
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: Image.asset(
              //     'assets/images/tiztaxi.png',
              //     width: 32,
              //     height: 32,
              //     errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_taxi, color: Colors.white),
              //   ),
              // ),
              // const SizedBox(width: 6),
              const Text('Resul Taxi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16)),
              const Spacer(),
              // Balance
              GestureDetector(
                onTap: _loadProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₸ ${_currentBalance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // GPS Status
              GestureDetector(
                onTap: _checkGpsStatus,
                child: Icon(
                  _isGpsEnabled ? Icons.location_on : Icons.location_off,
                  color: _isGpsEnabled ? Colors.white : Colors.red[300],
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              // Network Status
              GestureDetector(
                onTap: () async => await _connectivityService.testConnectivity(),
                child: Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.white : Colors.red[300],
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.grey[800],
          child: FutureBuilder<Map<String, String>>(
            future: _getDriverData(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.orange),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          '${data['first_name']} ${data['last_name']}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['vehicle_type'] ?? 'Professional Service',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['vehicle_number'] ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment, color: Colors.white),
                    title: const Text('Платежи', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.white),
                    title: const Text('Написать админу', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      _showErrorReportDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text('Настройки', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    },
                  ),
                ],
              );
            },
          ),
        ),
        body: Column(
          children: [
            // Network warning
            if (!_isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red,
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Нет подключения к интернету', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            // Main grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _SimpleButton(
                      icon: Icons.grid_view,
                      label: 'Районы',
                      color: Colors.blue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistrictsScreen())),
                    ),
                    _SimpleButton(
                      icon: Icons.speed,
                      label: 'Таксометр',
                      color: Colors.orange,
                      onTap: _taxometerService.currentOrder != null
                          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxometerScreen()))
                          : null,
                    ),
                    _SimpleButton(
                      icon: Icons.chat_bubble,
                      label: 'Сообщения',
                      color: Colors.green,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen())),
                    ),
                    _SimpleButton(
                      icon: Icons.notifications,
                      label: 'Объявления',
                      color: Colors.purple,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    ),
                    _SimpleButton(
                      icon: Icons.settings,
                      label: 'Настройки',
                      color: Colors.grey,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                    _SimpleButton(
                      icon: Icons.more_horiz,
                      label: 'Дополнительно',
                      color: Colors.teal,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdditionalSettingsScreen())),
                    ),
                  ],
                ),
              ),
            ),
            // Exit button at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => SystemNavigator.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Выход', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorReportDialog(BuildContext context) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text('Написать админу', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Опишите проблему:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ваше сообщение...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                getIt<ApiClient>().sendAppeal(messageController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Сообщение отправлено')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }
}

class _SimpleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SimpleButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDisabled 
                ? LinearGradient(
                    colors: [Colors.grey[700]!, Colors.grey[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled ? Colors.grey[500]! : color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDisabled 
                    ? Colors.black.withOpacity(0.1)
                    : color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDisabled 
                      ? Colors.grey[600]!.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: isDisabled ? Colors.grey[400] : Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: isDisabled ? Colors.grey[400] : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


