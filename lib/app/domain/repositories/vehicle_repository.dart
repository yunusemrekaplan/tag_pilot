import '../../data/models/vehicle_model.dart';

/// Vehicle Repository Interface
/// SOLID: Dependency Inversion - High-level modules buna bağımlı, implementation'a değil
/// SOLID: Interface Segregation - Sadece vehicle operasyonları
abstract class VehicleRepository {
  // Create Operations
  Future<void> createVehicle(VehicleModel vehicle);

  // Read Operations
  Future<List<VehicleModel>> getAllVehicles();
  Future<VehicleModel?> getVehicleById(String vehicleId);
  Stream<List<VehicleModel>> watchVehicles();

  // Update Operations
  Future<void> updateVehicle(VehicleModel vehicle);
  Future<void> setDefaultVehicle(String vehicleId);

  // Delete Operations
  Future<void> deleteVehicle(String vehicleId);
  Future<void> deleteAllUserVehicles();

  // Business Logic Operations
  Future<VehicleModel?> getDefaultVehicle();
  Future<bool> hasDefaultVehicle();
  Future<List<VehicleModel>> getVehiclesByType(String type);
  Future<bool> isVehiclePlateUnique(String plate);
  Future<double> calculateTotalFuelCost(DateTime startDate, DateTime endDate);
}
