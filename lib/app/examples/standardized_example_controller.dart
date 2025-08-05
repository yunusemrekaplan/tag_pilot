/*import 'package:get/get.dart';
import '../core/controllers/base_controller.dart';
import '../core/utils/form_validator.dart';
import '../core/extensions/string_extensions.dart';
import '../core/extensions/datetime_extensions.dart';
import '../core/utils/app_constants.dart';
import '../data/models/vehicle_model.dart';
import '../data/enums/fuel_type.dart';

/// Standardized Example Controller
/// Yeni utility class'ların nasıl kullanılacağını gösteren örnek
class StandardizedExampleController extends BaseController {
  // ============================================================================
  // FORM VALIDATION ÖRNEKLERI
  // ============================================================================

  /// Email validation örneği
  String? validateEmailField(String? value) {
    // Artık FormValidator kullanıyoruz
    return FormValidator.validateEmail(value);
  }

  /// Şifre validation örneği
  String? validatePasswordField(String? value) {
    return FormValidator.validatePassword(value);
  }

  /// Araç plaka validation örneği
  String? validatePlateField(String? value) {
    return FormValidator.validateVehiclePlate(value);
  }

  /// Composite validation örneği
  String? validateNameField(String? value) {
    return FormValidator.combineValidators(value, [
      (val) => FormValidator.validateRequired(val, 'İsim'),
      (val) => FormValidator.validateMinLength(val, 2, 'İsim'),
      (val) => FormValidator.validateMaxLength(val, 50, 'İsim'),
    ]);
  }

  // ============================================================================
  // STRING EXTENSIONS ÖRNEKLERI
  // ============================================================================

  void demonstrateStringExtensions() {
    final email = "test@example.com";
    final phone = "05551234567";
    final plate = "34abc123";

    // Validation extensions
    print('Email valid: ${email.isValidEmail}'); // true
    print('Phone valid: ${phone.isValidPhone}'); // true
    print('Plate valid: ${plate.isValidVehiclePlate}'); // false (küçük harf)

    // Formatting extensions
    print('Formatted phone: ${phone.formatPhone}'); // 0555 123 45 67
    print('Formatted plate: ${plate.formatVehiclePlate}'); // 34 ABC 123
    print('Title case: ${"mehmet ali".titleCase}'); // Mehmet Ali

    // Cleaning extensions
    print('Numbers only: ${"abc123def".numbersOnly}'); // 123
    print('Letters only: ${"abc123def".lettersOnly}'); // abcdef

    // Turkish specific
    print('English chars: ${"çğışü".toEnglishChars}'); // cgisu
  }

  // ============================================================================
  // DATETIME EXTENSIONS ÖRNEKLERI
  // ============================================================================

  void demonstrateDateTimeExtensions() {
    final now = DateTime.now();
    final birthday = DateTime(1990, 5, 15);

    // Formatting extensions
    print('Turkish date: ${now.toTurkishDate}'); // 15/03/2024
    print('Turkish long: ${now.turkishLongFormat}'); // 15 Mart 2024 Cuma
    print('Relative time: ${birthday.toRelativeTime}'); // 34 yıl önce

    // Manipulation extensions
    print('Start of week: ${now.startOfWeek.toTurkishDate}');
    print('End of month: ${now.endOfMonth.toTurkishDate}');
    print('Next month: ${now.addMonths(1).toTurkishDate}');

    // Comparison extensions
    print('Is today: ${now.isToday}'); // true
    print('Is weekend: ${now.isWeekend}'); // depends on current day
    print('Days between: ${now.daysBetween(birthday)}'); // ~12400

    // Business logic
    print('Working hours: ${now.isWorkingHours}'); // depends on time
    print('Age calculation: ${now.ageFrom(birthday)}'); // 34
  }

  // ============================================================================
  // BASE CONTROLLER EXECUTION PATTERNS ÖRNEKLERI
  // ============================================================================

  /// Loading state ile veri yükleme örneği
  Future<List<VehicleModel>> loadVehiclesExample() async {
    return executeWithLoading(
      () async {
        // Simulate API call
        await Future.delayed(Duration(seconds: 2));

        // Return dummy data
        return [
          VehicleModel(
            id: '1',
            userId: 'user1',
            brand: 'Toyota',
            model: 'Corolla',
            plate: '34ABC123',
            fuelType: FuelType.petrol,
            avgFuelPerKm: 0.08,
            fuelPricePerLitre: 25.0,
          ),
        ];
      },
      errorMessage: 'Araçlar yüklenirken hata oluştu',
    );
  }

  /// Creating state ile yeni veri oluşturma örneği
  Future<bool> createVehicleExample(VehicleModel vehicle) async {
    return executeWithCreating(
      () async {
        // Simulate API call
        await Future.delayed(Duration(seconds: 1));

        // Business logic here
        if (vehicle.plate.isEmpty) {
          throw Exception('Plaka boş olamaz');
        }

        return true;
      },
      successMessage: 'Araç başarıyla eklendi',
      errorMessage: 'Araç eklenirken hata oluştu',
    );
  }

  /// Safe execution örneği (hata durumunda null döner)
  Future<VehicleModel?> getVehicleSafelyExample(String id) async {
    return executeSafely(
      () async {
        // Simulate API call that might fail
        await Future.delayed(Duration(milliseconds: 500));

        if (id.isEmpty) {
          throw Exception('ID gerekli');
        }

        // Return dummy vehicle
        return VehicleModel(
          id: id,
          userId: 'user1',
          brand: 'Honda',
          model: 'Civic',
          plate: '06DEF789',
          fuelType: FuelType.petrol,
          avgFuelPerKm: 0.07,
          fuelPricePerLitre: 25.5,
        );
      },
      logError: false, // Silent error
    );
  }

  // ============================================================================
  // CONSTANTS KULLANIM ÖRNEKLERİ
  // ============================================================================

  void demonstrateConstants() {
    // Organized constants kullanımı
    print('App name: ${AppConstants.appName}');
    print('Max distance: ${BusinessConstants.maxDistance}');
    print('Default padding: ${UIConstants.defaultPadding}');
    print('Error message: ${MessageConstants.errorNetwork}');
    print('Currency: ${CurrencyConstants.currencySymbol}');

    // Database collections
    print('Users collection: ${DatabaseConstants.usersCollection}');
    print('Vehicles collection: ${DatabaseConstants.vehiclesCollection}');

    // Routes
    print('Login route: ${RouteConstants.login}');
    print('Dashboard route: ${RouteConstants.dashboard}');

    // Validation limits
    print('Min password: ${ValidationConstants.minPasswordLength}');
    print('Max description: ${ValidationConstants.maxDescriptionLength}');
  }

  // ============================================================================
  // FORM HANDLING ÖRNEĞİ
  // ============================================================================

  /// Comprehensive form validation örneği
  Map<String, String?> validateVehicleForm({
    required String brand,
    required String model,
    required String plate,
    required String fuelRate,
    required String fuelPrice,
  }) {
    final errors = <String, String?>{};

    // Brand validation
    errors['brand'] = FormValidator.validateVehicleBrand(brand);

    // Model validation
    errors['model'] = FormValidator.validateVehicleModel(model);

    // Plate validation with formatting
    final formattedPlate = plate.toUpperCase().removeSpecialChars;
    errors['plate'] = FormValidator.validateVehiclePlate(formattedPlate);

    // Fuel rate validation
    errors['fuelRate'] = FormValidator.validateFuelRate(fuelRate);

    // Fuel price validation
    errors['fuelPrice'] = FormValidator.validateFuelPrice(fuelPrice);

    // Remove null errors
    errors.removeWhere((key, value) => value == null);

    return errors;
  }

  // ============================================================================
  // COMPLETE WORKFLOW ÖRNEĞI
  // ============================================================================

  /// Tam bir workflow örneği (validation + formatting + execution)
  Future<bool> completeVehicleWorkflowExample({
    required String brand,
    required String model,
    required String plate,
    required String fuelRate,
    required String fuelPrice,
  }) async {
    return executeWithCreating(
      () async {
        // 1. Form validation
        final errors = validateVehicleForm(
          brand: brand,
          model: model,
          plate: plate,
          fuelRate: fuelRate,
          fuelPrice: fuelPrice,
        );

        if (errors.isNotEmpty) {
          throw Exception('Form hataları: ${errors.values.join(', ')}');
        }

        // 2. Data formatting
        final formattedPlate = plate.formatVehiclePlate;
        final formattedBrand = brand.titleCase;
        final formattedModel = model.titleCase;

        // 3. Create vehicle model
        final vehicle = VehicleModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user_id', // Get from auth service
          brand: formattedBrand,
          model: formattedModel,
          plate: formattedPlate,
          fuelType: FuelType.petrol,
          avgFuelPerKm:
              fuelRate.toDoubleOrNull ?? BusinessConstants.defaultFuelRate,
          fuelPricePerLitre:
              fuelPrice.toDoubleOrNull ?? BusinessConstants.defaultFuelPrice,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 4. Save to database (simulated)
        await Future.delayed(Duration(seconds: 1));

        // 5. Log success with timestamp
        print('Vehicle created at: ${DateTime.now().toTurkishDateTime}');

        return true;
      },
      successMessage: 'Araç başarıyla kaydedildi',
      errorMessage: 'Araç kaydedilirken hata oluştu',
    );
  }

  @override
  void onInit() {
    super.onInit();

    // Demonstrate new utilities
    demonstrateStringExtensions();
    demonstrateDateTimeExtensions();
    demonstrateConstants();
  }
}
*/
