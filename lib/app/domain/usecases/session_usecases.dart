import 'package:tag_pilot/app/data/enums/session_status.dart';

import '../../data/models/session_model.dart';
import '../../data/models/ride_model.dart';
import '../../data/enums/package_type.dart';
import '../repositories/session_repository.dart';

// Base Use Case Interface (Clean Architecture)
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// Session Use Case Parameters
class SessionParams {
  final String? userId; // Optional for backward compatibility
  final SessionModel? session;
  final RideModel? ride;
  final String? sessionId;
  final String? rideId;
  final String? vehicleId;
  final String? packageId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? date;
  final double? distanceKm;
  final double? earnings;
  final double? fuelRate;
  final double? fuelPrice;
  final String? notes;

  const SessionParams({
    this.userId,
    this.session,
    this.ride,
    this.sessionId,
    this.rideId,
    this.vehicleId,
    this.packageId,
    this.startDate,
    this.endDate,
    this.date,
    this.distanceKm,
    this.earnings,
    this.fuelRate,
    this.fuelPrice,
    this.notes,
  });
}

// ============================================================================
// SESSION CREATE USE CASES
// ============================================================================

/// Session oluştur Use Case
class CreateSessionUseCase implements UseCase<void, SessionParams> {
  final SessionRepository repository;

  CreateSessionUseCase(this.repository);

  @override
  Future<void> call(SessionParams params) async {
    if (params.session == null) {
      throw ArgumentError('Session gerekli');
    }

    // Business Logic: Aktif session kontrolü
    final hasActive = await repository.hasActiveSession();
    if (hasActive) {
      throw Exception(
          'Zaten aktif bir session var. Önce mevcut session\'ı bitirin.');
    }

    await repository.createSession(params.session!);
  }
}

/// Session başlat Use Case
class StartSessionUseCase {
  final SessionRepository _repository;

  StartSessionUseCase(this._repository);

  Future<SessionModel> call({
    required String userId,
    required String vehicleId,
    required String packageId,
    String? packageType,
    double? packagePrice,
    double? currentFuelPrice,
  }) async {
    // Benzersiz session ID oluştur
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    final session = SessionModel(
      id: sessionId,
      userId: userId,
      vehicleId: vehicleId,
      packageId: packageId,
      packageType: packageType != null
          ? PackageTypeExtension.fromString(packageType)
          : null,
      packagePrice: packagePrice,
      currentFuelPricePerLitre: currentFuelPrice,
      startTime: DateTime.now(),
      status: SessionStatus.active,
    );
    return await _repository.createSession(session);
  }
}

// ============================================================================
// SESSION READ USE CASES
// ============================================================================

/// Tüm session'ları getir Use Case
class GetAllSessionsUseCase
    implements UseCase<List<SessionModel>, SessionParams> {
  final SessionRepository repository;

  GetAllSessionsUseCase(this.repository);

  @override
  Future<List<SessionModel>> call(SessionParams params) async {
    return await repository.getAllSessions();
  }
}

/// Session ID ile getir Use Case
class GetSessionByIdUseCase implements UseCase<SessionModel?, SessionParams> {
  final SessionRepository repository;

  GetSessionByIdUseCase(this.repository);

  @override
  Future<SessionModel?> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.getSessionById(params.sessionId!);
  }
}

/// Session'ları izle Use Case
class WatchSessionsUseCase
    implements UseCase<Stream<List<SessionModel>>, SessionParams> {
  final SessionRepository repository;

  WatchSessionsUseCase(this.repository);

  @override
  Future<Stream<List<SessionModel>>> call(SessionParams params) async {
    return repository.watchSessions();
  }
}

/// Aktif session'ı getir Use Case
class GetActiveSessionUseCase implements UseCase<SessionModel?, SessionParams> {
  final SessionRepository repository;

  GetActiveSessionUseCase(this.repository);

  @override
  Future<SessionModel?> call(SessionParams params) async {
    return await repository.getActiveSession();
  }
}

/// Araç ID'ye göre session'ları getir Use Case
class GetSessionsByVehicleUseCase
    implements UseCase<List<SessionModel>, SessionParams> {
  final SessionRepository repository;

  GetSessionsByVehicleUseCase(this.repository);

  @override
  Future<List<SessionModel>> call(SessionParams params) async {
    if (params.vehicleId == null) {
      throw ArgumentError('Vehicle ID gerekli');
    }
    return await repository.getSessionsByVehicle(params.vehicleId!);
  }
}

