import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/session_model.dart';
import '../../../data/enums/session_status.dart';
import '../../../data/enums/package_type.dart';
import '../controllers/session_controller.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../routes/app_routes.dart';

/// Sessions List View
/// Tüm çalışma seanslarının görüntülendiği ve yönetildiği ana sayfa
/// SOLID: Single Responsibility - Sadece sessions listesi UI'ı
/// Clean Architecture: Controller üzerinden business logic'e erişim
/// GetView pattern ile reactive state management
class SessionsListView extends GetView<SessionController> {
  const SessionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return _SessionsListViewContent(controller: controller);
  }
}

class _SessionsListViewContent extends StatefulWidget {
  final SessionController controller;
  const _SessionsListViewContent({required this.controller});

  @override
  State<_SessionsListViewContent> createState() => _SessionsListViewContentState();
}

class _SessionsListViewContentState extends State<_SessionsListViewContent> {
  SessionController get controller => widget.controller;
  late final DashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    dashboardController = Get.find<DashboardController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Seferlerim',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        Obx(() => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
                if (controller.hasActiveFilters)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            )),
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: _showAnalyticsDialog,
        ),
      ],
    );
  }

  // Tab bar kaldırıldı - filtre sistemi kullanılıyor

  Widget _buildBody() {
    return _buildSessionsList('all');
  }

  Widget _buildSessionsList(String filter) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final filteredSessions = controller.getFilteredSessions(filter);

      if (filteredSessions.isEmpty) {
        return _buildEmptyState(filter);
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: filteredSessions.length,
        itemBuilder: (context, index) {
          final session = filteredSessions[index];
          return _buildSessionCard(session, index);
        },
      );
    });
  }

  Widget _buildSessionCard(SessionModel session, int index) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        top: index == 0 ? 8 : 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(session.status).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSessionDetails(session),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSessionHeader(session),
                const SizedBox(height: 12),
                _buildSessionStats(session),
                const SizedBox(height: 12),
                _buildSessionActions(session),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHeader(SessionModel session) {
    return Row(
      children: [
        // Status Indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getStatusColor(session.status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),

        // Session Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getStatusText(session.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(session.status),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      session.packageType?.displayName ?? 'Paket Yok',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                session.startTime.toTurkishDateTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionStats(SessionModel session) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildStatColumn(
            'Süre',
            session.totalDurationFormatted,
            Icons.schedule_outlined,
            AppColors.primary,
          ),
          _buildStatColumnDivider(),
          _buildStatColumn(
            'Durum',
            _getStatusText(session.status),
            Icons.info_outline,
            _getStatusColor(session.status),
          ),
          _buildStatColumnDivider(),
          _buildStatColumn(
            'Paket',
            session.packageType?.displayName ?? 'Yok',
            Icons.card_giftcard_outlined,
            AppColors.warning,
          ),
          _buildStatColumnDivider(),
          _buildStatColumn(
            'Fiyat',
            session.packagePrice != null ? '₺${session.packagePrice!.toStringAsFixed(0)}' : '₺0',
            Icons.monetization_on_outlined,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumnDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.outline.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildSessionActions(SessionModel session) {
    return Obx(() {
      final isBusy = controller.isBusy;
      if (session.isActive) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isBusy ? null : () => _pauseSession(session),
                icon: isBusy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                        ),
                      )
                    : const Icon(Icons.pause_outlined, size: 16),
                label: Text(isBusy ? 'İşleniyor...' : 'Molaya Al',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBusy ? AppColors.warning.withOpacity(0.6) : AppColors.warning,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isBusy
                    ? null
                    : () async {
                        final success = await controller.completeActiveSession();
                        if (success) {
                          await controller.refreshSessions();
                          await dashboardController.refreshDashboard();
                        }
                      },
                icon: isBusy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                        ),
                      )
                    : const Icon(Icons.stop_circle_outlined, size: 16),
                label: Text(isBusy ? 'İşleniyor...' : 'Seferi Bitir',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBusy ? AppColors.error.withOpacity(0.6) : AppColors.error,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildSecondaryActionButton(
              Icons.visibility_outlined,
              'Detay',
              () => _showSessionDetails(session),
            ),
          ],
        );
      } else if (session.isPaused) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isBusy ? null : () => _resumeSession(session),
                icon: isBusy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                        ),
                      )
                    : const Icon(Icons.play_arrow_outlined, size: 16),
                label: Text(isBusy ? 'İşleniyor...' : 'Devam Et',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBusy ? AppColors.success.withOpacity(0.6) : AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isBusy
                    ? null
                    : () async {
                        final success = await controller.completeActiveSession();
                        if (success) {
                          await controller.refreshSessions();
                          await dashboardController.refreshDashboard();
                        }
                      },
                icon: isBusy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                        ),
                      )
                    : const Icon(Icons.stop_circle_outlined, size: 16),
                label: Text(isBusy ? 'İşleniyor...' : 'Seferi Bitir',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBusy ? AppColors.error.withOpacity(0.6) : AppColors.error,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildSecondaryActionButton(
              Icons.visibility_outlined,
              'Detay',
              () => _showSessionDetails(session),
            ),
            // Silme özelliği kaldırıldı
          ],
        );
      } else if (session.isCompleted) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle_outlined, size: 16),
                label: const Text('Tamamlandı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success.withOpacity(0.5),
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildSecondaryActionButton(
              Icons.visibility_outlined,
              'Detay',
              () => _showSessionDetails(session),
            ),
          ],
        );
      } else {
        // Diğer durumlar için sadece detay
        return Row(
          children: [
            _buildSecondaryActionButton(
              Icons.visibility_outlined,
              'Detay',
              () => _showSessionDetails(session),
            ),
          ],
        );
      }
    });
  }

  Widget _buildSecondaryActionButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 16,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String message;
    String subtitle;
    IconData icon;

    // Filtre sistemi kullanıldığı için genel mesaj
    if (controller.hasActiveFilters) {
      message = 'Filtre kriterlerine uygun sefer bulunamadı';
      subtitle = 'Filtreleri değiştirerek farklı sonuçlar arayabilirsiniz';
      icon = Icons.filter_list_outlined;
    } else {
      message = 'Henüz sefer bulunamadı';
      subtitle = 'İlk seferinizi başlatmak için + butonuna dokunun';
      icon = Icons.route_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => controller.startSessionWithDialog(context),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: const Icon(Icons.add),
      label: const Text(
        'Yeni Sefer',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================================
  // ACTION METHODS - Controller methods kullanıyor
  // ============================================================================

  void _showFilterDialog() {
    Get.dialog(
      SessionFilterDialog(
        controller: controller,
        onFiltersApplied: () {
          // Filtreler uygulandığında UI'ı güncelle
          setState(() {});
        },
      ),
      barrierDismissible: true,
    );
  }

  void _showAnalyticsDialog() {
    // TODO: Implement analytics dialog
    NotificationHelper.showInfo('Analitik özelliği yakında eklenecek');
  }

  void _showSessionDetails(SessionModel session) {
    Get.toNamed('${AppRoutes.sessionDetail}?id=${session.id}');
  }

  // Sefer durumu değiştiğinde dashboardController.refreshDashboard() çağır
  Future<void> _pauseSession(SessionModel session) async {
    final success = await controller.pauseActiveSession();
    if (success) {
      await controller.refreshSessions();
      await dashboardController.refreshDashboard();
    }
  }

  Future<void> _resumeSession(SessionModel session) async {
    final success = await controller.resumeActiveSession();
    if (success) {
      await controller.refreshSessions();
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
}

/// Session Filter Dialog
/// Sefer filtreleme için dialog widget'ı
class SessionFilterDialog extends StatefulWidget {
  final SessionController controller;
  final VoidCallback onFiltersApplied;

  const SessionFilterDialog({
    super.key,
    required this.controller,
    required this.onFiltersApplied,
  });

  @override
  State<SessionFilterDialog> createState() => _SessionFilterDialogState();
}

class _SessionFilterDialogState extends State<SessionFilterDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  SessionStatus? _selectedStatus;
  PackageType? _selectedPackageType;

  @override
  void initState() {
    super.initState();
    // Mevcut filtreleri yükle
    _startDate = widget.controller.filterStartDate;
    _endDate = widget.controller.filterEndDate;
    _selectedStatus = widget.controller.filterStatus;
    _selectedPackageType = widget.controller.filterPackageType;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateFilters(),
                    const SizedBox(height: 20),
                    _buildStatusFilter(),
                    const SizedBox(height: 20),
                    _buildPackageTypeFilter(),
                    const SizedBox(height: 24),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_list,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sefer Filtreleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (widget.controller.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarih Aralığı',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'Başlangıç',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                'Bitiş',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime?) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? date.toTurkishDate : 'Tarih Seç',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null ? AppColors.onSurface : AppColors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sefer Durumu',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              'Tümü',
              null,
              _selectedStatus,
              (status) => setState(() => _selectedStatus = status),
            ),
            _buildFilterChip(
              'Aktif',
              SessionStatus.active,
              _selectedStatus,
              (status) => setState(() => _selectedStatus = status),
            ),
            _buildFilterChip(
              'Molada',
              SessionStatus.paused,
              _selectedStatus,
              (status) => setState(() => _selectedStatus = status),
            ),
            _buildFilterChip(
              'Tamamlandı',
              SessionStatus.completed,
              _selectedStatus,
              (status) => setState(() => _selectedStatus = status),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackageTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paket Türü',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              'Tümü',
              null,
              _selectedPackageType,
              (packageType) => setState(() => _selectedPackageType = packageType),
            ),
            ...PackageType.values.map((packageType) => _buildFilterChip(
                  packageType.displayName,
                  packageType,
                  _selectedPackageType,
                  (selectedPackageType) => setState(() => _selectedPackageType = selectedPackageType),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip<T>(
    String label,
    T? value,
    T? selectedValue,
    Function(T?) onSelected,
  ) {
    final isSelected = value == selectedValue;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(selected ? value : null);
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.onPrimary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.outline.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              widget.controller.clearFilters();
              widget.onFiltersApplied();
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Temizle'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.controller.applyFilters(
                startDate: _startDate,
                endDate: _endDate,
                status: _selectedStatus,
                packageType: _selectedPackageType,
              );
              widget.onFiltersApplied();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Uygula'),
          ),
        ),
      ],
    );
  }
}
