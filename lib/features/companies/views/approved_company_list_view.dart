import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/colors.dart';
import '../viewmodels/company_viewmodel.dart';
import '../models/company_dto.dart';

class ApprovedCompanyListView extends ConsumerStatefulWidget {
  const ApprovedCompanyListView({super.key});

  @override
  ConsumerState<ApprovedCompanyListView> createState() => _ApprovedCompanyListViewState();
}

class _ApprovedCompanyListViewState extends ConsumerState<ApprovedCompanyListView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: state.isLoading && state.data == null
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text('Lỗi: ${state.error}', style: const TextStyle(color: Colors.red)))
                    : state.data?.items.isEmpty == true
                        ? const Center(child: Text('Không có công ty nào.', style: TextStyle(color: AppColors.textGrey)))
                        : _buildDataTable(state.data?.items ?? []),
          ),
        ),

        // Phân trang
        if (state.data != null && state.data!.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Trang ${state.data!.pageNumber} / ${state.data!.totalPages}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: state.data!.hasPreviousPage
                      ? () => ref.read(companyViewModelProvider.notifier).loadCompanies(page: state.pageNumber - 1)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: state.data!.hasNextPage
                      ? () => ref.read(companyViewModelProvider.notifier).loadCompanies(page: state.pageNumber + 1)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDataTable(List<CompanyDto> companies) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 24,
                headingRowColor: WidgetStateProperty.all(AppColors.backgroundLightGrey),
                columns: const [
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tên công ty', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Lĩnh vực', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: companies.map((company) {
                  return DataRow(
                    cells: [
                      DataCell(Text(company.id.toString())),
                      DataCell(Text(company.name)),
                      DataCell(Text(company.industry ?? 'N/A')),
                      DataCell(Text('${company.createdAt.day}/${company.createdAt.month}/${company.createdAt.year}')),
                      DataCell(
                        ElevatedButton.icon(
                          onPressed: () => _showCompanyDetails(company),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Chi tiết'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCompanyDetails(CompanyDto company) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(company.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (company.logoUrl != null && company.logoUrl!.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Image.network(
                        company.logoUrl!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                _buildDetailRow('Mã số thuế:', company.taxCode ?? 'N/A'),
                _buildDetailRow('Địa chỉ:', company.address ?? 'N/A'),
                _buildDetailRow('Website:', company.website ?? 'N/A'),
                _buildDetailRow('Lĩnh vực:', company.industry ?? 'N/A'),
                _buildDetailRow('Quy mô:', '${company.employeeCount ?? 0} nhân viên'),
                _buildDetailRow('Năm thành lập:', company.foundedYear != null ? company.foundedYear!.year.toString() : 'N/A'),
                const SizedBox(height: 16),
                const Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(company.description ?? 'Không có mô tả.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textBlack))),
        ],
      ),
    );
  }
}
