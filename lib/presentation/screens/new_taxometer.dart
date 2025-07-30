// import 'dart:ui';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../core/utils/location_helper.dart';
// import 'package:taxi_service/core/network/api_client.dart';
// import 'package:taxi_service/core/di/injection.dart';
// import 'package:taxi_service/core/services/sound_service.dart';
// import 'package:taxi_service/core/mixins/location_warning_mixin.dart';
// import 'package:taxi_service/core/services/gps_service.dart';

// import 'package:taxi_service/core/services/profile_service.dart';
// import 'package:taxi_service/core/services/taxometer_service.dart';
// import 'package:taxi_service/domain/entities/order.dart';
// import 'package:taxi_service/presentation/widgets/circular_countdown_widget.dart';
// import 'dart:convert';

// class TaxometerScreen extends StatefulWidget {
//   final int? arrivalCountdownSeconds;
//   final Order? order;
//   const TaxometerScreen({
//     Key? key,
//     this.arrivalCountdownSeconds,
//     this.order,
//   }) : super(key: key);

//   @override
//   State<TaxometerScreen> createState() => _TaxometerScreenState();
// }

// class _TaxometerScreenState extends State<TaxometerScreen>
//     with TickerProviderStateMixin, LocationWarningMixin {
//   bool _isLoading = true;
//   late TaxometerService _taxometerService;
//   late VoidCallback _stateChangeListener;

//   // UI-only components
//   late AnimationController _pulseController;
//   late AnimationController _fadeController;
//   late AnimationController _freeWaitingAnimationController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _freeWaitingFadeAnimation;
//   late FlutterTts _flutterTts;

//   // All data comes from service via getters
//   bool get _isRunning => _taxometerService.isRunning;
//   bool get _isWaiting => _taxometerService.isWaiting;
//   bool get _arrivalCountdownActive => _taxometerService.arrivalCountdownActive;
//   int get _arrivalCountdown => _taxometerService.arrivalCountdown;
//   int get _initialArrivalCountdown => _taxometerService.initialArrivalCountdown;
//   double get _currentFare => _taxometerService.currentFare;
//   double get _distance => _taxometerService.distance;
//   int get _elapsedTime => _taxometerService.elapsedTime;
//   Position? get _currentPosition => _taxometerService.currentPosition;
//   bool get _isGpsEnabled => _taxometerService.isGpsEnabled;
//   bool get _freeWaitingActive => _taxometerService.freeWaitingActive;
//   int get _freeWaitingTime =>
//       _taxometerService.freeWaitingTime; // Default free waiting time
//   int get _freeWaitingCountdown => _taxometerService.freeWaitingCountdown;
//   bool get startedDriving => _taxometerService.startedDriving;
//   double get _baseFare => _taxometerService.baseFare;
//   double get _perKmRate => _taxometerService.perKmRate;
//   double get _waitingRate => _taxometerService.waitingRate;
//   double get _minOrderPrice => _taxometerService.minOrderPrice;
//   List<dynamic> get _tariffs => _taxometerService.tariffs;
//   Map<String, dynamic>? get _currentRegion => _taxometerService.currentRegion;
//   String? get _currentTariffName => _taxometerService.currentTariffName;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize taxometer service
//     _taxometerService = getIt<TaxometerService>();
//     // if (widget.order != null) {
//     //   _taxometerService.currentOrder? = widget.order!;
//     // }
//     _stateChangeListener = () {
//       if (mounted) {
//         setState(() {
//           // UI refreshes automatically via getters
//         });
//       }
//     };
//     _taxometerService.addStateChangeListener(_stateChangeListener);

//     // Set the order in the service
//     if (widget.order != null) {
//       _taxometerService.setOrder(widget.order!,
//           arrivalCountdownSeconds: widget.arrivalCountdownSeconds);
//     } else {
//       // If no order provided, try to get from service
//       print(
//           '[TAXOMETER_SCREEN] No order provided, checking service for existing order');
//     }

//     // Service handles GPS internally

//     // Initialize Text-to-Speech
//     _flutterTts = FlutterTts();
//     _initializeTTS();

//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _freeWaitingAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//     _freeWaitingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//           parent: _freeWaitingAnimationController, curve: Curves.easeInOut),
//     );
//     _pulseController.repeat(reverse: true);

//     // Initialize UI only
//     _initializeUI();
//   }

//   Future<void> _initializeUI() async {
//     // Set loading state
//     setState(() {
//       _isLoading = true;
//     });

//     // Service handles all initialization internally
//     // Just wait for it to be ready
//     await Future.delayed(const Duration(milliseconds: 500));

//     // Hide loading and show taxometer
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   // Get final price with minimum order price applied
//   double _getFinalPrice() {
//     return _taxometerService.getFinalPrice();
//   }

//   @override
//   void dispose() {
//     _taxometerService.removeStateChangeListener(_stateChangeListener);

//     // Only dispose UI resources - service continues in background
//     _pulseController.dispose();
//     _fadeController.dispose();
//     _freeWaitingAnimationController.dispose();

//     super.dispose();
//   }

//   // Future<void> _initializeLocation() async {
//   //   bool hasPermission = await LocationHelper.requestLocationPermission();
//   //   if (hasPermission) {
//   //     _currentPosition = await LocationHelper.getCurrentLocation();
//   //     if (_currentPosition != null) {
//   //       _lastPosition = _currentPosition;
//   //       _lastLocationUpdate = DateTime.now();
//   //     }

//   //     // Start location tracking immediately for region detection and UI updates
//   //     _startLocationTracking();
//   //   } else {
//   //     // Show location permission dialog if permission is denied
//   //     _showLocationPermissionDialog();
//   //   }
//   // }

//   // void _initializeGpsMonitoring() {
//   //   _gpsService.gpsStatusStream.listen((isEnabled) {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isGpsEnabled = isEnabled;
//   //       });
//   //     }
//   //   });

//   //   // Get initial GPS status
//   //   setState(() {
//   //     _isGpsEnabled = _gpsService.isGpsEnabled;
//   //   });
//   // }

//   Future<void> _initializeTTS() async {
//     await _flutterTts.setLanguage("ru-RU");
//     await _flutterTts.setSpeechRate(0.5);
//     await _flutterTts.setVolume(1.0);
//     await _flutterTts.setPitch(5);
//   }

//   Future<void> _speakCompletionMessage(double price) async {
//     try {
//       // Format price to show only 2 decimal places
//       String formattedPrice = price.toStringAsFixed(2);

//       // Create the message in Russian
//       String message =
//           "Вы прибыли на место, цена поездки $formattedPrice манат";

//       // Speak the message
//       await _flutterTts.speak(message);
//     } catch (e) {
//       print('Error speaking completion message: $e');
//     }
//   }

//   Future<void> _speakStartDrivingMessage() async {
//     try {
//       // Create the start driving message in Russian
//       String message = "Поездка началась, спасибо за то что выбрали нас";

//       // Speak the message
//       await _flutterTts.speak(message);
//     } catch (e) {
//       print('Error speaking start driving message: $e');
//     }
//   }

//   void _startTaxometer() async {
//     try {
//       await _taxometerService.startTaxometer();
//       _fadeController.forward();
//     } catch (e) {
//       if (e.toString().contains('Location permission required')) {
//         _showLocationPermissionDialog();
//       }
//     }
//   }

//   void _stopTaxometer() {
//     _taxometerService.stopTaxometer();
//     _fadeController.reverse();
//   }

//   void _resetTaxometer() {
//     _taxometerService.resetTaxometer();
//     _fadeController.reverse();
//   }

