import 'package:flutter/material.dart';
import 'package:taxi_service/presentation/widgets/gps_monitor_widget.dart';

class GpsDebugScreen extends StatefulWidget {
  const GpsDebugScreen({Key? key}) : super(key: key);

  @override
  State<GpsDebugScreen> createState() => _GpsDebugScreenState();
}

class _GpsDebugScreenState extends State<GpsDebugScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GPS Accuracy Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This screen helps you monitor GPS accuracy and movement detection. '
              'Stay still and observe if the location updates when you\'re not moving.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const GpsMonitorWidget(),
            const SizedBox(height: 24),
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Place your device on a stable surface\n'
              '2. Stay completely still for 30 seconds\n'
              '3. Watch the "Total Distance" value\n'
              '4. If it increases while stationary, GPS accuracy is poor\n'
              '5. Check the "Accuracy" value - lower is better\n'
              '6. Good accuracy should be under 10 meters',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'Expected Behavior:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• When stationary: Total Distance should remain stable\n'
              '• GPS Accuracy should be under 15 meters\n'
              '• Updates should be infrequent when not moving\n'
              '• Distance moved should be 0 or very small when still',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
