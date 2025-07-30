import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taxi_service/presentation/widgets/circular_countdown_widget.dart';

class CountdownTestWidget extends StatefulWidget {
  const CountdownTestWidget({Key? key}) : super(key: key);

  @override
  State<CountdownTestWidget> createState() => _CountdownTestWidgetState();
}

class _CountdownTestWidgetState extends State<CountdownTestWidget> {
  int _currentSeconds = 60;
  final int _totalSeconds = 60;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentSeconds--;
      });

      // Let it go negative for demonstration
      if (_currentSeconds < -30) {
        _resetCountdown();
      }
    });
  }

  void _resetCountdown() {
    _timer?.cancel();
    setState(() {
      _currentSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232526),
      appBar: AppBar(
        title: const Text('Countdown Test'),
        backgroundColor: const Color(0xFF232526),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Circular Countdown Demo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            CircularCountdownWidget(
              currentSeconds: _currentSeconds,
              totalSeconds: _totalSeconds,
              size: 200,
              positiveColor: Colors.deepPurple,
              negativeColor: Colors.red,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startCountdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isRunning ? 'Running...' : 'Start'),
                ),
                ElevatedButton(
                  onPressed: _resetCountdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Current: ${_currentSeconds}s',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