//   void _showLocationPermissionDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[900],
//           title: Text(
//             'Требуется разрешение на геолокацию',
//             style: TextStyle(color: Colors.white),
//           ),
//           content: Text(
//             'Приложению требуется доступ к вашему местоположению для работы таксометра.',
//             style: TextStyle(color: Colors.white70),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'Отмена',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 await LocationHelper.requestLocationPermission();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.greenAccent,
//                 foregroundColor: Colors.black,
//               ),
//               child: Text('Предоставить'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   String _formatTime(int seconds) {
//     int minutes = seconds ~/ 60;
//     int remainingSeconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   // Helper method to safely get current order
//   Order? get _currentOrder => _taxometerService.currentOrder;

//   void _stopTaxometerWithConfirmation() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[900],
//           title: Text(
//             'Завершить поездку?',
//             style: TextStyle(color: Colors.white),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Текущая стоимость: ${_getFinalPrice().toStringAsFixed(2)} TMT',
//                 style: TextStyle(
//                   color: Colors.greenAccent,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Расстояние: ${_distance.toStringAsFixed(2)} км',
//                 style: TextStyle(color: Colors.white70),
//               ),
//               Text(
//                 'Время: ${_formatTime(_elapsedTime)}',
//                 style: TextStyle(color: Colors.white70),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Вы уверены, что хотите завершить поездку?',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'Продолжить',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 _stopTaxometer();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//               ),
//               child: Text('Завершить'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _onArrived() async {
//     // Stop arrival countdown and transition to taxometer screen
//     _taxometerService.completeArrival();

//     // Send start request to backend
//     final apiClient = getIt<ApiClient>();
//     final nowMillis = DateTime.now().millisecondsSinceEpoch;
//     try {
//       final currentOrder = _taxometerService.currentOrder;
//       if (currentOrder != null) {
//         await apiClient.startOrder(currentOrder.id.toString(), nowMillis);
//         print('[TAXOMETER] Order started successfully');
//       } else {
//         print('[TAXOMETER] No current order to start');
//       }
//     } catch (e) {
//       print('Failed to start order: $e');
//     }
//   }

//   // Movement detection for automatic state switching
//   // Position? _lastPositionForMovementDetection;
//   // DateTime? _lastMovementDetectionTime;
//   // static const int _movementThresholdMeters =
//   //     10; // Minimum movement to consider driving
//   // static const int _movementDetectionTimeSeconds =
//   //     5; // Time window for movement detection
//   // static const int _waitingToDrivingThresholdMeters =
//   //     5; // Lower threshold for switching from waiting to driving

//   // void _startLocationTracking() {
//   //   print('[TAXOMETER] Starting location tracking...');

//   //   // Cancel any existing subscription
//   //   _locationSubscription?.cancel();

//   //   _locationSubscription = Geolocator.getPositionStream(
//   //     locationSettings: const LocationSettings(
//   //       accuracy: LocationAccuracy.high,
//   //       distanceFilter:
//   //           5, // Update when moving 5 meters or more (reduced for better tracking)
//   //       // timeLimit: Duration(seconds: 30), // Time limit for location updates
//   //     ),
//   //   ).listen(
//   //     (Position position) {
//   //       print(
//   //           '[TAXOMETER] Location update received: ${position.latitude}, ${position.longitude}, Accuracy: ${position.accuracy}m');

//   //       if (mounted) {
//   //         // Always check for movement detection first
//   //         _checkForMovementDetection(position);

//   //         if (_isRunning && !_isWaiting) {
//   //           // Calculate distance when driving
//   //           _updateDistance(position);
//   //         } else {
//   //           // Update UI and region when waiting or not running
//   //           _updateUIOnly(position);
//   //         }
//   //       }
//   //     },
//   //     onError: (error) {
//   //       print('[TAXOMETER] Location error: $error');
//   //       // Try to restart location tracking after a delay
//   //       Future.delayed(const Duration(seconds: 5), () {
//   //         if (mounted && _locationSubscription == null) {
//   //           print('[TAXOMETER] Restarting location tracking after error...');
//   //           _startLocationTracking();
//   //         }
//   //       });
//   //     },
//   //   );

//   //   print('[TAXOMETER] Location tracking started successfully');
//   // }

//   // void _stopLocationTracking() {
//   //   _locationSubscription?.cancel();
//   //   _locationSubscription = null;
//   // }

//   // void _updateUIOnly(Position newPosition) {
//   //   _lastLocationUpdate = DateTime.now();
//   //   _currentPosition = newPosition;

//   //   // Update region and tariff information
//   //   _updateRegionAndTariff(newPosition);

//   //   // Force UI update to show current location
//   //   if (mounted) {
//   //     setState(() {
//   //       // Trigger UI update to show current location
//   //     });
//   //   }

//   //   print(
//   //       '[TAXOMETER] UI updated with new position: ${newPosition.latitude}, ${newPosition.longitude}');
//   // }

//   // void _updateDistance(Position newPosition) {
//   //   _lastLocationUpdate = DateTime.now();

//   //   print(
//   //       '[TAXOMETER] _updateDistance called - _isRunning: $_isRunning, _isWaiting: $_isWaiting, _lastPosition: ${_lastPosition != null}');

//   //   // Only calculate distance if we're in driving mode (not waiting) and have a previous position
//   //   if (_isRunning && !_isWaiting && _lastPosition != null) {
//   //     double distanceInMeters = Geolocator.distanceBetween(
//   //       _lastPosition!.latitude,
//   //       _lastPosition!.longitude,
//   //       newPosition.latitude,
//   //       newPosition.longitude,
//   //     );

//   //     print(
//   //         '[TAXOMETER] Distance calculated: ${distanceInMeters.toStringAsFixed(2)}m');

//   //     // Only add distance if it's reasonable (filter out GPS noise and jumps)
//   //     if (distanceInMeters > 0 &&
//   //         distanceInMeters < 200 &&
//   //         newPosition.accuracy <= 50) {
//   //       setState(() {
//   //         _distance += distanceInMeters / 1000; // Convert to kilometers
//   //         _currentFare += (_perKmRate * distanceInMeters) /
//   //             1000; // Calculate fare based on distance
//   //       });

//   //       print(
//   //           '[TAXOMETER] Distance update: ${distanceInMeters.toStringAsFixed(2)}m, Total: ${_distance.toStringAsFixed(3)}km, Fare: ${_currentFare.toStringAsFixed(2)} TMT, Accuracy: ${newPosition.accuracy.toStringAsFixed(1)}m');
//   //     } else if (distanceInMeters > 0) {
//   //       print(
//   //           '[TAXOMETER] Filtered out distance reading: ${distanceInMeters.toStringAsFixed(2)}m, Accuracy: ${newPosition.accuracy.toStringAsFixed(1)}m (GPS noise/jump)');
//   //     }
//   //   } else {
//   //     print('[TAXOMETER] Distance calculation skipped - Conditions not met');
//   //     if (!_isRunning) print('[TAXOMETER]   - Not running');
//   //     if (_isWaiting) print('[TAXOMETER]   - Is waiting');
//   //     if (_lastPosition == null) print('[TAXOMETER]   - No last position');
//   //   }

//   //   _currentPosition = newPosition;
//   //   _lastPosition = newPosition;

//   //   // Update region and tariff information
//   //   _updateRegionAndTariff(newPosition);
//   // }

//   // void _updateRegionAndTariff(Position newPosition) {
//   //   if (_tariffs.isNotEmpty) {
//   //     Map<String, dynamic>? newRegion;
//   //     String? newTariffName;
//   //     double newPerKmRate = _perKmRate;
//   //     double newWaitingRate = _waitingRate;
//   //     int newFreeWaitingTime = _freeWaitingTime;