/// Paket ID'ye göre session'ları getir Use Case
class GetSessionsByPackageUseCase
    implements UseCase<List<SessionModel>, SessionParams> {
  final SessionRepository repository;

  GetSessionsByPackageUseCase(this.repository);

  @override
  Future<List<SessionModel>> call(SessionParams params) async {
    if (params.packageId == null) {
      throw ArgumentError('Package ID gerekli');
    }
    return await repository.getSessionsByPackage(params.packageId!);
  }
}

/// Tarih aralığına göre session'ları getir Use Case
class GetSessionsByDateRangeUseCase
    implements UseCase<List<SessionModel>, SessionParams> {
  final SessionRepository repository;

  GetSessionsByDateRangeUseCase(this.repository);

  @override
  Future<List<SessionModel>> call(SessionParams params) async {
    if (params.startDate == null || params.endDate == null) {
      throw ArgumentError('Start date ve end date gerekli');
    }
    return await repository.getSessionsByDateRange(
        params.startDate!, params.endDate!);
  }
}

/// Tamamlanan session'ları getir Use Case
class GetCompletedSessionsUseCase
    implements UseCase<List<SessionModel>, SessionParams> {
  final SessionRepository repository;

  GetCompletedSessionsUseCase(this.repository);

  @override
  Future<List<SessionModel>> call(SessionParams params) async {
    return await repository.getCompletedSessions();
  }
}

/// Session'ı tamamla Use Case
class CompleteSessionUseCase implements UseCase<void, SessionParams> {
  final SessionRepository repository;

  CompleteSessionUseCase(this.repository);

  @override
  Future<void> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    await repository.completeSession(params.sessionId!);
  }
}

/// Session sil Use Case
class DeleteSessionUseCase implements UseCase<void, SessionParams> {
  final SessionRepository repository;

  DeleteSessionUseCase(this.repository);

  @override
  Future<void> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }

    // Business Logic: Aktif session silinmek isteniyorsa uyarı
    final sessionToDelete = await repository.getSessionById(params.sessionId!);
    if (sessionToDelete?.isCurrentlyRunning == true) {
      throw Exception('Aktif session silinemez. Önce session\'ı bitirin.');
    }

    await repository.deleteSession(params.sessionId!);
  }
}

/// Kullanıcının tüm session'larını sil Use Case
class DeleteAllUserSessionsUseCase implements UseCase<void, SessionParams> {
  final SessionRepository repository;

  DeleteAllUserSessionsUseCase(this.repository);

  @override
  Future<void> call(SessionParams params) async {
    await repository.deleteAllUserSessions();
  }
}

// ============================================================================
// RIDE MANAGEMENT USE CASES
// ============================================================================

/// Session'a ride ekle Use Case
class AddRideToSessionUseCase implements UseCase<String, SessionParams> {
  final SessionRepository repository;

  AddRideToSessionUseCase(this.repository);

  @override
  Future<String> call(SessionParams params) async {
    if (params.sessionId == null ||
        params.distanceKm == null ||
        params.earnings == null ||
        params.fuelRate == null ||
        params.fuelPrice == null) {
      throw ArgumentError(
          'Session ID, distance, earnings, fuel rate ve fuel price gerekli');
    }

    return await repository.addRideToSession(
      params.sessionId!,
      params.distanceKm!,
      params.earnings!,
      params.fuelRate!,
      params.fuelPrice!,
      params.notes,
    );
  }
}

/// Session'daki ride'ları getir Use Case
class GetRidesBySessionUseCase
    implements UseCase<List<RideModel>, SessionParams> {
  final SessionRepository repository;

  GetRidesBySessionUseCase(this.repository);

  @override
  Future<List<RideModel>> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.getRidesBySession(params.sessionId!);
  }
}

/// Ride ID ile getir Use Case
class GetRideByIdUseCase implements UseCase<RideModel?, SessionParams> {
  final SessionRepository repository;

  GetRideByIdUseCase(this.repository);

  @override
  Future<RideModel?> call(SessionParams params) async {
    if (params.rideId == null) {
      throw ArgumentError('Ride ID gerekli');
    }
    return await repository.getRideById(params.rideId!);
  }
}

/// Session'daki ride'ları izle Use Case
class WatchRidesBySessionUseCase
    implements UseCase<Stream<List<RideModel>>, SessionParams> {
  final SessionRepository repository;

  WatchRidesBySessionUseCase(this.repository);

  @override
  Future<Stream<List<RideModel>>> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return repository.watchRidesBySession(params.sessionId!);
  }
}

