import '../enums/expense_enums.dart';
import '../../core/models/base_model.dart';

/// Gider modeli - Seans ve Genel giderler için
class ExpenseModel extends BaseModel {
  @override
  final String id;
  final String userId;
  final ExpenseType type;
  final ExpenseCategory category;
  final double amount;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  final String? sessionId; // Sadece seans giderleri için
  final RecurrenceInfo? recurrence; // Sadece genel giderler için
  final String? description; // Opsiyonel açıklama

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    required this.createdAt,
    this.updatedAt,
    this.sessionId,
    this.recurrence,
    this.description,
  });

  /// JSON'dan ExpenseModel oluştur
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: ExpenseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExpenseType.session,
      ),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.diger,
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      sessionId: json['sessionId'],
      recurrence: json['recurrence'] != null
          ? RecurrenceInfo.fromJson(json['recurrence'])
          : null,
      description: json['description'],
    );
  }

  /// ExpenseModel'i JSON'a çevir
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'category': category.name,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'sessionId': sessionId,
      'recurrence': recurrence?.toJson(),
      'description': description,
    };
  }

  /// Kopya oluştur
  ExpenseModel copyWith({
    String? id,
    String? userId,
    ExpenseType? type,
    ExpenseCategory? category,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sessionId,
    RecurrenceInfo? recurrence,
    String? description,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionId: sessionId ?? this.sessionId,
      recurrence: recurrence ?? this.recurrence,
      description: description ?? this.description,
    );
  }

  /// Seans gideri mi?
  bool get isSessionExpense => type == ExpenseType.session;

  /// Genel gider mi?
  bool get isGeneralExpense => type == ExpenseType.general;

  /// Periyodik gider mi?
  bool get isRecurring =>
      recurrence != null && recurrence!.type != RecurrenceType.none;

  /// Belirtilen tarih aralığındaki pay miktarını hesapla
  double getAmountForDateRange({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    if (type == ExpenseType.session) {
      // Seans gideri - sadece tarih aralığında mı kontrol et
      final isInRange =
          createdAt.isAfter(rangeStart.subtract(const Duration(days: 1))) &&
              createdAt.isBefore(rangeEnd.add(const Duration(days: 1)));
      return isInRange ? amount : 0.0;
    }

    // Genel gider - recurrence bilgisini kullan
    if (recurrence != null) {
      return recurrence!.calculateProportionalAmount(
        totalAmount: amount,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      );
    }

    // Recurrence bilgisi yoksa tek seferlik olarak treat et
    final isInRange =
        createdAt.isAfter(rangeStart.subtract(const Duration(days: 1))) &&
            createdAt.isBefore(rangeEnd.add(const Duration(days: 1)));
    return isInRange ? amount : 0.0;
  }

  /// Gider türü için display text
  String get typeDisplayName => type.displayName;

  /// Kategori için display text
  String get categoryDisplayName => category.displayName;

  /// Kategori için icon
  String get categoryIcon => category.icon;

  /// Formatted amount (₺123.45)
  String get formattedAmount => '₺${amount.toStringAsFixed(2)}';

  /// Recurrence display text
  String get recurrenceDisplayName {
    if (recurrence == null) return 'Tek Seferlik';
    return recurrence!.type.displayName;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseModel &&
        other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.category == category &&
        other.amount == amount &&
        other.createdAt == createdAt &&
        other.sessionId == sessionId &&
        other.recurrence == recurrence &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        type.hashCode ^
        category.hashCode ^
        amount.hashCode ^
        createdAt.hashCode ^
        sessionId.hashCode ^
        recurrence.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, type: $type, category: $category, amount: $amount, '
        'sessionId: $sessionId, recurrence: $recurrence)';
  }
}
