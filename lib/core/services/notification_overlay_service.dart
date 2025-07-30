import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taxi_service/domain/entities/notification.dart' as entity;

class NotificationOverlayService {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  /// Show a notification overlay that must be dismissed with OK button
  static Future<void> showNotificationOverlay({
    required BuildContext context,
    required String title,
    required String message,
    String? type,
    VoidCallback? onDismissed,
  }) async {
    // Don't show if another overlay is already visible
    if (_isShowing) {
      print('[NOTIFICATION_OVERLAY] Another overlay is already showing');
      return;
    }

    _isShowing = true;

    // Create the overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) => _NotificationOverlayWidget(
        title: title,
        message: message,
        type: type,
        onOkPressed: () {
          _dismissOverlay();
          onDismissed?.call();
        },
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(_currentOverlay!);

    print('[NOTIFICATION_OVERLAY] Showed overlay: $title');
  }

  /// Show notification overlay from entity
  static Future<void> showFromNotification(
    BuildContext context,
    entity.Notification notification, {
    VoidCallback? onDismissed,
  }) async {
    await showNotificationOverlay(
      context: context,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      onDismissed: onDismissed,
    );
  }

  /// Dismiss the current overlay
  static void _dismissOverlay() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
      print('[NOTIFICATION_OVERLAY] Dismissed overlay');
    }
  }

  /// Check if an overlay is currently showing
  static bool get isShowing => _isShowing;

  /// Force dismiss any showing overlay
  static void forceDismiss() {
    if (_isShowing) {
      _dismissOverlay();
    }
  }
}

/// The actual overlay widget
class _NotificationOverlayWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? type;
  final VoidCallback onOkPressed;

  const _NotificationOverlayWidget({
    required this.title,
    required this.message,
    this.type,
    required this.onOkPressed,
  });

  @override
  State<_NotificationOverlayWidget> createState() =>
      _NotificationOverlayWidgetState();
}

class _NotificationOverlayWidgetState extends State<_NotificationOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getTypeColor() {
    switch (widget.type?.toLowerCase()) {
      case 'error':
      case 'danger':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'info':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type?.toLowerCase()) {
      case 'error':
      case 'danger':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  void _handleOkPressed() async {
    // Animate out
    await _animationController.reverse();
    widget.onOkPressed();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final typeColor = _getTypeColor();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: screenSize.width,
                  margin: const EdgeInsets.only(
                    top: 50, // Account for status bar
                    left: 16,
                    right: 16,
                  ),
                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: typeColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            typeColor.withOpacity(0.1),
                            typeColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getTypeIcon(),
                                    color: typeColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: typeColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Message
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.message,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: _handleOkPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: typeColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
