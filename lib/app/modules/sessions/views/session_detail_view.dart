import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../data/models/session_model.dart';
import '../../../data/enums/session_status.dart';
import '../../../data/enums/package_type.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/session_controller.dart';

/// Session Detail View
/// Sefer detaylarının görüntülendiği ve yönetildiği sayfa
/// SOLID: Single Responsibility - Sadece session detay UI'ı
/// Clean Architecture: Controller üzerinden business logic'e erişim
/// GetView pattern ile reactive state management
class SessionDetailView extends GetView<SessionController> {
  final String sessionId;

  const SessionDetailView({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return _SessionDetailViewContent(
      controller: controller,
      sessionId: sessionId,
    );
  }
}

class _SessionDetailViewContent extends StatefulWidget {
  final SessionController controller;
  final String sessionId;

  const _SessionDetailViewContent({
    required this.controller,
    required this.sessionId,
  });

  @override
  State<_SessionDetailViewContent> createState() => _SessionDetailViewContentState();
}

class _SessionDetailViewContentState extends State<_SessionDetailViewContent> {
  SessionController get controller => widget.controller;
  String get sessionId => widget.sessionId;
  late final DashboardController dashboardController;

  SessionModel? session;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    dashboardController = Get.find<DashboardController>();
    _loadSessionDetails();
  }

