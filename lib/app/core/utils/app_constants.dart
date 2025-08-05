/// App Constants - Reorganized and Categorized
/// SOLID: Single Responsibility - Her kategori kendi sorumluluğunu taşır
class AppConstants {
  AppConstants._(); // Private constructor

  // ============================================================================
  // APP INFO
  // ============================================================================
  static const String appName = 'TAG Pilot';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Taksi Şoförü Kâr Yönetim Uygulaması';

  // Environment
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableCrashlytics = false;
}

/// Database Related Constants
class DatabaseConstants {
  DatabaseConstants._();

  // Collection Names
  static const String usersCollection = 'users';
  static const String vehiclesCollection = 'vehicles';
  static const String packagesCollection = 'packages';
  static const String sessionsCollection = 'sessions';
  static const String ridesCollection = 'rides';
  static const String expensesCollection = 'expenses';
  static const String preferencesCollection = 'preferences';

  // Field Names
  static const String idField = 'id';
  static const String userIdField = 'userId';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String deletedAtField = 'deletedAt';
  static const String isActiveField = 'isActive';
  static const String isDefaultField = 'isDefault';
}

/// Storage Related Constants
class StorageConstants {
  StorageConstants._();

  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keySelectedVehicleId = 'selected_vehicle_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyOnboardingCompleted = 'onboarding_completed';
}

/// Date and Time Constants
class DateTimeConstants {
  DateTimeConstants._();

  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String isoDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(minutes: 5);
}

/// Business Logic Constants
class BusinessConstants {
  BusinessConstants._();

  // Vehicle Constants
  static const double defaultFuelRate = 0.08; // L/km
  static const double defaultFuelPrice = 25.0; // TL/L
  static const double minFuelRate = 0.01;
  static const double maxFuelRate = 1.0;
  static const double minFuelPrice = 1.0;
  static const double maxFuelPrice = 100.0;

  // Session Constants
  static const int maxSessionHours = 24;
  static const int minBreakMinutes = 15;
  static const int sessionTimeoutMinutes = 30;
  static const int maxSessionDurationHours = 24;
  static const int maxBreakDurationMinutes = 120;

  // Financial Constants
  static const double breakEvenThreshold = 0.0;
  static const double minAmount = 0.01;
  static const double maxDistance = 1000.0; // km
  static const double maxEarnings = 10000.0; // TL
  static const double maxExpenseAmount = 5000.0; // TL
  static const double taxRate = 0.18; // %18 KDV

  // Limits
  static const int vehiclesLimit = 10;
  static const int packagesLimit = 50;
  static const int sessionsLimit = 1000;
  static const int ridesPerSessionLimit = 100;
  static const int expensesLimit = 1000;
}

/// Validation Constants
class ValidationConstants {
  ValidationConstants._();

  // Text Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 200;
  static const int maxCommentLength = 500;

  // Business Validation
  static const int minAge = 18;
  static const int maxAge = 80;
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // File Size Limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
}

/// TAG-Pilot App Constants
/// UI boyutları, animasyonlar ve responsive tasarım parametreleri
class UIConstants {
  UIConstants._();

  // Padding & Margin
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border Radius
  static const double smallBorderRadius = 8.0;
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 20.0;
  static const double maxBorderRadius = 24.0;

  // Button Heights
  static const double minButtonHeight = 44.0;
  static const double defaultButtonHeight = 48.0;
  static const double maxButtonHeight = 56.0;

  // Card Properties
  static const double cardElevation = 2.0;
  static const double maxCardElevation = 8.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Icon Sizes
  static const double smallIcon = 16.0;
  static const double defaultIcon = 24.0;
  static const double largeIcon = 32.0;
  static const double extraLargeIcon = 48.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Grid Layout
  static const int mobileColumns = 1;
  static const int tabletColumns = 2;
  static const int desktopColumns = 4;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
}

/// Currency Constants
class CurrencyConstants {
  CurrencyConstants._();