//   //     for (final t in _tariffs) {
//   //       final region = t['region'];
//   //       if (region != null && region['polygon'] != null) {
//   //         if (LocationHelper.pointInPolygon(
//   //             newPosition.latitude, newPosition.longitude, region['polygon'])) {
//   //           newRegion = region;
//   //           newTariffName = t['tarrif']?['slug'] ??
//   //               t['tarrif_slug'] ??
//   //               widget.order.tarrifSlug;
//   //           newPerKmRate = (t['waiting_price_per_km'] ??
//   //                   t['tarrif']?['waiting_price_per_km'] ??
//   //                   2.0)
//   //               .toDouble();
//   //           newFreeWaitingTime =
//   //               (t['tarrif']?['waiting_delay_time'] ?? 120000) / 1000;
//   //           newWaitingRate = (t['waiting_price_per_minute'] ??
//   //                   t['tarrif']?['waiting_price_per_minute'] ??
//   //                   0.3)
//   //               .toDouble();

//   //           print(
//   //               '[TAXOMETER] Found matching region: ${region['name'] ?? 'Unknown'}');
//   //           print('[TAXOMETER] New tariff: $newTariffName');
//   //           print('[TAXOMETER] New per km rate: $newPerKmRate');
//   //           print('[TAXOMETER] New waiting rate: $newWaitingRate');
//   //           break;
//   //         }
//   //       }
//   //     }

//   //     // Only update state if we found a new region or if we're not in any region
//   //     bool shouldUpdate = false;

//   //     if (newRegion != null) {
//   //       // Check if this is a different region than current
//   //       if (_currentRegion == null ||
//   //           _currentRegion!['id'] != newRegion['id'] ||
//   //           _currentTariffName != newTariffName) {
//   //         shouldUpdate = true;
//   //         print(
//   //             '[TAXOMETER] Auto-switching to new region: ${newRegion['name'] ?? 'Unknown'}');
//   //       }
//   //     } else if (_currentRegion != null) {
//   //       // We're no longer in any region, reset to defaults but keep free waiting time from order
//   //       shouldUpdate = true;
//   //       print('[TAXOMETER] No longer in any region, resetting to defaults');
//   //       newTariffName = widget.order.tarrifSlug;
//   //       newPerKmRate = 2.0;
//   //       newWaitingRate = 0.3;
//   //       // Keep the free waiting time from the original order tariff, don't reset to default
//   //       newFreeWaitingTime = _freeWaitingTime;
//   //     }

//   //     if (shouldUpdate) {
//   //       setState(() {
//   //         _currentRegion = newRegion;
//   //         _currentTariffName = newTariffName;
//   //         _perKmRate = newPerKmRate;
//   //         _waitingRate = newWaitingRate;
//   //         _freeWaitingTime = newFreeWaitingTime;
//   //       });
//   //     }
//   //   }
//   // }

//   // void _startWaitingTimer() {
//   //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//   //     if (_isWaiting && mounted && !_isRunning) {
//   //       setState(() {
//   //         _elapsedTime++;
//   //         _currentFare +=
//   //             _waitingRate / 60; // Convert per-minute rate to per-second
//   //       });
//   //     }
//   //   });
//   // }

//   // void _stopWaitingTimer() {
//   //   _timer?.cancel();
//   // }

//   // void _refreshLocation() async {
//   //   bool hasPermission = await LocationHelper.requestLocationPermission();
//   //   if (hasPermission) {
//   //     Position? newPosition = await LocationHelper.getCurrentLocation();
//   //     if (newPosition != null) {
//   //       setState(() {
//   //         _currentPosition = newPosition;
//   //         if (_lastPosition == null) {
//   //           _lastPosition = newPosition;
//   //         }
//   //       });
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Местоположение обновлено'),
//   //           backgroundColor: Colors.green,
//   //           duration: Duration(seconds: 2),
//   //         ),
//   //       );
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Не удалось получить местоположение'),
//   //           backgroundColor: Colors.red,
//   //           duration: Duration(seconds: 2),
//   //         ),
//   //       );
//   //     }
//   //   } else {
//   //     _showLocationPermissionDialog();
//   //   }
//   // }

//   // void _showLocationPermissionDialog() {
//   //   showDialog(
//   //     context: context,
//   //     barrierDismissible: false,
//   //     builder: (BuildContext context) {
//   //       return AlertDialog(
//   //         backgroundColor: Colors.grey[900],
//   //         title: const Text(
//   //           'Требуется разрешение на местоположение',
//   //           style: TextStyle(color: Colors.white),
//   //         ),
//   //         content: const Text(
//   //           'Для работы таксометра необходимо разрешение на доступ к местоположению. Пожалуйста, включите GPS и разрешите доступ к местоположению в настройках.',
//   //           style: TextStyle(color: Colors.white70),
//   //         ),
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () async {
//   //               Navigator.of(context).pop();
//   //               // Try to request permission again
//   //               bool hasPermission =
//   //                   await LocationHelper.requestLocationPermission();
//   //               if (hasPermission) {
//   //                 _initializeLocation();
//   //               }
//   //             },
//   //             child: const Text(
//   //               'Повторить',
//   //               style: TextStyle(color: Colors.blue),
//   //             ),
//   //           ),
//   //           TextButton(
//   //             onPressed: () {
//   //               Navigator.of(context).pop();
//   //               Navigator.of(context).pop(); // Go back to previous screen
//   //             },
//   //             child: const Text(
//   //               'Отмена',
//   //               style: TextStyle(color: Colors.red),
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }

//   // void _startDriving() async {
//   //   bool hasPermission = await LocationHelper.requestLocationPermission();
//   //   setState(() {
//   //     startedDriving = true;
//   //   });
//   //   if (!hasPermission) {
//   //     _showLocationPermissionDialog();
//   //     return;
//   //   }

//   //   // Stop free waiting countdown if active
//   //   if (_freeWaitingActive) {
//   //     _stopFreeWaitingCountdown();
//   //   }

//   //   // Set transition flag
//   //   _isStateTransitioning = true;

//   //   // Get a fresh current location to use as starting point for distance calculation
//   //   try {
//   //     Position? freshPosition = await LocationHelper.getCurrentLocation();
//   //     if (freshPosition != null) {
//   //       _currentPosition = freshPosition;
//   //       _lastPosition = freshPosition;
//   //       print(
//   //           '[TAXOMETER] Got fresh starting position: ${freshPosition.latitude}, ${freshPosition.longitude}');
//   //     } else if (_currentPosition != null) {
//   //       // Fallback to current position if fresh position fails
//   //       _lastPosition = _currentPosition;
//   //       print('[TAXOMETER] Using fallback position for distance calculation');
//   //     }
//   //   } catch (e) {
//   //     print('[TAXOMETER] Error getting fresh position: $e');
//   //     // Fallback to current position
//   //     if (_currentPosition != null) {
//   //       _lastPosition = _currentPosition;
//   //       print('[TAXOMETER] Using fallback position due to error');
//   //     }
//   //   }

//   //   // Reset movement detection to prevent immediate switching
//   //   _lastPositionForMovementDetection = _currentPosition;
//   //   _lastMovementDetectionTime = DateTime.now();

//   //   // Reset distance and fare to ensure clean start
//   //   setState(() {
//   //     _isWaiting = false;
//   //     _isRunning = true;
//   //     _waitingByLocationTimeout = false; // Clear location timeout flag
//   //     _distance = 0.0; // Ensure distance starts from 0
//   //   });
//   //   print(
//   //       '[TAXOMETER] Started driving - Local state: _isWaiting=$_isWaiting, _isRunning=$_isRunning, distance reset to: $_distance');

//   //   // Play start driving announcement
//   //   await _speakStartDrivingMessage();

//   //   _fadeController.forward();
//   //   _stopWaitingTimer(); // Stop waiting timer
//   //   _startLocationTracking(); // Start location tracking for distance calculation
//   //   _startLocationTimeoutChecker(); // Start timeout checker

