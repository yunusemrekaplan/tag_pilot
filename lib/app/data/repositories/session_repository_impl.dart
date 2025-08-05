import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/error_handler_service.dart';
import '../models/session_model.dart';
import '../models/ride_model.dart';
import '../enums/session_status.dart';

/// Session Repository Implementation (Clean Architecture)
/// SOLID: Dependency Inversion - SessionRepository interface'ini implement eder
/// SOLID: Single Responsibility - Sadece session ve ride data operations
class SessionRepositoryImpl implements SessionRepository {
  late final DatabaseService _databaseService;
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;

  SessionRepositoryImpl() {
    _databaseService = Get.find<DatabaseService>();
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
  }

  // Middleware kontrolü yaptığı için ! operatörü güvenli
  String get _userId => _authService.currentUserId!;

  // ============================================================================
  // SESSION CRUD OPERATIONS
  // ============================================================================

  @override
  Future<SessionModel> createSession(SessionModel session) async {
    try {
      final sessionWithTimestamp = session.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Eğer session ID boşsa, Firestore'un otomatik ID oluşturmasına izin ver
      DocumentReference? docRef;
      if (session.id.isEmpty) {
        docRef = await _databaseService.addDocument(
          '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}',
          sessionWithTimestamp.toJson(),
        );
      } else {
        docRef = await _databaseService.setDocument(
          '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/${session.id}',
          sessionWithTimestamp.toJson(),
        );
      }

      if (AppConstants.enableLogging) {
        print('🎯 Session created: ${docRef?.id}');
      }
      return sessionWithTimestamp.copyWith(id: docRef?.id ?? session.id);
    } catch (e) {
      _errorHandler.logError('Create session', e);
      rethrow;
    }
  }

