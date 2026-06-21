import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/colors.dart';
import '../viewmodels/jobs_viewmodel.dart';
import '../models/admin_job_dto.dart';

class JobsMainView extends ConsumerStatefulWidget {
  const JobsMainView({super.key});

  @override
  ConsumerState<JobsMainView> createState() => _JobsMainViewState();
}

class _JobsMainViewState extends ConsumerState<JobsMainView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(jobsViewModelProvider.notifier).loadJobs(
      search: _searchController.text,
      page: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobsViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý Tin tuyển dụng',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textBlack),
          ),
          const SizedBox(height: 24),
          
          // Thanh tìm kiếm
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên tin, công ty...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Tìm kiếm'),
              ),
              const Spacer(flex: 3),
            ],
          ),
          const SizedBox(height: 24),

          // Bảng dữ liệu
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
                      : _buildDataTable(state.data?.items ?? []),
            ),
          ),
          
          // Phân trang
          if (state.data != null)
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
                        ? () => ref.read(jobsViewModelProvider.notifier).loadJobs(page: state.pageNumber - 1)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: state.data!.hasNextPage
                        ? () => ref.read(jobsViewModelProvider.notifier).loadJobs(page: state.pageNumber + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<AdminJobDto> jobs) {
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
                  DataColumn(label: Text('Tiêu đề', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Công ty', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Lượt xem / Ứng tuyển', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: jobs.map((job) {
                  return DataRow(
                    cells: [
                      DataCell(Text(job.id.toString())),
                      DataCell(SizedBox(
                        width: 200, 
                        child: Text(job.title, overflow: TextOverflow.ellipsis)
                      )),
                      DataCell(Text(job.companyName ?? '--')),
                      DataCell(Text('${job.viewCount} / ${job.applicationCount}')),
                      DataCell(Text('${job.createdAt.day.toString().padLeft(2, '0')}/${job.createdAt.month.toString().padLeft(2, '0')}/${job.createdAt.year}')),
                      DataCell(_buildStatusBadge(job)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showConfirmLockDialog(job),
                              icon: Icon(
                                job.status == 5 ? Icons.lock_open : Icons.lock,
                                color: job.status == 5 ? Colors.green : Colors.orange,
                                size: 18,
                              ),
                              label: Text(
                                job.status == 5 ? 'Mở khóa' : 'Khóa',
                                style: TextStyle(color: job.status == 5 ? Colors.green : Colors.orange),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showConfirmDeleteDialog(job),
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
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

  Widget _buildStatusBadge(AdminJobDto job) {
    Color bgColor;
    Color textColor;
    String label = job.statusName;

    switch (job.status) {
      case 1: // Active
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case 5: // Locked
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        label = 'Bị khóa';
        break;
      case 0: // Draft
      case 2: // Closed
      case 3: // Expired
      case 4: // Archived
      default:
        bgColor = Colors.grey.withValues(alpha: 0.2);
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showConfirmLockDialog(AdminJobDto job) async {
    final isLocked = job.status == 5;
    final action = isLocked ? 'Mở khóa' : 'Khóa';
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận $action'),
        content: Text('Bạn có chắc chắn muốn $action tin tuyển dụng "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: isLocked ? Colors.green : Colors.orange),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        if (isLocked) {
          await ref.read(jobsViewModelProvider.notifier).unlockJob(job.id);
        } else {
          await ref.read(jobsViewModelProvider.notifier).lockJob(job.id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã $action tin tuyển dụng thành công')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showConfirmDeleteDialog(AdminJobDto job) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc chắn muốn XÓA VĨNH VIỄN tin tuyển dụng "${job.title}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await ref.read(jobsViewModelProvider.notifier).deleteJob(job.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa tin tuyển dụng thành công')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