//   //   // Clear transition flag after a short delay
//   //   Future.delayed(const Duration(milliseconds: 500), () {
//   //     _isStateTransitioning = false;
//   //   });
//   // }

//   // void _startDrivingTimer() {
//   //   Future.delayed(const Duration(seconds: 1), () {
//   //     if (_isRunning && mounted && !_isWaiting) {
//   //       setState(() {
//   //         _elapsedTime++;
//   //         // Fare increases only by distance, not by time
//   //         _currentFare = _currentFare + 0; // No time-based increment
//   //       });
//   //       _startDrivingTimer();
//   //     }
//   //   });
//   // }

//   // void _stopTaxometerWithConfirmation() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       backgroundColor: Colors.grey[900],
//   //       title: const Text(
//   //         'Завершить заказ',
//   //         style: TextStyle(color: Colors.white),
//   //       ),
//   //       content: Column(
//   //         mainAxisSize: MainAxisSize.min,
//   //         children: [
//   //           const SizedBox(height: 20),
//   //           const Text(
//   //             'Вы уверены, что хотите завершить заказ?',
//   //             style: TextStyle(
//   //               color: Colors.white70,
//   //               fontSize: 16,
//   //               fontWeight: FontWeight.w500,
//   //             ),
//   //           ),
//   //           const SizedBox(height: 60),
//   //           SizedBox(
//   //             width: double.infinity,
//   //             child: ElevatedButton(
//   //               onPressed: () => Navigator.of(context).pop(),
//   //               style: ElevatedButton.styleFrom(
//   //                 backgroundColor: Colors.transparent,
//   //                 padding:
//   //                     const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//   //                 shape: RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(8),
//   //                 ),
//   //               ),
//   //               child: const Text(
//   //                 'Отмена',
//   //                 style: TextStyle(
//   //                   color: Colors.white,
//   //                   fontSize: 16,
//   //                   fontWeight: FontWeight.w600,
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //           const SizedBox(height: 20),
//   //           SizedBox(
//   //             width: double.infinity,
//   //             child: ElevatedButton(
//   //               onPressed: () async {
//   //                 Navigator.of(context).pop();
//   //                 await _completeOrder();
//   //               },
//   //               style: ElevatedButton.styleFrom(
//   //                 backgroundColor: Colors.redAccent,
//   //                 padding:
//   //                     const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//   //                 shape: RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(8),
//   //                 ),
//   //               ),
//   //               child: const Text(
//   //                 'Завершить',
//   //                 style: TextStyle(
//   //                     color: Colors.white,
//   //                     fontSize: 18,
//   //                     fontWeight: FontWeight.w600),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Future<void> _completeOrder() async {
//   //   // Show loading dialog
//   //   showDialog(
//   //     context: context,
//   //     barrierDismissible: false,
//   //     builder: (context) => AlertDialog(
//   //       backgroundColor: Colors.transparent,
//   //       content: Container(
//   //         padding: const EdgeInsets.all(24),
//   //         decoration: BoxDecoration(
//   //           color: Colors.grey[900],
//   //           borderRadius: BorderRadius.circular(16),
//   //         ),
//   //         child: const Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             CircularProgressIndicator(
//   //               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//   //               strokeWidth: 3,
//   //             ),
//   //             SizedBox(height: 24),
//   //             Text(
//   //               'Завершение заказа...',
//   //               style: TextStyle(
//   //                 color: Colors.white,
//   //                 fontSize: 18,
//   //                 fontWeight: FontWeight.w500,
//   //               ),
//   //             ),
//   //             SizedBox(height: 8),
//   //             Text(
//   //               'Пожалуйста, подождите',
//   //               style: TextStyle(
//   //                 color: Colors.white70,
//   //                 fontSize: 14,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );

//   //   final apiClient = getIt<ApiClient>();

//   //   // Apply minimum order price
//   //   double finalPrice = _currentFare;
//   //   if (finalPrice < _minOrderPrice) {
//   //     finalPrice = _minOrderPrice;
//   //   }

//   //   try {
//   //     final response = await apiClient.completeOrder(
//   //       requestId: widget.order.id,
//   //       priceTotal: finalPrice,
//   //       roadDetails: _roadDetails,
//   //     );
//   //     if (response.statusCode == 200) {
//   //       // Play sound for order completion
//   //       getIt<SoundService>().playOrderCompleteSound();

//   //       // Speak the completion message with price
//   //       await _speakCompletionMessage(finalPrice);

//   //       // Update profile balance (assuming the order amount is added to balance)
//   //       final profileService = getIt<ProfileService>();
//   //       final currentBalance = profileService.balance;
//   //       print('[TAXOMETER] Current balance before update: $currentBalance');
//   //       print('[TAXOMETER] Adding fare to balance: $finalPrice');
//   //       await profileService.updateBalance(currentBalance + finalPrice);
//   //       print('[TAXOMETER] Balance updated to: ${profileService.balance}');

//   //       // Refresh profile data from API to ensure balance is up to date
//   //       try {
//   //         await profileService.loadProfile();
//   //         print(
//   //             '[TAXOMETER] Profile refreshed from API, new balance: ${profileService.balance}');
//   //       } catch (e) {
//   //         print('[TAXOMETER] Error refreshing profile: $e');
//   //       }

//   //       // Small delay to ensure balance update is processed
//   //       await Future.delayed(const Duration(milliseconds: 100));

