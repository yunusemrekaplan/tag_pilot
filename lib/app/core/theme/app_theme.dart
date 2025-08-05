import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import 'app_colors.dart';

/// TAG-Pilot uygulaması için tema konfigürasyonları
class AppTheme {
  AppTheme._();

  /// Light tema konfigürasyonu
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: UIConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        ),
        color: AppColors.surface,
        shadowColor: AppColors.outline.withOpacity(0.1),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, UIConstants.maxButtonHeight),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(UIConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, UIConstants.maxButtonHeight),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(UIConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 4,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.all(UIConstants.defaultPadding),
        filled: true,
        fillColor: AppColors.surface,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.secondary,
        disabledColor: AppColors.outline.withOpacity(0.3),
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        secondaryLabelStyle: const TextStyle(color: AppColors.onSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Typography
      fontFamily: 'Roboto',
      textTheme: _buildTextTheme(false),
    );
  }

  /// Dark tema konfigürasyonu
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        secondaryContainer: AppColors.darkSecondaryContainer,
        onSecondaryContainer: AppColors.darkOnSecondaryContainer,
        tertiary: AppColors.darkTertiary,
        onTertiary: AppColors.darkOnTertiary,
        tertiaryContainer: AppColors.darkTertiaryContainer,
        onTertiaryContainer: AppColors.darkOnTertiaryContainer,
        error: AppColors.darkError,
        onError: AppColors.darkOnError,
        errorContainer: AppColors.darkErrorContainer,
        onErrorContainer: AppColors.darkOnErrorContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceVariant: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkOnBackground,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: UIConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        ),
        color: AppColors.darkSurface,
        shadowColor: AppColors.darkOutline.withOpacity(0.1),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, UIConstants.maxButtonHeight),
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 2,
          shadowColor: AppColors.darkPrimary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(UIConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, UIConstants.maxButtonHeight),
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(UIConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkSecondary,
        foregroundColor: AppColors.darkOnSecondary,
        elevation: 4,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.darkError),
        ),
        contentPadding: const EdgeInsets.all(UIConstants.defaultPadding),
        filled: true,
        fillColor: AppColors.darkSurface,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.darkSecondary,
        disabledColor: AppColors.darkOutline.withOpacity(0.3),
        labelStyle: const TextStyle(color: AppColors.darkOnSurfaceVariant),
        secondaryLabelStyle: const TextStyle(color: AppColors.darkOnSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkSecondary,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Typography
      fontFamily: 'Roboto',
      textTheme: _buildTextTheme(true),
    );
  }

  /// Text tema oluşturucu
  static TextTheme _buildTextTheme(bool isDark) {
    final Color textColor =
        isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final Color secondaryTextColor =
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
          fontSize: 57, fontWeight: FontWeight.w400, color: textColor),
      displayMedium: TextStyle(
          fontSize: 45, fontWeight: FontWeight.w400, color: textColor),
      displaySmall: TextStyle(
          fontSize: 36, fontWeight: FontWeight.w400, color: textColor),

      // Headline styles
      headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w600, color: textColor),
      headlineMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w600, color: textColor),
      headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: textColor),

      // Title styles
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: textColor),

      // Body styles
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: secondaryTextColor),

      // Label styles
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
      labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
      labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500, color: secondaryTextColor),
    );
  }
}
