import 'package:get/get.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/error_handler_service.dart';
import '../models/vehicle_model.dart';

/// Vehicle Repository Implementation (Clean Architecture)
/// SOLID: Dependency Inversion - VehicleRepository interface'ini implement eder
/// SOLID: Single Responsibility - Sadece vehicle data operations
class VehicleRepositoryImpl implements VehicleRepository {
  late final DatabaseService _databaseService;
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;

  VehicleRepositoryImpl() {
    _databaseService = Get.find<DatabaseService>();
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
  }

  // Middleware kontrolü yaptığı için ! operatörü güvenli
  String get _userId => _authService.currentUserId!;

  // ============================================================================
  // CREATE OPERATIONS
  // ============================================================================

  @override
  Future<void> createVehicle(VehicleModel vehicle) async {
    try {
      final vehicleWithTimestamp = vehicle.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.setDocument(
        '${DatabaseConstants.usersCollection}/${vehicle.userId}/${DatabaseConstants.vehiclesCollection}/${vehicle.id}',
        vehicleWithTimestamp.toJson(),
      );

      if (AppConstants.enableLogging) {
        print('🚗 Vehicle created: ${vehicle.id}');
      }
    } catch (e) {
      _errorHandler.logError('Create vehicle', e);
      throw Exception('Araç oluşturulurken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  @override
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final querySnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}',
      );

      return querySnapshot.docs
          .map((doc) => VehicleModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Get all vehicles', e);
      throw Exception('Araçlar yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<VehicleModel?> getVehicleById(String vehicleId) async {
    try {
      final doc = await _databaseService.getDocumentById(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}/$vehicleId',
      );

      if (doc.exists && doc.data() != null) {
        return VehicleModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }

      return null;
    } catch (e) {
      _errorHandler.logError('Get vehicle by ID', e);
      throw Exception('Araç yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Stream<List<VehicleModel>> watchVehicles() {
    try {
      return _databaseService
          .watchCollection('${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}')
          .map((snapshot) => snapshot.docs
              .map((doc) => VehicleModel.fromJson({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  }))
              .toList());
    } catch (e) {
      _errorHandler.logError('Watch vehicles', e);
      throw Exception('Araç dinleme hatası: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<VehicleModel?> getDefaultVehicle() async {
    try {
      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}',
        'isDefault',
        true,
      );

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return VehicleModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }

      return null;
    } catch (e) {
      _errorHandler.logError('Get default vehicle', e);
      throw Exception('Varsayılan araç yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<bool> hasDefaultVehicle() async {
    try {
      final defaultVehicle = await getDefaultVehicle();
      return defaultVehicle != null;
    } catch (e) {
      _errorHandler.logError('Check default vehicle exists', e);
      return false; // Hata durumunda false döndür
    }
  }

  @override
  Future<List<VehicleModel>> getVehiclesByType(String type) async {
    try {
      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}',
        'fuelType',
        type,
      );

      return querySnapshot.docs
          .map((doc) => VehicleModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Get vehicles by type', e);
      throw Exception('Tipe göre araçlar yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // UPDATE OPERATIONS
  // ============================================================================

  @override
  Future<void> updateVehicle(VehicleModel vehicle) async {
    try {
      final vehicleWithTimestamp = vehicle.copyWith(
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateDocument(
        '${DatabaseConstants.usersCollection}/${vehicle.userId}/${DatabaseConstants.vehiclesCollection}/${vehicle.id}',
        vehicleWithTimestamp.toJson(),
      );

      if (AppConstants.enableLogging) {
        print('🚗 Vehicle updated: ${vehicle.id}');
      }
    } catch (e) {
      _errorHandler.logError('Update vehicle', e);
      throw Exception('Araç güncellenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> setDefaultVehicle(String vehicleId) async {
    try {
      final batch = _databaseService.getBatch();

      // Önce tüm araçların default flag'ini false yap
      final allVehiclesSnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}',
      );

      for (final doc in allVehiclesSnapshot.docs) {
        final docRef = _databaseService.getDocument(
          '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}/${doc.id}',
        );
        batch.update(docRef, {
          'isDefault': false,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      // Seçilen aracı default yap
      final vehicleRef = _databaseService.getDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}/$vehicleId',
      );

      batch.update(vehicleRef, {
        'isDefault': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await _databaseService.commitBatch(batch);

      if (AppConstants.enableLogging) {
        print('🚗 Default vehicle set: $vehicleId');
      }
    } catch (e) {
      _errorHandler.logError('Set default vehicle', e);
      throw Exception('Varsayılan araç ayarlanırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _databaseService.deleteDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}/$vehicleId',
      );

      if (AppConstants.enableLogging) {
        print('🚗 Vehicle deleted: $vehicleId');
      }
    } catch (e) {
      _errorHandler.logError('Delete vehicle', e);
      throw Exception('Araç silinirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> deleteAllUserVehicles() async {
    try {
      final batch = _databaseService.getBatch();

      final vehiclesSnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}',
      );

      for (final doc in vehiclesSnapshot.docs) {
        final docRef = _databaseService.getDocument(
          '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}/${doc.id}',
        );
        batch.delete(docRef);
      }

      await _databaseService.commitBatch(batch);

      if (AppConstants.enableLogging) {
        print('🚗 All user vehicles deleted for: $_userId');
      }
    } catch (e) {
      _errorHandler.logError('Delete all user vehicles', e);
      throw Exception('Tüm araçlar silinirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // BUSINESS LOGIC OPERATIONS
  // ============================================================================

  @override
  Future<bool> isVehiclePlateUnique(String plate) async {
    try {
      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.vehiclesCollection}',
        'plate',
        plate,
      );

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      _errorHandler.logError('Check plate unique', e);
      throw Exception('Plaka kontrolü yapılırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<double> calculateTotalFuelCost(DateTime startDate, DateTime endDate) async {
    try {
      // Bu method için ride'lar ve expense'lar gerekli
      // Şimdilik placeholder implementation
      // İleriki fazlarda ride ve expense modülleri tamamlandığında implement edilecek

      if (AppConstants.enableLogging) {
        print('🚗 Calculate fuel cost from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      }

      // TODO: Implement after ride and expense modules
      return 0.0;
    } catch (e) {
      _errorHandler.logError('Calculate fuel cost', e);
      throw Exception('Yakıt maliyeti hesaplanırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }
}