/// Ride güncelle Use Case
class UpdateRideUseCase implements UseCase<void, SessionParams> {
  final SessionRepository repository;

  UpdateRideUseCase(this.repository);

  @override
  Future<void> call(SessionParams params) async {
    if (params.ride == null) {
      throw ArgumentError('Ride gerekli');
    }
    await repository.updateRide(params.ride!);
  }
}

/// Ride sil Use Case
class DeleteRideUseCase implements UseCase<void, SessionParams> {
  final SessionRepository repository;

  DeleteRideUseCase(this.repository);

  @override
  Future<void> call(SessionParams params) async {
    if (params.rideId == null) {
      throw ArgumentError('Ride ID gerekli');
    }
    await repository.deleteRide(params.rideId!);
  }
}

/// Session'daki tüm ride'ları sil Use Case
class DeleteAllRidesInSessionUseCase implements UseCase<void, SessionParams> {
  final SessionRepository repository;

  DeleteAllRidesInSessionUseCase(this.repository);

  @override
  Future<void> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    await repository.deleteAllRidesInSession(params.sessionId!);
  }
}

// ============================================================================
// BUSINESS LOGIC USE CASES
// ============================================================================

/// Aktif session varlığını kontrol et Use Case
class HasActiveSessionUseCase implements UseCase<bool, SessionParams> {
  final SessionRepository repository;

  HasActiveSessionUseCase(this.repository);

  @override
  Future<bool> call(SessionParams params) async {
    return await repository.hasActiveSession();
  }
}

/// Aktif session süresini getir Use Case
class GetActiveSessionDurationUseCase
    implements UseCase<Duration, SessionParams> {
  final SessionRepository repository;

  GetActiveSessionDurationUseCase(this.repository);

  @override
  Future<Duration> call(SessionParams params) async {
    return await repository.getActiveSessionDuration();
  }
}

/// Session kazancını hesapla Use Case
class CalculateSessionEarningsUseCase
    implements UseCase<double, SessionParams> {
  final SessionRepository repository;

  CalculateSessionEarningsUseCase(this.repository);

  @override
  Future<double> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.calculateSessionEarnings(params.sessionId!);
  }
}

/// Session yakıt maliyetini hesapla Use Case
class CalculateSessionFuelCostUseCase
    implements UseCase<double, SessionParams> {
  final SessionRepository repository;

  CalculateSessionFuelCostUseCase(this.repository);

  @override
  Future<double> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.calculateSessionFuelCost(params.sessionId!);
  }
}

/// Session net kârını hesapla Use Case
class CalculateSessionNetProfitUseCase
    implements UseCase<double, SessionParams> {
  final SessionRepository repository;

  CalculateSessionNetProfitUseCase(this.repository);

  @override
  Future<double> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.calculateSessionNetProfit(params.sessionId!);
  }
}

/// Session ride sayısını getir Use Case
class GetSessionRideCountUseCase implements UseCase<int, SessionParams> {
  final SessionRepository repository;

  GetSessionRideCountUseCase(this.repository);

  @override
  Future<int> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.getSessionRideCount(params.sessionId!);
  }
}

/// Toplam mesafeyi hesapla Use Case
class CalculateTotalDistanceUseCase implements UseCase<double, SessionParams> {
  final SessionRepository repository;

  CalculateTotalDistanceUseCase(this.repository);

  @override
  Future<double> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.calculateTotalDistance(params.sessionId!);
  }
}

/// Ortalama ride kazancını hesapla Use Case
class CalculateAverageEarningsPerRideUseCase
    implements UseCase<double, SessionParams> {
  final SessionRepository repository;

  CalculateAverageEarningsPerRideUseCase(this.repository);

  @override
  Future<double> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.calculateAverageEarningsPerRide(params.sessionId!);
  }
}

/// Ortalama kâr marjını hesapla Use Case
class CalculateAverageProfitMarginUseCase
    implements UseCase<double, SessionParams> {
  final SessionRepository repository;

  CalculateAverageProfitMarginUseCase(this.repository);

  @override
  Future<double> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.calculateAverageProfitMargin(params.sessionId!);
  }
}

/// Session'ın kârlı olup olmadığını kontrol et Use Case
class IsSessionProfitableUseCase implements UseCase<bool, SessionParams> {
  final SessionRepository repository;

