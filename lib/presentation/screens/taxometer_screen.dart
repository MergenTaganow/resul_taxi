import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:taxi_service/core/services/additional_settings_service.dart';
import 'package:taxi_service/core/services/background_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/queued_requests_service.dart';
import '../../core/utils/location_helper.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/mixins/location_warning_mixin.dart';
import 'package:taxi_service/core/services/profile_service.dart';
import 'package:taxi_service/core/services/taxometer_service.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/presentation/widgets/circular_countdown_widget.dart';

import '../../domain/entities/queued_request.dart';
import 'districts_screen.dart';

class TaxometerScreen extends StatefulWidget {
  final int? arrivalCountdownSeconds;
  final Order? order;
  const TaxometerScreen({
    Key? key,
    this.arrivalCountdownSeconds,
    this.order,
  }) : super(key: key);

  @override
  State<TaxometerScreen> createState() => _TaxometerScreenState();
}

class _TaxometerScreenState extends State<TaxometerScreen>
    with TickerProviderStateMixin, LocationWarningMixin {
  bool _isLoading = true;
  late TaxometerService _taxometerService;
  late VoidCallback _stateChangeListener;

  // UI-only components
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _freeWaitingAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _freeWaitingFadeAnimation;
  late FlutterTts _flutterTts;

  // All data comes from service via getters
  bool get _isRunning => _taxometerService.isRunning;
  bool get _isWaiting => _taxometerService.isWaiting;
  bool get _arrivalCountdownActive => _taxometerService.arrivalCountdownActive;
  int get _arrivalCountdown => _taxometerService.arrivalCountdown;
  int get _initialArrivalCountdown => _taxometerService.initialArrivalCountdown;
  double get _currentFare => _taxometerService.currentFare;
  double get _distance => _taxometerService.distance;
  int get _elapsedTime => _taxometerService.elapsedTime;
  Position? get _currentPosition => _taxometerService.currentPosition;
  bool get _isGpsEnabled => _taxometerService.isGpsEnabled;
  bool get _freeWaitingActive => _taxometerService.freeWaitingActive;
  int get _freeWaitingTime => _taxometerService.freeWaitingTime; // Default free waiting time
  int get _freeWaitingCountdown => _taxometerService.freeWaitingCountdown;
  bool get startedDriving => _taxometerService.startedDriving;
  double get _baseFare => _taxometerService.baseFare;
  double get _perKmRate => _taxometerService.perKmRate;
  double get _waitingRate => _taxometerService.waitingRate;
  double get _minOrderPrice => _taxometerService.minOrderPrice;
  List<dynamic> get _tariffs => _taxometerService.tariffs;
  Map<String, dynamic>? get _currentRegion => _taxometerService.currentRegion;
  String? get _currentTariffName => _taxometerService.currentTariffName;
  List<Map<String, dynamic>> get _roadDetails => _taxometerService.roadDetails;

  @override
  void initState() {
    super.initState();

    // Initialize taxometer service
    _taxometerService = getIt<TaxometerService>();
    _taxometerService.isTaxometerScreenActive = true;
    // if (widget.order != null) {
    //   _taxometerService.currentOrder? = widget.order!;
    // }
    _stateChangeListener = () {
      if (mounted) {
        setState(() {
          // UI refreshes automatically via getters
        });
      }
    };

    _taxometerService.onRequestCancelled = () {
      print('Ali bot');
      Navigator.of(context)
        ..popUntil((route) => route.isFirst)
        ..push(
          MaterialPageRoute(
            builder: (context) => const DistrictsScreen(),
          ),
        );
    };

    _taxometerService.addStateChangeListener(_stateChangeListener);

    // Set the order in the service
    if (widget.order != null) {
      _taxometerService.setOrder(widget.order!,
          arrivalCountdownSeconds: widget.arrivalCountdownSeconds);
    } else {
      // If no order provided, try to get from service
      print('[TAXOMETER_SCREEN] No order provided, checking service for existing order');
    }

    // Service handles GPS internally

    // Initialize Text-to-Speech
    _flutterTts = FlutterTts();
    _initializeTTS();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _freeWaitingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _freeWaitingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _freeWaitingAnimationController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Initialize UI only
    _initializeUI();
  }

  Future<void> _initializeUI() async {
    // Set loading state
    setState(() {
      _isLoading = true;
    });

    // Service handles all initialization internally
    // Just wait for it to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    // Hide loading and show taxometer
    setState(() {
      _isLoading = false;
    });
  }

  // Get final price with minimum order price applied
  double _getFinalPrice() {
    return _taxometerService.getFinalPrice();
  }

  @override
  void dispose() {
    _taxometerService.removeStateChangeListener(_stateChangeListener);
    _taxometerService.isTaxometerScreenActive = false;

    // Only dispose UI resources - service continues in background
    _pulseController.dispose();
    _fadeController.dispose();
    _freeWaitingAnimationController.dispose();

    super.dispose();
  }

  // Future<void> _initializeLocation() async {
  //   bool hasPermission = await LocationHelper.requestLocationPermission();
  //   if (hasPermission) {
  //     _currentPosition = await LocationHelper.getCurrentLocation();
  //     if (_currentPosition != null) {
  //       _lastPosition = _currentPosition;
  //       _lastLocationUpdate = DateTime.now();
  //     }

  //     // Start location tracking immediately for region detection and UI updates
  //     _startLocationTracking();
  //   } else {
  //     // Show location permission dialog if permission is denied
  //     _showLocationPermissionDialog();
  //   }
  // }

  // void _initializeGpsMonitoring() {
  //   _gpsService.gpsStatusStream.listen((isEnabled) {
  //     if (mounted) {
  //       setState(() {
  //         _isGpsEnabled = isEnabled;
  //       });
  //     }
  //   });

  //   // Get initial GPS status
  //   setState(() {
  //     _isGpsEnabled = _gpsService.isGpsEnabled;
  //   });
  // }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage("ru-RU");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(getIt<AdditionalSettingsService>().soundLevel);
    await _flutterTts.setPitch(5);
  }

  Future<void> _speakCompletionMessage(int price) async {
    try {
      // Format price to show only 2 decimal places
      String formattedPrice = price.round().toString();

      // Create the message in Russian
      String message = "Вы прибыли на место, цена поездки $formattedPrice манат";

      // Speak the message
      await _flutterTts.speak(message);
    } catch (e) {
      print('Error speaking completion message: $e');
    }
  }

  Future<void> _speakStartDrivingMessage() async {
    try {
      // Create the start driving message in Russian
      String message = "Поездка началась, спасибо за то что выбрали нас";

      // Speak the message
      await _flutterTts.speak(message);
    } catch (e) {
      print('Error speaking start driving message: $e');
    }
  }

  void _startTaxometer() async {
    try {
      await _taxometerService.startTaxometer();
      _fadeController.forward();
    } catch (e) {
      if (e.toString().contains('Location permission required')) {
        _showLocationPermissionDialog();
      }
    }
  }

  void _stopTaxometer() async {
    print('HEREEEE');
    try {
      final response = await getIt<ApiClient>().completeOrder(
        requestId: _taxometerService.currentOrder!.id,
        priceTotal: _taxometerService.getFinalPrice(),
        roadDetails: _roadDetails,
      );
      if (response.statusCode == 200) {
        print('[TAXOMETER] Order completed successfully');
      } else {
        print('[TAXOMETER] Failed to complete order: ${response.statusCode}');
        final requestPayload = QueuedRequest(
          requestId: _taxometerService.currentOrder!.id,
          priceTotal: _taxometerService.getFinalPrice(),
          roadDetails: _roadDetails,
        );
        getIt<QueuedRequestsService>().queueRequest(requestPayload);
      }
    } catch (e) {
      final requestPayload = QueuedRequest(
        requestId: _taxometerService.currentOrder!.id,
        priceTotal: _taxometerService.getFinalPrice(),
        roadDetails: _roadDetails,
      );
      getIt<QueuedRequestsService>().queueRequest(requestPayload);
    }
    await stopBackgroundService();

    // getIt<SoundService>().playOrderCompleteSound();

    // Speak the completion message with price
    await _speakCompletionMessage(_taxometerService.getFinalPrice().round());

    // Update profile balance (assuming the order amount is added to balance)
    final profileService = getIt<ProfileService>();
    final currentBalance = profileService.balance;
    print('[TAXOMETER] Current balance before update: $currentBalance');
    print('[TAXOMETER] Adding fare to balance: ${_taxometerService.getFinalPrice()}');
    await profileService.updateBalance(currentBalance - _taxometerService.getFinalPrice());
    print('[TAXOMETER] Balance updated to: ${profileService.balance}');

    // Refresh profile data from API to ensure balance is up to date
    try {
      await profileService.loadProfile();
      print('[TAXOMETER] Profile refreshed from API, new balance: ${profileService.balance}');
    } catch (e) {
      print('[TAXOMETER] Error refreshing profile: $e');
    }
    _taxometerService.resetTaxometer();
    _fadeController.reverse();
  }

  // void _resetTaxometer() {
  //   _taxometerService.resetTaxometer();
  //   _fadeController.reverse();
  // }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Требуется разрешение на геолокацию',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Приложению требуется доступ к вашему местоположению для работы таксометра.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await LocationHelper.requestLocationPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Предоставить'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Helper method to safely get current order
  Order? get _currentOrder => _taxometerService.currentOrder;

  void _stopTaxometerWithConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Завершить поездку?',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Текущая стоимость: ${_getFinalPrice().toStringAsFixed(2)} TMT',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Расстояние: ${_distance.toStringAsFixed(2)} км',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Время: ${_formatTime(_elapsedTime)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Вы уверены, что хотите завершить поездку?',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Продолжить',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                _stopTaxometer();

                Navigator.of(context).pop();

                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OrderCompletionScreen(
                        finalPrice: _getFinalPrice().round(),
                        distance: _distance,
                        elapsedTime: _elapsedTime,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Завершить'),
            ),
          ],
        );
      },
    );
  }

  void _onArrived() async {
    // Stop arrival countdown and transition to taxometer screen
    _taxometerService.completeArrival();

    // Send start request to backend
    final apiClient = getIt<ApiClient>();
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    try {
      final currentOrder = _taxometerService.currentOrder;
      if (currentOrder != null) {
        await apiClient.startOrder(currentOrder.id.toString(), nowMillis);
        print('[TAXOMETER] Order started successfully');
      } else {
        print('[TAXOMETER] No current order to start');
      }
    } catch (e) {
      print('Failed to start order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while fetching tariffs
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF232526), Color(0xFF414345)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Loading spinner
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 24),
                  // Loading text
                  Text(
                    'Загрузка тарифов...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Пожалуйста, подождите',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: _arrivalCountdownActive
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF232526), Color(0xFF414345)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // App Bar
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Прибытие',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Client Information Card
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Address
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.orange,
                                  size: 30,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentOrder?.requestedAddress ?? 'Адрес не указан',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Phone Number with Call Button
                            if (_taxometerService.currentOrder?.phonenumber != null &&
                                _taxometerService.currentOrder!.phonenumber!.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _taxometerService.currentOrder!.phonenumber!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        final phoneNumber =
                                            _taxometerService.currentOrder!.phonenumber!;
                                        // Clean phone number - remove spaces, dashes, etc.
                                        final cleanPhone =
                                            phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                                        final url = 'tel:$cleanPhone';
                                        await launchUrl(Uri.parse(url));
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Ошибка: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.call, color: Colors.white, size: 16),
                                    label: const Text('Позвонить',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Countdown Display
                      Column(
                        children: [
                          Text(
                            _arrivalCountdown >= 0 ? 'Прибытие через:' : 'Опоздание:',
                            style: TextStyle(
                              color: _arrivalCountdown >= 0 ? Colors.white : Colors.red.shade300,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CircularCountdownWidget(
                            currentSeconds: _arrivalCountdown,
                            totalSeconds: _arrivalCountdown < 0
                                ? _initialArrivalCountdown + _arrivalCountdown.abs()
                                : _initialArrivalCountdown > 0
                                    ? _initialArrivalCountdown
                                    : 300,
                            size: MediaQuery.of(context).size.width * 0.6,
                            positiveColor: Colors.orange,
                            negativeColor: Colors.red,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Arrival Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _onArrived();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Я прибыл', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : _buildTaxometerContent(context),
    );
  }

  Widget _buildTaxometerContent(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _FrostedBar(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Таксометр',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Top Section - Tariff Name and Fare
                      const SizedBox(height: 20),
                      if (_currentTariffName != null)
                        Text(
                          '$_currentTariffName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      // Current Fare Display
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: AnimatedBuilder(
                            animation:
                                _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isRunning ? _pulseAnimation.value : 1.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    const Text(
                                      'TMT',
                                      style: TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _currentFare.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: MediaQuery.of(context).size.width * 0.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'TMT',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Time and Distance vs Free Waiting Countdown (animated transition)
                      Expanded(
                        flex: 6,
                        child: AnimatedBuilder(
                          animation: _freeWaitingFadeAnimation,
                          builder: (context, child) {
                            if (_freeWaitingActive) {
                              // Show Free Waiting Countdown
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Бесплатное ожидание',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 10),
                                  CircularCountdownWidget(
                                    currentSeconds: _freeWaitingCountdown,
                                    totalSeconds: _freeWaitingTime,
                                    size: 140,
                                    positiveColor: Colors.green,
                                    negativeColor: Colors.orange,
                                  ),
                                ],
                              );
                            } else {
                              // Show Time and Distance
                              return FadeTransition(
                                opacity: Tween<double>(begin: 1.0, end: 0.0)
                                    .animate(_freeWaitingFadeAnimation),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _InfoCard(
                                          icon: Icons.timer,
                                          label: 'Время',
                                          value: _formatTime(_elapsedTime),
                                          isHighlighted: _isWaiting,
                                        ),
                                        _InfoCard(
                                          icon: Icons.straighten,
                                          label: 'Расстояние',
                                          value: '${_distance.toStringAsFixed(3)} км',
                                          isHighlighted: _isRunning,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _isWaiting ? 'Ожидание' : 'В движении',
                                      style: TextStyle(
                                        color: _isWaiting
                                            ? Colors.orangeAccent
                                            : Colors.lightBlueAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),

                      // Client Information
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Address
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentOrder?.requestedAddress ?? 'Адрес не указан',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Phone Number with Call Button
                            if (_currentOrder?.phonenumber != null &&
                                _currentOrder!.phonenumber!.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _currentOrder!.phonenumber!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        final phoneNumber = _currentOrder!.phonenumber!;
                                        final cleanPhone =
                                            phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                                        final url = 'tel:$cleanPhone';
                                        await launchUrl(Uri.parse(url));
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Ошибка: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.call, color: Colors.white, size: 14),
                                    label: const Text('Позвонить',
                                        style: TextStyle(color: Colors.white, fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Tariff Cards (moved to bottom)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _TariffCard(
                                  label: 'Подача',
                                  value: _baseFare.toStringAsFixed(2),
                                  unit: 'тмт',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _TariffCard(
                                  label: 'Расстояние',
                                  value: _perKmRate.toStringAsFixed(2),
                                  unit: 'тмт/км',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _TariffCard(
                                  label: 'Ожидание',
                                  value: _waitingRate.toStringAsFixed(2),
                                  unit: 'тмт/мин',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Control Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _ControlButton(
                    icon: startedDriving ? Icons.stop : Icons.play_arrow,
                    label: startedDriving ? 'Завершить заказ' : 'Начать поездку',
                    color: startedDriving ? Colors.redAccent : Colors.greenAccent,
                    onPressed: startedDriving ? _stopTaxometerWithConfirmation : _startTaxometer),
              ),
            ],
          ),
        ));
  }
}

class _FrostedBar extends StatelessWidget {
  final Widget child;

  const _FrostedBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    const highlightColor = Colors.orangeAccent;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.4, // Make cards wider (40% of screen width each)
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? highlightColor : Colors.white.withOpacity(0.1),
          width: isHighlighted ? 2 : 1,
        ),
        // boxShadow: isHighlighted
        //     ? [
        //         BoxShadow(
        //           color: highlightColor.withOpacity(0.3),
        //           blurRadius: 8,
        //           offset: const Offset(0, 2),
        //         ),
        //       ]
        //     : null,
      ),
      child: Column(
        children: [
          // Icon(icon,
          //     color: isHighlighted ? highlightColor : Colors.white70,
          //     size: 28), // Slightly bigger icon
          // const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? highlightColor : Colors.white70,
              fontSize: 16, // Slightly bigger text
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted ? highlightColor : Colors.white,
              fontSize: 24, // Bigger value text
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TariffCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _TariffCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OrderCompletionScreen extends StatelessWidget {
  final int finalPrice;
  final double distance;
  final int elapsedTime;

  const OrderCompletionScreen({
    Key? key,
    required this.finalPrice,
    required this.distance,
    required this.elapsedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate waiting time in minutes
    final int waitingMinutes = (elapsedTime / 60).round();
    final int waitingSeconds = elapsedTime % 60;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Заказ завершен!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Total Price (Much Bigger)
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.1),
                          Colors.green.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Итоговая стоимость',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$finalPrice',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TMT',
                              style: TextStyle(
                                color: Colors.green.withOpacity(0.7),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Trip Details (Much Bigger)
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Детали поездки',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Distance
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Расстояние:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${distance.toStringAsFixed(2)} км',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Waiting Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Время ожидания:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              waitingMinutes > 0
                                  ? '$waitingMinutes мин ${waitingSeconds > 0 ? '$waitingSeconds сек' : ''}'
                                  : '$waitingSeconds сек',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                        ..popUntil((route) => route.isFirst)
                        ..push(
                          MaterialPageRoute(
                            builder: (context) => const DistrictsScreen(),
                          ),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.green.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Закрыть',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
