import '../../data/models/package_model.dart';
import '../../data/enums/package_type.dart';

/// Package Repository Interface
/// SOLID: Dependency Inversion - High-level modules buna bağımlı, implementation'a değil
/// SOLID: Interface Segregation - Sadece package operasyonları
abstract class PackageRepository {
  // Read Operations
  Future<List<PackageModel>> getAllPackages();
  Future<PackageModel?> getPackageById(String packageId);
  Stream<List<PackageModel>> watchPackages();

  // Read - Business Logic Operations
  Future<List<PackageModel>> getPackagesByType(PackageType type);
}