  IsSessionProfitableUseCase(this.repository);

  @override
  Future<bool> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.isSessionProfitable(params.sessionId!);
  }
}

/// Session istatistiklerini getir Use Case
class GetSessionStatisticsUseCase
    implements UseCase<Map<String, dynamic>, SessionParams> {
  final SessionRepository repository;

  GetSessionStatisticsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.getSessionStatistics(params.sessionId!);
  }
}

/// Günlük istatistikleri getir Use Case
class GetDailyStatisticsUseCase
    implements UseCase<Map<String, dynamic>, SessionParams> {
  final SessionRepository repository;

  GetDailyStatisticsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(SessionParams params) async {
    if (params.date == null) {
      throw ArgumentError('Date gerekli');
    }
    return await repository.getDailyStatistics(params.date!);
  }
}

/// Haftalık istatistikleri getir Use Case
class GetWeeklyStatisticsUseCase
    implements UseCase<Map<String, dynamic>, SessionParams> {
  final SessionRepository repository;

  GetWeeklyStatisticsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(SessionParams params) async {
    if (params.date == null) {
      throw ArgumentError('Start of week date gerekli');
    }
    return await repository.getWeeklyStatistics(params.date!);
  }
}

/// Aylık istatistikleri getir Use Case
class GetMonthlyStatisticsUseCase
    implements UseCase<Map<String, dynamic>, SessionParams> {
  final SessionRepository repository;

  GetMonthlyStatisticsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(SessionParams params) async {
    if (params.date == null) {
      throw ArgumentError('Start of month date gerekli');
    }
    return await repository.getMonthlyStatistics(params.date!);
  }
}

// ============================================================================
// BREAK MANAGEMENT USE CASES
// ============================================================================

/// Çalışma zamanını hesapla Use Case
class CalculateWorkTimeUseCase implements UseCase<Duration, SessionParams> {
  final SessionRepository repository;

  CalculateWorkTimeUseCase(this.repository);

  @override
  Future<Duration> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.calculateWorkTime(params.sessionId!);
  }
}

/// Mola zamanını hesapla Use Case
class CalculateBreakTimeUseCase implements UseCase<Duration, SessionParams> {
  final SessionRepository repository;

  CalculateBreakTimeUseCase(this.repository);

  @override
  Future<Duration> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.calculateBreakTime(params.sessionId!);
  }
}

/// Mola verilebilir mi kontrol et Use Case
class CanTakeBreakUseCase implements UseCase<bool, SessionParams> {
  final SessionRepository repository;

  CanTakeBreakUseCase(this.repository);

  @override
  Future<bool> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.canTakeBreak(params.sessionId!);
  }
}

// ============================================================================
// SESSION STATE MANAGEMENT USE CASES (YENİ)
// ============================================================================

/// Session'ı molaya al Use Case
class PauseSessionUseCase implements UseCase<SessionModel, SessionParams> {
  final SessionRepository repository;

  PauseSessionUseCase(this.repository);

  @override
  Future<SessionModel> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }

    // Business Logic: Session durumu kontrolü
    final session = await repository.getSessionById(params.sessionId!);
    if (session == null) {
      throw Exception('Session bulunamadı');
    }

    if (!session.isActive) {
      throw Exception('Sadece aktif session\'lar molaya alınabilir');
    }

    return await repository.pauseSession(params.sessionId!);
  }
}

/// Session'ı devam ettir Use Case
class ResumeSessionUseCase implements UseCase<SessionModel, SessionParams> {
  final SessionRepository repository;

  ResumeSessionUseCase(this.repository);

  @override
  Future<SessionModel> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }

    // Business Logic: Session durumu kontrolü
    final session = await repository.getSessionById(params.sessionId!);
    if (session == null) {
      throw Exception('Session bulunamadı');
    }

    if (!session.isPaused) {
      throw Exception('Sadece molada olan session\'lar devam ettirilebilir');
    }

    return await repository.resumeSession(params.sessionId!);
  }
}

/// Session'ı tekrar başlat Use Case
class RestartSessionUseCase implements UseCase<SessionModel, SessionParams> {
  final SessionRepository repository;

  RestartSessionUseCase(this.repository);

  @override
  Future<SessionModel> call(SessionParams params) async {
    if (params.sessionId == null) {
      throw ArgumentError('Session ID gerekli');
    }
    return await repository.restartSession(params.sessionId!);
  }
}
