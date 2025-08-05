import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Ana Uygulama Rengi #424242 (Koyu Gri)
  static const Color primary = Color(0xFF424242);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF757575);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  // Secondary colors - Accent Rengi #00d100 (Parlak Yeşil)
  static const Color secondary = Color(0xFF00D100);
  static const Color onSecondary = Color(0xFF000000);
  static const Color secondaryContainer = Color(0xFF66E066);
  static const Color onSecondaryContainer = Color(0xFF004D00);

  // Tertiary colors - Destekleyici renkler
  static const Color tertiary = Color(0xFF9E9E9E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFE0E0E0);
  static const Color onTertiaryContainer = Color(0xFF212121);

  // Error colors
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onErrorContainer = Color(0xFFB71C1C);

  // Surface colors - Ana beyaz renk #ffffff
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF424242);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurfaceVariant = Color(0xFF757575);

  // Background colors - Ana beyaz renk #ffffff
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF424242);

  // Outline colors
  static const Color outline = Color(0xFF9E9E9E);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Business specific colors
  static const Color success = Color(0xFF00D100); // Ana yeşil rengi kullan
  static const Color onSuccess = Color(0xFF000000);
  static const Color successContainer = Color(0xFF66E066);
  static const Color onSuccessContainer = Color(0xFF004D00);

  static const Color warning = Color(0xFFFF9800);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarningContainer = Color(0xFF8C5000);

  static const Color info = Color(0xFF2196F3);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // Status colors for profit/loss
  static const Color profit = success; // Ana yeşil
  static const Color loss = error;
  static const Color breakEven = Color(0xFF9E9E9E);

  // Session status colors
  static const Color sessionActive = Color(0xFF00D100); // Ana yeşil
  static const Color sessionPaused = Color(0xFFFF9800);
  static const Color sessionCompleted = Color(0xFF9E9E9E);

  // Chart colors - Ana renk paletine uygun
  static const List<Color> chartColors = [
    Color(0xFF424242), // Ana koyu gri
    Color(0xFF00D100), // Ana yeşil
    Color(0xFF9E9E9E), // Gri
    Color(0xFF757575), // Orta gri
    Color(0xFFFF9800), // Turuncu (warning)
    Color(0xFF2196F3), // Mavi (info)
    Color(0xFFD32F2F), // Kırmızı (error)
  ];

  // Gradient colors - Ana renklere dayalı
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF66E066)], // Ana yeşilden açık yeşile
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark theme colors - Ana renklere uygun karanlık tema
  static const Color darkPrimary = Color(0xFF757575); // Daha açık gri
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkPrimaryContainer = Color(0xFF424242); // Ana koyu gri
  static const Color darkOnPrimaryContainer = Color(0xFFFFFFFF);

  static const Color darkSecondary = Color(0xFF66E066); // Açık yeşil
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkSecondaryContainer = Color(0xFF00D100); // Ana yeşil
  static const Color darkOnSecondaryContainer = Color(0xFF000000);

  static const Color darkTertiary = Color(0xFFBDBDBD); // Açık gri
  static const Color darkOnTertiary = Color(0xFF000000);
  static const Color darkTertiaryContainer = Color(0xFF9E9E9E);
  static const Color darkOnTertiaryContainer = Color(0xFFFFFFFF);

  static const Color darkError = Color(0xFFEF5350);
  static const Color darkOnError = Color(0xFFFFFFFF);
  static const Color darkErrorContainer = Color(0xFFD32F2F);
  static const Color darkOnErrorContainer = Color(0xFFFFFFFF);

  static const Color darkSurface = Color(0xFF212121);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkSurfaceVariant = Color(0xFF424242);
  static const Color darkOnSurfaceVariant = Color(0xFFE0E0E0);

  static const Color darkBackground = Color(0xFF212121);
  static const Color darkOnBackground = Color(0xFFFFFFFF);

  static const Color darkOutline = Color(0xFF757575);
  static const Color darkOutlineVariant = Color(0xFF424242);

  // Helper methods
  static Color getStatusColor(bool isProfitable, {bool isDark = false}) {
    if (isProfitable) {
      return isDark ? Color(0xFF81C784) : success;
    } else {
      return isDark ? Color(0xFFEF5350) : error;
    }
  }

  static Color getSessionStatusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'active':
        return isDark ? Color(0xFF81C784) : sessionActive;
      case 'paused':
        return isDark ? Color(0xFFFFB74D) : sessionPaused;
      case 'completed':
        return isDark ? Color(0xFFBDBDBD) : sessionCompleted;
      default:
        return isDark ? darkOnSurface : onSurface;
    }
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Material 3 elevation colors
  static Color getElevationColor(int elevation, {bool isDark = false}) {
    if (isDark) {
      switch (elevation) {
        case 1:
          return Color(0xFF232229);
        case 2:
          return Color(0xFF272630);
        case 3:
          return Color(0xFF2D2A37);
        case 4:
          return Color(0xFF302D3A);
        case 5:
          return Color(0xFF34313E);
        default:
          return darkSurface;
      }
    } else {
      switch (elevation) {
        case 1:
          return Color(0xFFF7F2FA);
        case 2:
          return Color(0xFFF3EDF7);
        case 3:
          return Color(0xFFEEE8F4);
        case 4:
          return Color(0xFFECE6F2);
        case 5:
          return Color(0xFFE9E3EF);
        default:
          return surface;
      }
    }
  }
}
