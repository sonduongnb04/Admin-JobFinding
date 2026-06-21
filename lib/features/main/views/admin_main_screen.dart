import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/colors.dart';
import '../../dashboard/views/overview_view.dart';
import '../../users/views/user_management_view.dart';
import '../../company_requests/views/company_main_view.dart';
import '../../jobs/views/jobs_main_view.dart';
import '../../logs/views/logs_main_view.dart';

class AdminNavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final adminNavigationProvider = NotifierProvider<AdminNavigationNotifier, int>(
  () => AdminNavigationNotifier(),
);

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(adminNavigationProvider);

    final pages = [
      const OverviewView(),
      const UserManagementView(),
      const CompanyMainView(),
      const JobsMainView(),
      const LogsMainView(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar (NavigationRail)
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              ref.read(adminNavigationProvider.notifier).setIndex(index);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.backgroundWhite,
            selectedIconTheme: const IconThemeData(
              color: AppColors.primaryBlue,
            ),
            unselectedIconTheme: const IconThemeData(color: AppColors.textGrey),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.textGrey,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: Text('Companies'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work_outline),
                selectedIcon: Icon(Icons.work),
                label: Text('Jobs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Logs'),
              ),
            ],
            leading: Column(
              children: const [
                SizedBox(height: 16),
                Icon(
                  Icons.business_center,
                  color: AppColors.primaryBlue,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'JobFinding\nAdmin',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () {
                      // Xử lý đăng xuất (Gọi AuthViewModel.logout)
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    tooltip: 'Đăng xuất',
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: AppColors.borderGrey,
          ),
          // Nội dung chính
          Expanded(
            child: Container(
              color: AppColors.backgroundLightGrey,
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
