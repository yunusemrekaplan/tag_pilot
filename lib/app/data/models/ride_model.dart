import '../../core/models/base_model.dart';

class RideModel extends BaseModel
    with ValidationMixin, TimestampMixin, SoftDeleteMixin {
  final String _id;
  final String sessionId;
  final double distanceKm;
  final double earnings;
  final double fuelRate;
  final double fuelPrice;
  final double fuelCost;
  final double netProfit;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  final DateTime? _deletedAt;
  final String? notes;

  RideModel({
    required String id,
    required this.sessionId,
    required this.distanceKm,
    required this.earnings,
    required this.fuelRate,
    required this.fuelPrice,
    required this.fuelCost,
    required this.netProfit,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    this.notes,
  })  : _id = id,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _deletedAt = deletedAt;

  @override
  String get id => _id;

  @override
  DateTime? get createdAt => _createdAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  DateTime? get deletedAt => _deletedAt;

  factory RideModel.fromJson(Map<String, dynamic> json) => RideModel(
        id: json['id'] ?? '',
        sessionId: json['sessionId'] ?? '',
        distanceKm: ModelSerializer.numberToDouble(json['distanceKm']) ?? 0.0,
        earnings: ModelSerializer.numberToDouble(json['earnings']) ?? 0.0,
        fuelRate: ModelSerializer.numberToDouble(json['fuelRate']) ?? 0.0,
        fuelPrice: ModelSerializer.numberToDouble(json['fuelPrice']) ?? 0.0,
        fuelCost: ModelSerializer.numberToDouble(json['fuelCost']) ?? 0.0,
        netProfit: ModelSerializer.numberToDouble(json['netProfit']) ?? 0.0,
        createdAt: ModelSerializer.stringToDateTime(json['createdAt']),
        updatedAt: ModelSerializer.stringToDateTime(json['updatedAt']),
        deletedAt: ModelSerializer.stringToDateTime(json['deletedAt']),
        notes: json['notes'],
      );

  /// Yakıt gideri ile birlikte yolculuk oluştur
  factory RideModel.withFuelCalculation({
    required String id,
    required String sessionId,
    required double distanceKm,
    required double earnings,
    required double fuelConsumptionPer100Km,
    required double fuelPrice,
    String? notes,
    DateTime? createdAt,
  }) {
    // Yakıt giderini hesapla: (Mesafe / 100) × Tüketim × Fiyat
    final fuelCost = (distanceKm / 100) * fuelConsumptionPer100Km * fuelPrice;
    final netProfit = earnings - fuelCost;

    return RideModel(
      id: id,
      sessionId: sessionId,
      distanceKm: distanceKm,
      earnings: earnings,
      fuelRate: fuelConsumptionPer100Km,
      fuelPrice: fuelPrice,
      fuelCost: fuelCost,
      netProfit: netProfit,
      notes: notes,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'distanceKm': distanceKm,
        'earnings': earnings,
        'fuelRate': fuelRate,
        'fuelPrice': fuelPrice,
        'fuelCost': fuelCost,
        'netProfit': netProfit,
        'createdAt': ModelSerializer.dateTimeToString(createdAt),
        'updatedAt': ModelSerializer.dateTimeToString(updatedAt),
        'deletedAt': ModelSerializer.dateTimeToString(deletedAt),
        'notes': notes,
      };

  RideModel copyWith({
    String? id,
    String? sessionId,
    double? distanceKm,
    double? earnings,
    double? fuelRate,
    double? fuelPrice,
    double? fuelCost,
    double? netProfit,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? notes,
  }) {
    return RideModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      distanceKm: distanceKm ?? this.distanceKm,
      earnings: earnings ?? this.earnings,
      fuelRate: fuelRate ?? this.fuelRate,
      fuelPrice: fuelPrice ?? this.fuelPrice,
      fuelCost: fuelCost ?? this.fuelCost,
      netProfit: netProfit ?? this.netProfit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      notes: notes ?? this.notes,
    );
  }

  // Factory constructor for calculating values
  factory RideModel.calculate({
    required String id,
    required String sessionId,
    required double distanceKm,
    required double earnings,
    required double fuelRate,
    required double fuelPrice,
    String? notes,
  }) {
    final fuelCost = (distanceKm / 100) * fuelRate * fuelPrice;
    final netProfit = earnings - fuelCost;

    return RideModel(
      id: id,
      sessionId: sessionId,
      distanceKm: distanceKm,
      earnings: earnings,
      fuelRate: fuelRate,
      fuelPrice: fuelPrice,
      fuelCost: fuelCost,
      netProfit: netProfit,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  double get profitMargin => earnings > 0 ? (netProfit / earnings) * 100 : 0;

  double get fuelEfficiency => distanceKm > 0 ? fuelCost / distanceKm : 0;

  double get earningsPerKm => distanceKm > 0 ? earnings / distanceKm : 0;

  bool get isProfitable => netProfit > 0;

  String get profitStatus {
    if (netProfit > 0) return 'Kârlı';
    if (netProfit < 0) return 'Zararlı';
    return 'Başabaş';
  }

  @override
  List<String> validate() {
    final errors = <String>[];

    if (sessionId.isEmpty) errors.add('Seans ID gerekli');
    if (distanceKm <= 0) errors.add('Mesafe 0\'dan büyük olmalı');
    if (earnings < 0) errors.add('Kazanç negatif olamaz');
    if (fuelRate <= 0) errors.add('Yakıt tüketimi 0\'dan büyük olmalı');
    if (fuelPrice <= 0) errors.add('Yakıt fiyatı 0\'dan büyük olmalı');
    if (fuelCost < 0) errors.add('Yakıt maliyeti negatif olamaz');

    return errors;
  }

  @override
  String toString() {
    return 'RideModel(id: $id, sessionId: $sessionId, distanceKm: $distanceKm, earnings: $earnings, netProfit: $netProfit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideModel &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.distanceKm == distanceKm &&
        other.earnings == earnings &&
        other.fuelRate == fuelRate &&
        other.fuelPrice == fuelPrice &&
        other.fuelCost == fuelCost &&
        other.netProfit == netProfit;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sessionId.hashCode ^
        distanceKm.hashCode ^
        earnings.hashCode ^
        fuelRate.hashCode ^
        fuelPrice.hashCode ^
        fuelCost.hashCode ^
        netProfit.hashCode;
  }
}
