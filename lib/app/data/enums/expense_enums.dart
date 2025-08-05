/// Gider türleri
enum ExpenseType {
  session, // Seans gideri
  general, // Genel gider
}

extension ExpenseTypeExtension on ExpenseType {
  String get displayName {
    switch (this) {
      case ExpenseType.session:
        return 'Seans Gideri';
      case ExpenseType.general:
        return 'Genel Gider';
    }
  }
}

/// Gider kategorileri
enum ExpenseCategory {
  yemek,
  otopark,
  ceza,
  bakim,
  sigorta,
  yikama,
  yakitDisi,
  diger,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.yemek:
        return 'Yemek';
      case ExpenseCategory.otopark:
        return 'Otopark';
      case ExpenseCategory.ceza:
        return 'Ceza';
      case ExpenseCategory.bakim:
        return 'Bakım';
      case ExpenseCategory.sigorta:
        return 'Sigorta';
      case ExpenseCategory.yikama:
        return 'Yıkama';
      case ExpenseCategory.yakitDisi:
        return 'Yakıt Dışı';
      case ExpenseCategory.diger:
        return 'Diğer';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.yemek:
        return '🍽️';
      case ExpenseCategory.otopark:
        return '🅿️';
      case ExpenseCategory.ceza:
        return '⚠️';
      case ExpenseCategory.bakim:
        return '🔧';
      case ExpenseCategory.sigorta:
        return '🛡️';
      case ExpenseCategory.yikama:
        return '🚿';
      case ExpenseCategory.yakitDisi:
        return '⛽';
      case ExpenseCategory.diger:
        return '📝';
    }
  }
}

/// Tekrarlama türleri
enum RecurrenceType {
  none, // Tek seferlik
  weekly, // Haftalık
  monthly, // Aylık
  yearly, // Yıllık
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'Tek Seferlik';
      case RecurrenceType.weekly:
        return 'Haftalık';
      case RecurrenceType.monthly:
        return 'Aylık';
      case RecurrenceType.yearly:
        return 'Yıllık';
    }
  }
}

/// Tekrarlama bilgileri sınıfı
class RecurrenceInfo {
  final RecurrenceType type;
  final DateTime startDate;
  final DateTime? endDate; // Opsiyonel bitiş tarihi
  final int? durationCount; // Opsiyonel süre (kaç hafta/ay/yıl)

  const RecurrenceInfo({
    required this.type,
    required this.startDate,
    this.endDate,
    this.durationCount,
  });

  /// JSON'dan RecurrenceInfo oluştur
  factory RecurrenceInfo.fromJson(Map<String, dynamic> json) {
    return RecurrenceInfo(
      type: RecurrenceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecurrenceType.none,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      durationCount: json['durationCount'],
    );
  }

  /// RecurrenceInfo'yu JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'durationCount': durationCount,
    };
  }

  /// Kopya oluştur
  RecurrenceInfo copyWith({
    RecurrenceType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? durationCount,
  }) {
    return RecurrenceInfo(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationCount: durationCount ?? this.durationCount,
    );
  }

  /// Verilen tarih aralığında bu tekrarlama ne kadar pay almalı?
  /// (Aylık sigorta için günlük pay hesaplama vb.)
  double calculateProportionalAmount({
    required double totalAmount,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    if (type == RecurrenceType.none) {
      // Tek seferlik gider - tarih aralığında mı kontrol et
      final isInRange =
          startDate.isAfter(rangeStart.subtract(const Duration(days: 1))) &&
              startDate.isBefore(rangeEnd.add(const Duration(days: 1)));
      return isInRange ? totalAmount : 0.0;
    }

    // Periyodik gider için proportional pay hesapla
    final rangeDays = rangeEnd.difference(rangeStart).inDays + 1;

    switch (type) {
      case RecurrenceType.weekly:
        return (totalAmount / 7) * rangeDays;
      case RecurrenceType.monthly:
        return (totalAmount / 30) * rangeDays; // Yaklaşık hesap
      case RecurrenceType.yearly:
        return (totalAmount / 365) * rangeDays;
      case RecurrenceType.none:
        return 0.0; // Yukarıda handle edildi
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurrenceInfo &&
        other.type == type &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.durationCount == durationCount;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        durationCount.hashCode;
  }

  @override
  String toString() {
    return 'RecurrenceInfo(type: $type, startDate: $startDate, endDate: $endDate, durationCount: $durationCount)';
  }
}
