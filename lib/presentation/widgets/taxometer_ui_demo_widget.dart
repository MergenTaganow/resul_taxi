import 'package:flutter/material.dart';

class TaxometerUIDemoWidget extends StatefulWidget {
  const TaxometerUIDemoWidget({Key? key}) : super(key: key);

  @override
  State<TaxometerUIDemoWidget> createState() => _TaxometerUIDemoWidgetState();
}

class _TaxometerUIDemoWidgetState extends State<TaxometerUIDemoWidget> {
  bool _isGpsEnabled = true;
  int _elapsedTime = 245; // 4:05
  double _distance = 3.742;
  bool _isWaiting = true;
  bool _isRunning = false;

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getLocationStatusColor() {
    return _isGpsEnabled ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232526),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with GPS Status
              _FrostedBar(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Таксометр UI Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // GPS Status Icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getLocationStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        _isGpsEnabled ? Icons.location_on : Icons.location_off,
                        color: _getLocationStatusColor(),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Demo Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Fare Display
                      Container(
                        padding: const EdgeInsets.all(24),
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
                              '18.75 TMT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Time and Distance Cards (Wider)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _InfoCard(
                                  icon: Icons.timer,
                                  label: 'Время',
                                  value: _formatTime(_elapsedTime),
                                  isHighlighted: _isWaiting,
                                ),
                                _InfoCard(
                                  icon: Icons.straighten,
                                  label: 'Расстояние',
                                  value: '${_distance.toStringAsFixed(3)} км',
                                  isHighlighted: _isRunning,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isGpsEnabled = !_isGpsEnabled;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isGpsEnabled ? Colors.green : Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(_isGpsEnabled ? 'GPS ON' : 'GPS OFF'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isWaiting = !_isWaiting;
                                _isRunning = !_isRunning;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isWaiting ? Colors.orange : Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(_isWaiting ? 'Waiting' : 'Driving'),
                          ),
                        ],
                      ),

                      const Spacer(),

                      const Text(
                        'Features:\n• GPS status moved to app bar (top right)\n• Time and Distance cards are wider\n• Icons and text sizes increased',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrostedBar extends StatelessWidget {
  final Widget child;

  const _FrostedBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: child,
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
    final highlightColor = Colors.orangeAccent;
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
