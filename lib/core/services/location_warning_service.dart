import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_service/core/utils/location_helper.dart';

class LocationWarningService {
  static final LocationWarningService _instance =
      LocationWarningService._internal();
  factory LocationWarningService() => _instance;
  LocationWarningService._internal();

  bool _isGpsEnabled = false;
  bool _isWarningShowing = false;
  Timer? _gpsCheckTimer;
  final StreamController<bool> _gpsStatusController =
      StreamController<bool>.broadcast();
  OverlayEntry? _overlayEntry;
  BuildContext? _currentContext;

  // Getters
  bool get isGpsEnabled => _isGpsEnabled;
  bool get isWarningShowing => _isWarningShowing;
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

      if (_isGpsEnabled) {
        // GPS is now enabled, hide warning
        _hideWarning();
      } else {
        // GPS is now disabled, show warning
        _showWarning();
      }
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
    _hideWarning();
  }

  /// Set current context for showing overlay
  void setContext(BuildContext context) {
    _currentContext = context;
    if (!_isGpsEnabled && !_isWarningShowing) {
      _showWarning();
    }
  }

  /// Show location warning overlay
  void _showWarning() {
    if (_isWarningShowing || _currentContext == null || _isGpsEnabled) return;

    _isWarningShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => _LocationWarningOverlay(
        onDismiss: _hideWarning,
        onOpenSettings: () async {
          await Geolocator.openLocationSettings();
        },
      ),
    );

    Overlay.of(_currentContext!).insert(_overlayEntry!);
  }

  /// Hide location warning overlay
  void _hideWarning() {
    if (!_isWarningShowing) return;

    _isWarningShowing = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Manual check and show warning
  Future<void> checkAndShowWarning(BuildContext context) async {
    setContext(context);
    await _checkGpsStatus();
  }
}

class _LocationWarningOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback onOpenSettings;

  const _LocationWarningOverlay({
    required this.onDismiss,
    required this.onOpenSettings,
  });

  @override
  State<_LocationWarningOverlay> createState() =>
      _LocationWarningOverlayState();
}

class _LocationWarningOverlayState extends State<_LocationWarningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value * 100),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_off,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Включите геолокацию',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Для работы приложения необходимо включить GPS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: widget.onOpenSettings,
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: 'Открыть настройки',
                          ),
                          IconButton(
                            onPressed: widget.onDismiss,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: 'Закрыть',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
