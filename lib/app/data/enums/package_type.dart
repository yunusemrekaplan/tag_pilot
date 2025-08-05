enum PackageType { daily, weekly }

extension PackageTypeExtension on PackageType {
  String get displayName {
    switch (this) {
      case PackageType.daily:
        return 'Günlük Paket';
      case PackageType.weekly:
        return 'Haftalık Paket';
    }
  }

  String get value {
    switch (this) {
      case PackageType.daily:
        return 'daily';
      case PackageType.weekly:
        return 'weekly';
    }
  }

  int get durationInDays {
    switch (this) {
      case PackageType.daily:
        return 1;
      case PackageType.weekly:
        return 7;
    }
  }

  static PackageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return PackageType.daily;
      case 'weekly':
        return PackageType.weekly;
      default:
        throw Exception('Unknown PackageType: $value');
    }
  }
}
