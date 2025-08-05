abstract class AppRoutes {
  // Authentication routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerification = '/email-verification';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String navigation = '/navigation';

  // Feature routes
  static const String vehicles = '/vehicles';
  static const String vehicleDetail = '/vehicle-detail';
  static const String vehicleForm = '/vehicle-form';

  static const String packages = '/packages';
  static const String packageDetail = '/package-detail';
  static const String packageForm = '/package-form';

  static const String sessions = '/sessions';
  static const String sessionDetail = '/session-detail';
  static const String sessionForm = '/session-form';

  static const String rides = '/rides';
  static const String rideDetail = '/ride-detail';
  static const String rideForm = '/ride-form';
  static const String rideAdd = '/rides/add';

  static const String expenses = '/expenses';
  static const String expenseAdd = '/expenses/add';
  static const String expenseDetail = '/expense-detail';
  static const String expenseForm = '/expense-form';

  // Analytics & Reports
  static const String reports = '/reports';
  static const String analytics = '/analytics';

  // User & Settings
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';

  // Error
  static const String notFound = '/404';
}
