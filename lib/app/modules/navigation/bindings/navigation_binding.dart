import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';
import '../../dashboard/bindings/dashboard_binding.dart';
import '../../sessions/bindings/session_binding.dart';
import '../../expenses/bindings/expense_binding.dart';
import '../../reports/bindings/reports_binding.dart';

/// Navigation Binding
/// SOLID: Single Responsibility - Navigation ve related modül controller'ları
/// Core ve Application dependencies splash'ta yükleniyor
class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Module Controller'ları register et
    // Core ve Application dependencies ApplicationBinding'de hallediliyor

    // Dashboard Controller (main navigation için gerekli)
    DashboardBinding().dependencies();

    // Session Controller (session management için gerekli)
    SessionBinding().dependencies();

    // Expense Controller (expense management için gerekli)
    ExpenseBinding().dependencies();

    // Reports Controller (reports management için gerekli)
    ReportsBinding().dependencies();

    // Navigation Controller
    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );
  }
}
