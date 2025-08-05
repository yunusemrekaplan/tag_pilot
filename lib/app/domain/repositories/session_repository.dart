import '../../data/models/session_model.dart';
import '../../data/models/ride_model.dart';

/// Session Repository Interface
/// SOLID: Dependency Inversion - High-level modules buna bağımlı, implementation'a değil
/// SOLID: Interface Segregation - Sadece session ve ride operasyonları
abstract class SessionRepository {
  // ============================================================================
  // SESSION OPERATIONS
  // ============================================================================

  // Create Operations
  Future<SessionModel> createSession(SessionModel session);
  Future<String> startSession(String vehicleId, String? packageId);

  // Read Operations
  Future<List<SessionModel>> getAllSessions();
  Future<SessionModel?> getSessionById(String sessionId);
  Stream<List<SessionModel>> watchSessions();

  // Read - Business Logic Operations
  Future<SessionModel?> getActiveSession();
  Future<List<SessionModel>> getSessionsByVehicle(String vehicleId);
  Future<List<SessionModel>> getSessionsByPackage(String packageId);
  Future<List<SessionModel>> getSessionsByDateRange(
      DateTime startDate, DateTime endDate);
  Future<List<SessionModel>> getCompletedSessions();

  // Update Operations
  Future<void> updateSession(SessionModel session);
  Future<void> completeSession(String sessionId);
  Future<SessionModel> pauseSession(String sessionId);
  Future<SessionModel> resumeSession(String sessionId);
  Future<SessionModel> restartSession(String sessionId);

  // Delete Operations
  Future<void> deleteSession(String sessionId);
  Future<void> deleteAllUserSessions();

  // ============================================================================
  // RIDE OPERATIONS
  // ============================================================================

  // Create Operations
  Future<void> createRide(RideModel ride);
  Future<String> addRideToSession(
    String sessionId,
    double distanceKm,
    double earnings,
    double fuelRate,
    double fuelPrice,
    String? notes,
  );

  // Read Operations
  Future<List<RideModel>> getRidesBySession(String sessionId);
  Future<RideModel?> getRideById(String rideId);
  Stream<List<RideModel>> watchRidesBySession(String sessionId);

  // Update Operations
  Future<void> updateRide(RideModel ride);

  // Delete Operations
  Future<void> deleteRide(String rideId);
  Future<void> deleteAllRidesInSession(String sessionId);

  // ============================================================================
  // BUSINESS LOGIC OPERATIONS
  // ============================================================================

  // Session Business Logic
  Future<bool> hasActiveSession();
  Future<Duration> getActiveSessionDuration();
  Future<double> calculateSessionEarnings(String sessionId);
  Future<double> calculateSessionFuelCost(String sessionId);
  Future<double> calculateSessionNetProfit(String sessionId);
  Future<int> getSessionRideCount(String sessionId);

  // Ride Business Logic
  Future<double> calculateTotalDistance(String sessionId);
  Future<double> calculateAverageEarningsPerRide(String sessionId);
  Future<double> calculateAverageProfitMargin(String sessionId);
  Future<bool> isSessionProfitable(String sessionId);

  // Analytics
  Future<Map<String, dynamic>> getSessionStatistics(String sessionId);
  Future<Map<String, dynamic>> getDailyStatistics(DateTime date);
  Future<Map<String, dynamic>> getWeeklyStatistics(DateTime startOfWeek);
  Future<Map<String, dynamic>> getMonthlyStatistics(DateTime startOfMonth);

  // Break Management
  Future<Duration> calculateWorkTime(String sessionId);
  Future<Duration> calculateBreakTime(String sessionId);
  Future<bool> canTakeBreak(String sessionId);

  Future<void> endSession(String sessionId);
  Future<List<SessionModel>> getUserSessions();
}
