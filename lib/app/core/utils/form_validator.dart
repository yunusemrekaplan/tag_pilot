import 'package:get/get.dart';
import 'app_constants.dart';

/// Form Validation Utility Class
/// SOLID: Single Responsibility - Sadece validation logic
/// Tüm form alanları için merkezi validation kuralları
class FormValidator {
  FormValidator._();

  // ============================================================================
  // EMAIL VALIDATION
  // ============================================================================

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gerekli';
    }

    if (!GetUtils.isEmail(value.trim())) {
      return 'Geçerli bir email adresi girin';
    }

    return null;
  }

  static String? validateEmailOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (!GetUtils.isEmail(value.trim())) {
      return 'Geçerli bir email adresi girin';
    }

    return null;
  }

  // ============================================================================
  // PASSWORD VALIDATION
  // ============================================================================

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }

    if (value.length < ValidationConstants.minPasswordLength) {
      return 'Şifre en az ${ValidationConstants.minPasswordLength} karakter olmalı';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }

    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }

  static String? validateStrongPassword(String? value) {
    final basicValidation = validatePassword(value);
    if (basicValidation != null) return basicValidation;

    final password = value!;

    // En az bir büyük harf kontrolü
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermeli';
    }

    // En az bir küçük harf kontrolü
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermeli';
    }

    // En az bir rakam kontrolü
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermeli';
    }

    return null;
  }

  // ============================================================================
  // NAME VALIDATION
  // ============================================================================

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad soyad gerekli';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'En az 2 karakter olmalı';
    }

    if (trimmedValue.length > ValidationConstants.maxNameLength) {
      return 'En fazla ${ValidationConstants.maxNameLength} karakter olmalı';
    }

    // Sadece harf ve boşluk karakterlerine izin ver
    if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞIÖÇ\s]+$').hasMatch(trimmedValue)) {
      return 'Sadece harf karakterleri kullanın';
    }

    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad gerekli';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'En az 2 karakter olmalı';
    }

    if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞIÖÇ]+$').hasMatch(trimmedValue)) {
      return 'Sadece harf karakterleri kullanın';
    }

    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Soyad gerekli';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'En az 2 karakter olmalı';
    }

    if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞIÖÇ]+$').hasMatch(trimmedValue)) {
      return 'Sadece harf karakterleri kullanın';
    }

    return null;
  }

  // ============================================================================
  // NUMERIC VALIDATION
  // ============================================================================

  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Tutar gerekli';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Geçerli bir tutar girin';
    }

    if (min != null && amount < min) {
      return 'Tutar en az $min olmalı';
    }

    if (max != null && amount > max) {
      return 'Tutar en fazla $max olmalı';
    }

    if (amount <= 0) {
      return 'Tutar 0\'dan büyük olmalı';
    }

    return null;
  }

  static String? validateDistance(String? value) {
    return validateAmount(
      value,
      min: 0.1,
      max: BusinessConstants.maxDistance,
    );
  }

  static String? validateEarnings(String? value) {
    return validateAmount(
      value,
      min: 0.1,
      max: BusinessConstants.maxEarnings,
    );
  }

  static String? validateExpenseAmount(String? value) {
    return validateAmount(
      value,
      min: 0.1,
      max: BusinessConstants.maxExpenseAmount,
    );
  }

  static String? validateFuelRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yakıt tüketimi gerekli';
    }

    final rate = double.tryParse(value);
    if (rate == null) {
      return 'Geçerli bir değer girin';
    }

    if (rate <= 0) {
      return 'Değer 0\'dan büyük olmalı';
    }

    return null;
  }

  static String? validateFuelPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yakıt fiyatı gerekli';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Geçerli bir fiyat girin';
    }

    if (price <= 0) {
      return 'Fiyat 0\'dan büyük olmalı';
    }

    if (price > 100) {
      return 'Yakıt fiyatı çok yüksek görünüyor';
    }

    return null;
  }

  // ============================================================================
  // VEHICLE VALIDATION
  // ============================================================================

  static String? validateVehiclePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Plaka gerekli';
    }

    final trimmedValue = value.trim().toUpperCase();

    if (!AppRegex.vehiclePlate.hasMatch(trimmedValue)) {
      return 'Geçerli bir plaka formatı girin (ör: 34ABC123)';
    }

    return null;
  }

  static String? validateVehicleBrand(String? value) {
    if (value == null || value.isEmpty) {
      return 'Marka gerekli';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'En az 2 karakter olmalı';
    }

    if (trimmedValue.length > 30) {
      return 'En fazla 30 karakter olmalı';
    }

    return null;
  }

  static String? validateVehicleModel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Model gerekli';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 1) {
      return 'Model gerekli';
    }

    if (trimmedValue.length > 50) {
      return 'En fazla 50 karakter olmalı';
    }

    return null;
  }

  // ============================================================================
  // DESCRIPTION VALIDATION
  // ============================================================================

  static String? validateDescription(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Açıklama gerekli';
    }

    if (value != null &&
        value.trim().length > ValidationConstants.maxDescriptionLength) {
      return 'En fazla ${ValidationConstants.maxDescriptionLength} karakter olmalı';
    }

    return null;
  }

  static String? validateOptionalDescription(String? value) {
    return validateDescription(value, required: false);
  }

  static String? validateRequiredDescription(String? value) {
    return validateDescription(value, required: true);
  }

  // ============================================================================
  // PHONE VALIDATION
  // ============================================================================

  static String? validatePhoneNumber(String? value, {bool required = true}) {
    if (!required && (value == null || value.isEmpty)) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }

    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!AppRegex.phoneNumber.hasMatch(cleanedValue)) {
      return 'Geçerli bir telefon numarası girin';
    }

    return null;
  }

  // ============================================================================
  // GENERAL VALIDATION
  // ============================================================================

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value != null && value.trim().length < minLength) {
      return '$fieldName en az $minLength karakter olmalı';
    }
    return null;
  }

  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName en fazla $maxLength karakter olmalı';
    }
    return null;
  }

  static String? validateRange(
      double? value, double min, double max, String fieldName) {
    if (value == null) {
      return '$fieldName gerekli';
    }

    if (value < min || value > max) {
      return '$fieldName $min ile $max arasında olmalı';
    }

    return null;
  }

  // ============================================================================
  // COMPOSITE VALIDATORS
  // ============================================================================

  /// Multiple validator'ı birleştir
  static String? combineValidators(
      String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }

  /// Custom validator ile birleştir
  static String? validateWithCustom(
    String? value,
    String? Function(String?) baseValidator,
    String? Function(String?) customValidator,
  ) {
    final baseResult = baseValidator(value);
    if (baseResult != null) return baseResult;

    return customValidator(value);
  }
}
