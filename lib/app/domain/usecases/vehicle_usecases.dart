import '../../data/models/vehicle_model.dart';
import '../repositories/vehicle_repository.dart';

/// Base Use Case
/// SOLID: Single Responsibility - Sadece bir işlevi yerine getirir
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// No Parameters için
class NoParams {
  const NoParams();
}

/// Parameters için base class
class VehicleParams {
  final String? userId; // Optional for backward compatibility
  final VehicleModel? vehicle;
  final String? vehicleId;
  final String? plate;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const VehicleParams({
    this.userId,
    this.vehicle,
    this.vehicleId,
    this.plate,
    this.type,
    this.startDate,
    this.endDate,
  });
}

// ============================================================================
// CREATE USE CASES
// ============================================================================

/// Vehicle oluşturma Use Case
/// SOLID: Single Responsibility - Sadece vehicle oluşturma business logic'i
class CreateVehicleUseCase implements UseCase<void, VehicleParams> {
  final VehicleRepository repository;

  CreateVehicleUseCase(this.repository);

  @override
  Future<void> call(VehicleParams params) async {
    if (params.vehicle == null) {
      throw ArgumentError('Vehicle gerekli');
    }

    // Business Logic: Plaka benzersizlik kontrolü
    if (params.plate != null) {
      final isPlateUnique = await repository.isVehiclePlateUnique(
        params.plate!,
      );

      if (!isPlateUnique) {
        throw Exception('Bu plaka zaten kullanılıyor');
      }
    }

    // Business Logic: İlk araç ise default yap
    final existingVehicles = await repository.getAllVehicles();
    if (existingVehicles.isEmpty) {
      final vehicleWithDefault = params.vehicle!.copyWith(isDefault: true);
      await repository.createVehicle(vehicleWithDefault);
    } else {
      await repository.createVehicle(params.vehicle!);
    }
  }
}

// ============================================================================
// READ USE CASES
// ============================================================================

/// Tüm araçları getir Use Case
class GetAllVehiclesUseCase
    implements UseCase<List<VehicleModel>, VehicleParams> {
  final VehicleRepository repository;

  GetAllVehiclesUseCase(this.repository);

  @override
  Future<List<VehicleModel>> call(VehicleParams params) async {
    return await repository.getAllVehicles();
  }
}

/// Araç detayını getir Use Case
class GetVehicleByIdUseCase implements UseCase<VehicleModel?, VehicleParams> {
  final VehicleRepository repository;

  GetVehicleByIdUseCase(this.repository);

  @override
  Future<VehicleModel?> call(VehicleParams params) async {
    if (params.vehicleId == null) {
      throw ArgumentError('Vehicle ID gerekli');
    }
    return await repository.getVehicleById(params.vehicleId!);
  }
}

/// Araçları izle (Stream) Use Case
class WatchVehiclesUseCase
    implements UseCase<Stream<List<VehicleModel>>, VehicleParams> {
  final VehicleRepository repository;

  WatchVehiclesUseCase(this.repository);

  @override
  Future<Stream<List<VehicleModel>>> call(VehicleParams params) async {
    return repository.watchVehicles();
  }
}

/// Default araç getir Use Case
class GetDefaultVehicleUseCase
    implements UseCase<VehicleModel?, VehicleParams> {
  final VehicleRepository repository;

  GetDefaultVehicleUseCase(this.repository);

  @override
  Future<VehicleModel?> call(VehicleParams params) async {
    return await repository.getDefaultVehicle();
  }
}

/// Tipe göre araçları getir Use Case
class GetVehiclesByTypeUseCase
    implements UseCase<List<VehicleModel>, VehicleParams> {
  final VehicleRepository repository;

  GetVehiclesByTypeUseCase(this.repository);

  @override
  Future<List<VehicleModel>> call(VehicleParams params) async {
    if (params.type == null) {
      throw ArgumentError('Vehicle type gerekli');
    }
    return await repository.getVehiclesByType(params.type!);
  }
}

// ============================================================================
// UPDATE USE CASES
// ============================================================================

/// Araç güncelle Use Case
class UpdateVehicleUseCase implements UseCase<void, VehicleParams> {
  final VehicleRepository repository;

  UpdateVehicleUseCase(this.repository);

  @override
  Future<void> call(VehicleParams params) async {
    if (params.vehicle == null) {
      throw ArgumentError('Vehicle gerekli');
    }

    // Business Logic: Plaka değiştirildiyse benzersizlik kontrolü
    if (params.plate != null) {
      final isPlateUnique = await repository.isVehiclePlateUnique(
        params.plate!,
      );

      if (!isPlateUnique) {
        throw Exception('Bu plaka zaten kullanılıyor');
      }
    }

    await repository.updateVehicle(params.vehicle!);
  }
}

/// Default araç ayarla Use Case
class SetDefaultVehicleUseCase implements UseCase<void, VehicleParams> {
  final VehicleRepository repository;

  SetDefaultVehicleUseCase(this.repository);

  @override
  Future<void> call(VehicleParams params) async {
    if (params.vehicleId == null) {
      throw ArgumentError('Vehicle ID gerekli');
    }
    await repository.setDefaultVehicle(params.vehicleId!);
  }
}

// ============================================================================
// DELETE USE CASES
// ============================================================================

/// Araç sil Use Case
class DeleteVehicleUseCase implements UseCase<void, VehicleParams> {
  final VehicleRepository repository;

  DeleteVehicleUseCase(this.repository);

  @override
  Future<void> call(VehicleParams params) async {
    if (params.vehicleId == null) {
      throw ArgumentError('Vehicle ID gerekli');
    }

    // Business Logic: Silinen araç default ise başka bir aracı default yap
    final vehicleToDelete = await repository.getVehicleById(params.vehicleId!);

    await repository.deleteVehicle(params.vehicleId!);

    if (vehicleToDelete?.isDefault == true) {
      final remainingVehicles = await repository.getAllVehicles();
      if (remainingVehicles.isNotEmpty) {
        await repository.setDefaultVehicle(remainingVehicles.first.id);
      }
    }
  }
}

/// Kullanıcının tüm araçlarını sil Use Case
class DeleteAllUserVehiclesUseCase implements UseCase<void, VehicleParams> {
  final VehicleRepository repository;

  DeleteAllUserVehiclesUseCase(this.repository);

  @override
  Future<void> call(VehicleParams params) async {
    await repository.deleteAllUserVehicles();
  }
}

// ============================================================================
// BUSINESS LOGIC USE CASES
// ============================================================================

/// Plaka benzersizlik kontrolü Use Case
class IsVehiclePlateUniqueUseCase implements UseCase<bool, VehicleParams> {
  final VehicleRepository repository;

  IsVehiclePlateUniqueUseCase(this.repository);

  @override
  Future<bool> call(VehicleParams params) async {
    if (params.plate == null) {
      throw ArgumentError('Plate gerekli');
    }
    return await repository.isVehiclePlateUnique(params.plate!);
  }
}

/// Toplam yakıt maliyeti hesapla Use Case
class CalculateTotalFuelCostUseCase implements UseCase<double, VehicleParams> {
  final VehicleRepository repository;

  CalculateTotalFuelCostUseCase(this.repository);

  @override
  Future<double> call(VehicleParams params) async {
    if (params.startDate == null || params.endDate == null) {
      throw ArgumentError('Start date ve end date gerekli');
    }
    return await repository.calculateTotalFuelCost(
      params.startDate!,
      params.endDate!,
    );
  }
}