  @override
  Future<String> startSession(String vehicleId, String? packageId) async {
    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      final session = SessionModel(
        id: sessionId,
        vehicleId: vehicleId,
        packageId: packageId,
        startTime: DateTime.now(),
        status: SessionStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: _userId,
      );

      final createdSession = await createSession(session);
      if (AppConstants.enableLogging) {
        print('🎯 Session started: ${createdSession.id}');
      }
      return createdSession.id;
    } catch (e) {
      _errorHandler.logError('Start session', e);
      throw Exception('Session başlatılırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<SessionModel>> getAllSessions() async {
    try {
      final querySnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}',
      );

      return querySnapshot.docs
          .map((doc) => SessionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Get all sessions', e);
      throw Exception('Session\'lar yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<SessionModel?> getSessionById(String sessionId) async {
    try {
      final doc = await _databaseService.getDocumentById(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId',
      );

      if (doc.exists && doc.data() != null) {
        return SessionModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      _errorHandler.logError('Get session by ID', e);
      throw Exception('Session yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Stream<List<SessionModel>> watchSessions() {
    try {
      return _databaseService
          .watchCollection('${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}')
          .map((snapshot) => snapshot.docs
              .map((doc) => SessionModel.fromJson({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  }))
              .toList());
    } catch (e) {
      _errorHandler.logError('Watch sessions', e);
      throw Exception('Session dinleme hatası: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<SessionModel?> getActiveSession() async {
    try {
      // Yeni SessionStatus sistemi kullanarak active veya paused session'ları ara
      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}',
        'status',
        'active',
      );

      // Active session var mı kontrol et
      for (final doc in querySnapshot.docs) {
        final session = SessionModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });

        if (session.isActive) {
          return session;
        }
      }

      // Active session yoksa paused session'ları kontrol et
      final pausedQuerySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}',
        'status',
        'paused',
      );

      for (final doc in pausedQuerySnapshot.docs) {
        final session = SessionModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });

        if (session.isPaused) {
          return session;
        }
      }

      return null;
    } catch (e) {
      _errorHandler.logError('Get active session', e);
      throw Exception('Aktif session yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> completeSession(String sessionId) async {
    try {
      await _databaseService.updateDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId',
        {
          'endTime': DateTime.now().toIso8601String(),
          'status': 'completed', // Yeni SessionStatus sistemi
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (AppConstants.enableLogging) {
        print('🎯 Session completed: $sessionId');
      }
    } catch (e) {
      _errorHandler.logError('Complete session', e);
      throw Exception('Session tamamlanırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      // Önce session'daki tüm ride'ları sil
      await deleteAllRidesInSession(sessionId);

      // Sonra session'ı sil
      await _databaseService.deleteDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId',
      );

      if (AppConstants.enableLogging) {
        print('🎯 Session deleted: $sessionId');
      }
    } catch (e) {
      _errorHandler.logError('Delete session', e);
      throw Exception('Session silinirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // RIDE CRUD OPERATIONS
  // ============================================================================

  @override
  Future<void> createRide(RideModel ride) async {
    try {
      final rideWithTimestamp = ride.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.setDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/${ride.sessionId}/${DatabaseConstants.ridesCollection}/${ride.id}',
        rideWithTimestamp.toJson(),
      );

      if (AppConstants.enableLogging) {
        print('🚗 Ride created: ${ride.id} in session: ${ride.sessionId}');
      }
    } catch (e) {
      _errorHandler.logError('Create ride', e);
      throw Exception('Ride oluşturulurken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<String> addRideToSession(
    String sessionId,
    double distanceKm,
    double earnings,
    double fuelRate,
    double fuelPrice,
    String? notes,
  ) async {
    try {
      final rideId = DateTime.now().millisecondsSinceEpoch.toString();
      final ride = RideModel.calculate(
        id: rideId,
        sessionId: sessionId,
        distanceKm: distanceKm,
        earnings: earnings,
        fuelRate: fuelRate,
        fuelPrice: fuelPrice,
        notes: notes,
      );

      await createRide(ride);
      return rideId;
    } catch (e) {
      _errorHandler.logError('Add ride to session', e);
      throw Exception('Ride eklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<RideModel>> getRidesBySession(String sessionId) async {
    try {
      final querySnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId/${DatabaseConstants.ridesCollection}',
      );

      return querySnapshot.docs
          .map((doc) => RideModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Get rides by session', e);
      throw Exception('Session ride\'ları yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<RideModel?> getRideById(String rideId) async {
    try {
      // Basit implementation - tüm session'lardaki ride'ları ara
      final allSessions = await getAllSessions();
      for (final session in allSessions) {
        final rides = await getRidesBySession(session.id);
        final foundRide = rides.where((ride) => ride.id == rideId).firstOrNull;
        if (foundRide != null) {
          return foundRide;
        }
      }
      return null;
    } catch (e) {
      _errorHandler.logError('Get ride by ID', e);
      return null;
    }
  }

  @override
  Stream<List<RideModel>> watchRidesBySession(String sessionId) {
    try {
      return _databaseService
          .watchCollection(
              '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId/${DatabaseConstants.ridesCollection}')
          .map((snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  }))
              .toList());
    } catch (e) {
      _errorHandler.logError('Watch rides by session', e);
      throw Exception('Ride dinleme hatası: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> updateRide(RideModel ride) async {
    try {
      final rideWithTimestamp = ride.copyWith(updatedAt: DateTime.now());

      await _databaseService.updateDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/${ride.sessionId}/${DatabaseConstants.ridesCollection}/${ride.id}',
        rideWithTimestamp.toJson(),
      );
    } catch (e) {
      _errorHandler.logError('Update ride', e);
      throw Exception('Ride güncellenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> deleteRide(String rideId) async {
    try {
      final ride = await getRideById(rideId);
      if (ride == null) throw Exception('Ride bulunamadı');

      await _databaseService.deleteDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/${ride.sessionId}/${DatabaseConstants.ridesCollection}/$rideId',
      );
    } catch (e) {
      _errorHandler.logError('Delete ride', e);
      throw Exception('Ride silinirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> deleteAllRidesInSession(String sessionId) async {
    try {
      final batch = _databaseService.getBatch();
      final ridesSnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId/${DatabaseConstants.ridesCollection}',
      );

      for (final doc in ridesSnapshot.docs) {
        final docRef = _databaseService.getDocument(
          '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId/${DatabaseConstants.ridesCollection}/${doc.id}',
        );
        batch.delete(docRef);
      }

      await _databaseService.commitBatch(batch);
    } catch (e) {
      _errorHandler.logError('Delete all rides in session', e);
      throw Exception('Session ride\'ları silinirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // BUSINESS LOGIC OPERATIONS
  // ============================================================================

  @override
  Future<bool> hasActiveSession() async {
    try {
      final activeSession = await getActiveSession();
      return activeSession != null;
    } catch (e) {
      _errorHandler.logError('Check has active session', e);
      return false;
    }
  }

  @override
  Future<Duration> getActiveSessionDuration() async {
    try {
      final activeSession = await getActiveSession();
      return activeSession?.activeDuration ?? Duration.zero;
    } catch (e) {
      _errorHandler.logError('Get active session duration', e);
      return Duration.zero;
    }
  }

  @override
  Future<double> calculateSessionEarnings(String sessionId) async {
    try {
      final rides = await getRidesBySession(sessionId);
      return rides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
    } catch (e) {
      _errorHandler.logError('Calculate session earnings', e);
      return 0.0;
    }
  }

  @override
  Future<double> calculateSessionFuelCost(String sessionId) async {
    try {
      final rides = await getRidesBySession(sessionId);
      return rides.fold<double>(0.0, (sum, ride) => sum + ride.fuelCost);
    } catch (e) {
      _errorHandler.logError('Calculate session fuel cost', e);
      return 0.0;
    }
  }

  @override
  Future<double> calculateSessionNetProfit(String sessionId) async {
    try {
      final rides = await getRidesBySession(sessionId);
      return rides.fold<double>(0.0, (sum, ride) => sum + ride.netProfit);
    } catch (e) {
      _errorHandler.logError('Calculate session net profit', e);
      return 0.0;
    }
  }

  @override
  Future<int> getSessionRideCount(String sessionId) async {
    try {
      final rides = await getRidesBySession(sessionId);
      return rides.length;
    } catch (e) {
      _errorHandler.logError('Get session ride count', e);
      return 0;
    }
  }

  @override
  Future<double> calculateTotalDistance(String sessionId) async {
    try {
      final rides = await getRidesBySession(sessionId);
      return rides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);
    } catch (e) {
      _errorHandler.logError('Calculate total distance', e);
      return 0.0;
    }
  }

  @override
  Future<double> calculateAverageEarningsPerRide(String sessionId) async {
    try {
      final rides = await getRidesBySession(sessionId);
      if (rides.isEmpty) return 0.0;

      final totalEarnings = rides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
      return totalEarnings / rides.length;
    } catch (e) {
      _errorHandler.logError('Calculate average earnings per ride', e);
      return 0.0;
    }
  }

  @override
  Future<double> calculateAverageProfitMargin(String sessionId) async {
    try {
      final rides = await getRidesBySession(sessionId);
      if (rides.isEmpty) return 0.0;

      final totalMargin = rides.fold<double>(0.0, (sum, ride) => sum + ride.profitMargin);
      return totalMargin / rides.length;
    } catch (e) {
      _errorHandler.logError('Calculate average profit margin', e);
      return 0.0;
    }
  }

  @override
  Future<bool> isSessionProfitable(String sessionId) async {
    try {
      final netProfit = await calculateSessionNetProfit(sessionId);
      return netProfit > 0;
    } catch (e) {
      _errorHandler.logError('Check session profitability', e);
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getSessionStatistics(String sessionId) async {
    try {
      final session = await getSessionById(sessionId);
      if (session == null) return {};

      final rides = await getRidesBySession(sessionId);
      final totalEarnings = await calculateSessionEarnings(sessionId);
      final totalFuelCost = await calculateSessionFuelCost(sessionId);
      final netProfit = await calculateSessionNetProfit(sessionId);
      final totalDistance = await calculateTotalDistance(sessionId);

      return {
        'sessionId': sessionId,
        'duration': session.durationFormatted,
        'rideCount': rides.length,
        'totalEarnings': totalEarnings,
        'totalFuelCost': totalFuelCost,
        'netProfit': netProfit,
        'totalDistance': totalDistance,
        'isProfitable': netProfit > 0,
        'profitMargin': totalEarnings > 0 ? (netProfit / totalEarnings) * 100 : 0,
      };
    } catch (e) {
      _errorHandler.logError('Get session statistics', e);
      return {};
    }
  }

  // ============================================================================
  // STUB IMPLEMENTATIONS (Gelecekte implement edilecek)
  // ============================================================================

  @override
  Future<List<SessionModel>> getSessionsByVehicle(String vehicleId) async => [];

  @override
  Future<List<SessionModel>> getSessionsByPackage(String packageId) async => [];

  @override
  Future<List<SessionModel>> getSessionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _databaseService.getDocumentsWhereRange(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}',
        'createdAt',
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      );

      return querySnapshot.docs
          .map((doc) => SessionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Get sessions by date range', e);
      throw Exception('Tarih aralığındaki session\'lar alınırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<SessionModel>> getCompletedSessions() async => [];

  @override
  Future<void> updateSession(SessionModel session) async {}

  @override
  Future<SessionModel> pauseSession(String sessionId) async {
    try {
      // Mevcut session'ı al
      final session = await getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session bulunamadı: $sessionId');
      }

      // Session'ı pause durumuna getir ve pause history'e ekle
      final now = DateTime.now();
      final updatedPauseHistory = List<SessionPauseRecord>.from(session.pauseHistory)
        ..add(SessionPauseRecord(pausedAt: now));

      final pausedSession = session.copyWith(
        status: SessionStatus.paused,
        lastPausedAt: now,
        pauseHistory: updatedPauseHistory,
        updatedAt: now,
      );

      await _databaseService.updateDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId',
        pausedSession.toJson(),
      );

      if (AppConstants.enableLogging) {
        print('⏸️ Session paused: $sessionId');
      }

      return pausedSession;
    } catch (e) {
      _errorHandler.logError('Pause session', e);
      throw Exception('Session molaya alınırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<SessionModel> resumeSession(String sessionId) async {
    try {
      // Mevcut session'ı al
      final session = await getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session bulunamadı: $sessionId');
      }

      // Son pause record'u güncelle
      final now = DateTime.now();
      final updatedPauseHistory = List<SessionPauseRecord>.from(session.pauseHistory);

      if (updatedPauseHistory.isNotEmpty && updatedPauseHistory.last.resumedAt == null) {
        // Son pause'u resume et
        final lastPause = updatedPauseHistory.removeLast();
        updatedPauseHistory.add(SessionPauseRecord(
          pausedAt: lastPause.pausedAt,
          resumedAt: now,
        ));
      }

      final resumedSession = session.copyWith(
        status: SessionStatus.active,
        lastResumedAt: now,
        pauseHistory: updatedPauseHistory,
        updatedAt: now,
      );

      await _databaseService.updateDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId',
        resumedSession.toJson(),
      );

      if (AppConstants.enableLogging) {
        print('▶️ Session resumed: $sessionId');
      }

      return resumedSession;
    } catch (e) {
      _errorHandler.logError('Resume session', e);
      throw Exception('Session devam ettirilirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<SessionModel> restartSession(String sessionId) async {
    try {
      final session = await getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session bulunamadı: $sessionId');
      }
      final restartedSession = session.copyWith(
        status: SessionStatus.active,
        endTime: null,
        updatedAt: DateTime.now(),
      );
      await _databaseService.updateDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId',
        restartedSession.toJson(),
      );
      if (AppConstants.enableLogging) {
        print('🔄 Session restarted: $sessionId');
      }
      return restartedSession;
    } catch (e) {
      _errorHandler.logError('Restart session', e);
      throw Exception('Session tekrar başlatılırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> deleteAllUserSessions() async {}

  @override
  Future<Map<String, dynamic>> getDailyStatistics(DateTime date) async => {};

  @override
  Future<Map<String, dynamic>> getWeeklyStatistics(DateTime startOfWeek) async => {};

  @override
  Future<Map<String, dynamic>> getMonthlyStatistics(DateTime startOfMonth) async => {};

  @override
  Future<Duration> calculateWorkTime(String sessionId) async => Duration.zero;

  @override
  Future<Duration> calculateBreakTime(String sessionId) async => Duration.zero;

  @override
  Future<bool> canTakeBreak(String sessionId) async => true;

  @override
  Future<void> endSession(String sessionId) async {
    try {
      await _databaseService.updateDocument(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId',
        {
          'status': 'completed', // Yeni SessionStatus sistemi
          'endTime': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _errorHandler.logError('End session', e);
      throw Exception('Session sonlandırılırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<SessionModel>> getUserSessions() async {
    try {
      final querySnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}',
      );
      return querySnapshot.docs
          .map((doc) => SessionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Get user sessions', e);
      return [];
    }
  }
}
