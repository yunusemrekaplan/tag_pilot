import '../enums/package_type.dart';
import '../../core/models/base_model.dart';

/// Default paket modeli - Admin tarafından oluşturulur
/// Kullanıcılar sadece bu paketlerden seçim yapar
class PackageModel extends BaseModel
    with ValidationMixin, TimestampMixin, SoftDeleteMixin {
  final String _id;
  final String name; // Paket adı (örn: "Premium Günlük", "Standart Haftalık")
  final PackageType type;
  final double price; // Paket fiyatı
  final String description; // Paket açıklaması
  final List<String> features; // Paket özellikleri
  final bool isAvailable; // Paket aktif mi?
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  final DateTime? _deletedAt;

  PackageModel({
    required String id,
    required this.name,
    required this.type,
    required this.price,
    required this.description,
    required this.features,
    this.isAvailable = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
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

  /// Paket süresi (gün cinsinden)
  int get durationInDays => type.durationInDays;

  /// Günlük maliyet
  double get dailyCost => price / durationInDays;

  /// Başabaş hesaplama için paket maliyeti
  /// Günlük paket: dailyCost
  /// Haftalık paket: direkt price (7'ye bölmeden)
  double get breakEvenCost {
    switch (type) {
      case PackageType.daily:
        return dailyCost; // Günlük için mevcut mantık
      case PackageType.weekly:
        return price; // Haftalık için direkt paket fiyatı
    }
  }

  /// Başabaş hesaplama için paket maliyeti (string açıklama ile)
  String get breakEvenCostDescription {
    switch (type) {
      case PackageType.daily:
        return '₺${dailyCost.toStringAsFixed(0)}/gün';
      case PackageType.weekly:
        return '₺${price.toStringAsFixed(0)}/hafta';
    }
  }

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: PackageTypeExtension.fromString(json['type']),
        price: ModelSerializer.numberToDouble(json['price']) ?? 0.0,
        description: json['description'] ?? '',
        features: List<String>.from(json['features'] ?? []),
        isAvailable: ModelSerializer.toBool(json['isAvailable']) ?? true,
        createdAt: ModelSerializer.stringToDateTime(json['createdAt']),
        updatedAt: ModelSerializer.stringToDateTime(json['updatedAt']),
        deletedAt: ModelSerializer.stringToDateTime(json['deletedAt']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.value,
        'price': price,
        'description': description,
        'features': features,
        'isAvailable': isAvailable,
        'createdAt': ModelSerializer.dateTimeToString(createdAt),
        'updatedAt': ModelSerializer.dateTimeToString(updatedAt),
        'deletedAt': ModelSerializer.dateTimeToString(deletedAt),
      };

  PackageModel copyWith({
    String? id,
    String? name,
    PackageType? type,
    double? price,
    String? description,
    List<String>? features,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      description: description ?? this.description,
      features: features ?? this.features,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) errors.add('Paket adı gerekli');
    if (price <= 0) errors.add('Paket fiyatı 0\'dan büyük olmalı');
    if (description.isEmpty) errors.add('Paket açıklaması gerekli');
    if (features.isEmpty) errors.add('En az bir özellik gerekli');

    return errors;
  }

  @override
  String toString() {
    return 'PackageModel(id: $id, name: $name, type: $type, price: $price, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackageModel &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.price == price &&
        other.description == description &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        price.hashCode ^
        description.hashCode ^
        isAvailable.hashCode;
  }
}
