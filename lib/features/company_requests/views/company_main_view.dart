import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import 'company_request_view.dart';
import '../../companies/views/approved_company_list_view.dart';

class CompanyMainView extends StatelessWidget {
  const CompanyMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý Doanh nghiệp',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textBlack),
            ),
            const SizedBox(height: 16),
            const TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor: AppColors.primaryBlue,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: 'Danh sách công ty'),
                Tab(text: 'Chờ phê duyệt'),
              ],
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: TabBarView(
                children: [
                  ApprovedCompanyListView(),
                  CompanyRequestInnerView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
