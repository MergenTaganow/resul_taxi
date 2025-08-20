import 'package:flutter/material.dart';

class CircularCountdownWidget extends StatefulWidget {
  final int currentSeconds;
  final int totalSeconds;
  final double size;
  final Color? positiveColor;
  final Color? negativeColor;
  final TextStyle? textStyle;

  const CircularCountdownWidget({
    Key? key,
    required this.currentSeconds,
    required this.totalSeconds,
    this.size = 120,
    this.positiveColor,
    this.negativeColor,
    this.textStyle,
  }) : super(key: key);

  @override
  State<CircularCountdownWidget> createState() =>
      _CircularCountdownWidgetState();
}

class _CircularCountdownWidgetState extends State<CircularCountdownWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation controller for smooth transitions
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Pulse controller for negative countdown
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation if countdown is negative
    if (widget.currentSeconds < 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CircularCountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle state changes
    if (widget.currentSeconds < 0 && oldWidget.currentSeconds >= 0) {
      // Just went negative
      _pulseController.repeat(reverse: true);
    } else if (widget.currentSeconds >= 0 && oldWidget.currentSeconds < 0) {
      // Just went positive
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = widget.currentSeconds < 0;
    final displaySeconds = widget.currentSeconds.abs();

    // Calculate progress (0.0 to 1.0)
    double progress;
    if (widget.totalSeconds <= 0) {
      progress = 0.0;
    } else if (isNegative) {
      // For negative countdown, show as overtime
      progress = 1.0; // Complete circle
    } else {
      progress = 1.0 - (widget.currentSeconds / widget.totalSeconds);
      progress = progress.clamp(0.0, 1.0);
    }

    final baseColor = isNegative
        ? (widget.negativeColor ?? Colors.red)
        : (widget.positiveColor ?? Colors.deepPurple);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isNegative ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // color: baseColor.withOpacity(0),
                    border: Border.all(
                      color: baseColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),

                // Progress circle
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: baseColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isNegative ? baseColor.withOpacity(0.8) : baseColor,
                    ),
                  ),
                ),

                // Time text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isNegative)
                      Icon(
                        Icons.schedule,
                        color: baseColor,
                        size: 16,
                      ),
                    Text(
                      _formatTime(displaySeconds),
                      style: widget.textStyle ??
                          TextStyle(
                            fontSize: widget.size * 0.25,
                            fontWeight: FontWeight.bold,
                            color: baseColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (isNegative)
                      Text(
                        'ОПОЗДАНИЕ',
                        style: TextStyle(
                          fontSize: widget.size * 0.08,
                          fontWeight: FontWeight.w600,
                          color: baseColor,
                          letterSpacing: 1,
                        ),
                      ),
                  ],
                ),

                // Outer glow effect for negative countdown
                if (isNegative)
                  Container(
                    width: widget.size + 10,
                    height: widget.size + 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes < 60) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
