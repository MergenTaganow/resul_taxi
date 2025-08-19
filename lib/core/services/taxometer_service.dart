import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/task_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_service/core/services/additional_settings_service.dart';
import 'package:taxi_service/core/services/background_service.dart';
import 'package:taxi_service/core/services/push_notification_service.dart';
import '../utils/location_helper.dart';
import '../network/api_client.dart';
import '../di/injection.dart';
import 'sound_service.dart';
import 'gps_service.dart';
import 'profile_service.dart';
import 'settings_service.dart';
import '../../domain/entities/order.dart';

class TaxometerService {
  static const String _keyTaxometerState = 'taxometer_state';

  // late Order _order;
  // Order get order => _order;
  // set order(Order value) {
  //   _order = value;
  // }

  // Core state
  bool _isRunning = false;
  bool _isWaiting = true;
  bool _arrivalCountdownActive = false;
  int _arrivalCountdown = 0;
  Timer? _arrivalTimer;
  int _initialArrivalCountdown = 0;
  double _currentFare = 0.0;

  // GPS monitoring
  late GpsService _gpsService;
  bool _isGpsEnabled = false;

  // Free waiting time feature
  bool _freeWaitingActive = false;
  int _freeWaitingTime = 0; // 2 minutes in seconds
  int _freeWaitingCountdown = 120;
  Timer? _freeWaitingTimer;
  double _distance = 0.0;
  int _elapsedTime = 0;
  bool _startedDriving = false;
  Map<String, dynamic>? _currentTariff;

  // Location tracking
  Position? _currentPosition;
  Position? _lastPosition;
  Position? _switchedToWaitingModePosition;
  Position? _freeWaitingStartPosition;
  StreamSubscription<Position>? _locationSubscription;
  DateTime? _lastLocationUpdate;
  Timer? _locationTimeoutTimer;
  Timer? _timer;

  // Taxometer settings
  double _baseFare = 0;
  double _perKmRate = 0;
  double _waitingRate = 0;
  double _minOrderPrice = 0;

  List<dynamic> _tariffs = [];
  int? _orderTarrifId;
  Map<String, dynamic>? _currentRegion;
  String? _currentTariffName;

  bool _waitingByLocationTimeout = false;

  Timer? _logTimer;
  Timer? _uiSyncTimer;
  List<Map<String, dynamic>> _roadDetails = [];
  double? _lastLoggedFare;
  double? _lastLoggedLat;
  double? _lastLoggedLng;
  bool _isStateTransitioning = false;
  bool _tookStartingPosition = false;
  bool showModifiedOrderAlert = false;

  // Text-to-Speech
  late FlutterTts _flutterTts;

  // Movement detection for automatic state switching
  Position? _lastPositionForMovementDetection;
  DateTime? _lastMovementDetectionTime;
  static const int _movementThresholdMeters = 10; // Minimum movement to consider driving
  int movementDetectionTimeSeconds = 5; // Time window for movement detection
  static const int _waitingToDrivingThresholdMeters =
      20; // Lower threshold for switching from waiting to driving

  // Current order
  Order? _currentOrder;

  setTimeForDrivingToWaiting(int milliSecond) {
    movementDetectionTimeSeconds = (milliSecond / 1000).toInt();
  }

  // State change listeners
  bool _isTaxometerScreenActive = false;
  bool requestCancelled = false;
  VoidCallback? onRequestCancelled;
  final List<VoidCallback> _stateChangeListeners = [];

  bool get isTaxometerScreenActive => _isTaxometerScreenActive;

  void set isTaxometerScreenActive(bool value) {
    _isTaxometerScreenActive = value;
    Future.delayed(const Duration(milliseconds: 200), () {
      _notifyStateChange();
    });
  }

  // Background operation
  bool _isInBackground = false;

