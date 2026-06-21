import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/colors.dart';
import '../viewmodels/company_request_viewmodel.dart';
import '../models/company_request_dto.dart';

class CompanyRequestInnerView extends ConsumerStatefulWidget {
  const CompanyRequestInnerView({super.key});

  @override
  ConsumerState<CompanyRequestInnerView> createState() => _CompanyRequestInnerViewState();
}

class _CompanyRequestInnerViewState extends ConsumerState<CompanyRequestInnerView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyRequestViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
              tooltip: 'Làm mới danh sách',
              onPressed: () {
                ref.read(companyRequestViewModelProvider.notifier).loadPendingRequests();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
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
                          ? const Center(child: Text('Không có yêu cầu nào đang chờ duyệt.', style: TextStyle(color: AppColors.textGrey)))
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
                        ? () => ref.read(companyRequestViewModelProvider.notifier).loadPendingRequests(page: state.pageNumber - 1)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: state.data!.hasNextPage
                        ? () => ref.read(companyRequestViewModelProvider.notifier).loadPendingRequests(page: state.pageNumber + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      );
  }

  Widget _buildDataTable(List<CompanyRequestDto> requests) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.backgroundLightGrey),
        columns: const [
          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Tên công ty', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Mã số thuế', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: requests.map((req) {
          return DataRow(
            cells: [
              DataCell(Text(req.id.toString())),
              DataCell(Text(req.companyName)),
              DataCell(Text(req.taxCode)),
              DataCell(Text('${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}')),
              DataCell(
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _handleApprove(req),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Duyệt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(req),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Từ chối'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handleApprove(CompanyRequestDto req) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Duyệt'),
        content: Text('Bạn chắc chắn muốn duyệt công ty ${req.companyName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await ref.read(companyRequestViewModelProvider.notifier).approveRequest(req.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt thành công')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _showRejectDialog(CompanyRequestDto req) async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối Yêu cầu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lý do từ chối công ty ${req.companyName}:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      if (result.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do từ chối!'), backgroundColor: Colors.red));
        return;
      }
      try {
        await ref.read(companyRequestViewModelProvider.notifier).rejectRequest(req.id, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối yêu cầu')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
        }
      }
    }
  }
}
