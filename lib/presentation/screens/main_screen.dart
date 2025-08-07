import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/core/services/taxometer_service.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_bloc.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_event.dart';
import 'package:taxi_service/presentation/screens/districts_screen.dart';
import 'package:taxi_service/presentation/screens/taxometer_screen.dart';
import 'package:taxi_service/presentation/screens/notifications_screen.dart';
import 'package:taxi_service/presentation/screens/messages_screen.dart';
import 'package:taxi_service/presentation/screens/statistics_screen.dart';
import 'package:taxi_service/presentation/screens/payments_screen.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:taxi_service/presentation/screens/settings_screen.dart';
import 'package:taxi_service/core/services/gps_service.dart';

import 'package:taxi_service/presentation/screens/additional_settings_screen.dart';

import 'package:taxi_service/core/services/profile_service.dart';
import 'package:taxi_service/core/mixins/location_warning_mixin.dart';
import 'package:taxi_service/core/services/connectivity_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with WidgetsBindingObserver, LocationWarningMixin {
  late ProfileService _profileService;
  late GpsService _gpsService;
  late ConnectivityService _connectivityService;
  bool _isGpsEnabled = false;
  bool _isConnected = false;
  double _currentBalance = 0.0;
  late TaxometerService _taxometerService;

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
    final theme = Theme.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return WillPopScope(
      onWillPop: () {
        // Show exit confirmation dialog
        return Future.microtask(() => false);
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: _AppDrawer(),
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF232526), Color(0xFF414345)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar with glassmorphism
                  _FrostedBar(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => scaffoldKey.currentState?.openDrawer(),
                          child: const Icon(Icons.menu,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/tiztaxi.png',
                            width: 50,
                            height: 50,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _loadProfile,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('₸ ${_currentBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // GPS Status Indicator
                        GestureDetector(
                          onTap: _checkGpsStatus,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _isGpsEnabled
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              _isGpsEnabled
                                  ? Icons.location_on
                                  : Icons.location_off,
                              color: _isGpsEnabled
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Network Status Indicator
                        GestureDetector(
                          onTap: () async {
                            await _connectivityService.testConnectivity();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _isConnected
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              _isConnected ? Icons.wifi : Icons.wifi_off,
                              color: _isConnected
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 28,
                        crossAxisSpacing: 16,
                        children: [
                          _DashboardButton(
                              icon: Icons.grid_view_rounded,
                              label: 'Районы',
                              iconColor: Colors.blueAccent,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const DistrictsScreen()),
                                );
                              }),
                          _DashboardButton(
                            icon: Icons.speed_rounded,
                            label: 'Таксометр',
                            iconColor: Colors.orange,
                            onTap: _taxometerService.currentOrder != null
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const TaxometerScreen(),
                                      ),
                                    );
                                    // Taxometer is now self-contained, no service dependency
                                    // This will be handled by the order flow
                                  }
                                : null,
                          ),
                          // _DashboardButton(
                          //     icon: Icons.event_available_rounded,
                          //     label: 'Предзаказы',
                          //     iconColor: Colors.purpleAccent),
                          _DashboardButton(
                              icon: Icons.chat_bubble_rounded,
                              label: 'Сообщения',
                              iconColor: Colors.lightBlueAccent,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MessagesScreen(),
                                  ),
                                );
                              }),
                          _DashboardButton(
                              icon: Icons.sticky_note_2_rounded,
                              label: 'Объявления',
                              iconColor: Colors.amberAccent,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen(),
                                  ),
                                );
                              }),
                          // _DashboardButton(
                          //     icon: Icons.bar_chart_rounded,
                          //     label: 'Статистика',
                          //     iconColor: Colors.greenAccent,
                          //     onTap: () {
                          //       Navigator.of(context).push(
                          //         MaterialPageRoute(
                          //           builder: (_) => const StatisticsScreen(),
                          //         ),
                          //       );
                          //     }),
                          _DashboardButton(
                              icon: Icons.build_rounded,
                              label: 'Настройки',
                              iconColor: Colors.deepOrangeAccent,
                              onTap: () async {
                                // await FloatingOverlayController
                                //     .requestPermission();
                                // await FloatingOverlayController.closeOverlay();
                                // await FloatingOverlayController.showOverlay();

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              }),
                          _DashboardButton(
                              icon: Icons.more_horiz_rounded,
                              label: 'Дополнительно',
                              iconColor: Colors.tealAccent,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdditionalSettingsScreen(),
                                  ),
                                );
                              }),
                          _DashboardButton(
                              icon: Icons.exit_to_app_rounded,
                              label: 'Выход',
                              iconColor: Colors.redAccent,
                              onTap: () async {
                                // final shouldExit = await _showExitDialog();
                                // if (shouldExit) {
                                //   // Exit the app
                                // Navigator.of(context).pop();
                                SystemNavigator.pop();
                                // }
                              }),
                          // Test button for overlay
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Network connectivity warning overlay
            if (!_isConnected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Нет подключения к интернету',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    // Taxometer is now self-contained, no service dependency
    // Show normal exit dialog
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Выход из приложения',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Вы уверены, что хотите выйти из приложения?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Выйти'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class _AppDrawer extends StatefulWidget {
  @override
  State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> {
  TextEditingController _messageController = TextEditingController();

  Future<Map<String, String>> _getDriverData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'first_name': prefs.getString('first_name') ?? '',
      'last_name': prefs.getString('last_name') ?? '',
      'vehicle_type': prefs.getString('vehicle_type') ?? '',
      'vehicle_number': prefs.getString('vehicle_number') ?? '',
    };
  }

  void _showErrorReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.bug_report_rounded,
                color: Colors.orange,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Написать админу',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Если вы столкнулись с проблемой в приложении, пожалуйста, сообщите нам об этом.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Мы рассмотрим ваше сообщение и постараемся решить проблему как можно скорее.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Письмо',
                  fillColor: Colors.transparent,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendAppeal(context, _messageController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Отправить письмо',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendAppeal(BuildContext context, String message) {
    getIt<ApiClient>().sendAppeal(message);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, String>>(
            future: _getDriverData(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // Driver info header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${data['first_name']} ${data['last_name']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.directions_car,
                                  color: Colors.white70, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                data['vehicle_type'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number,
                                  color: Colors.white70, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                data['vehicle_number'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Drawer buttons with icons

                  _DrawerButton(
                      label: 'Платежи',
                      icon: Icons.payment_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PaymentsScreen(),
                          ),
                        );
                      }),
                  _DrawerButton(
                    label: 'Написать админу',
                    icon: Icons.bug_report_rounded,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showErrorReportDialog(context);
                    },
                  ),
                  // _DrawerButton(
                  //   label: 'Мои заказы',
                  //   icon: Icons.assignment_rounded,
                  //   onTap: () {
                  //     Navigator.of(context).pop();
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (_) => const StatisticsScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  _DrawerButton(
                    label: 'Настройки',
                    icon: Icons.settings_rounded,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  //   child: Divider(color: Colors.white24, thickness: 1),
                  // ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  //   child: ElevatedButton.icon(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.red.withOpacity(0.8),
                  //       foregroundColor: Colors.white,
                  //       minimumSize: const Size.fromHeight(48),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(14),
                  //       ),
                  //       elevation: 0,
                  //     ),
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //       context.read<AuthBloc>().add(const AuthEvent.logout());
                  //     },
                  //     icon: const Icon(Icons.logout, size: 24),
                  //     label:
                  //         const Text('Выйти', style: TextStyle(fontSize: 18)),
                  //   ),
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DrawerButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isBold;
  final bool highlight;
  final VoidCallback? onTap;
  const _DrawerButton({
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.isBold = false,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color?.withOpacity(highlight ? 0.95 : 0.85) ??
              const Color(0xFF4B5A67).withOpacity(0.85),
          foregroundColor: textColor ?? Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: highlight ? 6 : 0,
          shadowColor:
              highlight ? Colors.amber.withOpacity(0.3) : Colors.transparent,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 28, color: textColor ?? Colors.white),
              const SizedBox(width: 18),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: textColor ?? Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrostedBar extends StatelessWidget {
  final Widget child;
  const _FrostedBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  const _StatusIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _DashboardButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final bool highlight;
  final VoidCallback? onTap;
  const _DashboardButton(
      {required this.icon,
      required this.label,
      this.iconColor,
      this.highlight = false,
      this.onTap});

  @override
  State<_DashboardButton> createState() => _DashboardButtonState();
}

class _DashboardButtonState extends State<_DashboardButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final highlight = widget.highlight;
    final isDisabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (highlight)
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.5),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.white
              .withOpacity(_pressed ? 0.18 : (isDisabled ? 0.08 : 0.13)),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: isDisabled
                ? Colors.transparent
                : (widget.iconColor ?? Colors.white).withOpacity(0.18),
            highlightColor: Colors.transparent,
            onTap: widget.onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: (widget.iconColor ?? Colors.white)
                        .withOpacity(isDisabled ? 0.08 : 0.13),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(widget.icon,
                      size: 40,
                      color: (widget.iconColor ?? Colors.white)
                          .withOpacity(isDisabled ? 0.5 : 1.0)),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(isDisabled ? 0.5 : 1.0),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DutyStatusDialog extends StatefulWidget {
  @override
  State<_DutyStatusDialog> createState() => _DutyStatusDialogState();
}

class _DutyStatusDialogState extends State<_DutyStatusDialog> {
  bool _onDuty = true;
  bool _loading = false;
  String? _error;

  Future<void> _setDutyStatus(bool onDuty) async {
    setState(() {
      _loading = true;
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
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Статус водителя',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const Text('Принимать заказы',
                //         style: TextStyle(color: Colors.white, fontSize: 16)),
                //     Switch(
                //       value: _onDuty,
                //       onChanged: _loading ? null : (val) => _setDutyStatus(val),
                //       activeColor: Colors.greenAccent,
                //       inactiveThumbColor: Colors.redAccent,
                //     ),
                //   ],
                // ),
                if (_loading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!,
                      style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _loading ? null : () => Navigator.of(context).pop(),
                        child: const Text('Закрыть',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
