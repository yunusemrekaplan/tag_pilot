import '../../data/models/package_model.dart';
import '../../data/enums/package_type.dart';
import '../repositories/package_repository.dart';

// Base Use Case Interface (Clean Architecture)
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// Package Use Case Parameters
class PackageParams {
  final String? userId; // Optional for backward compatibility
  final PackageModel? package;
  final String? packageId;
  final PackageType? type;
  final double? amount;
  final DateTime? startDate;
  final DateTime? endDate;

  const PackageParams({
    this.userId,
    this.package,
    this.packageId,
    this.type,
    this.amount,
    this.startDate,
    this.endDate,
  });
}

// ============================================================================
// READ USE CASES
// ============================================================================

/// Tüm paketleri getir Use Case
class GetAllPackagesUseCase
    implements UseCase<List<PackageModel>, PackageParams> {
  final PackageRepository repository;

  GetAllPackagesUseCase(this.repository);

  @override
  Future<List<PackageModel>> call(PackageParams params) async {
    return await repository.getAllPackages();
  }
}

/// Paket ID ile getir Use Case
class GetPackageByIdUseCase implements UseCase<PackageModel?, PackageParams> {
  final PackageRepository repository;

  GetPackageByIdUseCase(this.repository);

  @override
  Future<PackageModel?> call(PackageParams params) async {
    if (params.packageId == null) {
      throw ArgumentError('Package ID gerekli');
    }
    return await repository.getPackageById(params.packageId!);
  }
}

/// Paketleri izle Use Case
class WatchPackagesUseCase
    implements UseCase<Stream<List<PackageModel>>, PackageParams> {
  final PackageRepository repository;

  WatchPackagesUseCase(this.repository);

  @override
  Future<Stream<List<PackageModel>>> call(PackageParams params) async {
    return repository.watchPackages();
  }
}

/// Tipe göre paketleri getir Use Case
class GetPackagesByTypeUseCase
    implements UseCase<List<PackageModel>, PackageParams> {
  final PackageRepository repository;

  GetPackagesByTypeUseCase(this.repository);

  @override
  Future<List<PackageModel>> call(PackageParams params) async {
    if (params.type == null) {
      throw ArgumentError('Package type gerekli');
    }
    return await repository.getPackagesByType(params.type!);
  }
}
