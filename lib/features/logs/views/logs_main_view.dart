import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/colors.dart';
import '../viewmodels/logs_viewmodel.dart';
import '../models/activity_log_dto.dart';
import '../models/error_log_dto.dart';

class LogsMainView extends ConsumerStatefulWidget {
  const LogsMainView({super.key});

  @override
  ConsumerState<LogsMainView> createState() => _LogsMainViewState();
}

class _LogsMainViewState extends ConsumerState<LogsMainView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhật ký Hệ thống',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textBlack),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primaryBlue,
            tabs: const [
              Tab(text: 'Activity Logs', icon: Icon(Icons.local_activity)),
              Tab(text: 'Error Logs', icon: Icon(Icons.error_outline)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActivityLogsTab(),
                _buildErrorLogsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogsTab() {
    final state = ref.watch(activityLogViewModelProvider);
    return _buildLogContainer(
      state.isLoading,
      state.error,
      state.data?.items.isEmpty == true,
      _buildActivityLogsTable(state.data?.items ?? []),
      state.data,
      (page) => ref.read(activityLogViewModelProvider.notifier).loadLogs(page: page),
    );
  }

  Widget _buildErrorLogsTab() {
    final state = ref.watch(errorLogViewModelProvider);
    return _buildLogContainer(
      state.isLoading,
      state.error,
      state.data?.items.isEmpty == true,
      _buildErrorLogsTable(state.data?.items ?? []),
      state.data,
      (page) => ref.read(errorLogViewModelProvider.notifier).loadLogs(page: page),
    );
  }

  Widget _buildLogContainer(bool isLoading, String? error, bool isEmpty, Widget table, dynamic data, Function(int) loadPage) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: isLoading && data == null
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text('Lỗi: $error', style: const TextStyle(color: Colors.red)))
                    : isEmpty
                        ? const Center(child: Text('Không có dữ liệu', style: TextStyle(color: AppColors.textGrey)))
                        : table,
          ),
        ),
        if (data != null && !isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Trang ${data.pageNumber} / ${data.totalPages}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: data.hasPreviousPage ? () => loadPage(data.pageNumber - 1) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: data.hasNextPage ? () => loadPage(data.pageNumber + 1) : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityLogsTable(List<ActivityLogDto> logs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.backgroundLightGrey),
                columns: const [
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Method', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Path', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: logs.map((log) {
                  return DataRow(
                    cells: [
                      DataCell(Text(log.id.toString())),
                      DataCell(Text(log.userId?.toString() ?? 'N/A')),
                      DataCell(Text(log.method)),
                      DataCell(Text(log.path)),
                      DataCell(Text(log.statusCode.toString(), style: TextStyle(color: log.statusCode >= 400 ? Colors.red : Colors.green))),
                      DataCell(Text('${log.timestamp.day.toString().padLeft(2, '0')}/${log.timestamp.month.toString().padLeft(2, '0')} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}')),
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

  Widget _buildErrorLogsTable(List<ErrorLogDto> logs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.backgroundLightGrey),
                columns: const [
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Level', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Message', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Exception', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: logs.map((log) {
                  return DataRow(
                    cells: [
                      DataCell(Text(log.id.toString())),
                      DataCell(Text(log.level, style: TextStyle(color: log.level == 'Critical' ? Colors.redAccent : Colors.orange))),
                      DataCell(SizedBox(width: 300, child: Text(log.message, maxLines: 2, overflow: TextOverflow.ellipsis))),
                      DataCell(Text(log.exceptionType ?? '--')),
                      DataCell(Text('${log.timestamp.day.toString().padLeft(2, '0')}/${log.timestamp.month.toString().padLeft(2, '0')} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}')),
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
}
