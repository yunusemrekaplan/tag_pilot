import '../../data/models/vehicle_model.dart';
import '../../data/models/session_model.dart';
import '../../data/models/ride_model.dart';

/// Yakıt gideri hesaplama servisi
/// Gider = (Gidilen KM / 100) × Ortalama Tüketim × Benzin Fiyatı
abstract class FuelCalculationService {
  /// Belirli bir mesafe için yakıt giderini hesapla
  double calculateFuelCost({
    required VehicleModel vehicle,
    required double distanceKm,
    double? currentFuelPrice,
  });

  /// Session için toplam yakıt giderini hesapla
  Future<double> calculateSessionFuelCost({
    required SessionModel session,
    required VehicleModel vehicle,
    required List<RideModel> rides,
  });

  /// Günlük hedef için yakıt giderini tahmin et
  double estimateDailyFuelCost({
    required VehicleModel vehicle,
    required double estimatedDailyKm,
    double? currentFuelPrice,
  });

  /// Yakıt fiyatı değişikliğinin etkisini hesapla
  double calculateFuelPriceImpact({
    required VehicleModel vehicle,
    required double distanceKm,
    required double oldPrice,
    required double newPrice,
  });
}
