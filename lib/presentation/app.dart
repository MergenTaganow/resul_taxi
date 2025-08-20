import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/network/socket_client.dart';
import 'package:taxi_service/core/services/taxometer_service.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_bloc.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_state.dart';
import 'package:taxi_service/presentation/blocs/order/order_bloc.dart';
import 'package:taxi_service/presentation/blocs/order/order_event.dart';
import 'package:taxi_service/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:taxi_service/presentation/blocs/messages/messages_bloc.dart';
import 'package:taxi_service/presentation/screens/login_screen.dart';
import 'package:taxi_service/presentation/screens/main_screen.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_event.dart';
import 'package:taxi_service/presentation/blocs/districts/districts_cubit.dart';
import 'package:taxi_service/presentation/blocs/order/order_state.dart';
import 'package:taxi_service/domain/entities/commute_type.dart';
import 'package:taxi_service/domain/repositories/order_repository.dart';
import 'package:taxi_service/presentation/screens/taxometer_screen.dart';
import 'dart:async';
import 'package:taxi_service/core/services/sound_service.dart';
import 'package:taxi_service/core/services/notification_listener_service.dart';
import 'package:taxi_service/presentation/widgets/taxometer_overlay_widget.dart';
import 'package:taxi_service/presentation/widgets/splash_screen.dart';
import '../core/services/background_service.dart';
import 'package:vibration/vibration.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class TaxiDriverApp extends StatefulWidget {
  const TaxiDriverApp({super.key});

  @override
  State<TaxiDriverApp> createState() => _TaxiDriverAppState();
}

class _TaxiDriverAppState extends State<TaxiDriverApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
// Request permissions and initialize the service.
      requestPermissions();
      initBackgroundService();
      getIt<TaxometerService>().addStateChangeListener(() {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) {
              print('[APP] Creating AuthBloc and dispatching appStarted event');
              final authBloc = getIt<AuthBloc>();
              authBloc.add(const AuthEvent.appStarted());
              print('[APP] appStarted event dispatched');
              return authBloc;
            },
          ),
          BlocProvider(create: (_) => getIt<OrderBloc>()),
          BlocProvider(create: (_) => DistrictsCubit()),
          BlocProvider(create: (_) => getIt<NotificationsBloc>()),
          BlocProvider(create: (_) => getIt<MessagesBloc>()),
        ],
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              MaterialApp(
                navigatorKey: navigatorKey,
                title: 'Taxi Driver',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF7C3AED),
                    primary: const Color(0xFF7C3AED),
                    secondary: const Color(0xFFB794F4),
                    surface: Colors.white,
                    background: Colors.grey[50]!,
                  ),
                  useMaterial3: true,
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                darkTheme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF7C3AED),
                    brightness: Brightness.dark,
                    primary: const Color(0xFF7C3AED),
                    secondary: const Color(0xFFB794F4),
                    surface: const Color(0xFF22223A),
                    background: const Color(0xFF181829),
                  ),
                  useMaterial3: true,
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF22223A),
                  ),
                ),
                themeMode: ThemeMode.dark,
                home: MultiBlocListener(
                  listeners: [
                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        state.maybeWhen(
                          authenticated: (token) async {
                            // Connect socket when authenticated
                            if (token.isNotEmpty) {
                              getIt<SocketClient>().setAuthToken(token);
                              // Initialize notification listener service
                              await NotificationListenerService.initialize(context);
                            }
                          },
                          unauthenticated: () {
                            // Disconnect socket when unauthenticated
                            getIt<SocketClient>().disconnect();
                            // Dispose notification listener service
                            NotificationListenerService.dispose();
                          },
                          orElse: () {},
                        );
                      },
                    ),
                    BlocListener<OrderBloc, OrderState>(
                      listener: (context, state) {
                        state.maybeWhen(
                          orderReceived: (order, commuteTime) {
                            // Play warning sound for new order
                            getIt<SoundService>().playNewRequestWarningSound();

                            // Play voice announcement for new order with address
                            String address = order.requestedAddress ?? 'неизвестный адрес';
                            // getIt<SoundService>()
                            //     .playNewOrderVoiceAnnouncement(address);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) {
                                final theme = Theme.of(ctx);
                                return _OrderDialogWithCommuteTypes(order: order);
                              },
                            );
                          },
                          orElse: () {},
                        );
                      },
                    ),
                    BlocListener<OrderBloc, OrderState>(
                      listener: (context, state) {
                        state.maybeWhen(
                          orderAccepted: (order, freeOrder, commuteTime) {
                            // Play sound for order start
                            // getIt<SoundService>().playOrderStartSound();
                            if (freeOrder) {
                              context.read<DistrictsCubit>().fetchDistricts();
                            }
                            final commuteSeconds = (int.tryParse(commuteTime ?? '') ?? 0) ~/ 1000;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TaxometerScreen(
                                  arrivalCountdownSeconds: commuteSeconds,
                                  order: order,
                                ),
                              ),
                            );
                          },
                          orElse: () {},
                        );
                      },
                    ),
                  ],
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return state.maybeWhen(
                        authenticated: (_) => const MainScreen(),
                        loading: () => const SplashScreen(),
                        orElse: () => const LoginScreen(),
                      );
                    },
                  ),
                ),
              ),
              if (getIt<TaxometerService>().currentOrder != null &&
                  !getIt<TaxometerService>().isTaxometerScreenActive)
                // Taxometer overlay widget that appears on all screens
                const Positioned(
                  bottom: 20,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: TaxometerOverlayWidget(),
                  ),
                ),
            ],
          ),
        ));
  }
}