  // Getters
  bool get isRunning => _isRunning;
  bool get isWaiting => _isWaiting;
  bool get isActive => _isRunning;
  double get currentFare => _currentFare;
  double get distance => _distance;
  int get elapsedTime => _elapsedTime;
  Position? get currentPosition => _currentPosition;
  bool get isGpsEnabled => _isGpsEnabled;
  bool get freeWaitingActive => _freeWaitingActive;
  int get freeWaitingCountdown => _freeWaitingCountdown;
  bool get arrivalCountdownActive => _arrivalCountdownActive;
  int get arrivalCountdown => _arrivalCountdown;
  int get initialArrivalCountdown => _initialArrivalCountdown;
  Map<String, dynamic>? get currentRegion => _currentRegion;
  String? get currentTariffName => _currentTariffName;
  double get baseFare => _baseFare;
  double get perKmRate => _perKmRate;
  double get waitingRate => _waitingRate;
  double get minOrderPrice => _minOrderPrice;
  List<dynamic> get tariffs => _tariffs;
  Order? get currentOrder => _currentOrder;
  bool get startedDriving => _startedDriving;
  int get freeWaitingTime => _freeWaitingTime;
  List<Map<String, dynamic>> get roadDetails => _roadDetails;

  // Get final price with minimum order price applied
  double getFinalPrice() {
    return _currentFare < _minOrderPrice ? _minOrderPrice : _currentFare;
  }

  // Constructor
  TaxometerService() {
    _initialize();
  }

  void _initialize() async {
    _gpsService = getIt<GpsService>();
    _flutterTts = FlutterTts();

    // Configure TTS
    await _flutterTts.setLanguage("ru-RU");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(getIt<AdditionalSettingsService>().soundLevel);
    await _flutterTts.setPitch(1.0);
  }

  speakSentence(String rusSentence) async {
    try {
      await _flutterTts.speak(rusSentence);
    } catch (e) {
      print('Error speaking start driving message: $e');
    }
  }

  // void _resumeFromBackground() {
  //   if (_isRunning) {
  //     if (_isWaiting) {
  //       _switchToWaiting();
  //     }
  //     _startLocationTracking();
  //     _notifyStateChange();
  //   }
  // }

  void _startGpsMonitoring() async {
    await _gpsService.initialize();
    _gpsService.gpsStatusStream.listen((isEnabled) {
      _isGpsEnabled = isEnabled;
      _notifyStateChange();
    });
  }

  void modifiedInitialPrice(double modifiedInitialPrice, String note) {
    _currentFare += modifiedInitialPrice - _baseFare;
    _baseFare = modifiedInitialPrice;

    PushNotificationService.showNotification(
      id: 1,
      title: 'Подача изменена',
      body: '''Подача изменена на $modifiedInitialPrice TMT
      причина: $note''',
      payload: 'modified_order',
      category: NotificationCategory.message,
    );
    _notifyStateChange();
  }

  void cancelRequest(data) {
    PushNotificationService.showNotification(
        id: 1,
        title: 'Заказ отменён!',
        body: 'Заказ по адресу: ${data['requested_address']} был отменён.');
    if (onRequestCancelled != null) {
      onRequestCancelled;
      requestCancelled = true;
      _notifyStateChange();
    }
  }

  Future<void> _loadTariffs() async {
    late Map<String, dynamic> tariffs;
    try {
      final apiClient = getIt<ApiClient>();
      tariffs = await apiClient.getRegionTariffs(_currentOrder?.tarrifId ?? 1);

      _currentTariff = tariffs;

      _currentTariffName = tariffs['slug'] ?? _currentOrder?.tarrifSlug;
      _baseFare = (tariffs['initial_price'] ?? _baseFare).toDouble();
      _minOrderPrice = (tariffs['min_request_price'] ?? _minOrderPrice).toDouble();
      _perKmRate = (tariffs['waiting_price_per_km'] ?? _perKmRate).toDouble();
      _waitingRate = (tariffs['waiting_price_per_minute'] ?? _waitingRate).toDouble();
      // Set free waiting time from tariff data
      _freeWaitingTime = int.parse(tariffs['waiting_delay_time'] ?? '120000') ~/ 1000;

      // Set current fare to base fare if not running
      if (!_isRunning) {
        _currentFare = _baseFare;
      }
    } catch (e) {
      print('Error loading tariffs: $e');
    }

    // Parse polygon field from string to JSON
    try {
      for (final t in tariffs['region_tarrifs']) {
        if (t['region'] != null && t['region']['polygon'] is String) {
          try {
            t['region']['polygon'] = json.decode(t['region']['polygon']);
          } catch (_) {
            t['region']['polygon'] = null;
          }
        }
      }

      _tariffs = tariffs['region_tarrifs'];

      // Load initial settings from current order tariff or defaults
      // if (_currentOrder != null && _currentOrder!.tarrifId != null) {
      _orderTarrifId = _currentOrder!.tarrifId;
      _loadTariffSettings();
      // } else {
      // }

      _notifyStateChange();
    } catch (e) {
      print('Error parsing tariffs: $e');
      // _loadDefaultSettings();
    }
  }

