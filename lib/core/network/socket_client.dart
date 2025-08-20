import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/services/taxometer_service.dart';
import 'package:taxi_service/core/services/sound_service.dart';
import 'package:taxi_service/core/utils/location_helper.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/domain/entities/notification.dart';
import 'package:taxi_service/domain/entities/message.dart';

class SocketClient {
  // static const String _apiRoot = '46.173.17.202:9094';
  // static const String _apiRoot = '46.173.17.202:9094';
  // static const bool _useHttps = false;
  static const String _apiRoot = 'taksi.esynag.com:9094';
  static const bool _useHttps = false;
  IO.Socket? _socket;
  final _orderController = StreamController<Order>.broadcast();
  final _notificationController = StreamController<Notification>.broadcast();
  final _messageController = StreamController<Message>.broadcast();
  String? _authToken;
  Timer? _locationTimer;
  bool _isConnected = false;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;
  DateTime? _lastLocationSent;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  Stream<Order> get orderStream => _orderController.stream;
  Stream<Notification> get notificationStream => _notificationController.stream;
  Stream<Message> get messageStream => _messageController.stream;

  void setAuthToken(String token) {
    _authToken = token;
    _connect();
  }

  void initializeConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print(
            '[SOCKET.IO] Internet connection restored, attempting to reconnect...');
        if (_authToken != null && !_isConnected) {
          _connect();
        }
      } else {
        print('[SOCKET.IO] Internet connection lost');
        _isConnected = false;
        _stopLocationUpdates();
      }
    });
  }

  // Method to handle token refresh and reconnect
  void onTokenRefreshed(String newToken) {
    try {
      print('[SOCKET.IO] Token refreshed, reconnecting with new token...');
      _authToken = newToken;

      // Disconnect current socket and reconnect with new token
      if (_socket != null) {
        final wasConnected = _isConnected;
        _socket!.disconnect();
        _socket = null;
        _isConnected = false;

        // Reconnect if it was previously connected
        if (wasConnected) {
          _connect();
        }
      }
    } catch (e) {
      print('[SOCKET.IO] Error during token refresh reconnection: $e');
    }
  }

  // Method to get current auth token
  String? get authToken => _authToken;

  // Method to manually reconnect
  void reconnect() {
    print('[SOCKET.IO] Manual reconnection requested');
    if (_authToken != null) {
      _connect();
    } else {
      print('[SOCKET.IO] Cannot reconnect - no auth token available');
    }
  }

  void _connect() {
    if (_socket != null) {
      print('[SOCKET.IO] Disconnecting existing socket...');
      _locationTimer?.cancel();
      _socket!.disconnect();
    }

    _initializeGpsMonitoring();

    if (_authToken == null) {
      print('[SOCKET.IO] No auth token available, cannot connect');
      return;
    }

    const protocol = _useHttps ? 'https' : 'http';
    final socketUrl = '$protocol://$_apiRoot/requests?token=$_authToken';
    print('[SOCKET.IO] Connecting to: $socketUrl');

    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {'token': _authToken},
    });

    _socket!.onConnect((_) {
      print('[SOCKET.IO] Connected!');
      _isConnected = true;

      // Map<String, dynamic> orderMap = {
      //   'id': 1,
      //   'status': 'accepted',
      //   'district_slug': 'howdan_w',
      //   'district_id': 1,
      //   'tarrif_id': 1,
      //   'tarrif_slug': 'standart day',
      //   'phonenumber': '+99362626622',
      //   'driver_notified_time': '345345345',
      //   'note': 'bellik',
      //   'created_at': '123123123123',
      //   'requested_address': 'Howdan W',
      //   'requested_time': '123123123123',
      //   'approx_price': 100,
      // };
      // final order = Order.fromJson(orderMap);
      // _orderController.add(order);
      startLocationUpdates();
    });

    _socket!.onDisconnect((_) {
      print('[SOCKET.IO] Disconnected. Attempting to reconnect...');
      _isConnected = false;
      _stopLocationUpdates();
      // Socket.IO handles reconnection automatically
    });

    _socket!.onConnectError((error) {
      print('[SOCKET.IO] Connection error: $error');
      _isConnected = false;
      _stopLocationUpdates();
    });

    _socket!.onError((error) {
      print('[SOCKET.IO] Error: $error');
      _isConnected = false;
      _stopLocationUpdates();
    });

    // Listen for order events
    _socket!.on('request-accepted', (data) {
      print('[SOCKET.IO] Received request: $data');
      try {
        Map<String, dynamic> orderMap;
        if (data is Map<String, dynamic>) {
          orderMap = data;
        } else if (data is String) {
          orderMap = jsonDecode(data) as Map<String, dynamic>;
        } else {
          print('[SOCKET.IO] Unknown data type:  [${data.runtimeType}]');
          return;
        }
        final order = Order.fromJson(orderMap);

        // Play warning sound when new request is received
        getIt<SoundService>().playNewRequestWarningSound();

        _orderController.add(order);
      } catch (e, st) {
        print('[SOCKET.IO] Error parsing Order: $e\n$st');
      }
    });

    _socket!.on('request-initial-price', (data) {
      print('[SOCKET.IO] Modified initial price: $data');
      // try {
        Map<String, dynamic> orderMap;
        if (data is Map<String, dynamic>) {
          orderMap = data;
        } else if (data is String) {
          orderMap = jsonDecode(data) as Map<String, dynamic>;
        } else {
          print('[SOCKET.IO] Unknown data type:  [${data.runtimeType}]');
          return;
        }
        // final order = Order.fromJson(orderMap);
        final modifiedInitialPrice = orderMap['modified_initial_price'];
        if (modifiedInitialPrice != null) {
          getIt.get<TaxometerService>().modifiedInitialPrice(
              modifiedInitialPrice.toDouble(), orderMap['note'] ?? '');
        }
      // } catch (e, st) {
      //   print('[SOCKET.IO] Error parsing Order: $e\n$st');
      // }
    });

    _socket!.on('request-cancelled', (data) {
      print('[SOCKET.IO] Received request cancelled: $data');
      try {
        getIt.get<TaxometerService>().cancelRequest(data);
      } catch (e, st) {
        print('[SOCKET.IO] Error parsing Order: $e\n$st');
      }
    });

    // Listen for notification events
    _socket!.on('new-notification', (data) {
      print('[SOCKET.IO] Received notification: $data');
      try {
        Map<String, dynamic> notificationMap;
        if (data[0] is Map<String, dynamic>) {
          notificationMap = data[0];
        } else if (data[0] is String) {
          notificationMap = jsonDecode(data[0]) as Map<String, dynamic>;
        } else {
          print(
              '[SOCKET.IO] Unknown notification data type: [${data[0].runtimeType}]');
          return;
        }
        final notification = Notification.fromJson(notificationMap);
        _notificationController.add(notification);
      } catch (e, st) {
        print('[SOCKET.IO] Error parsing Notification: $e\n$st');
      }
    });

    // Listen for message events
    _socket!.on('new-message', (data) {
      print('[SOCKET.IO] Received message: $data');
      try {
        Map<String, dynamic> messageMap;
        if (data[0] is Map<String, dynamic>) {
          messageMap = data[0];
        } else if (data[0] is String) {
          messageMap = jsonDecode(data[0]) as Map<String, dynamic>;
        } else {
          print(
              '[SOCKET.IO] Unknown message data[0] type: [${data[0].runtimeType}]');
          return;
        }
        final message = Message.fromJson(messageMap);
        _messageController.add(message);
      } catch (e, st) {
        print('[SOCKET.IO] Error parsing Message: $e\n$st');
      }
    });

    // Listen for general messages
    _socket!.on('message', (data) {
      print('[SOCKET.IO] Received message: $data');
    });

    _socket!.connect();
  }

  void _initializeGpsMonitoring() {
    LocationSettings locationSettings;
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    // _locationSubscription =
    //     Geolocator.getPositionStream(locationSettings: locationSettings).listen(
    //   (Position position) {
    //     _currentPosition = position;
    //   },
    // );
  }

  void startLocationUpdates() {
    _stopLocationUpdates(); // Stop any existing timer
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isConnected) {
        sendLocationUpdate();
      }
    });
    print('[SOCKET.IO] Started location updates every 5 seconds');
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
    print('[SOCKET.IO] Stopped location updates');
  }

  Future<void> sendLocationUpdate() async {
    try {
      // Throttle location updates to prevent too frequent requests
      // if (_lastLocationSent != null &&
      //     DateTime.now().difference(_lastLocationSent!).inSeconds < 3) {
      //   print('[SOCKET.IO] Location update throttled - too frequent');
      //   return;
      // }

      // Try to get last known position first to reduce frequency

      if (await LocationHelper.isLocationServiceEnabled()) {
        _currentPosition = await Geolocator.getCurrentPosition();
      }
      if (_currentPosition == null) {
        print(
            '[SOCKET.IO] Could not get location - permissions or services disabled');
        return;
      }

      // Prepare location data
      final locationData = {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      };

      // Send location via Socket.IO
      emit('driver-location', locationData);
      _lastLocationSent = DateTime.now();
          } catch (e) {
      print('[SOCKET.IO] Error getting location: $e');
    }
  }

  void disconnect() {
    _stopLocationUpdates();
    _isConnected = false;
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    disconnect();
    _orderController.close();
    _notificationController.close();
    _messageController.close();
  }



  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  // Manual control methods for location updates
  // void startLocationUpdates() {
  //   if (_isConnected) {
  //     _startLocationUpdates();
  //   } else {
  //     print('[SOCKET.IO] Cannot start location updates - not connected');
  //   }
  // }

  void stopLocationUpdates() {
    _stopLocationUpdates();
  }

  bool get isConnected => _isConnected;

  bool get isLocationTrackingActive => _locationTimer != null;

  // Method to get connection status with more details
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _isConnected,
      'hasAuthToken': _authToken != null,
      'isLocationTrackingActive': isLocationTrackingActive,
      'socketId': _socket?.id,
    };
  }

  // Get current location status
  Future<Map<String, dynamic>> getLocationStatus() async {
    final isLocationEnabled = await LocationHelper.isLocationServiceEnabled();
    final permission = await LocationHelper.getLocationPermission();

    return {
      'locationServiceEnabled': isLocationEnabled,
      'permission': permission.toString(),
      'socketConnected': _isConnected,
      'locationTrackingActive': isLocationTrackingActive,
    };
  }
}
