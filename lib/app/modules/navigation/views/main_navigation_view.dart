import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../sessions/views/sessions_list_view.dart';
import '../../expenses/views/expense_list_view.dart';
import '../../reports/views/reports_main_view.dart';
import '../controllers/navigation_controller.dart';

/// Main Navigation View
/// Ana uygulama navigation'ı - BottomNavigationBar ile
class MainNavigationView extends GetView<NavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _getPage(controller.selectedIndex)),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Seçili index'e göre sayfa döndür
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const DashboardView();
      case 1:
        return const SessionsListView();
      case 2:
        return const ExpenseListView();
      case 3:
        return const ReportsMainView();
      case 4:
        return _buildPlaceholderPage(
          icon: Icons.person,
          title: 'Profil',
          subtitle: 'Kullanıcı profili ve ayarlar yakında!',
        );
      default:
        return const DashboardView();
    }
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.selectedIndex,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car),
              label: 'Seferler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Giderler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Raporlar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ));
  }

  /// Placeholder page builder (MVP için diğer sayfalar)
  Widget _buildPlaceholderPage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildComingSoonChips(),
            ],
          ),
        ),
      ),
    );
  }

  /// "Yakında" bilgi chip'leri
  Widget _buildComingSoonChips() {
    final features = [
      'Yakında geliyor!',
      'Geliştirme aşamasında',
      'MVP versiyonu',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features
          .map((feature) => Chip(
                label: Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                backgroundColor: AppColors.surfaceVariant,
                side: BorderSide.none,
              ))
          .toList(),
    );
  }
}