//   //       _stopTaxometer();
//   //       // Dismiss loading dialog
//   //       if (mounted) {
//   //         Navigator.of(context).pop();
//   //       }
//   //       // Navigate to completion screen with order details
//   //       if (mounted) {
//   //         Navigator.of(context).pushReplacement(
//   //           MaterialPageRoute(
//   //             builder: (context) => OrderCompletionScreen(
//   //               finalPrice: finalPrice.round(),
//   //               distance: _distance,
//   //               elapsedTime: _elapsedTime,
//   //             ),
//   //           ),
//   //         );
//   //       }
//   //     } else {
//   //       // Dismiss loading dialog
//   //       if (mounted) {
//   //         Navigator.of(context).pop();
//   //       }
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text('Не удалось завершить заказ: ${response.statusCode}'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     // Dismiss loading dialog
//   //     if (mounted) {
//   //       Navigator.of(context).pop();
//   //     }
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('Ошибка: ${e.toString()}'),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //   }
//   // }

//   // void _startArrivalCountdown(int seconds) {
//   //   setState(() {
//   //     _arrivalCountdownActive = true;
//   //     _arrivalCountdown = seconds;
//   //     _initialArrivalCountdown =
//   //         seconds; // Store initial value for progress calculation
//   //   });
//   //   _arrivalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//   //     setState(() {
//   //       _arrivalCountdown--;
//   //     });

//   //     // Don't stop the timer when it reaches 0, let it go negative
//   //     // Only start free waiting when user actually arrives
//   //   });
//   // }

//   // void _onArrived() async {
//   //   setState(() {
//   //     _arrivalCountdownActive = false;
//   //   });
//   //   _arrivalTimer?.cancel();

//   //   // Start free waiting time countdown if not already started
//   //   if (!_freeWaitingActive) {
//   //     _startFreeWaitingCountdown();
//   //   }

//   //   // Send start request to backend
//   //   final apiClient = getIt<ApiClient>();
//   //   final nowMillis = DateTime.now().millisecondsSinceEpoch;
//   //   try {
//   //     await apiClient.startOrder(widget.order.id.toString(), nowMillis);
//   //   } catch (e) {
//   //     print('Failed to start order: $e');
//   //   }
//   //   // Don't start taxometer here - let user press "Start Driving" button
//   // }

//   // void _startFreeWaitingCountdown() {
//   //   // Ensure free waiting time is properly initialized from backend
//   //   if (_freeWaitingTime == 120 && _tariffs.isNotEmpty) {
//   //     // If still using default value but tariffs are loaded, try to get the correct value
//   //     final matched = _tariffs.firstWhere(
//   //       (t) =>
//   //           t['tarrif_id'] == _orderTarrifId ||
//   //           t['tarrif']?['id'] == _orderTarrifId,
//   //       orElse: () => null,
//   //     );
//   //     if (matched != null) {
//   //       _freeWaitingTime =
//   //           (matched['tarrif']?['waiting_delay_time'] ?? 120000) ~/ 1000;
//   //       print(
//   //           '[TAXOMETER] Updated free waiting time from backend: $_freeWaitingTime seconds');
//   //     }
//   //   }

//   //   setState(() {
//   //     _freeWaitingActive = true;
//   //     _freeWaitingCountdown = _freeWaitingTime;
//   //   });

//   //   // Animate in the free waiting countdown
//   //   _freeWaitingAnimationController.forward();

//   //   // Update taxometer service
//   //   // Start free waiting in service (now local)

//   //   _freeWaitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//   //     if (_freeWaitingCountdown > 0) {
//   //       setState(() {
//   //         _freeWaitingCountdown--;
//   //       });
//   //     } else {
//   //       timer.cancel();
//   //       // Animate out the free waiting countdown
//   //       _freeWaitingAnimationController.reverse().then((_) {
//   //         setState(() {
//   //           _freeWaitingActive = false;
//   //         });
//   //       });
//   //       // Start regular waiting timer when free waiting ends
//   //       _startWaitingTimer();
//   //       // _startLocationTimeoutChecker();
//   //     }
//   //   });
//   // }

//   // void _stopFreeWaitingCountdown() {
//   //   _freeWaitingTimer?.cancel();
//   //   // Animate out the free waiting countdown
//   //   _freeWaitingAnimationController.reverse().then((_) {
//   //     setState(() {
//   //       _freeWaitingActive = false;
//   //     });
//   //   });
//   // }

//   // String _formatTime(int seconds) {
//   //   int hours = seconds ~/ 3600;
//   //   int minutes = (seconds % 3600) ~/ 60;
//   //   int secs = seconds % 60;
//   //   return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//   // }

//   // String _formatDateTime(DateTime dateTime) {
//   //   return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
//   // }

//   // String _formatTimestamp(String timestamp) {
//   //   final date = DateTime.parse(timestamp);
//   //   return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
//   // }

//   // void _startLogTimer() {
//   //   _logTimer?.cancel();
//   //   _logTimer = Timer.periodic(const Duration(seconds: 3), (_) {
//   //     if (_currentPosition == null) return;
//   //     final lat = _currentPosition!.latitude;
//   //     final lng = _currentPosition!.longitude;
//   //     if (_lastLoggedFare == _currentFare &&
//   //         _lastLoggedLat == lat &&
//   //         _lastLoggedLng == lng) return;
//   //     _lastLoggedFare = _currentFare;
//   //     _lastLoggedLat = lat;
//   //     _lastLoggedLng = lng;

//   //     final roadDetail = {
//   //       'price': _currentFare,
//   //       'waiting_price_per_km': _perKmRate,
//   //       'waiting_price_per_minute': _waitingRate,
//   //       'created_at': DateTime.now().millisecondsSinceEpoch,
//   //       'type': _isWaiting ? 'waiting' : 'driving',
//   //       'location': {
//   //         'longitude': lng,
//   //         'latitude': lat,
//   //       }
//   //     };

//   //     _roadDetails.add(roadDetail);

//   //     // No storage update
//   //   });
//   // }

//   // void _startUISyncTimer() {
//   //   // UI sync timer is no longer needed since all state is local
//   //   // Keeping the method for compatibility but it does nothing
//   //   print('[TAXOMETER] UI sync timer disabled - all state is now local');
//   // }

//   // bool _isLocationTrackingWorking() {
//   //   return _isGpsEnabled;
//   // }

//   // String _getLocationStatusText() {
//   //   return _isGpsEnabled ? 'GPS активен' : 'GPS неактивен';
//   // }

//   // Color _getLocationStatusColor() {
//   //   return _isGpsEnabled ? Colors.green : Colors.red;
//   // }

//   // void _checkGpsStatus() {
//   //   // Optional: Add any GPS status check logic here
//   //   print('[TAXOMETER] GPS Status: ${_isGpsEnabled ? 'Enabled' : 'Disabled'}');
//   // }

//   // void _checkForMovementDetection(Position newPosition) {
//   //   final now = DateTime.now();

//   //   // Initialize movement detection if this is the first position
//   //   if (_lastPositionForMovementDetection == null) {
//   //     _lastPositionForMovementDetection = newPosition;
//   //     _lastMovementDetectionTime = now;
//   //     return;
//   //   }

//   //   // Calculate distance moved
//   //   double distanceMoved = Geolocator.distanceBetween(
//   //     _lastPositionForMovementDetection!.latitude,
//   //     _lastPositionForMovementDetection!.longitude,
//   //     newPosition.latitude,
//   //     newPosition.longitude,
//   //   );

//   //   // Check if enough time has passed for movement detection
//   //   if (_lastMovementDetectionTime != null) {
//   //     int timeSinceLastDetection =
//   //         now.difference(_lastMovementDetectionTime!).inSeconds;

//   //     // Only do automatic movement detection if user hasn't manually started driving
//   //     if (!startedDriving) {
//   //       // Check for movement to switch from waiting to driving
//   //       if (!_isRunning && distanceMoved >= _waitingToDrivingThresholdMeters) {
//   //         print(
//   //             '[TAXOMETER] Movement detected: ${distanceMoved.toStringAsFixed(2)}m - Auto-switching to driving mode');
//   //         _switchToDrivingMode();
//   //       }
//   //       // Check for no movement to switch from driving to waiting
//   //       else if (_isRunning && !_isWaiting) {
//   //         if (distanceMoved < _movementThresholdMeters &&
//   //             timeSinceLastDetection >= _movementDetectionTimeSeconds) {
//   //           print(
//   //               '[TAXOMETER] No movement detected: ${distanceMoved.toStringAsFixed(2)}m in ${timeSinceLastDetection}s - Auto-switching to waiting mode');
//   //           _switchToWaitingMode();
//   //         }
//   //       }
//   //     } else {
//   //       // If user manually started driving, only check for switching back to waiting
//   //       if (_isRunning && !_isWaiting) {
//   //         if (distanceMoved < _movementThresholdMeters &&
//   //             timeSinceLastDetection >= _movementDetectionTimeSeconds) {
//   //           print(
//   //               '[TAXOMETER] No movement detected: ${distanceMoved.toStringAsFixed(2)}m in ${timeSinceLastDetection}s - Auto-switching to waiting mode');
//   //           _switchToWaitingMode();
//   //         }
//   //       }
//   //     }
//   //   }

//   //   // Update movement detection position and time
//   //   _lastPositionForMovementDetection = newPosition;
//   //   _lastMovementDetectionTime = now;
//   // }

//   // void _switchToDrivingMode() {
//   //   if (!_isRunning) {
//   //     setState(() {
//   //       _isWaiting = false;
//   //       _isRunning = true;
//   //       _waitingByLocationTimeout = false;
//   //     });

//   //     // Reset last position to current position to prevent distance jump
//   //     if (_currentPosition != null) {
//   //       _lastPosition = _currentPosition;
//   //       print(
//   //           '[TAXOMETER] Reset _lastPosition to current position to prevent distance jump');
//   //     }

//   //     // Stop waiting timer and start distance calculation
//   //     _stopWaitingTimer();

//   //     // Announce driving mode
//   //     // _speakStartDrivingMessage();

//   //     print(
//   //         '[TAXOMETER] Switched to driving mode - _isRunning: $_isRunning, _isWaiting: $_isWaiting');
//   //   } else {
//   //     print(
//   //         '[TAXOMETER] Cannot switch to driving mode - _isRunning: $_isRunning, _isWaiting: $_isWaiting');
//   //   }
//   // }

//   // void _switchToWaitingMode() {
//   //   if (_isRunning && !_isWaiting) {
//   //     setState(() {
//   //       _isWaiting = true;
//   //       _isRunning = false;
//   //     });

//   //     // Start waiting timer
//   //     _startWaitingTimer();

//   //     print(
//   //         '[TAXOMETER] Switched to waiting mode - _isRunning: $_isRunning, _isWaiting: $_isWaiting');
//   //   } else {
//   //     print(
//   //         '[TAXOMETER] Cannot switch to waiting mode - _isRunning: $_isRunning, _isWaiting: $_isWaiting');
//   //   }
//   // }

//   // void _forceWaitingMode() {
//   //   if (_isRunning) {
//   //     setState(() {
//   //       _isWaiting = true;
//   //       _waitingByLocationTimeout = false;
//   //     });

//   //     // Stop distance calculation and start waiting timer
//   //     _stopWaitingTimer();
//   //     _startWaitingTimer();

//   //     print('[TAXOMETER] Manually forced to waiting mode');
//   //   }
//   // }

//   // void _forceDrivingMode() {
//   //   if (_isRunning && _isWaiting) {
//   //     setState(() {
//   //       _isWaiting = false;
//   //       _waitingByLocationTimeout = false;
//   //     });

//   //     // Reset last position to current position to prevent distance jump
//   //     if (_currentPosition != null) {
//   //       _lastPosition = _currentPosition;
//   //       print(
//   //           '[TAXOMETER] Reset _lastPosition to current position to prevent distance jump (manual)');
//   //     }

//   //     // Stop waiting timer
//   //     _stopWaitingTimer();

//   //     // Announce driving mode
//   //     _speakStartDrivingMessage();

//   //     print('[TAXOMETER] Manually forced to driving mode');
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // Show loading screen while fetching tariffs
//     if (_isLoading) {
//       return Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF232526), Color(0xFF414345)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: const SafeArea(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Loading spinner
//                   CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     strokeWidth: 3,
//                   ),
//                   SizedBox(height: 24),
//                   // Loading text
//                   Text(
//                     'Загрузка тарифов...',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Пожалуйста, подождите',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       body: _arrivalCountdownActive
//           ? Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF232526), Color(0xFF414345)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       // App Bar
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.arrow_back,
//                                 color: Colors.white),
//                             onPressed: () => Navigator.of(context).pop(),
//                           ),
//                           const SizedBox(width: 16),
//                           const Text(
//                             'Прибытие',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Client Information Card
//                       Container(
//                         margin: const EdgeInsets.symmetric(vertical: 20),
//                         padding: const EdgeInsets.all(20),
//                         // decoration: BoxDecoration(
//                         //   color: Colors.white.withOpacity(0.1),
//                         //   borderRadius: BorderRadius.circular(16),
//                         //   border: Border.all(
//                         //     color: Colors.white.withOpacity(0.2),
//                         //     width: 1,
//                         //   ),
//                         // ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Address
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.location_on,
//                                   color: Colors.orange,
//                                   size: 30,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     _currentOrder?.requestedAddress ??
//                                         'Адрес не указан',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 40,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 12),

//                             // Phone Number with Call Button
//                             if (_taxometerService.currentOrder?.phonenumber !=
//                                     null &&
//                                 _taxometerService
//                                     .currentOrder!.phonenumber!.isNotEmpty) ...[
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.phone,
//                                     color: Colors.green,
//                                     size: 20,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       _taxometerService
//                                           .currentOrder!.phonenumber!,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   ElevatedButton.icon(
//                                     onPressed: () async {
//                                       try {
//                                         final phoneNumber = _taxometerService
//                                             .currentOrder!.phonenumber!;
//                                         // Clean phone number - remove spaces, dashes, etc.
//                                         final cleanPhone =
//                                             phoneNumber.replaceAll(
//                                                 RegExp(r'[\s\-\(\)]'), '');
//                                         final url = 'tel:$cleanPhone';
//                                         await launchUrl(Uri.parse(url));
//                                       } catch (e) {
//                                         if (context.mounted) {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                               content: Text(
//                                                   'Ошибка: ${e.toString()}'),
//                                               backgroundColor: Colors.red,
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     },
//                                     icon: const Icon(Icons.call,
//                                         color: Colors.white, size: 16),
//                                     label: const Text('Позвонить',
//                                         style: TextStyle(color: Colors.white)),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.green,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 12, vertical: 8),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),

