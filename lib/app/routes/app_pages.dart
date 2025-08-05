import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

// Middleware
import '../core/middleware/auth_middleware.dart';

// Authentication Module
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/email_verification_view.dart';

// Navigation Module
import '../modules/navigation/bindings/navigation_binding.dart';
import '../modules/navigation/views/main_navigation_view.dart';

// Dashboard Module
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';

// Vehicle Module
import '../modules/vehicles/bindings/vehicle_binding.dart';
import '../modules/vehicles/views/vehicle_list_view.dart';
import '../modules/vehicles/views/vehicle_form_view.dart';

// Session Module
import '../modules/sessions/bindings/session_binding.dart';
import '../modules/sessions/views/sessions_list_view.dart';
import '../modules/sessions/views/session_detail_view.dart';

// Ride Module
import '../modules/rides/bindings/ride_binding.dart';
import '../modules/rides/bindings/ride_form_binding.dart';
import '../modules/rides/views/ride_management_view.dart';
import '../modules/rides/views/ride_add_view.dart';

// Expense Module
import '../modules/expenses/bindings/expense_binding.dart';
import '../modules/expenses/views/expense_list_view.dart';
import '../modules/expenses/views/expense_add_view.dart';

// Reports Module
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_main_view.dart';

// Splash Module
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});
  @override
  Widget build(context) => const Scaffold(body: Center(child: Text('Forgot Password')));
}

// VehicleView artık gerçek Vehicle modülünde

// SessionView artık gerçek Session modülünde

// RideManagementView artık gerçek Ride modülünde
// ExpenseManagementView artık gerçek Expense modülünde

/// TAG-Pilot App Pages Configuration
/// GetX routing sistemi için sayfa tanımları
class AppPages {
  static List<GetPage> get pages => [
        // Splash
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashView(),
          binding: SplashBinding(),
          transition: Transition.fadeIn,
        ),

        // Authentication Pages (SOLID: Singleton kontrolü ile)
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginView(),
          binding: AuthBinding(),
          transition: Transition.fadeIn,
        ),

        GetPage(
          name: AppRoutes.register,
          page: () => const RegisterView(),
          binding: AuthBinding(),
          transition: Transition.rightToLeft,
        ),

        GetPage(
          name: AppRoutes.emailVerification,
          page: () => const EmailVerificationView(),
          binding: AuthBinding(),
          transition: Transition.fadeIn,
        ),

        GetPage(
          name: AppRoutes.forgotPassword,
          page: () => const ForgotPasswordView(),
          binding: AuthBinding(),
          transition: Transition.rightToLeft,
        ),

        // Main App Pages (Protected Routes)
        GetPage(
          name: AppRoutes.navigation,
          page: () => const MainNavigationView(),
          binding: NavigationBinding(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),

        GetPage(
          name: AppRoutes.dashboard,
          page: () => const DashboardView(),
          binding: DashboardBinding(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),

        // Vehicle Management (Protected Routes)
        GetPage(
          name: AppRoutes.vehicles,
          page: () => const VehicleListView(),
          binding: VehicleBinding(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),

        GetPage(
          name: AppRoutes.vehicleForm,
          page: () => const VehicleFormView(),
          binding: VehicleBinding(),
          transition: Transition.rightToLeft,
          middlewares: [AuthMiddleware()],
        ),

        // Session Management (Protected Routes)
        GetPage(
          name: AppRoutes.sessions,
          page: () => const SessionsListView(),
          binding: SessionBinding(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),

        GetPage(
          name: AppRoutes.sessionDetail,
          page: () => SessionDetailView(sessionId: Get.parameters['id'] ?? ''),
          binding: SessionBinding(),
          transition: Transition.rightToLeft,
          middlewares: [AuthMiddleware()],
        ),

        // Ride Management (Protected Routes)
        GetPage(
          name: AppRoutes.rides,
          page: () => const RideManagementView(),
          binding: RideBinding(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),

        // Ride Add Form (Protected Routes)
        GetPage(
          name: AppRoutes.rideAdd,
          page: () => const RideAddView(),
          binding: RideFormBinding(),
          transition: Transition.rightToLeft,
          middlewares: [AuthMiddleware()],
        ),

        // Expense Management (Protected Routes)
        GetPage(
          name: AppRoutes.expenses,
          page: () => const ExpenseListView(),
          binding: ExpenseBinding(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),

        // Expense Add Form (Protected Routes)
        GetPage(
          name: AppRoutes.expenseAdd,
          page: () => const ExpenseAddView(),
          binding: ExpenseBinding(),
          transition: Transition.rightToLeft,
          middlewares: [AuthMiddleware()],
        ),

        // Reports Module (Protected Routes)
        GetPage(
          name: AppRoutes.reports,
          page: () => const ReportsMainView(),
          binding: ReportsBinding(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),
      ];

  /// 404 Page (Unknown Route)
  static GetPage get unknownRoute => GetPage(
        name: AppRoutes.notFound,
        page: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64),
                SizedBox(height: 16),
                Text('Sayfa Bulunamadı', style: TextStyle(fontSize: 24)),
                SizedBox(height: 8),
                Text('404 - Page Not Found'),
              ],
            ),
          ),
        ),
      );
}
