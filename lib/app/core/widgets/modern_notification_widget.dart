import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/modern_notification_service.dart';

/// Modern Notification Widget
/// Beautiful, branded notification UI component
class ModernNotificationWidget extends StatefulWidget {
  final NotificationType type;
  final String message;
  final String? title;
  final NotificationPosition position;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final Widget? customIcon;

  const ModernNotificationWidget({
    super.key,
    required this.type,
    required this.message,
    this.title,
    required this.position,
    required this.onTap,
    required this.onDismiss,
    this.customIcon,
  });

  @override
  State<ModernNotificationWidget> createState() =>
      _ModernNotificationWidgetState();
}

class _ModernNotificationWidgetState extends State<ModernNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _animateIn();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide animation based on position
    final slideBegin = _getSlideBegin();
    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  Offset _getSlideBegin() {
    switch (widget.position) {
      case NotificationPosition.top:
        return const Offset(0, -1);
      case NotificationPosition.center:
        return const Offset(0, 0);
      case NotificationPosition.bottom:
        return const Offset(0, 1);
    }
  }

  void _animateIn() {
    _animationController.forward();
  }

  Future<void> _animateOut() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == NotificationPosition.top ? 50 : null,
      bottom: widget.position == NotificationPosition.bottom ? 50 : null,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: _buildNotificationCard(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard() {
    final color = ModernNotificationService.getColorForType(widget.type);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Glass effect background
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildContent(color),
              ),

              // Dismiss button for non-loading notifications
              if (widget.type != NotificationType.loading)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildDismissButton(),
                ),

              // Progress indicator for loading
              if (widget.type == NotificationType.loading)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    return Row(
      children: [
        // Icon
        _buildIcon(color),

        const SizedBox(width: 12),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(Color color) {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    if (widget.type == NotificationType.loading) {
      return Container(
        width: 24,
        height: 24,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        ModernNotificationService.getIconForType(widget.type),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildDismissButton() {
    return GestureDetector(
      onTap: _animateOut,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: LinearProgressIndicator(
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
