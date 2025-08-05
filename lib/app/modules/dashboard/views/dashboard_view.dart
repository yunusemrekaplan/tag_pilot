import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/core/theme/app_colors.dart';
import 'package:tag_pilot/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:tag_pilot/app/modules/dashboard/views/widgets/active_session_summary.dart';
import 'package:tag_pilot/app/modules/dashboard/views/widgets/break_even_progress_card.dart';
import 'package:tag_pilot/app/modules/dashboard/views/widgets/hero_session_card.dart';
import 'package:tag_pilot/app/modules/dashboard/views/widgets/insights_section.dart';
import 'package:tag_pilot/app/modules/dashboard/views/widgets/modern_loading_widget.dart';
import 'package:tag_pilot/app/modules/dashboard/views/widgets/modern_sliver_app_bar.dart';
import 'package:tag_pilot/app/modules/dashboard/views/widgets/quick_action_fab.dart';

/// Modern Dashboard View - Responsive & Dynamic
/// Material 3 Design System ile modern, dinamik ve responsive dashboard
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: const QuickActionFAB(),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const ModernLoadingWidget();
          }

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // Modern App Bar
              const ModernSliverAppBar(),

              // Main Content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Section - Session Status
                    const HeroSessionCard(),
                    const SizedBox(height: 20),

                    // Başabaş Noktası (artık üstte)
                    const BreakEvenProgressCard(),
                    const SizedBox(height: 20),

                    // Aktif Sefer Özeti (artık altta)
                    const ActiveSessionSummary(),
                    const SizedBox(height: 16),

                    // Insights Section
                    const InsightsSection(),
                  ]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