  void _loadTariffSettings() {
    if (_orderTarrifId != null) {
      final matched = _tariffs.firstWhere(
        (t) => LocationHelper.pointInPolygon(
            _currentPosition!.latitude, _currentPosition!.longitude, t['region']['polygon']),
        orElse: () => null,
      );

      if (matched != null) {
        _currentRegion = matched;
        _currentTariffName = matched?['slug'] ?? _currentOrder?.tarrifSlug;
        _baseFare = (matched['initial_price'] ?? _baseFare).toDouble();
        _minOrderPrice = (matched['min_request_price'] ?? _minOrderPrice).toDouble();
        _perKmRate = (matched['waiting_price_per_km'] ?? _perKmRate).toDouble();
        _waitingRate = (matched['waiting_price_per_minute'] ?? _waitingRate).toDouble();
        // Set current fare to base fare if not running
        // if (!_isRunning) {
        //   _currentFare = _baseFare;
        // }
      } else {
        _currentTariffName = _currentTariff?['slug'] ?? _currentOrder?.tarrifSlug;
        _baseFare = (_currentTariff?['initial_price'] ?? _baseFare).toDouble();
        _minOrderPrice = (_currentTariff?['min_request_price'] ?? _minOrderPrice).toDouble();
        _perKmRate = (_currentTariff?['waiting_price_per_km'] ?? _perKmRate).toDouble();
        _waitingRate = (_currentTariff?['waiting_price_per_minute'] ?? _waitingRate).toDouble();
      }
    }
  }

  void setOrder(Order order, {int? arrivalCountdownSeconds}) async {
    startBackgroundService();
    _startGpsMonitoring();

    // Start location tracking
    _initializeLocation();

    // Load tariffs - this will be called again when order is set
    _currentOrder = order;
    _orderTarrifId = order.tarrifId;
    _elapsedTime = 0;
    _distance = 0.0;
    await _loadTariffs();
    _currentFare = _baseFare;

    if (arrivalCountdownSeconds != null && arrivalCountdownSeconds > 0) {
      _startArrivalCountdown(arrivalCountdownSeconds);
    }
  }

