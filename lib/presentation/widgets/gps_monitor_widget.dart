import 'package:flutter/material.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/services/gps_service.dart';

class GpsMonitorWidget extends StatefulWidget {
  final Widget child;

  const GpsMonitorWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<GpsMonitorWidget> createState() => _GpsMonitorWidgetState();
}

class _GpsMonitorWidgetState extends State<GpsMonitorWidget> {
  late GpsService _gpsService;

  @override
  void initState() {
    super.initState();
    _gpsService = getIt<GpsService>();
    _initializeGpsMonitoring();
  }

  Future<void> _initializeGpsMonitoring() async {
    await _gpsService.initialize();

    // Listen to GPS status changes
    _gpsService.gpsStatusStream.listen((isEnabled) {
      if (mounted) {
        if (isEnabled) {
          // GPS was enabled, dialog will auto-dismiss
          print('[GPS] GPS enabled, dialog will dismiss automatically');
        } else {
          // GPS was disabled, show dialog
          _gpsService.checkAndShowDialog(context);
        }
      }
    });

    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _gpsService.checkAndShowDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
