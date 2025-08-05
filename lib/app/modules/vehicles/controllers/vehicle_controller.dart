import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/usecases/vehicle_usecases.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/enums/fuel_type.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/controllers/base_controller.dart';
import '../../../core/extensions/string_extensions.dart';

/// Clean Architecture uyumlu Vehicle Controller
/// SOLID: Single Responsibility - Sadece UI state management ve business logic orchestration
/// SOLID: Dependency Inversion - Use case'lere bağımlı, concrete implementation'lara değil
/// BaseController: Standardized loading states ve execution patterns kullanır
class VehicleController extends BaseController {
  // Dependencies (Use Cases)
  late final CreateVehicleUseCase _createVehicleUseCase;
  late final GetAllVehiclesUseCase _getAllVehiclesUseCase;
  late final GetVehicleByIdUseCase _getVehicleByIdUseCase;
  late final WatchVehiclesUseCase _watchVehiclesUseCase;
  late final GetDefaultVehicleUseCase _getDefaultVehicleUseCase;
  late final GetVehiclesByTypeUseCase _getVehiclesByTypeUseCase;
  late final UpdateVehicleUseCase _updateVehicleUseCase;
  late final SetDefaultVehicleUseCase _setDefaultVehicleUseCase;
  late final DeleteVehicleUseCase _deleteVehicleUseCase;
  late final IsVehiclePlateUniqueUseCase _isVehiclePlateUniqueUseCase;

  // Reactive State Variables
  final _vehicles = <VehicleModel>[].obs;
  final _defaultVehicle = Rxn<VehicleModel>();
  final _selectedVehicle = Rxn<VehicleModel>();

  // Getters
  List<VehicleModel> get vehicles => _vehicles.toList();
  VehicleModel? get defaultVehicle => _defaultVehicle.value;
  VehicleModel? get selectedVehicle => _selectedVehicle.value;
  // Loading states BaseController'dan geliyor: isLoading, isCreating, isUpdating, isDeleting
  bool get hasVehicles => _vehicles.isNotEmpty;

