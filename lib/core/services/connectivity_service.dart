import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  bool _isConnected = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool get isConnected => _isConnected;
  Stream<bool> get connectivityStream => _connectivityController.stream;

  Future<void> initialize() async {
    await _checkConnectivity();
    _startConnectivityMonitoring();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      bool wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;

      if (wasConnected != _isConnected) {
        _connectivityController.add(_isConnected);
        print(
            '[CONNECTIVITY] Internet connection: ${_isConnected ? 'Available' : 'Unavailable'}');
      }
    } catch (e) {
      print('[CONNECTIVITY] Error checking connectivity: $e');
      _isConnected = false;
      _connectivityController.add(false);
    }
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      bool wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;

      if (wasConnected != _isConnected) {
        _connectivityController.add(_isConnected);
        print(
            '[CONNECTIVITY] Internet connection changed: ${_isConnected ? 'Available' : 'Unavailable'} (${result.name})');
      }
    });
  }

  Future<ConnectivityResult> getConnectivityResult() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      print('[CONNECTIVITY] Error getting connectivity result: $e');
      return ConnectivityResult.none;
    }
  }

  // Test method to manually check connectivity
  Future<void> testConnectivity() async {
    print('[CONNECTIVITY] Testing connectivity...');
    final result = await getConnectivityResult();
    print('[CONNECTIVITY] Current connectivity: ${result.name}');
    print('[CONNECTIVITY] Is connected: ${result != ConnectivityResult.none}');
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
