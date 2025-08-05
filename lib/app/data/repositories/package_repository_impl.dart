import 'package:get/get.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/repositories/package_repository.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/error_handler_service.dart';
import '../models/package_model.dart';
import '../enums/package_type.dart';

/// Package Repository Implementation (Clean Architecture)
/// SOLID: Dependency Inversion - PackageRepository interface'ini implement eder
/// SOLID: Single Responsibility - Sadece package data operations
class PackageRepositoryImpl implements PackageRepository {
  late final DatabaseService _databaseService;
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;

  PackageRepositoryImpl() {
    _databaseService = Get.find<DatabaseService>();
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
  }

  // Middleware kontrolü yaptığı için ! operatörü güvenli
  String get _userId => _authService.currentUserId!;

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  @override
  Future<List<PackageModel>> getAllPackages() async {
    try {
      final querySnapshot = await _databaseService.getDocuments(
        DatabaseConstants.packagesCollection,
      );

      return querySnapshot.docs
          .map((doc) => PackageModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Get all packages', e);
      throw Exception('Paketler yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<PackageModel?> getPackageById(String packageId) async {
    try {
      final doc = await _databaseService.getDocumentById(
        '${DatabaseConstants.packagesCollection}/$packageId',
      );

      if (doc.exists && doc.data() != null) {
        return PackageModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }

      return null;
    } catch (e) {
      _errorHandler.logError('Get package by ID', e);
      throw Exception('Paket yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Stream<List<PackageModel>> watchPackages() {
    try {
      return _databaseService.watchCollection(DatabaseConstants.packagesCollection).map((snapshot) => snapshot.docs
          .map((doc) => PackageModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList());
    } catch (e) {
      _errorHandler.logError('Watch packages', e);
      throw Exception('Paket dinleme hatası: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<PackageModel>> getPackagesByType(PackageType type) async {
    try {
      final querySnapshot = await _databaseService.getDocumentsWhere(
        DatabaseConstants.packagesCollection,
        'type',
        type.value,
      );

      return querySnapshot.docs
          .map((doc) => PackageModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Get packages by type', e);
      throw Exception('Tipe göre paketler yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }
}
