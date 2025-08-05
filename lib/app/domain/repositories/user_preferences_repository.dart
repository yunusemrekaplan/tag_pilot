import '../../data/models/user_preferences_model.dart';

/// User Preferences Repository Interface
/// Kullanıcı tercihleri için data layer abstraction
abstract class UserPreferencesRepository {
  /// Kullanıcının tercihlerini getir
  Future<UserPreferencesModel?> getUserPreferences(String userId);

  /// Kullanıcı tercihlerini kaydet/güncelle
  Future<void> saveUserPreferences(UserPreferencesModel preferences);

  /// Günlük hedefi güncelle
  Future<void> updateDailyTarget(String userId, double dailyTarget);

  /// Varsayılan araç ID'sini güncelle
  Future<void> updateDefaultVehicleId(String userId, String? vehicleId);

  /// Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings(String userId, bool enabled);

  /// Kullanıcı tercihlerini sil
  Future<void> deleteUserPreferences(String userId);
}
