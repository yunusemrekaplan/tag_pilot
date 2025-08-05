import 'package:get/get.dart';

// Domain Services (Interfaces) - Critical Infrastructure Only
import '../../domain/services/database_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/error_handler_service.dart';

// Infrastructure Services (Implementations) - Critical Only
import '../../infrastructure/services/firestore_service_impl.dart';
import '../../infrastructure/services/firebase_auth_service_impl.dart';
import '../../infrastructure/services/error_handler_service_impl.dart';

// Core Navigation Service (Critical for Auth Routing)
import '../services/navigation_service.dart';

// Utils
import '../utils/app_constants.dart';

/// Core Binding - Clean Architecture compliant
/// SOLID: Single Responsibility - Sadece kritik infrastructure servislerden sorumlu
/// SOLID: Dependency Inversion - Interface'lere dependency injection
/// Bu binding sadece uygulama başlatılması için ZORUNLU olan servisleri içerir
class CoreBinding extends Bindings {
  @override
  void dependencies() {
    // ============================================================================
    // CRITICAL INFRASTRUCTURE SERVICES (Required for App Bootstrap)
    // ============================================================================

    // Database Service (Firestore implementation) - Firebase bağlantısı için kritik
    Get.put<DatabaseService>(
      FirestoreDatabaseService(),
      permanent: true,
    );

    // Auth Service (Firebase implementation) - Authentication için kritik
    Get.put<AuthService>(
      FirebaseAuthServiceImpl(),
      permanent: true,
    );

    // Error Handler Service - Hata yönetimi için kritik
    Get.put<ErrorHandlerService>(
      ErrorHandlerServiceImpl(),
      permanent: true,
    );

    // Navigation Service - Auth state routing için kritik
    // Vehicle dependency'si ApplicationBinding'de çözülecek
    Get.put<NavigationService>(
      NavigationService(),
      permanent: true,
    );

    if (AppConstants.enableLogging) {
      print('✅ Core infrastructure services initialized');
    }
  }
}
