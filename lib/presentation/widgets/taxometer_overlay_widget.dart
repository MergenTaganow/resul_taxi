import 'package:flutter/material.dart';
import 'package:taxi_service/presentation/app.dart';
import 'package:taxi_service/presentation/screens/taxometer_screen.dart';
import '../../core/di/injection.dart';
import '../../core/services/taxometer_service.dart';

class TaxometerOverlayWidget extends StatefulWidget {
  const TaxometerOverlayWidget({Key? key}) : super(key: key);

  @override
  State<TaxometerOverlayWidget> createState() => _TaxometerOverlayWidgetState();
}

class _TaxometerOverlayWidgetState extends State<TaxometerOverlayWidget> {
  late TaxometerService _taxometerService;
  late VoidCallback _stateChangeListener;

  @override
  void initState() {
    super.initState();
    _taxometerService = getIt<TaxometerService>();
    _stateChangeListener = () {
      print(
          '[OVERLAY] State changed - isActive: ${_taxometerService.isActive}');
      if (mounted) {
        setState(() {});
      }
    };
    _taxometerService.addStateChangeListener(_stateChangeListener);
    print(
        '[OVERLAY] Initialized - initial isActive: ${_taxometerService.isActive}');
  }

  @override
  void dispose() {
    _taxometerService.removeStateChangeListener(_stateChangeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show overlay on all screens, but with different content based on taxometer state
    print(
        '[OVERLAY] isActive: ${_taxometerService.isActive}, isRunning: ${_taxometerService.isRunning}');

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _taxometerService.isWaiting
            ? Colors.orange.withOpacity(0.95)
            : Colors.green.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to taxometer screen when tapped
          Navigator.of(navigatorKey.currentContext!)
              .push(MaterialPageRoute(builder: (context) => TaxometerScreen()));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status icon
              // Container(
              //   width: 36,
              //   height: 36,
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(18),
              //   ),
              //   child: Icon(
              //     _taxometerService.isWaiting
              //         ? Icons.pause_circle_filled
              //         : Icons.play_circle_filled,
              //     color: Colors.white,
              //     size: 20,
              //   ),
              // ),

              const SizedBox(width: 12),

              // Status and fare info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status text
                  Text(
                    _taxometerService.arrivalCountdownActive
                        ? 'ПРИБЫТИЕ'
                        : _taxometerService.freeWaitingActive
                            ? 'БЕСПЛАТНОЕ\nОЖИДАНИЕ'
                            : _taxometerService.isWaiting
                                ? 'ОЖИДАНИЕ'
                                : 'ПОЕЗДКА',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Fare amount
                  Text(
                    '${_taxometerService.currentFare.toStringAsFixed(2)} TMT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Distance and time info
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     // Distance
              //      ...[
              //       Text(
              //         '${_taxometerService.distance.toStringAsFixed(2)} км',
              //         style: const TextStyle(
              //           color: Colors.white,
              //           fontSize: 11,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //       const SizedBox(height: 2),
              //     ],

              //     // Time
              //     Text(
              //       _formatElapsedTime(_taxometerService.elapsedTime),
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 11,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ],
              // ),

              // const SizedBox(width: 8),

              // // Quick action buttons
              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     // Toggle waiting/driving button
              //     InkWell(
              //       borderRadius: BorderRadius.circular(16),
              //       onTap: () {
              //         // if (_taxometerService.isWaiting) {
              //         //   _taxometerService.forceDrivingMode();
              //         // } else {
              //         //   _taxometerService.forceWaitingMode();
              //         // }
              //       },
              //       child: Container(
              //         width: 32,
              //         height: 32,
              //         decoration: BoxDecoration(
              //           color: Colors.white.withOpacity(0.2),
              //           borderRadius: BorderRadius.circular(16),
              //         ),
              //         child: Icon(
              //           _taxometerService.isWaiting
              //               ? Icons.play_arrow
              //               : Icons.pause,
              //           color: Colors.white,
              //           size: 16,
              //         ),
              //       ),
              //     ),

              //     const SizedBox(width: 8),

              //     // Stop button
              //     InkWell(
              //       borderRadius: BorderRadius.circular(16),
              //       onTap: () {
              //         _showStopConfirmationDialog();
              //       },
              //       child: Container(
              //         width: 32,
              //         height: 32,
              //         decoration: BoxDecoration(
              //           color: Colors.red.withOpacity(0.3),
              //           borderRadius: BorderRadius.circular(16),
              //         ),
              //         child: const Icon(
              //           Icons.stop,
              //           color: Colors.white,
              //           size: 16,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatElapsedTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}м ${remainingSeconds}с';
    } else {
      return '${remainingSeconds}с';
    }
  }

  void _showStopConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Остановить таксометр?'),
          content: const Text(
            'Вы уверены, что хотите остановить таксометр? '
            'Это завершит текущую поездку.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // _taxometerService.stopTaxometer();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Остановить'),
            ),
          ],
        );
      },
    );
  }
}
