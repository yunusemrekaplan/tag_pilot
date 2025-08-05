import '../../core/models/base_model.dart';
import '../enums/package_type.dart';
import '../enums/session_status.dart';

/// Session Pause/Resume kaydı
class SessionPauseRecord {
  final DateTime pausedAt;
  final DateTime? resumedAt;

  const SessionPauseRecord({
    required this.pausedAt,
    this.resumedAt,
  });

  Duration get pauseDuration {
    final end = resumedAt ?? DateTime.now();
    return end.difference(pausedAt);
  }

  bool get isCurrentlyPaused => resumedAt == null;

  Map<String, dynamic> toJson() => {
        'pausedAt': pausedAt.toIso8601String(),
        'resumedAt': resumedAt?.toIso8601String(),
      };

  factory SessionPauseRecord.fromJson(Map<String, dynamic> json) =>
      SessionPauseRecord(
        pausedAt: DateTime.parse(json['pausedAt']),
        resumedAt: json['resumedAt'] != null
            ? DateTime.parse(json['resumedAt'])
            : null,
      );
}

class SessionModel extends UserOwnedModel
    with ValidationMixin, TimestampMixin, SoftDeleteMixin {
  final String _id;
  @override
  final String userId;
  final String vehicleId;
  final String? packageId;
  final PackageType? packageType;
  final double? packagePrice;
  final double?
      currentFuelPricePerLitre; // Sefer başlatılırken girilen güncel yakıt fiyatı
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  final DateTime? _deletedAt;

  // YENİ SESSION DURUM YÖNETİMİ
  final SessionStatus status;
  final DateTime? lastPausedAt;
  final DateTime? lastResumedAt;
  final List<SessionPauseRecord> pauseHistory;

  SessionModel({
    required String id,
    required this.userId,
    required this.vehicleId,
    this.packageId,
    this.packageType,
    this.packagePrice,
    this.currentFuelPricePerLitre,
    required this.startTime,
    this.endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    this.status = SessionStatus.active,
    this.lastPausedAt,
    this.lastResumedAt,
    this.pauseHistory = const [],
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

  /// Toplam geçen süre (molalar dahil)
  Duration get totalDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Sadece aktif çalışma süresi (molalar hariç)
  Duration get activeDuration {
    Duration totalActive = Duration.zero;
    DateTime currentStart = startTime;

    for (final pause in pauseHistory) {
      // Bu pause'a kadar olan aktif süreyi ekle
      totalActive += pause.pausedAt.difference(currentStart);

      // Eğer pause resume edilmişse, currentStart'ı resume time olarak güncelle
      if (pause.resumedAt != null) {
        currentStart = pause.resumedAt!;
      }
    }

    // Eğer session completed veya şu anda active ise, son aktif süreyi ekle
    if (status.isCompleted) {
      totalActive += endTime!.difference(currentStart);
    } else if (status.isActive) {
      totalActive += DateTime.now().difference(currentStart);
    }

    return totalActive;
  }

  /// Toplam mola süresi
  Duration get totalPauseDuration {
    return pauseHistory.fold(
        Duration.zero, (total, pause) => total + pause.pauseDuration);
  }

  String get durationFormatted {
    final dur = activeDuration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String get totalDurationFormatted {
    final dur = totalDuration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  bool get isCompleted => status.isCompleted;
  bool get isActive => status.isActive;
  bool get isPaused => status.isPaused;
  bool get isRunning => status.isRunning;

  /// Eski API uyumluluğu için
  bool get isCurrentlyRunning => isRunning;
  bool get isActiveSession => isRunning;

  double get hoursWorked => activeDuration.inMilliseconds / (1000 * 60 * 60);

  bool get isPackageExpired {
    if (packageType == null) return false;
    final packageEndTime =
        startTime.add(Duration(days: packageType!.durationInDays));
    return DateTime.now().isAfter(packageEndTime);
  }

  int get remainingPackageDays {
    if (packageType == null) return 0;
    final packageEndTime =
        startTime.add(Duration(days: packageType!.durationInDays));
    final remaining = packageEndTime.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  DateTime? get packageEndTime {
    if (packageType == null) return null;
    return startTime.add(Duration(days: packageType!.durationInDays));
  }

  double get dailyPackageCost {
    if (packagePrice == null || packageType == null) return 0.0;
    return packagePrice! / packageType!.durationInDays;
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        vehicleId: json['vehicleId'] ?? '',
        packageId: json['packageId'],
        packageType: json['packageType'] != null
            ? PackageTypeExtension.fromString(json['packageType'])
            : null,
        packagePrice: ModelSerializer.numberToDouble(json['packagePrice']),
        currentFuelPricePerLitre:
            ModelSerializer.numberToDouble(json['currentFuelPricePerLitre']),
        startTime: ModelSerializer.stringToDateTime(json['startTime']) ??
            DateTime.now(),
        endTime: ModelSerializer.stringToDateTime(json['endTime']),
        createdAt: ModelSerializer.stringToDateTime(json['createdAt']),
        updatedAt: ModelSerializer.stringToDateTime(json['updatedAt']),
        deletedAt: ModelSerializer.stringToDateTime(json['deletedAt']),
        status: json['status'] != null
            ? SessionStatus.fromString(json['status'])
            : SessionStatus.active,
        lastPausedAt: ModelSerializer.stringToDateTime(json['lastPausedAt']),
        lastResumedAt: ModelSerializer.stringToDateTime(json['lastResumedAt']),
        pauseHistory: (json['pauseHistory'] as List<dynamic>?)
                ?.map((p) => SessionPauseRecord.fromJson(p))
                .toList() ??
            const [],
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'vehicleId': vehicleId,
        'packageId': packageId,
        'packageType': packageType?.value,
        'packagePrice': packagePrice,
        'currentFuelPricePerLitre': currentFuelPricePerLitre,
        'startTime': ModelSerializer.dateTimeToString(startTime),
        'endTime': ModelSerializer.dateTimeToString(endTime),
        'createdAt': ModelSerializer.dateTimeToString(createdAt),
        'updatedAt': ModelSerializer.dateTimeToString(updatedAt),
        'deletedAt': ModelSerializer.dateTimeToString(deletedAt),
        'status': status.value,
        'lastPausedAt': ModelSerializer.dateTimeToString(lastPausedAt),
        'lastResumedAt': ModelSerializer.dateTimeToString(lastResumedAt),
        'pauseHistory': pauseHistory.map((p) => p.toJson()).toList(),
      };

  SessionModel copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    String? packageId,
    PackageType? packageType,
    double? packagePrice,
    double? currentFuelPricePerLitre,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    SessionStatus? status,
    DateTime? lastPausedAt,
    DateTime? lastResumedAt,
    List<SessionPauseRecord>? pauseHistory,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      packageId: packageId ?? this.packageId,
      packageType: packageType ?? this.packageType,
      packagePrice: packagePrice ?? this.packagePrice,
      currentFuelPricePerLitre:
          currentFuelPricePerLitre ?? this.currentFuelPricePerLitre,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      status: status ?? this.status,
      lastPausedAt: lastPausedAt ?? this.lastPausedAt,
      lastResumedAt: lastResumedAt ?? this.lastResumedAt,
      pauseHistory: pauseHistory ?? this.pauseHistory,
    );
  }

  SessionModel complete() {
    return copyWith(
      endTime: DateTime.now(),
      status: SessionStatus.completed,
      updatedAt: DateTime.now(),
    );
  }

  SessionModel pause() {
    return copyWith(
      lastPausedAt: DateTime.now(),
      status: SessionStatus.paused,
      updatedAt: DateTime.now(),
    );
  }

  SessionModel resume() {
    return copyWith(
      lastResumedAt: DateTime.now(),
      status: SessionStatus.active,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<String> validate() {
    final errors = <String>[];

    if (userId.isEmpty) errors.add('Kullanıcı ID gerekli');
    if (vehicleId.isEmpty) errors.add('Araç ID gerekli');
    if (startTime.isAfter(DateTime.now()))
      errors.add('Başlangıç zamanı gelecekte olamaz');
    if (endTime != null && endTime!.isBefore(startTime))
      errors.add('Bitiş zamanı başlangıçtan önce olamaz');

    return errors;
  }

  @override
  String toString() {
    return 'SessionModel(id: $id, userId: $userId, vehicleId: $vehicleId, packageId: $packageId, packageType: $packageType, startTime: $startTime, endTime: $endTime, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionModel &&
        other.id == id &&
        other.userId == userId &&
        other.vehicleId == vehicleId &&
        other.packageId == packageId &&
        other.packageType == packageType &&
        other.packagePrice == packagePrice &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.status == status &&
        other.lastPausedAt == lastPausedAt &&
        other.lastResumedAt == lastResumedAt &&
        other.pauseHistory.length == pauseHistory.length;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        vehicleId.hashCode ^
        packageId.hashCode ^
        packageType.hashCode ^
        packagePrice.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        status.hashCode ^
        lastPausedAt.hashCode ^
        lastResumedAt.hashCode ^
        pauseHistory.hashCode;
  }
}
