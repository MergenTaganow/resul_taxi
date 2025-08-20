import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taxi_service/presentation/widgets/circular_countdown_widget.dart';

class TaxometerDemoWidget extends StatefulWidget {
  const TaxometerDemoWidget({Key? key}) : super(key: key);

  @override
  State<TaxometerDemoWidget> createState() => _TaxometerDemoWidgetState();
}

class _TaxometerDemoWidgetState extends State<TaxometerDemoWidget>
    with TickerProviderStateMixin {
  bool _freeWaitingActive = false;
  int _freeWaitingCountdown = 120;
  final int _freeWaitingTime = 120;
  final int _elapsedTime = 156; // 2:36
  final double _distance = 2.543;
  Timer? _freeWaitingTimer;

  late AnimationController _freeWaitingAnimationController;
  late Animation<double> _freeWaitingFadeAnimation;

  @override
  void initState() {
    super.initState();

    _freeWaitingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _freeWaitingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _freeWaitingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _freeWaitingAnimationController.dispose();
    _freeWaitingTimer?.cancel();
    super.dispose();
  }

  void _startFreeWaitingCountdown() {
    setState(() {
      _freeWaitingActive = true;
      _freeWaitingCountdown = _freeWaitingTime;
    });

    // Animate in the free waiting countdown
    _freeWaitingAnimationController.forward();

    _freeWaitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_freeWaitingCountdown > 0) {
        setState(() {
          _freeWaitingCountdown--;
        });
      } else {
        timer.cancel();
        // Animate out the free waiting countdown
        _freeWaitingAnimationController.reverse().then((_) {
          setState(() {
            _freeWaitingActive = false;
          });
        });
      }
    });
  }

  void _stopFreeWaitingCountdown() {
    _freeWaitingTimer?.cancel();
    // Animate out the free waiting countdown
    _freeWaitingAnimationController.reverse().then((_) {
      setState(() {
        _freeWaitingActive = false;
      });
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232526),
      appBar: AppBar(
        title: const Text('Taxometer Demo'),
        backgroundColor: const Color(0xFF232526),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Free Waiting Countdown Demo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // This mimics the taxometer screen layout
            Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Текущая стоимость',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '15.50 TMT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time and Distance vs Free Waiting Countdown (animated transition)
                  AnimatedBuilder(
                    animation: _freeWaitingFadeAnimation,
                    builder: (context, child) {
                      if (_freeWaitingActive) {
                        // Show Free Waiting Countdown
                        return FadeTransition(
                          opacity: _freeWaitingFadeAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'Бесплатное ожидание',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              CircularCountdownWidget(
                                currentSeconds: _freeWaitingCountdown,
                                totalSeconds: _freeWaitingTime > 0
                                    ? _freeWaitingTime
                                    : 120,
                                size: 140,
                                positiveColor: Colors.green,
                                negativeColor: Colors.orange,
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Show Time and Distance
                        return FadeTransition(
                          opacity: Tween<double>(begin: 1.0, end: 0.0)
                              .animate(_freeWaitingFadeAnimation),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _InfoCard(
                                icon: Icons.timer,
                                label: 'Время',
                                value: _formatTime(_elapsedTime),
                                isHighlighted: true,
                              ),
                              _InfoCard(
                                icon: Icons.straighten,
                                label: 'Расстояние',
                                value: '${_distance.toStringAsFixed(3)} км',
                                isHighlighted: false,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      _freeWaitingActive ? null : _startFreeWaitingCountdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                      _freeWaitingActive ? 'Running...' : 'Start Free Waiting'),
                ),
                ElevatedButton(
                  onPressed: _stopFreeWaitingCountdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Stop'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'Status: ${_freeWaitingActive ? "Free Waiting Active" : "Normal Mode"}',
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    const highlightColor = Colors.orangeAccent;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.4, // Make cards wider (40% of screen width each)
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? highlightColor : Colors.white.withOpacity(0.1),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon,
              color: isHighlighted ? highlightColor : Colors.white70,
              size: 28), // Slightly bigger icon
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? highlightColor : Colors.white70,
              fontSize: 13, // Slightly bigger text
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted ? highlightColor : Colors.white,
              fontSize: 18, // Bigger value text
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
