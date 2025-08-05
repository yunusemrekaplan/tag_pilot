enum FuelType { lpg, petrol, diesel }

extension FuelTypeExtension on FuelType {
  String get displayName {
    switch (this) {
      case FuelType.lpg:
        return 'LPG';
      case FuelType.petrol:
        return 'Benzin';
      case FuelType.diesel:
        return 'Dizel';
    }
  }

  String get value {
    switch (this) {
      case FuelType.lpg:
        return 'lpg';
      case FuelType.petrol:
        return 'petrol';
      case FuelType.diesel:
        return 'diesel';
    }
  }

  static FuelType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'lpg':
        return FuelType.lpg;
      case 'petrol':
        return FuelType.petrol;
      case 'diesel':
        return FuelType.diesel;
      default:
        throw Exception('Unknown FuelType: $value');
    }
  }
}
