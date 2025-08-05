import '../utils/app_constants.dart';

/// String Extension Methods
/// Validation, formatting ve utility fonksiyonları
extension StringExtensions on String {
  // ============================================================================
  // VALIDATION EXTENSIONS
  // ============================================================================

  /// Email format kontrolü
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Telefon numarası format kontrolü
  bool get isValidPhone {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return AppRegex.phoneNumber.hasMatch(cleaned);
  }

  /// Araç plaka format kontrolü
  bool get isValidVehiclePlate {
    return AppRegex.vehiclePlate.hasMatch(toUpperCase());
  }

  /// Numerik string kontrolü
  bool get isNumeric {
    return AppRegex.numbers.hasMatch(this);
  }

  /// Decimal string kontrolü
  bool get isDecimal {
    return AppRegex.decimal.hasMatch(this);
  }

  /// Boş veya null kontrolü
  bool get isNullOrEmpty {
    return trim().isEmpty;
  }

  /// Güçlü şifre kontrolü
  bool get isStrongPassword {
    if (length < ValidationConstants.minPasswordLength) return false;

    return contains(RegExp(r'[A-Z]')) && // Büyük harf
        contains(RegExp(r'[a-z]')) && // Küçük harf
        contains(RegExp(r'[0-9]')); // Rakam
  }

  // ============================================================================
  // FORMATTING EXTENSIONS
  // ============================================================================

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Title case (her kelimenin ilk harfi büyük)
  String get titleCase {
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalize)
        .join(' ');
  }

  /// Telefon numarasını format et
  String get formatPhone {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length == 11 && cleaned.startsWith('0')) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 9)} ${cleaned.substring(9)}';
    }
    return this;
  }

  /// Araç plakasını format et
  String get formatVehiclePlate {
    final cleaned = replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
    if (cleaned.length >= 6) {
      // 34ABC123 -> 34 ABC 123
      final numbers1 = cleaned.substring(0, 2);
      final letters = cleaned.substring(2, cleaned.length - 3);
      final numbers2 = cleaned.substring(cleaned.length - 3);
      return '$numbers1 $letters $numbers2';
    }
    return cleaned;
  }

  /// Para birimi format et
  String get formatCurrency {
    final amount = double.tryParse(this);
    if (amount == null) return this;

    return '${amount.toStringAsFixed(2)} ${CurrencyConstants.currencySymbol}';
  }

  /// Mesafe format et
  String get formatDistance {
    final distance = double.tryParse(this);
    if (distance == null) return this;

    if (distance < 1) {
      return '${(distance * 1000).toInt()} m';
    } else {
      return '${distance.toStringAsFixed(1)} km';
    }
  }

  // ============================================================================
  // CLEANING EXTENSIONS
  // ============================================================================

  /// Sadece rakamları al
  String get numbersOnly {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Sadece harfleri al
  String get lettersOnly {
    return replaceAll(RegExp(r'[^a-zA-ZğüşıöçĞÜŞIÖÇ]'), '');
  }

  /// Özel karakterleri temizle
  String get removeSpecialChars {
    return replaceAll(RegExp(r'[^a-zA-Z0-9ğüşıöçĞÜŞIÖÇ\s]'), '');
  }

  /// HTML tag'lerini temizle
  String get removeHtmlTags {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Çoklu boşlukları temizle
  String get removeExtraSpaces {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // ============================================================================
  // CONVERSION EXTENSIONS
  // ============================================================================

  /// String'i double'a çevir (güvenli)
  double? get toDoubleOrNull {
    return double.tryParse(this);
  }

  /// String'i int'e çevir (güvenli)
  int? get toIntOrNull {
    return int.tryParse(this);
  }

  /// String'i DateTime'a çevir (güvenli)
  DateTime? get toDateTimeOrNull {
    return DateTime.tryParse(this);
  }

  /// String'i bool'a çevir
  bool get toBool {
    return toLowerCase() == 'true' || this == '1';
  }

  // ============================================================================
  // UTILITY EXTENSIONS
  // ============================================================================

  /// Maskelenmiş string (şifre, kart no vs için)
  String mask(
      {int visibleStart = 0, int visibleEnd = 0, String maskChar = '*'}) {
    if (length <= visibleStart + visibleEnd) return this;

    final start = substring(0, visibleStart);
    final end = visibleEnd > 0 ? substring(length - visibleEnd) : '';
    final maskLength = length - visibleStart - visibleEnd;

    return start + (maskChar * maskLength) + end;
  }

  /// Kelime sayısını al
  int get wordCount {
    return trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  /// Karakter sayısını al (boşluksuz)
  int get charCountWithoutSpaces {
    return replaceAll(' ', '').length;
  }

  /// Kısalt
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Reverse string
  String get reverse {
    return split('').reversed.join('');
  }

  /// İlk kelimeyi al
  String get firstWord {
    final words = trim().split(RegExp(r'\s+'));
    return words.isNotEmpty ? words.first : '';
  }

  /// Son kelimeyi al
  String get lastWord {
    final words = trim().split(RegExp(r'\s+'));
    return words.isNotEmpty ? words.last : '';
  }

  // ============================================================================
  // SEARCH EXTENSIONS
  // ============================================================================

  /// Case-insensitive contains
  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }

  /// Case-insensitive equals
  bool equalsIgnoreCase(String other) {
    return toLowerCase() == other.toLowerCase();
  }

  /// Starts with ignore case
  bool startsWithIgnoreCase(String other) {
    return toLowerCase().startsWith(other.toLowerCase());
  }

  /// Ends with ignore case
  bool endsWithIgnoreCase(String other) {
    return toLowerCase().endsWith(other.toLowerCase());
  }

  // ============================================================================
  // TURKISH SPECIFIC EXTENSIONS
  // ============================================================================

  /// Türkçe karakterleri İngilizce'ye çevir
  String get toEnglishChars {
    const turkish = 'çğıöşüÇĞIÖŞÜ';
    const english = 'cgiosuCGIOSU';

    String result = this;
    for (int i = 0; i < turkish.length; i++) {
      result = result.replaceAll(turkish[i], english[i]);
    }
    return result;
  }

  /// Türkçe sort için normalize et
  String get normalizeForSort {
    return toEnglishChars.toLowerCase();
  }
}

/// Nullable String Extensions
extension NullableStringExtensions on String? {
  /// Null-safe boş kontrolü
  bool get isNullOrEmpty {
    return this == null || this!.trim().isEmpty;
  }

  /// Null-safe uzunluk
  int get safeLength {
    return this?.length ?? 0;
  }

  /// Null ise default değer döner
  String orDefault(String defaultValue) {
    return this ?? defaultValue;
  }

  /// Null veya boş ise default değer döner
  String orDefaultIfEmpty(String defaultValue) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}
