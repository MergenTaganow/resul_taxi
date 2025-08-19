import 'package:flutter/material.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/services/location_warning_service.dart';

mixin LocationWarningMixin<T extends StatefulWidget> on State<T> {
  LocationWarningService? _locationWarningService;

  @override
  void initState() {
    super.initState();
    _locationWarningService = getIt<LocationWarningService>();

    // Set context and check GPS status when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationWarningService?.setContext(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update context when dependencies change (e.g., screen rotation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationWarningService?.setContext(context);
    });
  }

  @override
  void dispose() {
    // Don't dispose the service here as it's a singleton
    super.dispose();
  }

  /// Manual check and show warning (can be called from screen)
  Future<void> checkLocationWarning() async {
    await _locationWarningService?.checkAndShowWarning(context);
  }
}
