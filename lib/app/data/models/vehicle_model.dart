import '../enums/fuel_type.dart';
import '../../core/models/base_model.dart';

class VehicleModel extends UserOwnedModel
    with ValidationMixin, TimestampMixin, SoftDeleteMixin {
  final String _id;
  @override
  final String userId;
  final String brand;
  final String model;
  final String plate;
  final FuelType fuelType;
  final double fuelConsumptionPer100Km; // Litre/100km
  final double defaultFuelPricePerLitre; // Varsayılan yakıt fiyatı
  final bool isDefault;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  final DateTime? _deletedAt;

  VehicleModel({
    required String id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.plate,
    required this.fuelType,
    required this.fuelConsumptionPer100Km,
    required this.defaultFuelPricePerLitre,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  })  : _id = id,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _deletedAt = deletedAt;

  @override
  DateTime? get deletedAt => _deletedAt;

  @override
  String get id => _id;

  @override
  DateTime? get createdAt => _createdAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        brand: json['brand'] ?? '',
        model: json['model'] ?? '',
        plate: json['plate'] ?? '',
        fuelType: FuelTypeExtension.fromString(json['fuelType']),
        fuelConsumptionPer100Km:
            ModelSerializer.numberToDouble(json['fuelConsumptionPer100Km']) ??
                0.0,
        defaultFuelPricePerLitre:
            ModelSerializer.numberToDouble(json['defaultFuelPricePerLitre']) ??
                0.0,
        isDefault: ModelSerializer.toBool(json['isDefault']) ?? false,
        createdAt: ModelSerializer.stringToDateTime(json['createdAt']),
        updatedAt: ModelSerializer.stringToDateTime(json['updatedAt']),
        deletedAt: ModelSerializer.stringToDateTime(json['deletedAt']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'brand': brand,
        'model': model,
        'plate': plate,
        'fuelType': fuelType.value,
        'fuelConsumptionPer100Km': fuelConsumptionPer100Km,
        'defaultFuelPricePerLitre': defaultFuelPricePerLitre,
        'isDefault': isDefault,
        'createdAt': ModelSerializer.dateTimeToString(createdAt),
        'updatedAt': ModelSerializer.dateTimeToString(updatedAt),
        'deletedAt': ModelSerializer.dateTimeToString(deletedAt),
      };

  VehicleModel copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    String? plate,
    FuelType? fuelType,
    double? fuelConsumptionPer100Km,
    double? defaultFuelPricePerLitre,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      fuelType: fuelType ?? this.fuelType,
      fuelConsumptionPer100Km:
          fuelConsumptionPer100Km ?? this.fuelConsumptionPer100Km,
      defaultFuelPricePerLitre:
          defaultFuelPricePerLitre ?? this.defaultFuelPricePerLitre,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  String get displayName => '$brand $model ($plate)';

  /// Yakıt giderini hesapla (Yeni formül)
  /// Gider = (Gidilen KM / 100) × Ortalama Tüketim × Benzin Fiyatı
  double calculateFuelCost(double distanceKm, [double? currentFuelPrice]) {
    final fuelPrice = currentFuelPrice ?? defaultFuelPricePerLitre;
    return (distanceKm / 100) * fuelConsumptionPer100Km * fuelPrice;
  }

  @override
  List<String> validate() {
    final errors = <String>[];

    if (userId.isEmpty) errors.add('Kullanıcı ID gerekli');
    if (brand.isEmpty) errors.add('Marka gerekli');
    if (model.isEmpty) errors.add('Model gerekli');
    if (plate.isEmpty) errors.add('Plaka gerekli');
    if (fuelConsumptionPer100Km <= 0)
      errors.add('Yakıt tüketimi pozitif olmalı');
    if (defaultFuelPricePerLitre <= 0)
      errors.add('Yakıt fiyatı pozitif olmalı');

    return errors;
  }

  @override
  String toString() {
    return 'VehicleModel(id: $id, userId: $userId, brand: $brand, model: $model, plate: $plate, fuelType: $fuelType, fuelConsumptionPer100Km: $fuelConsumptionPer100Km, defaultFuelPricePerLitre: $defaultFuelPricePerLitre, isDefault: $isDefault, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleModel &&
        other.id == id &&
        other.userId == userId &&
        other.brand == brand &&
        other.model == model &&
        other.plate == plate &&
        other.fuelType == fuelType &&
        other.fuelConsumptionPer100Km == fuelConsumptionPer100Km &&
        other.defaultFuelPricePerLitre == defaultFuelPricePerLitre &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      brand,
      model,
      plate,
      fuelType,
      fuelConsumptionPer100Km,
      defaultFuelPricePerLitre,
      isDefault,
    );
  }
}
