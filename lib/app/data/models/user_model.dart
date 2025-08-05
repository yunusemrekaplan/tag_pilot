import '../../core/models/base_model.dart';

class UserModel extends BaseModel
    with ValidationMixin, TimestampMixin, SoftDeleteMixin {
  final String _id;
  final String name;
  final String email;
  final String? defaultVehicleId;
  final DateTime? _createdAt;
  final DateTime? _deletedAt;

  UserModel({
    required String uid,
    required this.name,
    required this.email,
    this.defaultVehicleId,
    DateTime? createdAt,
    DateTime? deletedAt,
  })  : _id = uid,
        _createdAt = createdAt,
        _deletedAt = deletedAt;

  @override
  String get id => _id;

  @override
  DateTime? get createdAt => _createdAt;

  @override
  DateTime? get updatedAt => null; // User model doesn't have updatedAt

  @override
  DateTime? get deletedAt => _deletedAt;

  String get uid => _id; // Backward compatibility

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        defaultVehicleId: json['defaultVehicleId'],
        createdAt: ModelSerializer.stringToDateTime(json['createdAt']),
        deletedAt: ModelSerializer.stringToDateTime(json['deletedAt']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'defaultVehicleId': defaultVehicleId,
        'createdAt': ModelSerializer.dateTimeToString(createdAt),
        'deletedAt': ModelSerializer.dateTimeToString(deletedAt),
      };

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? defaultVehicleId,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      defaultVehicleId: defaultVehicleId ?? this.defaultVehicleId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) errors.add('Ad gerekli');
    if (email.isEmpty) errors.add('Email gerekli');
    if (!email.contains('@')) errors.add('Geçerli bir email adresi girin');

    return errors;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, defaultVehicleId: $defaultVehicleId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.defaultVehicleId == defaultVehicleId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        defaultVehicleId.hashCode ^
        createdAt.hashCode;
  }
}
