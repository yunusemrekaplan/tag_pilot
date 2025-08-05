import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Core
import '../utils/app_constants.dart';
import '../theme/app_theme.dart';

// Routes
import '../../routes/app_pages.dart';
import '../../routes/app_routes.dart';

class TagPilotApp extends StatelessWidget {
  const TagPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // GetX configuration
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: DateTimeConstants.mediumAnimationDuration,

      // Localization
      locale: const Locale('tr', 'TR'),
      fallbackLocale: const Locale('tr', 'TR'),

      // Error handling
      unknownRoute: AppPages.unknownRoute,
    );
  }
}