//                       const Spacer(),

//                       // Countdown Display
//                       Column(
//                         children: [
//                           Text(
//                             _arrivalCountdown >= 0
//                                 ? 'Прибытие через:'
//                                 : 'Опоздание:',
//                             style: TextStyle(
//                               color: _arrivalCountdown >= 0
//                                   ? Colors.white
//                                   : Colors.red.shade300,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           CircularCountdownWidget(
//                             currentSeconds: _arrivalCountdown,
//                             totalSeconds: _initialArrivalCountdown > 0
//                                 ? _initialArrivalCountdown
//                                 : 300, // Default 5 minutes if no initial
//                             size: MediaQuery.of(context).size.width * 0.6,
//                             positiveColor: Colors.deepPurple,
//                             negativeColor: Colors.red,
//                           ),
//                         ],
//                       ),

//                       const Spacer(),

//                       // Arrival Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             _onArrived();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text('Я прибыл',
//                               style: TextStyle(fontSize: 20)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           : _buildTaxometerContent(context),
//     );
//   }

//   Widget _buildTaxometerContent(BuildContext context) {
//     return Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF232526), Color(0xFF414345)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // App Bar
//               _FrostedBar(
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                     const SizedBox(width: 16),
//                     const Text(
//                       'Таксометр',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     // GPS Status Icon
//                     GestureDetector(
//                       // onTap: _checkGpsStatus,
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: _isGpsEnabled
//                               ? Colors.green.withOpacity(0.2)
//                               : Colors.red.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Icon(
//                           _isGpsEnabled
//                               ? Icons.location_on
//                               : Icons.location_off,
//                           color: _isGpsEnabled
//                               ? Colors.greenAccent
//                               : Colors.redAccent,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Main Content
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     children: [
//                       // Top Section - Tariff Name and Fare
//                       const SizedBox(height: 20),
//                       if (_currentTariffName != null)
//                         Text(
//                           '${_currentTariffName}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       // Current Fare Display
//                       Expanded(
//                         flex: 5,
//                         child: Center(
//                           child: AnimatedBuilder(
//                             animation: _isRunning
//                                 ? _pulseAnimation
//                                 : const AlwaysStoppedAnimation(1.0),
//                             builder: (context, child) {
//                               return Transform.scale(
//                                 scale: _isRunning ? _pulseAnimation.value : 1.0,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.baseline,
//                                   textBaseline: TextBaseline.alphabetic,
//                                   children: [
//                                     const Text(
//                                       'TMT',
//                                       style: TextStyle(
//                                         color: Colors.transparent,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       _currentFare.toStringAsFixed(2),
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize:
//                                             MediaQuery.of(context).size.width *
//                                                 0.2,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 6),
//                                     const Text(
//                                       'TMT',
//                                       style: TextStyle(
//                                         color: Colors.white70,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),

//                       // Time and Distance vs Free Waiting Countdown (animated transition)
//                       Expanded(
//                         flex: 6,
//                         child: AnimatedBuilder(
//                           animation: _freeWaitingFadeAnimation,
//                           builder: (context, child) {
//                             if (_freeWaitingActive) {
//                               // Show Free Waiting Countdown
//                               return Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Text('Бесплатное ожидание',
//                                       style: TextStyle(
//                                         color: Colors.green,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       )),
//                                   const SizedBox(height: 10),
//                                   CircularCountdownWidget(
//                                     currentSeconds: _freeWaitingCountdown,
//                                     totalSeconds: _freeWaitingTime,
//                                     size: 140,
//                                     positiveColor: Colors.green,
//                                     negativeColor: Colors.orange,
//                                   ),
//                                 ],
//                               );
//                             } else {
//                               // Show Time and Distance
//                               return FadeTransition(
//                                 opacity: Tween<double>(begin: 1.0, end: 0.0)
//                                     .animate(_freeWaitingFadeAnimation),
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         _InfoCard(
//                                           icon: Icons.timer,
//                                           label: 'Время',
//                                           value: _formatTime(_elapsedTime),
//                                           isHighlighted: _isWaiting,
//                                         ),
//                                         _InfoCard(
//                                           icon: Icons.straighten,
//                                           label: 'Расстояние',
//                                           value:
//                                               '${_distance.toStringAsFixed(3)} км',
//                                           isHighlighted: _isRunning,
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Text(
//                                       _isWaiting ? 'Ожидание' : 'В движении',
//                                       style: TextStyle(
//                                         color: _isWaiting
//                                             ? Colors.orangeAccent
//                                             : Colors.lightBlueAccent,
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }
//                           },
//                         ),
//                       ),

//                       // Client Information
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Address
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.location_on,
//                                   color: Colors.orange,
//                                   size: 24,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     _currentOrder?.requestedAddress ??
//                                         'Адрес не указан',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 8),

//                             // Phone Number with Call Button
//                             if (_currentOrder?.phonenumber != null &&
//                                 _currentOrder!.phonenumber!.isNotEmpty) ...[
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.phone,
//                                     color: Colors.green,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       _currentOrder!.phonenumber!,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   ElevatedButton.icon(
//                                     onPressed: () async {
//                                       try {
//                                         final phoneNumber =
//                                             _currentOrder!.phonenumber!;
//                                         final cleanPhone =
//                                             phoneNumber.replaceAll(
//                                                 RegExp(r'[\s\-\(\)]'), '');
//                                         final url = 'tel:$cleanPhone';
//                                         await launchUrl(Uri.parse(url));
//                                       } catch (e) {
//                                         if (context.mounted) {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                               content: Text(
//                                                   'Ошибка: ${e.toString()}'),
//                                               backgroundColor: Colors.red,
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     },
//                                     icon: const Icon(Icons.call,
//                                         color: Colors.white, size: 14),
//                                     label: const Text('Позвонить',
//                                         style: TextStyle(
//                                             color: Colors.white, fontSize: 12)),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.green,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 8, vertical: 6),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),

//                       // Tariff Cards (moved to bottom)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Expanded(
//                                 child: _TariffCard(
//                                   label: 'Подача',
//                                   value: '${_baseFare.toStringAsFixed(2)}',
//                                   unit: 'тмт',
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: _TariffCard(
//                                   label: 'Расстояние',
//                                   value: '${_perKmRate.toStringAsFixed(2)}',
//                                   unit: 'тмт/км',
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: _TariffCard(
//                                   label: 'Ожидание',
//                                   value: '${_waitingRate.toStringAsFixed(2)}',
//                                   unit: 'тмт/мин',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//               ),

//               // Fixed Bottom Control Button
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
//                 child: _ControlButton(
//                     icon: startedDriving ? Icons.stop : Icons.play_arrow,
//                     label:
//                         startedDriving ? 'Завершить заказ' : 'Начать поездку',
//                     color:
//                         startedDriving ? Colors.redAccent : Colors.greenAccent,
//                     onPressed: startedDriving
//                         ? _stopTaxometerWithConfirmation
//                         : _startTaxometer),
//               ),
//             ],
//           ),
//         ));
//   }

//   // void _showSettingsDialog() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => _SettingsDialog(
//   //       baseFare: _baseFare,
//   //       perKmRate: _perKmRate,
//   //       perMinuteRate: 0,
//   //       waitingRate: _waitingRate,
//   //       minOrderPrice: _minOrderPrice,
//   //       onSave: (baseFare, perKm, perMin, waiting, minOrder) {
//   //         setState(() {
//   //           _baseFare = baseFare;
//   //           _perKmRate = perKm;
//   //           _waitingRate = waiting;
//   //           _minOrderPrice = minOrder;
//   //         });
//   //       },
//   //     ),
//   //   );
//   // }

//   // Future<void> _fetchTariffsAndSetRates() async {
//   //   final apiClient = getIt<ApiClient>();
//   //   try {
//   //     final tariffs = await apiClient.getRegionTariffs();
//   //     // Parse polygon field from string to JSON
//   //     for (final t in tariffs) {
//   //       if (t['region'] != null && t['region']['polygon'] is String) {
//   //         try {
//   //           t['region']['polygon'] = json.decode(t['region']['polygon']);
//   //         } catch (_) {
//   //           t['region']['polygon'] = null;
//   //         }
//   //       }
//   //     }
//   //     setState(() {
//   //       _tariffs = tariffs;
//   //     });

//   //     final matched = tariffs.firstWhere(
//   //       (t) =>
//   //           t['tarrif_id'] == _orderTarrifId ||
//   //           t['tarrif']?['id'] == _orderTarrifId,
//   //       orElse: () => null,
//   //     );
//   //     if (matched != null) {
//   //       setState(() {
//   //         _currentTariffName = matched['tarrif']?['slug'] ??
//   //             matched['tarrif_slug'] ??
//   //             widget.order.tarrifSlug;
//   //         _baseFare = (matched['initial_price'] ??
//   //                 matched['tarrif']?['initial_price'] ??
//   //                 _baseFare)
//   //             .toDouble();
//   //         _minOrderPrice = (matched['min_request_price'] ??
//   //                 matched['tarrif']?['min_request_price'] ??
//   //                 _minOrderPrice)
//   //             .toDouble();
//   //         _perKmRate = (matched['waiting_price_per_km'] ??
//   //                 matched['tarrif']?['waiting_price_per_km'] ??
//   //                 _perKmRate)
//   //             .toDouble();
//   //         _waitingRate = (matched['waiting_price_per_minute'] ??
//   //                 matched['tarrif']?['waiting_price_per_minute'] ??
//   //                 _waitingRate)
//   //             .toDouble();
//   //         // Set free waiting time from tariff data
//   //         print('Rasul');
//   //         print(matched['tarrif']?['waiting_delay_time']);
//   //         _freeWaitingTime =
//   //             (matched['tarrif']?['waiting_delay_time'] ?? 120000) ~/ 1000;
//   //       });
//   //     } else {
//   //       setState(() {
//   //         _currentTariffName = widget.order.tarrifSlug;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print('Failed to fetch tariffs: $e');
//   //   }
//   // }

//   // void _startLocationTimeoutChecker() {
//   //   _locationTimeoutTimer?.cancel();
//   //   _locationTimeoutTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
//   //     if (_isRunning && !_isWaiting && _lastLocationUpdate != null) {
//   //       final now = DateTime.now();
//   //       if (now.difference(_lastLocationUpdate!).inSeconds >= 10) {
//   //         print(
//   //             '[TAXOMETER] Location timeout detected - switching to waiting mode');

//   //         // Set transition flag to prevent UI sync interference
//   //         _isStateTransitioning = true;

//   //         // Then update local state
//   //         setState(() {
//   //           _isWaiting = true;
//   //           _isRunning = false;
//   //           _waitingByLocationTimeout = true;
//   //           _fadeController.reverse();
//   //         });

//   //         _startWaitingTimer(); // Start waiting timer again

//   //         // Clear transition flag after a delay to allow UI sync to resume
//   //         Future.delayed(const Duration(milliseconds: 1000), () {
//   //           _isStateTransitioning = false;
//   //         });
//   //       }
//   //     }
//   //   });
//   // }
// }

// class _FrostedBar extends StatelessWidget {
//   final Widget child;

//   const _FrostedBar({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1,
//               ),
//             ),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }

// class _FrostedCard extends StatelessWidget {
//   final Widget child;

//   const _FrostedCard({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//               width: 1,
//             ),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final bool isHighlighted;

//   const _InfoCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.isHighlighted = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final highlightColor = Colors.orangeAccent;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Container(
//       width: screenWidth * 0.4, // Make cards wider (40% of screen width each)
//       padding: const EdgeInsets.all(20), // Increased padding
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isHighlighted ? highlightColor : Colors.white.withOpacity(0.1),
//           width: isHighlighted ? 2 : 1,
//         ),
//         // boxShadow: isHighlighted
//         //     ? [
//         //         BoxShadow(
//         //           color: highlightColor.withOpacity(0.3),
//         //           blurRadius: 8,
//         //           offset: const Offset(0, 2),
//         //         ),
//         //       ]
//         //     : null,
//       ),
//       child: Column(
//         children: [
//           // Icon(icon,
//           //     color: isHighlighted ? highlightColor : Colors.white70,
//           //     size: 28), // Slightly bigger icon
//           // const SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               color: isHighlighted ? highlightColor : Colors.white70,
//               fontSize: 16, // Slightly bigger text
//               fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               color: isHighlighted ? highlightColor : Colors.white,
//               fontSize: 24, // Bigger value text
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ControlButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onPressed;

//   const _ControlButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: onPressed,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Column(
//               children: [
//                 Icon(icon, color: Colors.white, size: 32),
//                 const SizedBox(height: 8),
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RateRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _RateRow({
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 16,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SettingsDialog extends StatefulWidget {
//   final double baseFare;
//   final double perKmRate;
//   final double perMinuteRate;
//   final double waitingRate;
//   final double minOrderPrice;
//   final Function(double, double, double, double, double) onSave;

//   const _SettingsDialog({
//     required this.baseFare,
//     required this.perKmRate,
//     required this.perMinuteRate,
//     required this.waitingRate,
//     required this.minOrderPrice,
//     required this.onSave,
//   });

//   @override
//   State<_SettingsDialog> createState() => _SettingsDialogState();
// }

// class _SettingsDialogState extends State<_SettingsDialog> {
//   late TextEditingController _baseFareController;
//   late TextEditingController _perKmController;
//   late TextEditingController _perMinuteController;
//   late TextEditingController _waitingController;
//   late TextEditingController _minOrderController;

//   @override
//   void initState() {
//     super.initState();
//     _baseFareController =
//         TextEditingController(text: widget.baseFare.toString());
//     _perKmController = TextEditingController(text: widget.perKmRate.toString());
//     _perMinuteController =
//         TextEditingController(text: widget.perMinuteRate.toString());
//     _waitingController =
//         TextEditingController(text: widget.waitingRate.toString());
//     _minOrderController =
//         TextEditingController(text: widget.minOrderPrice.toString());
//   }

//   @override
//   void dispose() {
//     _baseFareController.dispose();
//     _perKmController.dispose();
//     _perMinuteController.dispose();
//     _waitingController.dispose();
//     _minOrderController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Настройки тарифов',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 _SettingsField(
//                   controller: _baseFareController,
//                   label: 'Посадка (TMT)',
//                   icon: Icons.flag,
//                 ),
//                 const SizedBox(height: 16),
//                 _SettingsField(
//                   controller: _perKmController,
//                   label: 'За км (TMT)',
//                   icon: Icons.straighten,
//                 ),
//                 const SizedBox(height: 16),
//                 _SettingsField(
//                   controller: _perMinuteController,
//                   label: 'За минуту (TMT)',
//                   icon: Icons.timer,
//                 ),
//                 const SizedBox(height: 16),
//                 _SettingsField(
//                   controller: _waitingController,
//                   label: 'Ожидание (TMT/мин)',
//                   icon: Icons.pause,
//                 ),
//                 const SizedBox(height: 16),
//                 _SettingsField(
//                   controller: _minOrderController,
//                   label: 'Минимальная цена заказа (TMT)',
//                   icon: Icons.attach_money,
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text(
//                           'Отмена',
//                           style: TextStyle(color: Colors.white70),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           final baseFare =
//                               double.tryParse(_baseFareController.text) ??
//                                   widget.baseFare;
//                           final perKm =
//                               double.tryParse(_perKmController.text) ??
//                                   widget.perKmRate;
//                           final perMin =
//                               double.tryParse(_perMinuteController.text) ??
//                                   widget.perMinuteRate;
//                           final waiting =
//                               double.tryParse(_waitingController.text) ??
//                                   widget.waitingRate;
//                           final minOrder =
//                               double.tryParse(_minOrderController.text) ??
//                                   widget.minOrderPrice;

//                           widget.onSave(
//                               baseFare, perKm, perMin, waiting, minOrder);
//                           Navigator.of(context).pop();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.greenAccent,
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text('Сохранить'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _TariffCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final String unit;

//   const _TariffCard({
//     required this.label,
//     required this.value,
//     required this.unit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.15),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 2),
//           Text(
//             unit,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class OrderCompletionScreen extends StatelessWidget {
//   final int finalPrice;
//   final double distance;
//   final int elapsedTime;

//   const OrderCompletionScreen({
//     Key? key,
//     required this.finalPrice,
//     required this.distance,
//     required this.elapsedTime,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Calculate waiting time in minutes
//     final int waitingMinutes = (elapsedTime / 60).round();
//     final int waitingSeconds = elapsedTime % 60;

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF1A1A2E),
//               Color(0xFF16213E),
//               Color(0xFF0F3460),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Icon(
//                         Icons.check_circle,
//                         color: Colors.green,
//                         size: 32,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     const Expanded(
//                       child: Text(
//                         'Заказ завершен!',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 40),

//                 // Total Price (Much Bigger)
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(32),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.green.withOpacity(0.1),
//                           Colors.green.withOpacity(0.05),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(
//                         color: Colors.green.withOpacity(0.3),
//                         width: 2,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.green.withOpacity(0.2),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Итоговая стоимость',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 24,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.baseline,
//                           textBaseline: TextBaseline.alphabetic,
//                           children: [
//                             Text(
//                               '${finalPrice}',
//                               style: const TextStyle(
//                                 color: Colors.green,
//                                 fontSize: 80,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: -2,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'TMT',
//                               style: TextStyle(
//                                 color: Colors.green.withOpacity(0.7),
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Trip Details (Much Bigger)
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.2),
//                         width: 1,
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Детали поездки',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 30),

//                         // Distance
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Расстояние:',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             Text(
//                               '${distance.toStringAsFixed(2)} км',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 20),

//                         // Waiting Time
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Время ожидания:',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             Text(
//                               waitingMinutes > 0
//                                   ? '$waitingMinutes мин ${waitingSeconds > 0 ? '$waitingSeconds сек' : ''}'
//                                   : '$waitingSeconds сек',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Close Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop(); // Pop from taxometer screen
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 20),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 8,
//                       shadowColor: Colors.green.withOpacity(0.3),
//                     ),
//                     child: const Text(
//                       'Закрыть',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SettingsField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;

//   const _SettingsField({
//     required this.controller,
//     required this.label,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       inputFormatters: [
//         FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
//       ],
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: Icon(icon, color: Colors.white70),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.white30),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.white30),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.white),
//         ),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.05),
//       ),
//     );
//   }
// }
