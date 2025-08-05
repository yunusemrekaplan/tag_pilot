import 'package:intl/intl.dart';

import '../utils/app_constants.dart';

/// DateTime Extension Methods
/// Tarih-saat formatting, manipulation ve utility fonksiyonları
extension DateTimeExtensions on DateTime {
  // ============================================================================
  // FORMATTING EXTENSIONS
  // ============================================================================

  /// Türkçe format (dd/MM/yyyy)
  String get toTurkishDate {
    return DateFormat(DateTimeConstants.dateFormat).format(this);
  }

  /// Saat format (HH:mm)
  String get toTimeString {
    return DateFormat(DateTimeConstants.timeFormat).format(this);
  }

  /// Tarih ve saat format (dd/MM/yyyy HH:mm)
  String get toTurkishDateTime {
    return DateFormat(DateTimeConstants.dateTimeFormat).format(this);
  }

  /// API format (yyyy-MM-dd)
  String get toApiDate {
    return DateFormat(DateTimeConstants.apiDateFormat).format(this);
  }

  /// ISO 8601 format (API için)
  String get toIsoString {
    return toIso8601String();
  }

  /// Relative time (X dakika önce, X saat önce vb.)
  String get toRelativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Günaydın/İyi akşamlar formatı
  String get toGreetingTime {
    final hour = this.hour;
    if (hour < 6) {
      return 'İyi geceler';
    } else if (hour < 12) {
      return 'Günaydın';
    } else if (hour < 18) {
      return 'İyi günler';
    } else {
      return 'İyi akşamlar';
    }
  }

  /// Gün adı (Türkçe)
  String get turkishDayName {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    return days[weekday - 1];
  }

  /// Ay adı (Türkçe)
  String get turkishMonthName {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month - 1];
  }

  /// Türkçe uzun format (15 Mart 2024 Cuma)
  String get turkishLongFormat {
    return '$day $turkishMonthName $year $turkishDayName';
  }

  /// Türkçe kısa format (15 Mar 2024)
  String get turkishShortFormat {
    final shortMonth = turkishMonthName.substring(0, 3);
    return '$day $shortMonth $year';
  }

  // ============================================================================
  // DATE MANIPULATION EXTENSIONS
  // ============================================================================

  /// Günün başlangıcı (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Günün sonu (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Haftanın başlangıcı (Pazartesi)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Haftanın sonu (Pazar)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).endOfDay;
  }

  /// Ayın başlangıcı
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Ayın sonu
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Yılın başlangıcı
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// Yılın sonu
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  /// N gün sonra
  DateTime addDays(int days) {
    return add(Duration(days: days));
  }

  /// N hafta sonra
  DateTime addWeeks(int weeks) {
    return add(Duration(days: weeks * 7));
  }

  /// N ay sonra
  DateTime addMonths(int months) {
    final newMonth = month + months;
    final newYear = year + (newMonth - 1) ~/ 12;
    final finalMonth = ((newMonth - 1) % 12) + 1;

    // Ayın son günü kontrolü (29 Şubat gibi durumlar için)
    final daysInNewMonth = DateTime(newYear, finalMonth + 1, 0).day;
    final newDay = day <= daysInNewMonth ? day : daysInNewMonth;

    return DateTime(
        newYear, finalMonth, newDay, hour, minute, second, millisecond);
  }

  /// N yıl sonra
  DateTime addYears(int years) {
    return addMonths(years * 12);
  }

  // ============================================================================
  // COMPARISON EXTENSIONS
  // ============================================================================

  /// Bugün mü?
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Dün mü?
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Yarın mı?
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Bu hafta mı?
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.startOfWeek;
    final endOfWeek = now.endOfWeek;
    return isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        isBefore(endOfWeek.add(const Duration(seconds: 1)));
  }

  /// Bu ay mı?
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Bu yıl mı?
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  /// Geçmiş tarih mi?
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Gelecek tarih mi?
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Hafta sonu mu?
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Hafta içi mi?
  bool get isWeekday {
    return !isWeekend;
  }

  /// Aynı gün mü?
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Aynı hafta mı?
  bool isSameWeek(DateTime other) {
    final thisWeekStart = startOfWeek;
    final otherWeekStart = other.startOfWeek;
    return thisWeekStart.isSameDay(otherWeekStart);
  }

  /// Aynı ay mı?
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  // ============================================================================
  // BUSINESS LOGIC EXTENSIONS
  // ============================================================================

  /// Yaş hesapla
  int ageFrom(DateTime birthDate) {
    int age = year - birthDate.year;
    if (month < birthDate.month ||
        (month == birthDate.month && day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// İki tarih arası gün sayısı
  int daysBetween(DateTime other) {
    return difference(other).inDays.abs();
  }

  /// İki tarih arası çalışma günü sayısı (hafta sonu hariç)
  int workingDaysBetween(DateTime other) {
    DateTime start = isBefore(other) ? this : other;
    DateTime end = isAfter(other) ? this : other;

    int workingDays = 0;
    DateTime current = start;

    while (current.isBefore(end) || current.isSameDay(end)) {
      if (current.isWeekday) {
        workingDays++;
      }
      current = current.addDays(1);
    }

    return workingDays;
  }

  /// Çalışma saatleri içinde mi? (09:00-18:00)
  bool get isWorkingHours {
    final hour = this.hour;
    return hour >= 9 && hour < 18 && isWeekday;
  }

  /// Gece saatleri mi? (22:00-06:00)
  bool get isNightTime {
    final hour = this.hour;
    return hour >= 22 || hour < 6;
  }

  // ============================================================================
  // UTILITY EXTENSIONS
  // ============================================================================

  /// Unix timestamp
  int get timestamp {
    return millisecondsSinceEpoch ~/ 1000;
  }

  /// Başka bir timezone'a çevir
  DateTime toTimezone(Duration offset) {
    return add(offset - timeZoneOffset);
  }

  /// UTC'ye çevir
  DateTime get toUtcFromLocal {
    return toUtc();
  }

  /// Local time'a çevir
  DateTime get toLocalFromUtc {
    return toLocal();
  }

  /// Saniye ve milisaniye olmadan
  DateTime get withoutTime {
    return DateTime(year, month, day);
  }

  /// Sadece saat ve dakika ile
  DateTime get withTimeOnly {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

/// Nullable DateTime Extensions
extension NullableDateTimeExtensions on DateTime? {
  /// Null-safe format
  String get safeFormat {
    return this?.toTurkishDate ?? '';
  }

  /// Null-safe time format
  String get safeTimeFormat {
    return this?.toTimeString ?? '';
  }

  /// Null ise default değer döner
  DateTime orDefault(DateTime defaultValue) {
    return this ?? defaultValue;
  }

  /// Null ise şimdi döner
  DateTime get orNow {
    return this ?? DateTime.now();
  }

  /// Null-safe bugün kontrolü
  bool get isNullOrToday {
    return this?.isToday ?? false;
  }
}

/// Duration Extensions (bonus)
extension DurationExtensions on Duration {
  /// Türkçe format (2 saat 30 dakika)
  String get toTurkishFormat {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    List<String> parts = [];

    if (hours > 0) {
      parts.add('$hours saat');
    }
    if (minutes > 0) {
      parts.add('$minutes dakika');
    }
    if (seconds > 0 && hours == 0) {
      parts.add('$seconds saniye');
    }

    return parts.isEmpty ? '0 saniye' : parts.join(' ');
  }

  /// Kısa format (2s 30d)
  String get toShortFormat {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}s ${minutes}d';
    } else {
      return '${minutes}d';
    }
  }
}