class _OrderDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  const _OrderDetailRow({
    required this.label,
    this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            '$label:',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '-',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDialogWithCommuteTypes extends StatefulWidget {
  final Order order;
  const _OrderDialogWithCommuteTypes({required this.order});

  @override
  State<_OrderDialogWithCommuteTypes> createState() => _OrderDialogWithCommuteTypesState();
}

class _OrderDialogWithCommuteTypesState extends State<_OrderDialogWithCommuteTypes> {
  List<CommuteType>? _commuteTypes;
  String? _selectedCommuteKey;
  bool _isLoading = false;
  bool _loading = true;
  String? _error;

  // Countdown timer vari ables
  Timer? _countdownTimer;
  int _countdownSeconds = 30;

  @override
  void initState() {
    super.initState();
    _fetchCommuteTypes();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    getIt<SoundService>().audioPlayer.stop();
    Vibration.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdownSeconds--;
        });

        if (_countdownSeconds <= 0) {
          timer.cancel();
          // Auto-reject the order when countdown reaches 0
          if (mounted) {
            Navigator.of(context).pop();
            // Optionally dispatch reject event
            context.read<OrderBloc>().add(
                  OrderEvent.rejectOrder(widget.order.id),
                );
          }
        }
      }
    });
  }

  Future<void> _fetchCommuteTypes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = getIt<OrderRepository>();
      final types = await repo.getCommuteTypes();
      getIt<TaxometerService>().setTimeForDrivingToWaiting(
          int.parse(types.firstWhere((e) => e.key == "commute_for_waiting").value));
      setState(() {
        _commuteTypes = types;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        print(e);
        _error = 'Failed to load arriving time types.';
        _loading = false;
      });
    }
  }

  String _formatCommuteTime(String value) {
    try {
      // Convert milliseconds to minutes
      final milliseconds = int.tryParse(value) ?? 0;
      final minutes = (milliseconds / 1000 / 60).round();

      if (minutes == 0) {
        return 'Менее 1 минуты';
      } else if (minutes == 1) {
        return '1 минута';
      } else if (minutes < 5) {
        return '$minutes минуты';
      } else {
        return '$minutes минут';
      }
    } catch (e) {
      // Fallback to original description if parsing fails
      return 'Время поездки';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isUrgent = _countdownSeconds <= 10;
    final progress = _countdownSeconds / 30.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              if (isUrgent) Colors.red.shade900.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isUrgent ? Colors.red.withOpacity(0.5) : Colors.white.withOpacity(0.1),
            width: isUrgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUrgent ? Colors.red.withOpacity(0.3) : Colors.black.withOpacity(0.5),
              blurRadius: isUrgent ? 20 : 15,
              spreadRadius: isUrgent ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with pulsing countdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Title and urgency indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_taxi,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Новый заказ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUrgent ? Colors.red : Colors.orange,
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUrgent
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                '$_countdownSeconds',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: isUrgent
                                      ? [
                                          const Shadow(
                                            color: Colors.red,
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Address Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                Icons.location_on,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.order.requestedAddress ?? 'Адрес не указан',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Commute types section
                    _loading
                        ? const SizedBox(
                            height: 120,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          )
                        : _error != null
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Время прибытия:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...?_commuteTypes?.map((type) => type.key == "commute_for_waiting"
                                      ? Container()
                                      : Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: _selectedCommuteKey == type.key
                                                ? Colors.orange.withOpacity(0.2)
                                                : Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _selectedCommuteKey == type.key
                                                  ? Colors.orange
                                                  : Colors.white.withOpacity(0.1),
                                              width: _selectedCommuteKey == type.key ? 2 : 1,
                                            ),
                                          ),
                                          child: RadioListTile<String>(
                                            selectedTileColor: Colors.orange,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                            title: Text(
                                              _formatCommuteTime(type.value),
                                              style: TextStyle(
                                                color: _selectedCommuteKey == type.key
                                                    ? Colors.orange.shade200
                                                    : Colors.white,
                                                fontWeight: _selectedCommuteKey == type.key
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            value: type.key,
                                            groupValue: _selectedCommuteKey,
                                            onChanged: (val) =>
                                                setState(() => _selectedCommuteKey = val),
                                            activeColor: Colors.orange,
                                          ),
                                        )),
                                ],
                              ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _countdownTimer?.cancel();
                              Navigator.of(context).pop();
                              context.read<OrderBloc>().add(
                                    OrderEvent.rejectOrder(widget.order.id),
                                  );
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Отклонить',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isLoading || _selectedCommuteKey == null ? null : () => _acceptOrder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Принять заказ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptOrder() async {
    // Cancel countdown timer when user accepts order
    _countdownTimer?.cancel();

    setState(() {
      _isLoading = true;
    });

    try {
      final commuteTime =
          _commuteTypes!.firstWhere((type) => type.key == _selectedCommuteKey).value;

      // Dispatch Bloc event instead of calling repository directly
      context.read<OrderBloc>().add(
            OrderEvent.acceptOrder(
              widget.order.id,
              false,
              widget.order,
              commuteTime: commuteTime,
            ),
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Загрузка...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
