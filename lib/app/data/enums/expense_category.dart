enum ExpenseCategory {
  fuel,
  carWash,
  meal,
  fine,
  maintenance,
  toll,
  parking,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.fuel:
        return 'Yakıt';
      case ExpenseCategory.carWash:
        return 'Araç Yıkama';
      case ExpenseCategory.meal:
        return 'Yemek';
      case ExpenseCategory.fine:
        return 'Ceza';
      case ExpenseCategory.maintenance:
        return 'Bakım';
      case ExpenseCategory.toll:
        return 'Köprü/Geçiş';
      case ExpenseCategory.parking:
        return 'Otopark';
      case ExpenseCategory.other:
        return 'Diğer';
    }
  }

  String get value {
    switch (this) {
      case ExpenseCategory.fuel:
        return 'fuel';
      case ExpenseCategory.carWash:
        return 'carwash';
      case ExpenseCategory.meal:
        return 'meal';
      case ExpenseCategory.fine:
        return 'fine';
      case ExpenseCategory.maintenance:
        return 'maintenance';
      case ExpenseCategory.toll:
        return 'toll';
      case ExpenseCategory.parking:
        return 'parking';
      case ExpenseCategory.other:
        return 'other';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.fuel:
        return '⛽';
      case ExpenseCategory.carWash:
        return '🚿';
      case ExpenseCategory.meal:
        return '🍽️';
      case ExpenseCategory.fine:
        return '🚨';
      case ExpenseCategory.maintenance:
        return '🔧';
      case ExpenseCategory.toll:
        return '🌉';
      case ExpenseCategory.parking:
        return '🅿️';
      case ExpenseCategory.other:
        return '📝';
    }
  }

  static ExpenseCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fuel':
        return ExpenseCategory.fuel;
      case 'carwash':
        return ExpenseCategory.carWash;
      case 'meal':
        return ExpenseCategory.meal;
      case 'fine':
        return ExpenseCategory.fine;
      case 'maintenance':
        return ExpenseCategory.maintenance;
      case 'toll':
        return ExpenseCategory.toll;
      case 'parking':
        return ExpenseCategory.parking;
      case 'other':
        return ExpenseCategory.other;
      default:
        throw Exception('Unknown ExpenseCategory: $value');
    }
  }

  static List<ExpenseCategory> get allCategories => ExpenseCategory.values;
}
