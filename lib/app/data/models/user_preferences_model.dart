import '../../core/models/base_model.dart';

/// User Preferences Model
/// Kullanıcının uygulama tercihlerini tutar
class UserPreferencesModel extends UserOwnedModel
    with ValidationMixin, TimestampMixin, SoftDeleteMixin {
  final String _id;
  @override
  final String userId;
  final double dailyTarget;
  final String? defaultVehicleId;
  final bool notificationsEnabled;
  final String? preferredCurrency;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  final DateTime? _deletedAt;

  UserPreferencesModel({
    required String id,
    required this.userId,
    this.dailyTarget = 500.0,
    this.defaultVehicleId,
    this.notificationsEnabled = true,
    this.preferredCurrency = 'TRY',
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

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      UserPreferencesModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        dailyTarget: (json['dailyTarget'] ?? 500.0).toDouble(),
        defaultVehicleId: json['defaultVehicleId'],
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        preferredCurrency: json['preferredCurrency'] ?? 'TRY',
        createdAt: ModelSerializer.stringToDateTime(json['createdAt']),
        updatedAt: ModelSerializer.stringToDateTime(json['updatedAt']),
        deletedAt: ModelSerializer.stringToDateTime(json['deletedAt']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'dailyTarget': dailyTarget,
        'defaultVehicleId': defaultVehicleId,
        'notificationsEnabled': notificationsEnabled,
        'preferredCurrency': preferredCurrency,
        'createdAt': ModelSerializer.dateTimeToString(createdAt),
        'updatedAt': ModelSerializer.dateTimeToString(updatedAt),
        'deletedAt': ModelSerializer.dateTimeToString(deletedAt),
      };

  UserPreferencesModel copyWith({
    String? id,
    String? userId,
    double? dailyTarget,
    String? defaultVehicleId,
    bool? notificationsEnabled,
    String? preferredCurrency,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserPreferencesModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      defaultVehicleId: defaultVehicleId ?? this.defaultVehicleId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<String> validate() {
    final errors = <String>[];

    if (userId.isEmpty) errors.add('Kullanıcı ID gerekli');
    if (dailyTarget < 0) errors.add('Günlük hedef negatif olamaz');

    return errors;
  }

  @override
  String toString() {
    return 'UserPreferencesModel(id: $id, userId: $userId, dailyTarget: $dailyTarget, defaultVehicleId: $defaultVehicleId, notificationsEnabled: $notificationsEnabled, preferredCurrency: $preferredCurrency, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferencesModel &&
        other.id == id &&
        other.userId == userId &&
        other.dailyTarget == dailyTarget &&
        other.defaultVehicleId == defaultVehicleId &&
        other.notificationsEnabled == notificationsEnabled &&
        other.preferredCurrency == preferredCurrency &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        dailyTarget.hashCode ^
        defaultVehicleId.hashCode ^
        notificationsEnabled.hashCode ^
        preferredCurrency.hashCode ^
        createdAt.hashCode;
  }
}
