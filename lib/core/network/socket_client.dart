import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
import 'package:taxi_service/core/utils/location_helper.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/domain/entities/notification.dart';
import 'package:taxi_service/domain/entities/message.dart';

class SocketClient {
  static const String _apiRoot = 'taksi.hakyky.site:9094';
  static const bool _useHttps = false;
  IO.Socket? _socket;
  final _orderController = StreamController<Order>.broadcast();
  final _notificationController = StreamController<Notification>.broadcast();
  final _messageController = StreamController<Message>.broadcast();
  String? _authToken;
  Timer? _locationTimer;
  bool _isConnected = false;
  DateTime? _lastLocationSent;

  Stream<Order> get orderStream => _orderController.stream;
  Stream<Notification> get notificationStream => _notificationController.stream;
  Stream<Message> get messageStream => _messageController.stream;

  void setAuthToken(String token) {
    _authToken = token;
    _connect();
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
      _socket!.disconnect();
    }

    if (_authToken == null) {
      print('[SOCKET.IO] No auth token available, cannot connect');
      return;
    }

    final protocol = _useHttps ? 'https' : 'http';
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
      _startLocationUpdates();
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
        _orderController.add(order);
      } catch (e, st) {
        print('[SOCKET.IO] Error parsing Order: $e\n$st');
      }
    });

    _socket!.on('request-initial-price', (data) {
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
        _orderController.add(order);
      } catch (e, st) {
        print('[SOCKET.IO] Error parsing Order: $e\n$st');
      }
    });

    _socket!.on('request-cancelled', (data) {
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
        _orderController.add(order);
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

  void _startLocationUpdates() {
    _stopLocationUpdates(); // Stop any existing timer
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isConnected) {
        _sendLocationUpdate();
      }
    });
    print('[SOCKET.IO] Started location updates every 5 seconds');
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
    print('[SOCKET.IO] Stopped location updates');
  }

  Future<void> _sendLocationUpdate() async {
    try {
      // Throttle location updates to prevent too frequent requests
      if (_lastLocationSent != null &&
          DateTime.now().difference(_lastLocationSent!).inSeconds < 8) {
        print('[SOCKET.IO] Location update throttled - too frequent');
        return;
      }

      // Try to get last known position first to reduce frequency
      Position? position = await LocationHelper.getCurrentLocation();

      if (position == null) {
        print(
            '[SOCKET.IO] Could not get location - permissions or services disabled');
        return;
      }

      // Prepare location data
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      // Send location via Socket.IO
      emit('driver-location', locationData);
      _lastLocationSent = DateTime.now();
      print(
          '[SOCKET.IO] Sent location: ${locationData['latitude']}, ${locationData['longitude']}');
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
    disconnect();
    _orderController.close();
    _notificationController.close();
    _messageController.close();
  }

  void send(String event, dynamic data) {
    final encoded = data is String ? data : jsonEncode(data);
    print('[SOCKET.IO] Sending $event: $encoded');
    _socket?.emit(event, encoded);
  }

  void emit(String event, dynamic data) {
    print('[SOCKET.IO] Emitting $event: $data');
    _socket?.emit(event, data);
  }

  // Manual control methods for location updates
  void startLocationUpdates() {
    if (_isConnected) {
      _startLocationUpdates();
    } else {
      print('[SOCKET.IO] Cannot start location updates - not connected');
    }
  }

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
