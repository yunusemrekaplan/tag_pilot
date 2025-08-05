import '../../domain/repositories/user_preferences_repository.dart';
import '../../data/models/user_preferences_model.dart';

/// Base Use Case class
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// User Preferences Use Cases (Clean Architecture)
/// SOLID: Single Responsibility - Her use case tek bir iş yapar
/// Business Logic: Domain layer'da business rules

// ============================================================================
// GET USER PREFERENCES
// ============================================================================

/// Kullanıcı tercihlerini getirme use case
class GetUserPreferencesUseCase
    implements UseCase<UserPreferencesModel?, String> {
  final UserPreferencesRepository repository;

  GetUserPreferencesUseCase(this.repository);

  @override
  Future<UserPreferencesModel?> call(String userId) async {
    return await repository.getUserPreferences(userId);
  }
}

// ============================================================================
// SAVE USER PREFERENCES
// ============================================================================

/// Kullanıcı tercihlerini kaydetme use case
class SaveUserPreferencesUseCase
    implements UseCase<void, UserPreferencesModel> {
  final UserPreferencesRepository repository;

  SaveUserPreferencesUseCase(this.repository);

  @override
  Future<void> call(UserPreferencesModel preferences) async {
    // Validation
    final errors = preferences.validate();
    if (errors.isNotEmpty) {
      throw Exception('Validation errors: ${errors.join(', ')}');
    }

    await repository.saveUserPreferences(preferences);
  }
}

// ============================================================================
// UPDATE DAILY TARGET
// ============================================================================

/// Günlük hedef güncelleme use case
class UpdateDailyTargetUseCase
    implements UseCase<void, UpdateDailyTargetParams> {
  final UserPreferencesRepository repository;

  UpdateDailyTargetUseCase(this.repository);

  @override
  Future<void> call(UpdateDailyTargetParams params) async {
    // Business validation
    if (params.dailyTarget < 0) {
      throw Exception('Günlük hedef negatif olamaz');
    }

    if (params.dailyTarget > 10000) {
      throw Exception('Günlük hedef çok yüksek');
    }

    await repository.updateDailyTarget(params.userId, params.dailyTarget);
  }
}

/// Günlük hedef güncelleme parametreleri
class UpdateDailyTargetParams {
  final String userId;
  final double dailyTarget;

  const UpdateDailyTargetParams({
    required this.userId,
    required this.dailyTarget,
  });
}

// ============================================================================
// UPDATE DEFAULT VEHICLE
// ============================================================================

/// Varsayılan araç güncelleme use case
class UpdateDefaultVehicleUseCase
    implements UseCase<void, UpdateDefaultVehicleParams> {
  final UserPreferencesRepository repository;

  UpdateDefaultVehicleUseCase(this.repository);

  @override
  Future<void> call(UpdateDefaultVehicleParams params) async {
    await repository.updateDefaultVehicleId(params.userId, params.vehicleId);
  }
}

/// Varsayılan araç güncelleme parametreleri
class UpdateDefaultVehicleParams {
  final String userId;
  final String? vehicleId;

  const UpdateDefaultVehicleParams({
    required this.userId,
    this.vehicleId,
  });
}

// ============================================================================
// UPDATE NOTIFICATION SETTINGS
// ============================================================================

/// Bildirim ayarları güncelleme use case
class UpdateNotificationSettingsUseCase
    implements UseCase<void, UpdateNotificationSettingsParams> {
  final UserPreferencesRepository repository;

  UpdateNotificationSettingsUseCase(this.repository);

  @override
  Future<void> call(UpdateNotificationSettingsParams params) async {
    await repository.updateNotificationSettings(params.userId, params.enabled);
  }
}

/// Bildirim ayarları güncelleme parametreleri
class UpdateNotificationSettingsParams {
  final String userId;
  final bool enabled;

  const UpdateNotificationSettingsParams({
    required this.userId,
    required this.enabled,
  });
}

// ============================================================================
// DELETE USER PREFERENCES
// ============================================================================

/// Kullanıcı tercihlerini silme use case
class DeleteUserPreferencesUseCase implements UseCase<void, String> {
  final UserPreferencesRepository repository;

  DeleteUserPreferencesUseCase(this.repository);

  @override
  Future<void> call(String userId) async {
    await repository.deleteUserPreferences(userId);
  }
}
