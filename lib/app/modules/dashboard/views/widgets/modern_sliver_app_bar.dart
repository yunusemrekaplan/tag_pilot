import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/core/theme/app_colors.dart';
import 'package:tag_pilot/app/modules/dashboard/controllers/dashboard_controller.dart';

/// Modern Sliver App Bar
class ModernSliverAppBar extends GetView<DashboardController> {
  const ModernSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                Obx(() => Text(
                      controller.currentUser?.name ?? 'Şoför',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                    )),
              ],
            ),
            const Spacer(),
            // Profile Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.onPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 17) return 'İyi Günler';
    return 'İyi Akşamlar';
  }
}
