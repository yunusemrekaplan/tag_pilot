import '../../domain/services/fuel_calculation_service.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/models/session_model.dart';
import '../../data/models/ride_model.dart';
import '../../core/utils/app_constants.dart';

/// Yakıt gideri hesaplama servisi implementasyonu
class FuelCalculationServiceImpl implements FuelCalculationService {
  @override
  double calculateFuelCost({
    required VehicleModel vehicle,
    required double distanceKm,
    double? currentFuelPrice,
  }) {
    if (distanceKm <= 0) return 0.0;

    // Güncel yakıt fiyatı yoksa araçtaki varsayılan fiyatı kullan
    final fuelPrice = currentFuelPrice ?? vehicle.defaultFuelPricePerLitre;

    // Formül: (Gidilen KM / 100) × Ortalama Tüketim × Benzin Fiyatı
    final fuelCost =
        (distanceKm / 100) * vehicle.fuelConsumptionPer100Km * fuelPrice;

    if (AppConstants.enableLogging) {
      print(
          '🛢️ Fuel cost calculated: ${distanceKm}km × ${vehicle.fuelConsumptionPer100Km}L/100km × ₺${fuelPrice}/L = ₺${fuelCost.toStringAsFixed(2)}');
    }

    return fuelCost;
  }

  @override
  Future<double> calculateSessionFuelCost({
    required SessionModel session,
    required VehicleModel vehicle,
    required List<RideModel> rides,
  }) async {
    double totalFuelCost = 0.0;

    for (final ride in rides) {
      // Her yolculuk için yakıt giderini hesapla
      // Ride'da zaten fuelCost var ama yeniden hesaplayabiliriz
      final rideFuelCost = calculateFuelCost(
        vehicle: vehicle,
        distanceKm: ride.distanceKm,
        currentFuelPrice: session.currentFuelPricePerLitre,
      );

      totalFuelCost += rideFuelCost;
    }

    if (AppConstants.enableLogging) {
      print(
          '🛢️ Session total fuel cost: ₺${totalFuelCost.toStringAsFixed(2)} for ${rides.length} rides');
    }

    return totalFuelCost;
  }

  @override
  double estimateDailyFuelCost({
    required VehicleModel vehicle,
    required double estimatedDailyKm,
    double? currentFuelPrice,
  }) {
    return calculateFuelCost(
      vehicle: vehicle,
      distanceKm: estimatedDailyKm,
      currentFuelPrice: currentFuelPrice,
    );
  }

  @override
  double calculateFuelPriceImpact({
    required VehicleModel vehicle,
    required double distanceKm,
    required double oldPrice,
    required double newPrice,
  }) {
    final oldCost = calculateFuelCost(
      vehicle: vehicle,
      distanceKm: distanceKm,
      currentFuelPrice: oldPrice,
    );

    final newCost = calculateFuelCost(
      vehicle: vehicle,
      distanceKm: distanceKm,
      currentFuelPrice: newPrice,
    );

    return newCost - oldCost;
  }
}