  // Current user - Middleware kontrolü yaptığı için ! operatörü güvenli
  String get _currentUserId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    _initializeUseCases();
    _loadInitialData();
  }

  /// Use case dependency'lerini initialize et
  /// SOLID: Dependency Inversion - Interface'ler üzerinden dependency injection
  void _initializeUseCases() {
    _createVehicleUseCase = Get.find<CreateVehicleUseCase>();
    _getAllVehiclesUseCase = Get.find<GetAllVehiclesUseCase>();
    _getVehicleByIdUseCase = Get.find<GetVehicleByIdUseCase>();
    _watchVehiclesUseCase = Get.find<WatchVehiclesUseCase>();
    _getDefaultVehicleUseCase = Get.find<GetDefaultVehicleUseCase>();
    _getVehiclesByTypeUseCase = Get.find<GetVehiclesByTypeUseCase>();
    _updateVehicleUseCase = Get.find<UpdateVehicleUseCase>();
    _setDefaultVehicleUseCase = Get.find<SetDefaultVehicleUseCase>();
    _deleteVehicleUseCase = Get.find<DeleteVehicleUseCase>();
    _isVehiclePlateUniqueUseCase = Get.find<IsVehiclePlateUniqueUseCase>();
  }

  /// Initial data loading
  void _loadInitialData() {
    // Middleware userId kontrolü yaptığı için burada kontrol gerekli değil
    loadVehicles();
    loadDefaultVehicle();
  }

  // ============================================================================
  // VEHICLE OPERATIONS
  // ============================================================================

  /// Araçları yükle
  /// SOLID: Single Responsibility - Sadece araç yükleme logic'i
  Future<void> loadVehicles() async {
    // Middleware userId kontrolü yaptığı için burada gerekli değil

    await executeWithLoading(() async {
      final vehicles = await _getAllVehiclesUseCase(
        VehicleParams(userId: _currentUserId),
      );
      _vehicles.assignAll(vehicles);
    });
  }

  /// Default araç yükle
  Future<void> loadDefaultVehicle() async {
    // Middleware userId kontrolü yaptığı için burada gerekli değil

    try {
      final defaultVehicle = await _getDefaultVehicleUseCase(
        VehicleParams(userId: _currentUserId),
      );
      _defaultVehicle.value = defaultVehicle;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Load default vehicle error: $e');
      }
    }
  }

  /// Araçları gerçek zamanlı izle
  void watchVehicles() {
    // Middleware userId kontrolü yaptığı için burada gerekli değil

    _watchVehiclesUseCase(VehicleParams(userId: _currentUserId)).then((vehicleStream) {
      vehicleStream.listen((vehicles) {
        _vehicles.assignAll(vehicles);
        // Default araç listede yoksa güncelle
        if (defaultVehicle != null && !vehicles.any((v) => v.id == defaultVehicle!.id)) {
          _defaultVehicle.value = vehicles.firstWhereOrNull((v) => v.isDefault);
        }
      });
    });
  }

  /// Araç detayını yükle
  Future<VehicleModel?> getVehicleById(String vehicleId) async {
    try {
      return await _getVehicleByIdUseCase(
        VehicleParams(userId: _currentUserId, vehicleId: vehicleId),
      );
    } catch (e) {
      NotificationHelper.showError('Araç detayı yüklenirken hata oluştu');
      if (AppConstants.enableLogging) {
        print('🔥 Get vehicle by ID error: $e');
      }
      return null;
    }
  }

  /// Tipe göre araçları getir
  Future<List<VehicleModel>> getVehiclesByType(FuelType fuelType) async {
    // Middleware userId kontrolü yaptığı için burada gerekli değil

    try {
      return await _getVehiclesByTypeUseCase(
        VehicleParams(userId: _currentUserId, type: fuelType.value),
      );
    } catch (e) {
      NotificationHelper.showError('Araçlar yüklenirken hata oluştu');
      if (AppConstants.enableLogging) {
        print('🔥 Get vehicles by type error: $e');
      }
      return [];
    }
  }

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Yeni araç oluştur
  /// SOLID: Single Responsibility - Sadece araç oluşturma UI logic'i
  Future<bool> createVehicle({
    required String brand,
    required String model,
    required String plate,
    required FuelType fuelType,
    required double fuelConsumptionPer100Km,
    required double defaultFuelPricePerLitre,
  }) async {
    return await executeWithCreating(() async {
      final vehicle = VehicleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId,
        brand: brand.trim().titleCase,
        model: model.trim().titleCase,
        plate: plate.formatVehiclePlate,
        fuelType: fuelType,
        fuelConsumptionPer100Km: fuelConsumptionPer100Km,
        defaultFuelPricePerLitre: defaultFuelPricePerLitre,
      );

      await _createVehicleUseCase(
        VehicleParams(userId: _currentUserId, vehicle: vehicle),
      );

      NotificationHelper.showSuccess('Araç başarıyla eklendi');
      loadVehicles(); // Listeyi güncelle
      loadDefaultVehicle(); // Default araç güncelle
      return true;
    }, errorMessage: 'Araç oluşturulurken hata oluştu');
  }

  /// Araç güncelle
  Future<bool> updateVehicle({
    required String vehicleId,
    required String brand,
    required String model,
    required String plate,
    required FuelType fuelType,
    required double fuelConsumptionPer100Km,
    required double defaultFuelPricePerLitre,
  }) async {
    return await executeWithUpdating(() async {
      // Mevcut aracı bul
      final existingVehicle = vehicles.firstWhereOrNull((v) => v.id == vehicleId);
      if (existingVehicle == null) {
        throw Exception('Güncellenecek araç bulunamadı');
      }

      final updatedVehicle = existingVehicle.copyWith(
        brand: brand.trim().titleCase,
        model: model.trim().titleCase,
        plate: plate.formatVehiclePlate,
        fuelType: fuelType,
        fuelConsumptionPer100Km: fuelConsumptionPer100Km,
        defaultFuelPricePerLitre: defaultFuelPricePerLitre,
      );

      await _updateVehicleUseCase(
        VehicleParams(userId: _currentUserId, vehicle: updatedVehicle),
      );

      NotificationHelper.showSuccess('Araç başarıyla güncellendi');
      loadVehicles(); // Listeyi güncelle
      return true;
    }, errorMessage: 'Araç güncellenirken hata oluştu');
  }

  /// Araç sil
  Future<bool> deleteVehicle(String vehicleId) async {
    return await executeWithDeleting(() async {
      await _deleteVehicleUseCase(
        VehicleParams(userId: _currentUserId, vehicleId: vehicleId),
      );

      NotificationHelper.showSuccess('Araç başarıyla silindi');
      loadVehicles(); // Listeyi güncelle
      loadDefaultVehicle(); // Default araç güncelle
      return true;
    }, errorMessage: 'Araç silinirken hata oluştu');
  }

  /// Default araç ayarla
  Future<bool> setDefaultVehicle(String vehicleId) async {
    try {
      await _setDefaultVehicleUseCase(
        VehicleParams(userId: _currentUserId, vehicleId: vehicleId),
      );

      NotificationHelper.showSuccess('Varsayılan araç değiştirildi');
      loadVehicles(); // Listeyi güncelle
      loadDefaultVehicle(); // Default araç güncelle
      return true;
    } catch (e) {
      NotificationHelper.showError('Varsayılan araç ayarlanırken hata oluştu');
      if (AppConstants.enableLogging) {
        print('🔥 Set default vehicle error: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // VALIDATION METHODS
  // ============================================================================

  /// Plaka unique kontrolü
  Future<bool> isPlateUnique(String plate, {String? excludeVehicleId}) async {
    // Middleware userId kontrolü yaptığı için burada gerekli değil

    try {
      final formattedPlate = plate.formatVehiclePlate;
      final isUnique = await _isVehiclePlateUniqueUseCase(
        VehicleParams(userId: _currentUserId, plate: formattedPlate),
      );

      // Eğer mevcut araç güncelleniyor ise o aracın plakaları aynı olabilir
      if (!isUnique && excludeVehicleId != null) {
        final existingVehicle = vehicles.firstWhereOrNull((v) => v.id == excludeVehicleId);
        return existingVehicle?.plate == formattedPlate;
      }

      return isUnique;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Check plate unique error: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // UI HELPER METHODS
  // ============================================================================

  /// Araç seç
  void selectVehicle(VehicleModel? vehicle) {
    _selectedVehicle.value = vehicle;
  }

  /// Seçimi temizle
  void clearSelection() {
    _selectedVehicle.value = null;
  }

  /// Listeyi yenile
  Future<void> refreshVehicles() async {
    await loadVehicles();
    await loadDefaultVehicle();
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================
  // Custom execution methods artık gerekli değil - BaseController'dan geliyor
}
