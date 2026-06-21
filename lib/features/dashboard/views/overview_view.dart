import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/colors.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../models/admin_stats_dto.dart';
import '../../main/views/admin_main_screen.dart';

class OverviewView extends ConsumerWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textBlack),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Lỗi tải dữ liệu: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (stats) => _buildStatsGrid(context, ref, stats),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref, AdminStatsDto stats) {
    return ListView(
      children: [
        _buildStatCard(
          title: 'Người dùng',
          value: stats.totalUsers.toString(),
          icon: Icons.people_alt_rounded,
          gradientColors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
          onTap: () => ref.read(adminNavigationProvider.notifier).setIndex(1),
        ),
        const SizedBox(height: 24),
        _buildStatCard(
          title: 'Tin tuyển dụng',
          value: stats.totalJobs.toString(),
          icon: Icons.work_rounded,
          gradientColors: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
          onTap: () => ref.read(adminNavigationProvider.notifier).setIndex(3),
        ),
        const SizedBox(height: 24),
        _buildStatCard(
          title: 'Công ty',
          value: stats.totalCompanies.toString(),
          icon: Icons.business_rounded,
          gradientColors: [const Color(0xFFfa709a), const Color(0xFFfee140)],
          onTap: () => ref.read(adminNavigationProvider.notifier).setIndex(2),
        ),
        const SizedBox(height: 24),
        _buildStatCard(
          title: 'Yêu cầu chờ duyệt',
          value: stats.pendingCompanyRequests.toString(),
          icon: Icons.pending_actions_rounded,
          gradientColors: [const Color(0xFFf83600), const Color(0xFFf9d423)],
          onTap: () => ref.read(adminNavigationProvider.notifier).setIndex(2),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: gradientColors.first.withValues(alpha: 0.1),
          highlightColor: gradientColors.first.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.borderGrey.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