  static const String currencySymbol = '₺';
  static const String currencyCode = 'TRY';
  static const String currencyName = 'Turkish Lira';
  static const int decimalPlaces = 2;
}

/// Message Constants
class MessageConstants {
  MessageConstants._();

  // Error Messages
  static const String errorGeneral = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorNetwork = 'İnternet bağlantınızı kontrol edin.';
  static const String errorAuth = 'Kimlik doğrulama hatası.';
  static const String errorNotFound = 'İstenen veri bulunamadı.';
  static const String errorPermission = 'Yetkiniz bulunmuyor.';
  static const String errorValidation = 'Lütfen tüm alanları doğru doldurun.';
  static const String errorTimeout = 'İşlem zaman aşımına uğradı.';
  static const String errorOffline = 'İnternet bağlantısı bulunamadı.';

  // Success Messages
  static const String successSaved = 'Başarıyla kaydedildi.';
  static const String successUpdated = 'Başarıyla güncellendi.';
  static const String successDeleted = 'Başarıyla silindi.';
  static const String successLogin = 'Giriş başarılı.';
  static const String successLogout = 'Çıkış başarılı.';
  static const String successEmailSent = 'E-posta gönderildi.';

  // Info Messages
  static const String infoLoading = 'Yükleniyor...';
  static const String infoSaving = 'Kaydediliyor...';
  static const String infoDeleting = 'Siliniyor...';
  static const String infoUpdating = 'Güncelleniyor...';
  static const String infoProcessing = 'İşleniyor...';

  // Warning Messages
  static const String warningUnsavedChanges =
      'Kaydedilmemiş değişiklikler var.';
  static const String warningDeleteConfirm = 'Bu işlem geri alınamaz.';
  static const String warningOfflineMode = 'Çevrimdışı modda çalışıyorsunuz.';
}

/// Asset Constants
class AssetConstants {
  AssetConstants._();

  // Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String fontsPath = 'assets/fonts/';
  static const String animationsPath = 'assets/animations/';

  // Images
  static const String logoPath = '${imagesPath}logo.png';
  static const String placeholderPath = '${imagesPath}placeholder.png';
  static const String backgroundPath = '${imagesPath}background.png';
  static const String avatarPlaceholder = '${imagesPath}avatar_placeholder.png';

  // Icons
  static const String googleIcon = '${iconsPath}google.png';
  static const String appleIcon = '${iconsPath}apple.png';

  // Fonts
  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'Inter';
}

/// Route Constants
class RouteConstants {
  RouteConstants._();

  // Auth Routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';

  // Main Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String navigation = '/navigation';

  // Feature Routes
  static const String vehicles = '/vehicles';
  static const String packages = '/packages';
  static const String sessions = '/sessions';
  static const String rides = '/rides';
  static const String expenses = '/expenses';
  static const String reports = '/reports';
  static const String analytics = '/analytics';

  // Settings Routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String about = '/about';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
}

/// Session Status Constants
class SessionStatusConstants {
  SessionStatusConstants._();

  static const String active = 'active';
  static const String completed = 'completed';
  static const String paused = 'paused';
  static const String cancelled = 'cancelled';
}

/// Notification Constants
class NotificationConstants {
  NotificationConstants._();

  // Channel IDs
  static const String breakEvenChannelId = 'break_even_channel';
  static const String reminderChannelId = 'reminder_channel';
  static const String alertChannelId = 'alert_channel';

  // Channel Names
  static const String breakEvenChannelName = 'Başabaş Bildirimleri';
  static const String reminderChannelName = 'Hatırlatma Bildirimleri';
  static const String alertChannelName = 'Uyarı Bildirimleri';

  // Channel Descriptions
  static const String breakEvenChannelDescription =
      'Günlük başabaş noktası bildirimleri';
  static const String reminderChannelDescription =
      'Genel hatırlatma bildirimleri';
  static const String alertChannelDescription = 'Önemli uyarı bildirimleri';
}

