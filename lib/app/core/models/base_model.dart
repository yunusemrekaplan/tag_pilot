/// Base Model Interface
/// Tüm model'lar için ortak metodları tanımlar
/// SOLID: Interface Segregation - Sadece gerekli metodlar
abstract class BaseModel {
  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson();

  /// JSON'dan model oluştur
  /// Bu method abstract olduğu için her model kendi implementasyonunu yapacak

  /// Model'i kopya et (immutable update için)
  /// Bu method abstract olduğu için her model kendi implementasyonunu yapacak

  /// Model'in unique identifier'ı
  String get id;

  /// Model'in oluşturulma tarihi
  DateTime? get createdAt;

  /// Model'in güncellenme tarihi
  DateTime? get updatedAt;
}

/// User-related model'lar için base class
abstract class UserOwnedModel extends BaseModel {
  /// Model'in sahibi olan user'ın ID'si
  String get userId;
}

/// Timestamp'li model'lar için mixin
mixin TimestampMixin {
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Timestamp'leri güncelle
  Map<String, dynamic> withTimestamps({
    DateTime? createdAt,
    DateTime? updatedAt,
    bool updateModifiedAt = true,
  }) {
    final now = DateTime.now();
    return {
      'createdAt': (createdAt ?? this.createdAt ?? now).toIso8601String(),
      'updatedAt': updateModifiedAt
          ? now.toIso8601String()
          : (updatedAt ?? this.updatedAt)?.toIso8601String(),
    };
  }

  /// Model yeni mi?
  bool get isNew => createdAt == null;

  /// Model değiştirilmiş mi?
  bool get isModified =>
      updatedAt != null && updatedAt!.isAfter(createdAt ?? DateTime.now());
}

/// Soft delete destekli model'lar için mixin
mixin SoftDeleteMixin {
  DateTime? get deletedAt;

  /// Silinmiş mi?
  bool get isDeleted => deletedAt != null;

  /// Aktif mi?
  bool get isActive => !isDeleted;
}

/// Validation destekli model'lar için mixin
mixin ValidationMixin {
  /// Model geçerli mi?
  bool get isValid => validate().isEmpty;

  /// Validation hataları
  List<String> validate();

  /// İlk validation hatasını al
  String? get firstValidationError {
    final errors = validate();
    return errors.isNotEmpty ? errors.first : null;
  }
}

/// Serialization helper'ları
class ModelSerializer {
  ModelSerializer._();

  /// DateTime'ı string'e çevir (null-safe)
  static String? dateTimeToString(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  /// String'i DateTime'a çevir (null-safe)
  static DateTime? stringToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Number'ı double'a çevir (null-safe)
  static double? numberToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Number'ı int'e çevir (null-safe)
  static int? numberToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Bool'a çevir (null-safe)
  static bool? toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return null;
  }

  /// List'i safe olarak al
  static List<T> toList<T>(dynamic value, T Function(dynamic) converter) {
    if (value == null) return [];
    if (value is! List) return [];

    return value
        .map((item) {
          try {
            return converter(item);
          } catch (e) {
            return null;
          }
        })
        .where((item) => item != null)
        .cast<T>()
        .toList();
  }

  /// Map'i safe olarak al
  static Map<String, dynamic> toMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }
}
