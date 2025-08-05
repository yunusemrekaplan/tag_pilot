import 'package:firebase_core/firebase_core.dart';

// Core
import '../utils/app_constants.dart';
import '../bindings/core_binding.dart';

// Firebase Options
import '../../../firebase_options.dart';

class AppInitializationService {
  static Future<void> initializeServices() async {
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
}
