import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/core/theme/app_colors.dart';
import 'package:tag_pilot/app/modules/dashboard/controllers/dashboard_controller.dart';

/// Hero Session Card - Dynamic status display with pause/resume functionality
class HeroSessionCard extends GetView<DashboardController> {
  const HeroSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasActiveSession = controller.hasActiveSession;
      final sessionStatus = _getSessionStatus();
      final isProcessing = controller.isSessionProcessing;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: _getGradientForStatus(sessionStatus),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.onPrimary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getColorForStatus(sessionStatus).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    // Status Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.onPrimary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getIconForStatus(sessionStatus),
                        color: sessionStatus == 'active'
                            ? AppColors.primary
                            : sessionStatus == 'paused'
                                ? AppColors.primary
                                : AppColors.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Status Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(sessionStatus),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: sessionStatus == 'active'
                                      ? AppColors.primary
                                      : sessionStatus == 'paused'
                                          ? AppColors.primary
                                          : AppColors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getSubtitleText(sessionStatus),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: sessionStatus == 'active'
                                      ? AppColors.primary
                                      : sessionStatus == 'paused'
                                          ? AppColors.primary
                                          : AppColors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Action Buttons
                if (hasActiveSession) ...[
                  const SizedBox(height: 14),
                  _buildActionButtons(context, sessionStatus, isProcessing),
                ] else ...[
                  const SizedBox(height: 14),
                  _buildStartButton(isProcessing),
                ],

                // Package Info
                if (hasActiveSession && controller.activePackage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.onPrimary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Paket:  ${controller.activePackage!.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  String _getSessionStatus() {
    return controller.currentSessionStatus;
  }

  Gradient _getGradientForStatus(String status) {
    switch (status) {
      case 'active':
        return AppColors.successGradient;
      case 'paused':
        return AppColors.warningGradient;
      case 'completed':
        return AppColors.primaryGradient;
      default:
        return AppColors.primaryGradient;
    }
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'paused':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'active':
        return Icons.directions_car_rounded;
      case 'paused':
        return Icons.pause_circle_filled_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      default:
        return Icons.play_circle_filled_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'AKTİF SEFER';
      case 'paused':
        return 'SEFER MOLADA';
      case 'completed':
        return 'SEFER TAMAMLANDI';
      default:
        return 'SEFER BAŞLAT';
    }
  }

  String _getSubtitleText(String status) {
    switch (status) {
      case 'active':
      case 'paused':
        return controller.sessionDuration;
      case 'completed':
        return 'Tamamlandı';
      default:
        return 'Hemen başla';
    }
  }

  Widget _buildStartButton(bool isProcessing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : controller.startSessionWithPackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onPrimary,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                'Sefer Başlat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String status, bool isProcessing) {
    return Row(
      children: [
        // Ana Action Button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isProcessing ? null : _getPrimaryAction(status),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onPrimary,
              foregroundColor: _getColorForStatus(status),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _getPrimaryActionText(status),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 12),

        // Secondary Action Button
        Expanded(
          child: OutlinedButton(
            onPressed: isProcessing ? null : () => _showEndSessionConfirmation(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              side: BorderSide(color: AppColors.errorContainer),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Bitir',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  VoidCallback? _getPrimaryAction(String status) {
    switch (status) {
      case 'active':
        return controller.pauseActiveSession;
      case 'paused':
        return controller.resumeActiveSession;
      default:
        return null;
    }
  }

  String _getPrimaryActionText(String status) {
    switch (status) {
      case 'active':
        return 'Mola Ver';
      case 'paused':
        return 'Devam Et';
      default:
        return 'Başlat';
    }
  }

  void _showEndSessionConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Seferi Bitir',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktif seferi bitirmek istediğinizden emin misiniz?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bu işlem geri alınamaz ve sefer tamamlanmış olarak kaydedilir.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.outline),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'İptal',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                controller.endActiveSession();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              child: const Text('Seferi Bitir'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