  void _startArrivalCountdown(int seconds) {
    _arrivalCountdown = seconds;
    _initialArrivalCountdown = seconds;
    _arrivalCountdownActive = true;

    _arrivalTimer?.cancel();
    _arrivalTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _arrivalCountdown--;
      _notifyStateChange();
      if (_arrivalCountdown == 0 ||
          (_arrivalCountdown < 0 && (_arrivalTimer?.tick ?? 1) % 10 == 0)) {
        try {
          await _flutterTts.speak("Вы опаздываете");
        } catch (e) {
          print('Error speaking start driving message: $e');
        }
      }
    });
  }

  void _stopArrivalCountdown() {
    _arrivalTimer?.cancel();
    _arrivalCountdownActive = false;
    _arrivalCountdown = 0;
    _startLogTimer();
    // _switchedToWaitingModePosition =
    _notifyStateChange();
  }

  void completeArrival() {
    _stopArrivalCountdown();
    // Start free waiting countdown
    _startFreeWaitingCountdown();
  }

  Future<void> startTaxometer() async {
    // Ensure we have location permission before starting
    bool hasPermission = await LocationHelper.requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission required');
    }

    _startedDriving = true;
    _isRunning = false;
    _isWaiting = true; // Start in waiting mode
    // _currentFare = _baseFare; // Start with base fare
    // _distance = 0.0;
    // _elapsedTime = 0;

    // Initialize movement detection and distance tracking
    if (_currentPosition != null) {
      _lastPositionForMovementDetection = _currentPosition;
      _lastMovementDetectionTime = DateTime.now();
      _lastPosition = _currentPosition; // Initialize for distance calculation
    } else {
      print('[TAXOMETER_SERVICE] Warning: No current position available for initialization');
    }

    _freeWaitingActive = false;
    _freeWaitingCountdown = 0;
    _freeWaitingTimer?.cancel();
    startLocationTimeoutChecker();
    _switchToWaitingMode(force: true); // Start waiting timer initially
    _notifyStateChange();

    print('[TAXOMETER_SERVICE] Taxometer started - isRunning: $_isRunning, isActive: $isActive');

    // Speak start message
    _speakStartDriving();
  }

  void resetTaxometer() {
    _isRunning = false;
    _isWaiting = false;
    _startedDriving = false;
    _currentOrder = null;

    // Reset movement detection
    _lastPositionForMovementDetection = null;
    _lastMovementDetectionTime = null;

    _stopWaitingTimer();
    _notifyStateChange();
  }

  Future<void> _initializeLocation() async {
    bool hasPermission = await LocationHelper.requestLocationPermission();
    if (hasPermission) {
      _currentPosition = await LocationHelper.getCurrentLocation();
      if (_currentPosition != null) {
        _lastPosition = _currentPosition;
        _lastLocationUpdate = DateTime.now();
      }

      // Start location tracking immediately for region detection and UI updates
      _startLocationTracking();
    } else {
      // Show location permission dialog if permission is denied
      // _showLocationPermissionDialog();
    }
  }

  void _startLocationTracking() {
    print('[TAXOMETER_SERVICE] Starting location tracking...');
    // Cancel any existing subscription
    _locationSubscription?.cancel();

    LocationSettings locationSettings;

    locationSettings = const LocationSettings(
      distanceFilter: 10,
      // timeLimit: Duration(seconds: 30), // Time limit for location updates
    );

    _locationSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        print(
            '[TAXOMETER_SERVICE] Location update received: ${position.latitude}, ${position.longitude}, Accuracy: ${position.accuracy}m');

        // Always check for movement detection first
        if (_isRunning && !_isWaiting) {
          // Calculate distance when driving
          _updateDistance(position);
        } else {
          // Update UI and region when waiting or not running
          _updateUIOnly();
        }

        _checkForMovementDetection(position);
// Latitude: 37.8963088, Longitude: 58.3347357
        _loadTariffSettings();
      },
      onError: (error) {
        print('[TAXOMETER_SERVICE] Location error: $error');
        // Try to restart location tracking after a delay
        Future.delayed(const Duration(seconds: 5), () {
          print('[TAXOMETER_SERVICE] Restarting location tracking after error...');
          _startLocationTracking();
        });
      },
    );
  }

  void _updateUIOnly() {
    _lastLocationUpdate = DateTime.now();

    // Update region and tariff information
    _notifyStateChange();
  }

  void _updateDistance(Position newPosition) {
    // if (!_isRunning || _isWaiting || _lastPosition == null) {
    //   print(
    //       '[TAXOMETER_SERVICE] Distance calculation skipped - Conditions not met');
    //   return;
    // }

    _lastLocationUpdate = DateTime.now();

    if (_isRunning && !_isWaiting && _lastPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      // print('[TAXOMETER_SERVICE] Distance calculated: ${distanceInMeters.toStringAsFixed(2)}m');

      // Only add distance if it's reasonable (not GPS noise/jump)
      if (distanceInMeters > 0 && distanceInMeters < 500) {
        _distance += distanceInMeters / 1000; // Convert to kilometers
        _currentFare += (distanceInMeters / 1000 * _perKmRate);
        _notifyStateChange();

        // print(
        //     '[TAXOMETER_SERVICE] Distance update: ${distanceInMeters.toStringAsFixed(2)}m, Total: ${_distance.toStringAsFixed(3)}km, Fare: ${_currentFare.toStringAsFixed(2)} TMT');
      } else if (distanceInMeters > 0) {}
    } else {}

    _currentPosition = newPosition;
    _lastPosition = newPosition;
  }

  void _checkForMovementDetection(Position newPosition) {
    final now = DateTime.now();

    // Initialize movement detection if this is the first position
    if (_switchedToWaitingModePosition == null) {
      _lastPositionForMovementDetection = newPosition;
    }

    if (_switchedToWaitingModePosition == null) {
      _switchedToWaitingModePosition = newPosition;
      _lastMovementDetectionTime = now;
      return;
    }

    // Calculate distance moved
    double distanceMovedFromWaitingPosition = Geolocator.distanceBetween(
      _switchedToWaitingModePosition!.latitude,
      _switchedToWaitingModePosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    double distanceMoved = Geolocator.distanceBetween(
      _lastPositionForMovementDetection!.latitude,
      _lastPositionForMovementDetection!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    // Check if enough time has passed for movement detection
    if (_lastMovementDetectionTime != null) {
      int timeSinceLastDetection = now.difference(_lastMovementDetectionTime!).inSeconds;

      // Only do automatic movement detection if user hasn't manually started driving
      if (startedDriving) {
        // Check for movement to switch from waiting to driving
        if (!_isRunning && distanceMovedFromWaitingPosition >= _waitingToDrivingThresholdMeters) {
          // print(
          //     '[TAXOMETER] Movement detected: ${distanceMovedFromWaitingPosition.toStringAsFixed(2)}m - Auto-switching to driving mode');
          _switchToDrivingMode();
        }
        // Check for no movement to switch from driving to waiting
        else if (_isRunning && !_isWaiting) {
          if (distanceMoved < _movementThresholdMeters &&
              timeSinceLastDetection >= movementDetectionTimeSeconds) {
            // print(
            //     '[TAXOMETER] No movement detected: ${distanceMoved.toStringAsFixed(2)}m in ${timeSinceLastDetection}s - Auto-switching to waiting mode');
            _switchedToWaitingModePosition = newPosition;
            _switchToWaitingMode();
          }
        }
      }
    }

    // Update movement detection position and time
    _lastPositionForMovementDetection = newPosition;
    _lastMovementDetectionTime = now;
  }

  void _switchToDrivingMode() {
    if (!_isRunning) {
      _isWaiting = false;
      _isRunning = true;
      _waitingByLocationTimeout = false;

      _notifyStateChange();
      // Reset last position to current position to prevent distance jump
      if (_currentPosition != null) {
        _lastPosition = _currentPosition;
      }

      // Stop waiting timer and start distance calculation
      _stopWaitingTimer();

      // Announce driving mode
      // _speakStartDrivingMessage();

      print(
          '[TAXOMETER] Switched to driving mode - _isRunning: $_isRunning, _isWaiting: $_isWaiting');
    } else {
      print(
          '[TAXOMETER] Cannot switch to driving mode - _isRunning: $_isRunning, _isWaiting: $_isWaiting');
    }
  }

  void _switchToWaitingMode({bool force = false}) {
    _switchedToWaitingModePosition = _currentPosition;
    if ((_isRunning && !_isWaiting) || force) {
      _isWaiting = true;
      _isRunning = false;
      _notifyStateChange();

      // Start waiting timer
      _startWaitingTimer();

      print(
          '[TAXOMETER] Switched to waiting mode - _isRunning: $_isRunning, _isWaiting: $_isWaiting');
    } else {
      print(
          '[TAXOMETER] Cannot switch to waiting mode - _isRunning: $_isRunning, _isWaiting: $_isWaiting');
    }
  }

  void _startFreeWaitingCountdown() async {
    _freeWaitingActive = true;
    _freeWaitingCountdown = _freeWaitingTime;
    _notifyStateChange();
    _freeWaitingStartPosition = await Geolocator.getCurrentPosition();

    _freeWaitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_freeWaitingCountdown > 0) {
        _freeWaitingCountdown--;
        _notifyStateChange();
        if ((_freeWaitingTimer?.tick ?? 1) % 5 == 0) {
          var newPos = await Geolocator.getCurrentPosition();
          var distance = Geolocator.distanceBetween(
            _freeWaitingStartPosition!.latitude,
            _freeWaitingStartPosition!.longitude,
            newPos.latitude,
            newPos.longitude,
          );
          if (distance > 20) {
            try {
              await _flutterTts.speak("Начните поездку!");
            } catch (e) {
              print('Error speaking start driving message: $e');
            }
          }
        }
      } else {
        timer.cancel();
        _freeWaitingActive = false;
        _switchToWaitingMode(force: true);
        _notifyStateChange();
      }
    });
  }

  void _stopWaitingTimer() {
    _timer?.cancel();
  }

  Future<void> _speakStartDriving() async {
    try {
      await _flutterTts.speak("Поездка началась, счастливого пути!");
    } catch (e) {
      print('Error speaking start driving message: $e');
    }
  }

  // State change management
  void addStateChangeListener(VoidCallback listener) {
    _stateChangeListeners.add(listener);
  }

  void removeStateChangeListener(VoidCallback listener) {
    _stateChangeListeners.remove(listener);
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _notifyStateChange() {
    for (final listener in _stateChangeListeners) {
      listener();
    }
    FlutterForegroundTask.updateService(
      notificationTitle: 'Tiz Taxi',
      notificationText:
          // 'Töleg: ${currentFare.toStringAsFixed(2)}, Geçilen ýol: ${_distance}, Wagt: ${_formatTime(_elapsedTime)}',
          '💲: ${currentFare.toStringAsFixed(2)}TMT , ⏱️: ${_formatTime(_elapsedTime)}, 🚕: ${_distance.toStringAsFixed(2)} km',
    );
  }

  void startLocationTimeoutChecker() {
    _locationTimeoutTimer?.cancel();
    _locationTimeoutTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isRunning && !_isWaiting && _lastLocationUpdate != null) {
        final now = DateTime.now();
        if (now.difference(_lastLocationUpdate!).inSeconds >= 10) {
          // Set transition flag to prevent UI sync interference
          _isStateTransitioning = true;

          _switchToWaitingMode();

          // Clear transition flag after a delay to allow UI sync to resume
          Future.delayed(const Duration(milliseconds: 1000), () {
            _isStateTransitioning = false;
          });
        }
      }
    });
  }

  void _startWaitingTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isWaiting && !_isRunning) {
        _elapsedTime++;
        _currentFare += _waitingRate / 60; // Convert per-minute rate to per-second
        _notifyStateChange();
      }
    });
  }

  void stopLocationTimeoutChecker() {
    _locationTimeoutTimer?.cancel();
  }

  void _startLogTimer() {
    _logTimer?.cancel();
    _logTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_currentPosition == null) return;
      final lat = _currentPosition!.latitude;
      final lng = _currentPosition!.longitude;
      if (_lastLoggedFare == _currentFare && _lastLoggedLat == lat && _lastLoggedLng == lng) return;
      _lastLoggedFare = _currentFare;
      _lastLoggedLat = lat;
      _lastLoggedLng = lng;

      final roadDetail = {
        'price': _currentFare,
        'waiting_price_per_km': _perKmRate,
        'waiting_price_per_minute': _waitingRate,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'type': _isWaiting ? 'waiting' : 'driving',
        'location': {
          'longitude': lng,
          'latitude': lat,
        }
      };

      _roadDetails.add(roadDetail);

      // No storage update
    });
  }

  void stopLogTimer() {
    _logTimer?.cancel();
  }

  // Cleanup
  void dispose() {
    _arrivalTimer?.cancel();
    _freeWaitingTimer?.cancel();
    _locationSubscription?.cancel();
    _locationTimeoutTimer?.cancel();
    _timer?.cancel();
    _logTimer?.cancel();
    _uiSyncTimer?.cancel();
    _gpsService.dispose();
    _stateChangeListeners.clear();
  }
}
