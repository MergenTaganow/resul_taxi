import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsMonitorWidget extends StatefulWidget {
  const GpsMonitorWidget({Key? key}) : super(key: key);

  @override
  State<GpsMonitorWidget> createState() => _GpsMonitorWidgetState();
}

class _GpsMonitorWidgetState extends State<GpsMonitorWidget> {
  Position? _currentPosition;
  Position? _lastPosition;
  StreamSubscription<Position>? _locationSubscription;
  double _totalDistance = 0;
  int _updateCount = 0;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _startLocationMonitoring();
  }

  void _startLocationMonitoring() {
    const locationSettings = LocationSettings(
      distanceFilter: 5, // Same as taxometer service
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        setState(() {
          _lastPosition = _currentPosition;
          _currentPosition = position;
          _updateCount++;
          _lastUpdateTime = DateTime.now();

          if (_lastPosition != null) {
            double distance = Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );
            _totalDistance += distance;
          }
        });

        print('[GPS_MONITOR] Update #$_updateCount');
        print(
            '[GPS_MONITOR] Position: ${position.latitude}, ${position.longitude}');
        print('[GPS_MONITOR] Accuracy: ${position.accuracy}m');
        if (_lastPosition != null) {
          double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          print(
              '[GPS_MONITOR] Distance moved: ${distance.toStringAsFixed(2)}m');
        }
      },
      onError: (error) {
        print('[GPS_MONITOR] Error: $error');
      },
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'GPS Monitor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_currentPosition != null) ...[
            _buildInfoRow(
                'Latitude', _currentPosition!.latitude.toStringAsFixed(6)),
            _buildInfoRow(
                'Longitude', _currentPosition!.longitude.toStringAsFixed(6)),
            _buildInfoRow('Accuracy',
                '${_currentPosition!.accuracy.toStringAsFixed(1)}m'),
            _buildInfoRow('Updates', _updateCount.toString()),
            _buildInfoRow(
                'Total Distance', '${_totalDistance.toStringAsFixed(2)}m'),
            if (_lastUpdateTime != null)
              _buildInfoRow(
                  'Last Update', _lastUpdateTime!.toString().substring(11, 19)),
          ] else ...[
            const Text(
              'Waiting for GPS...',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
