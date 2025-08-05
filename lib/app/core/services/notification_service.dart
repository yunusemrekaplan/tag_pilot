import 'package:flutter/material.dart';

/// Notification Types for different message contexts
enum NotificationType {
  success,
  error,
  warning,
  info,
  loading,
}

/// Notification Position for where to show
enum NotificationPosition {
  top,
  center,
  bottom,
}

/// Modern Notification Service Interface
/// SOLID: Interface Segregation Principle
abstract class NotificationService {
  /// Show success notification
  void showSuccess(String message, {String? title, Duration? duration});

  /// Show error notification
  void showError(String message, {String? title, Duration? duration});

  /// Show warning notification
  void showWarning(String message, {String? title, Duration? duration});

  /// Show info notification
  void showInfo(String message, {String? title, Duration? duration});

  /// Show loading notification
  void showLoading(String message);

  /// Hide loading notification
  void hideLoading();

  /// Show custom notification
  void showCustom({
    required String message,
    String? title,
    required NotificationType type,
    Duration? duration,
    NotificationPosition position = NotificationPosition.top,
    VoidCallback? onTap,
    Widget? icon,
  });

  /// Clear all notifications
  void clearAll();
}
