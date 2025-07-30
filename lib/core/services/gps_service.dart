import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_service/core/utils/location_helper.dart';

class GpsService {
  static final GpsService _instance = GpsService._internal();
  factory GpsService() => _instance;
  GpsService._internal();

  bool _isGpsEnabled = false;
  bool _isDialogShowing = false;
  Timer? _gpsCheckTimer;
  final StreamController<bool> _gpsStatusController =
      StreamController<bool>.broadcast();

  // Getters
  bool get isGpsEnabled => _isGpsEnabled;
  bool get isDialogShowing => _isDialogShowing;
  Stream<bool> get gpsStatusStream => _gpsStatusController.stream;

  /// Initialize GPS monitoring
  Future<void> initialize() async {
    await _checkGpsStatus();
    _startGpsMonitoring();
  }

  /// Check current GPS status
  Future<void> _checkGpsStatus() async {
    bool wasEnabled = _isGpsEnabled;
    _isGpsEnabled = await LocationHelper.isLocationServiceEnabled();

    if (wasEnabled != _isGpsEnabled) {
      _gpsStatusController.add(_isGpsEnabled);
    }
  }

  /// Start periodic GPS status monitoring
  void _startGpsMonitoring() {
    _gpsCheckTimer?.cancel();
    _gpsCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _checkGpsStatus();
    });
  }

  /// Stop GPS monitoring
  void dispose() {
    _gpsCheckTimer?.cancel();
    _gpsStatusController.close();
  }

  /// Set dialog showing state
  void setDialogShowing(bool showing) {
    _isDialogShowing = showing;
  }

  /// Show GPS dialog if GPS is disabled
  Future<void> showGpsDialogIfNeeded(BuildContext context) async {
    if (!_isGpsEnabled && !_isDialogShowing) {
      setDialogShowing(true);
      await _showGpsDialog(context);
    }
  }

  /// Show GPS dialog
  Future<void> _showGpsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Prevent dialog from being dismissed if GPS is still off
            return _isGpsEnabled;
          },
          child: AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.location_off,
                  color: Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'GPS отключен',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Для работы приложения необходимо включить GPS.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Пожалуйста, включите GPS в настройках устройства.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Open device location settings
                  await Geolocator.openLocationSettings();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Открыть настройки',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setDialogShowing(false);
    });
  }

  /// Check if GPS is enabled and show dialog if needed
  Future<void> checkAndShowDialog(BuildContext context) async {
    await _checkGpsStatus();
    if (!_isGpsEnabled) {
      await showGpsDialogIfNeeded(context);
    }
  }
}
