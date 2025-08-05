import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase Options
import 'app/core/utils/app_constants.dart';
import 'firebase_options.dart';

// Core
import 'app/core/bindings/core_binding.dart';
import 'app/core/theme/app_theme.dart';

// Routes
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  runApp(const TagPilotApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (AppConstants.enableLogging) {
      print('🔥 Firebase initialized successfully');
    }

    // Initialize core bindings (Firebase, Notification services)
    CoreBinding().dependencies();

    if (AppConstants.enableLogging) {
      print('✅ All services initialized');
    }
  } catch (e) {
    if (AppConstants.enableLogging) {
      print('❌ Service initialization error: $e');
    }
    rethrow;
  }
}

class TagPilotApp extends StatelessWidget {
  const TagPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration - Artık theme klasöründen
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // GetX configuration
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: DateTimeConstants.mediumAnimationDuration,

      // Localization (will be expanded later)
      locale: const Locale('tr', 'TR'),
      fallbackLocale: const Locale('tr', 'TR'),

      // Error handling
      unknownRoute: AppPages.unknownRoute,
    );
  }
}