/// Chart Constants
class ChartConstants {
  ChartConstants._();

  // Material 3 compatible colors
  static const List<String> chartColors = [
    '#6750A4', // Primary
    '#625B71', // Secondary
    '#7D5260', // Tertiary
    '#6F7976', // Surface variant
    '#B93C5D', // Error variant
    '#386A20', // Success green
    '#8C5000', // Warning orange
    '#1976D2', // Blue
    '#388E3C', // Green
    '#F57C00', // Orange
    '#7B1FA2', // Purple
    '#C2185B', // Pink
  ];

  // Chart Settings
  static const double chartHeight = 200.0;
  static const double pieChartRadius = 100.0;
  static const double barChartMaxHeight = 150.0;
}

/// Environment Constants
class Environment {
  Environment._();

  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  static const String current = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: development,
  );

  static bool get isDevelopment => current == development;
  static bool get isStaging => current == staging;
  static bool get isProduction => current == production;
}

/// RegEx Patterns
class AppRegex {
  AppRegex._();

  static RegExp email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static RegExp phoneNumber =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  static RegExp turkishPhone = RegExp(r'^(\+90|0)?[1-9][0-9]{9}$');
  static RegExp numbers = RegExp(r'^[0-9]+$');
  static RegExp decimal = RegExp(r'^[0-9]+\.?[0-9]*$');
  static RegExp vehiclePlate = RegExp(r'^[0-9]{2}[A-Z]{1,3}[0-9]{1,4}$');
  static RegExp password =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$');
  static RegExp turkishChars = RegExp(r'[çğıöşüÇĞIÖŞÜ]');
  static RegExp onlyLetters = RegExp(r'^[a-zA-ZçğıöşüÇĞIÖŞÜ\s]+$');
  static RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9çğıöşüÇĞIÖŞÜ]+$');
}

/// API Constants
class ApiConstants {
  ApiConstants._();

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
}

/// Cache Constants
class CacheConstants {
  CacheConstants._();

  // Cache Keys
  static const String userDataKey = 'user_data';
  static const String dashboardStatsKey = 'dashboard_stats';
  static const String vehiclesKey = 'vehicles';
  static const String packagesKey = 'packages';
  static const String sessionsKey = 'sessions';

  // Cache Durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(minutes: 30);
  static const Duration longCacheDuration = Duration(hours: 2);
  static const Duration dayCache = Duration(days: 1);
}

// Backward compatibility için eski constants'ları expose et
class AppConstants_Legacy {
  // Core constants'ları expose et
  static const String appName = AppConstants.appName;
  static const String appVersion = AppConstants.appVersion;
  static const bool enableLogging = AppConstants.enableLogging;

  // Database
  static const String usersCollection = DatabaseConstants.usersCollection;
  static const String vehiclesCollection = DatabaseConstants.vehiclesCollection;
  static const String packagesCollection = DatabaseConstants.packagesCollection;
  static const String sessionsCollection = DatabaseConstants.sessionsCollection;
  static const String ridesCollection = DatabaseConstants.ridesCollection;
  static const String expensesCollection = DatabaseConstants.expensesCollection;

  // UI
  static const double defaultPadding = UIConstants.defaultPadding;
  static const double defaultBorderRadius = UIConstants.defaultBorderRadius;

  // Business
  static const double defaultFuelRate = BusinessConstants.defaultFuelRate;
  static const double maxDistance = BusinessConstants.maxDistance;
  static const int minPasswordLength = ValidationConstants.minPasswordLength;

  // Messages
  static const String errorGeneral = MessageConstants.errorGeneral;
  static const String errorNetwork = MessageConstants.errorNetwork;
  static const String successSaved = MessageConstants.successSaved;

  // Currency
  static const String currencySymbol = CurrencyConstants.currencySymbol;

  // Routes
  static const String login = RouteConstants.login;
  static const String dashboard = RouteConstants.dashboard;
}
