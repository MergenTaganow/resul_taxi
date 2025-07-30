import 'package:flutter/material.dart';

class TariffCardsDemoWidget extends StatefulWidget {
  const TariffCardsDemoWidget({Key? key}) : super(key: key);

  @override
  State<TariffCardsDemoWidget> createState() => _TariffCardsDemoWidgetState();
}

class _TariffCardsDemoWidgetState extends State<TariffCardsDemoWidget> {
  double _baseFare = 5.0;
  double _perKmRate = 2.5;
  double _waitingRate = 0.3;
  String _currentTariffName = 'Стандарт';

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
              // App Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Tariff Cards Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                      // Main Fare Display
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
                              '25.75 TMT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Tariff Cards Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Тариф: $_currentTariffName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tariff Cards in Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _TariffCard(
                                  icon: Icons.flag,
                                  label: 'Подача',
                                  value: _baseFare.toStringAsFixed(2),
                                  unit: 'TMT',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _TariffCard(
                                  icon: Icons.straighten,
                                  label: 'За км',
                                  value: _perKmRate.toStringAsFixed(2),
                                  unit: 'TMT',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _TariffCard(
                                  icon: Icons.schedule,
                                  label: 'Ожидание',
                                  value: _waitingRate.toStringAsFixed(2),
                                  unit: 'TMT/мин',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Test Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _baseFare = _baseFare == 5.0 ? 7.0 : 5.0;
                                _perKmRate = _perKmRate == 2.5 ? 3.0 : 2.5;
                                _waitingRate = _waitingRate == 0.3 ? 0.5 : 0.3;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Switch Tariff'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentTariffName =
                                    _currentTariffName == 'Стандарт'
                                        ? 'Премиум'
                                        : 'Стандарт';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Change Name'),
                          ),
                        ],
                      ),

                      const Spacer(),

                      const Text(
                        'Features:\n• 3 tariff cards in a row\n• Clean design with icon, label, value, unit\n• Responsive layout with equal spacing\n• Different units per card',
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

class _TariffCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _TariffCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