  Future<void> _loadSessionDetails() async {
    setState(() => isLoading = true);

    try {
      // Session'ı controller'dan al
      final sessions = controller.sessions;
      session = sessions.firstWhereOrNull((s) => s.id == sessionId);

      if (session == null) {
        NotificationHelper.showError('Sefer bulunamadı');
        Get.back();
        return;
      }
    } catch (e) {
      NotificationHelper.showError('Sefer detayları yüklenirken hata oluştu');
      Get.back();
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(
          child: Text('Sefer bulunamadı'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Sefer Detayı',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        // Düzenleme ve silme özellikleri kaldırıldı
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildSessionInfoCard(),
          const SizedBox(height: 16),
          _buildTimingCard(),
          const SizedBox(height: 16),
          _buildPackageCard(),
          const SizedBox(height: 16),
          _buildPauseHistoryCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(session!.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(session!.status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getStatusColor(session!.status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getStatusIcon(session!.status),
              color: AppColors.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(session!.status),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(session!.status),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(session!.status),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sefer Bilgileri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Başlangıç', session!.startTime.toTurkishDateTime),
          if (session!.endTime != null) _buildInfoRow('Bitiş', session!.endTime!.toTurkishDateTime),
          _buildInfoRow('Araç ID', session!.vehicleId),
          if (session!.currentFuelPricePerLitre != null)
            _buildInfoRow(
              'Yakıt Fiyatı',
              '₺${session!.currentFuelPricePerLitre!.toStringAsFixed(2)}/L',
            ),
        ],
      ),
    );
  }

  Widget _buildTimingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Zaman Bilgileri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimingItem(
                  'Aktif Süre',
                  session!.durationFormatted,
                  Icons.play_circle_outline,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimingItem(
                  'Toplam Süre',
                  session!.totalDurationFormatted,
                  Icons.timer_outlined,
                  AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimingItem(
                  'Mola Süresi',
                  _formatDuration(session!.totalPauseDuration),
                  Icons.pause_circle_outline,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimingItem(
                  'Mola Sayısı',
                  session!.pauseHistory.length.toString(),
                  Icons.pause_outlined,
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimingItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard() {
    if (session!.packageType == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Paket Bilgisi Yok',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Paket Bilgileri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Paket Türü', session!.packageType!.displayName),
          if (session!.packagePrice != null)
            _buildInfoRow('Paket Fiyatı', '₺${session!.packagePrice!.toStringAsFixed(0)}'),
          _buildInfoRow('Günlük Maliyet', '₺${session!.dailyPackageCost.toStringAsFixed(2)}'),
          if (session!.packageEndTime != null) _buildInfoRow('Paket Bitiş', session!.packageEndTime!.toTurkishDate),
          _buildInfoRow('Kalan Gün', session!.remainingPackageDays.toString()),
        ],
      ),
    );
  }

  Widget _buildPauseHistoryCard() {
    if (session!.pauseHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.pause_circle_outline,
              color: AppColors.info,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Mola Geçmişi Yok',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pause_circle_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Mola Geçmişi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...session!.pauseHistory.asMap().entries.map((entry) {
            final index = entry.key;
            final pause = entry.value;
            return _buildPauseHistoryItem(index + 1, pause);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPauseHistoryItem(int index, SessionPauseRecord pause) {
    return Container(
      margin: EdgeInsets.only(bottom: index < session!.pauseHistory.length ? 12 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mola #$index',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      pause.isCurrentlyPaused ? AppColors.warning.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pause.isCurrentlyPaused ? 'Devam Ediyor' : 'Tamamlandı',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: pause.isCurrentlyPaused ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Başlangıç', pause.pausedAt.toTurkishDateTime),
          if (pause.resumedAt != null) _buildInfoRow('Bitiş', pause.resumedAt!.toTurkishDateTime),
          _buildInfoRow('Süre', _formatDuration(pause.pauseDuration)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Obx(() {
      if (session!.isCompleted) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check_circle_outlined),
                  label: const Text('Tamamlandı'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success.withOpacity(0.5),
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            if (session!.isActive) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isBusy ? null : _pauseSession,
                  icon: controller.isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                          ),
                        )
                      : const Icon(Icons.pause_outlined),
                  label: Text(controller.isBusy ? 'İşleniyor...' : 'Molaya Al'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isBusy ? AppColors.warning.withOpacity(0.6) : AppColors.warning,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ] else if (session!.isPaused) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isBusy ? null : _resumeSession,
                  icon: controller.isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                          ),
                        )
                      : const Icon(Icons.play_arrow_outlined),
                  label: Text(controller.isBusy ? 'İşleniyor...' : 'Devam Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isBusy ? AppColors.success.withOpacity(0.6) : AppColors.success,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isBusy ? null : _completeSession,
                icon: controller.isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                        ),
                      )
                    : const Icon(Icons.stop_circle_outlined),
                label: Text(controller.isBusy ? 'İşleniyor...' : 'Seferi Bitir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isBusy ? AppColors.error.withOpacity(0.6) : AppColors.error,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================================
  // ACTION METHODS
  // ============================================================================

  // Düzenleme ve silme özellikleri kaldırıldı

  Future<void> _pauseSession() async {
    final success = await controller.pauseActiveSession();
    if (success) {
      await _loadSessionDetails();
      await dashboardController.refreshDashboard();
    }
  }

  Future<void> _resumeSession() async {
    final success = await controller.resumeActiveSession();
    if (success) {
      await _loadSessionDetails();
      await dashboardController.refreshDashboard();
    }
  }

  Future<void> _completeSession() async {
    final success = await controller.completeActiveSession();
    if (success) {
      await _loadSessionDetails();
      await dashboardController.refreshDashboard();
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return AppColors.success;
      case SessionStatus.paused:
        return AppColors.warning;
      case SessionStatus.completed:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return Icons.play_circle_outline;
      case SessionStatus.paused:
        return Icons.pause_circle_outline;
      case SessionStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return 'AKTİF';
      case SessionStatus.paused:
        return 'MOLADA';
      case SessionStatus.completed:
        return 'TAMAMLANDI';
    }
  }

  String _getStatusDescription(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return 'Sefer şu anda aktif olarak devam ediyor';
      case SessionStatus.paused:
        return 'Sefer geçici olarak duraklatıldı';
      case SessionStatus.completed:
        return 'Sefer başarıyla tamamlandı';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}s ${minutes}d';
    } else {
      return '${minutes}d';
    }
  }
}
