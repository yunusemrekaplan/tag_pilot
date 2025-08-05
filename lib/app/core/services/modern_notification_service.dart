import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/modern_notification_widget.dart';

/// Modern Notification Service Implementation
/// SOLID: Single Responsibility, Dependency Inversion
class ModernNotificationService implements NotificationService {
  static final ModernNotificationService _instance =
      ModernNotificationService._internal();
  factory ModernNotificationService() => _instance;
  ModernNotificationService._internal();

  OverlayEntry? _currentNotification;
  OverlayEntry? _loadingNotification;
  final List<OverlayEntry> _notificationQueue = [];

  /// Default configuration
  static const Duration _defaultDuration = Duration(seconds: 2);
  static const Duration _loadingDuration = Duration(seconds: 30);

  @override
  void showSuccess(String message, {String? title, Duration? duration}) {
    showCustom(
      message: message,
      title: title ?? 'Başarılı',
      type: NotificationType.success,
      duration: duration ?? _defaultDuration,
    );
  }

  @override
  void showError(String message, {String? title, Duration? duration}) {
    showCustom(
      message: message,
      title: title ?? 'Hata',
      type: NotificationType.error,
      duration: duration ?? _defaultDuration,
    );
  }

  @override
  void showWarning(String message, {String? title, Duration? duration}) {
    showCustom(
      message: message,
      title: title ?? 'Uyarı',
      type: NotificationType.warning,
      duration: duration ?? _defaultDuration,
    );
  }

  @override
  void showInfo(String message, {String? title, Duration? duration}) {
    showCustom(
      message: message,
      title: title ?? 'Bilgi',
      type: NotificationType.info,
      duration: duration ?? _defaultDuration,
    );
  }

  @override
  void showLoading(String message) {
    hideLoading(); // Clear existing loading

    _loadingNotification = _createOverlayEntry(
      type: NotificationType.loading,
      message: message,
      title: 'Yükleniyor...',
      duration: _loadingDuration,
      position: NotificationPosition.center,
    );

    if (Get.overlayContext != null) {
      Overlay.of(Get.overlayContext!).insert(_loadingNotification!);
    }
  }

  @override
  void hideLoading() {
    if (_loadingNotification != null) {
      _loadingNotification!.remove();
      _loadingNotification = null;
    }
  }

  @override
  void showCustom({
    required String message,
    String? title,
    required NotificationType type,
    Duration? duration,
    NotificationPosition position = NotificationPosition.top,
    VoidCallback? onTap,
    Widget? icon,
  }) {
    // Clear current notification if exists
    _clearCurrentNotification();

    // Create new overlay entry
    _currentNotification = _createOverlayEntry(
      type: type,
      message: message,
      title: title,
      duration: duration ?? _defaultDuration,
      position: position,
      onTap: onTap,
      icon: icon,
    );

    // Insert to overlay
    if (Get.overlayContext != null) {
      Overlay.of(Get.overlayContext!).insert(_currentNotification!);

      // Auto hide after duration (except loading)
      if (type != NotificationType.loading) {
        Future.delayed(duration ?? _defaultDuration, () {
          _clearCurrentNotification();
        });
      }
    }
  }

  @override
  void clearAll() {
    _clearCurrentNotification();
    hideLoading();
    _clearQueue();
  }

  /// Create overlay entry for notification
  OverlayEntry _createOverlayEntry({
    required NotificationType type,
    required String message,
    String? title,
    required Duration duration,
    NotificationPosition position = NotificationPosition.top,
    VoidCallback? onTap,
    Widget? icon,
  }) {
    return OverlayEntry(
      builder: (context) => ModernNotificationWidget(
        type: type,
        message: message,
        title: title,
        position: position,
        onTap: onTap ?? () => _clearCurrentNotification(),
        onDismiss: _clearCurrentNotification,
        customIcon: icon,
      ),
    );
  }

  /// Clear current notification
  void _clearCurrentNotification() {
    if (_currentNotification != null) {
      _currentNotification!.remove();
      _currentNotification = null;
    }
  }

  /// Clear notification queue
  void _clearQueue() {
    for (var entry in _notificationQueue) {
      entry.remove();
    }
    _notificationQueue.clear();
  }

  /// Get color for notification type
  static Color getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.info;
      case NotificationType.loading:
        return AppColors.primary;
    }
  }

  /// Get icon for notification type
  static IconData getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.loading:
        return Icons.hourglass_empty;
    }
  }
}
