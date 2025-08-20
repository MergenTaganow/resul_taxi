import 'package:flutter/material.dart';
import 'dart:async';

class NewOrderDialogDemo extends StatefulWidget {
  const NewOrderDialogDemo({Key? key}) : super(key: key);

  @override
  State<NewOrderDialogDemo> createState() => _NewOrderDialogDemoState();
}

class _NewOrderDialogDemoState extends State<NewOrderDialogDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('New Order Dialog Demo'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'New Order Dialog Redesign',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Features:\n• Prominent address display\n• Animated countdown with circular progress\n• Modern gradient design\n• Enhanced visual hierarchy\n• Urgency indicators',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const _DemoOrderDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Show New Order Dialog',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoOrderDialog extends StatefulWidget {
  const _DemoOrderDialog();

  @override
  State<_DemoOrderDialog> createState() => _DemoOrderDialogState();
}

class _DemoOrderDialogState extends State<_DemoOrderDialog> {
  Timer? _countdownTimer;
  int _countdownSeconds = 30;
  String? _selectedCommuteKey = '1';
  bool _isLoading = false;

  final List<CommuteType> _commuteTypes = [
    CommuteType(key: '1', value: '300000'), // 5 minutes
    CommuteType(key: '2', value: '600000'), // 10 minutes
    CommuteType(key: '3', value: '900000'), // 15 minutes
  ];

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdownSeconds--;
        });

        if (_countdownSeconds <= 0) {
          timer.cancel();
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order auto-rejected due to timeout'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  String _formatCommuteTime(String value) {
    try {
      final milliseconds = int.tryParse(value) ?? 0;
      final minutes = (milliseconds / 1000 / 60).round();

      if (minutes == 0) {
        return 'Менее 1 минуты';
      } else if (minutes == 1) {
        return '1 минута';
      } else if (minutes < 5) {
        return '$minutes минуты';
      } else {
        return '$minutes минут';
      }
    } catch (e) {
      return 'Время поездки';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isUrgent = _countdownSeconds <= 10;
    final progress = _countdownSeconds / 30.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              if (isUrgent) Colors.red.shade900.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isUrgent
                ? Colors.red.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isUrgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUrgent
                  ? Colors.red.withOpacity(0.3)
                  : Colors.black.withOpacity(0.5),
              blurRadius: isUrgent ? 20 : 15,
              spreadRadius: isUrgent ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with pulsing countdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Top row with close button and countdown
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            _countdownTimer?.cancel();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      // Animated countdown with circular progress
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUrgent ? Colors.red : Colors.orange,
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUrgent
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                '$_countdownSeconds',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: isUrgent
                                      ? [
                                          const Shadow(
                                            color: Colors.red,
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title and urgency indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_taxi,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Новый заказ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isUrgent
                                  ? 'Срочно! Время истекает!'
                                  : 'Время на принятие решения',
                              style: TextStyle(
                                color: isUrgent
                                    ? Colors.red.shade300
                                    : Colors.white70,
                                fontSize: 14,
                                fontWeight: isUrgent
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Address Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Адрес назначения',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ул. Гёроглы, дом 25, кв. 15, 3-й этаж',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Phone number
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '+993 65 123 456',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Commute types section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Время прибытия:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._commuteTypes.map((type) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: _selectedCommuteKey == type.key
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedCommuteKey == type.key
                                      ? Colors.orange
                                      : Colors.white.withOpacity(0.1),
                                  width:
                                      _selectedCommuteKey == type.key ? 2 : 1,
                                ),
                              ),
                              child: RadioListTile<String>(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                title: Text(
                                  _formatCommuteTime(type.value),
                                  style: TextStyle(
                                    color: _selectedCommuteKey == type.key
                                        ? Colors.orange.shade200
                                        : Colors.white,
                                    fontWeight: _selectedCommuteKey == type.key
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                value: type.key,
                                groupValue: _selectedCommuteKey,
                                onChanged: (val) =>
                                    setState(() => _selectedCommuteKey = val),
                                activeColor: Colors.orange,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _countdownTimer?.cancel();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order rejected'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Отклонить',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading || _selectedCommuteKey == null
                          ? null
                          : () {
                              setState(() => _isLoading = true);
                              _countdownTimer?.cancel();

                              // Simulate loading
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Order accepted successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Принять заказ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommuteType {
  final String key;
  final String value;

  CommuteType({required this.key, required this.value});
}
