import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/colors.dart';
import '../viewmodels/user_viewmodel.dart';
import '../models/user_dto.dart';

class UserManagementView extends ConsumerStatefulWidget {
  const UserManagementView({super.key});

  @override
  ConsumerState<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends ConsumerState<UserManagementView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(userViewModelProvider.notifier).loadUsers(
      search: _searchController.text,
      page: 1, // Reset to page 1 on new search
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý Người Dùng',
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
                    hintText: 'Tìm kiếm theo tên, email...',
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
                        ? () => ref.read(userViewModelProvider.notifier).loadUsers(page: state.pageNumber - 1)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: state.data!.hasNextPage
                        ? () => ref.read(userViewModelProvider.notifier).loadUsers(page: state.pageNumber + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<UserDto> users) {
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
                  DataColumn(label: Text('Họ Tên', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Phân quyền', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user.id.toString())),
                      DataCell(Text(user.fullName ?? '--')),
                      DataCell(Text(user.email)),
                      DataCell(Text(user.roles.join(', '))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: user.isLocked ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            user.isLocked ? 'Bị khóa' : 'Hoạt động',
                            style: TextStyle(
                              color: user.isLocked ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        TextButton.icon(
                          onPressed: () => _showConfirmDialog(user),
                          icon: Icon(user.isLocked ? Icons.lock_open : Icons.lock,
                            color: user.isLocked ? Colors.green : Colors.red,
                            size: 18,
                          ),
                          label: Text(
                            user.isLocked ? 'Mở khóa' : 'Khóa',
                            style: TextStyle(color: user.isLocked ? Colors.green : Colors.red),
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

  Future<void> _showConfirmDialog(UserDto user) async {
    final action = user.isLocked ? 'Mở khóa' : 'Khóa';
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận $action'),
        content: Text('Bạn có chắc chắn muốn $action tài khoản ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: user.isLocked ? Colors.green : Colors.red),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await ref.read(userViewModelProvider.notifier).toggleLockUser(user.id, user.isLocked);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã $action tài khoản thành công')),
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
