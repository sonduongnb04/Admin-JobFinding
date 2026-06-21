import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_job_dto.dart';
import '../services/admin_job_service.dart';
import '../../../core/network/models/paginated_list_dto.dart';

class JobsState {
  final bool isLoading;
  final String? error;
  final PaginatedListDto<AdminJobDto>? data;
  final String searchQuery;
  final int pageNumber;

  JobsState({
    this.isLoading = false,
    this.error,
    this.data,
    this.searchQuery = '',
    this.pageNumber = 1,
  });

  JobsState copyWith({
    bool? isLoading,
    String? error,
    PaginatedListDto<AdminJobDto>? data,
    String? searchQuery,
    int? pageNumber,
  }) {
    return JobsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
      searchQuery: searchQuery ?? this.searchQuery,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class JobsViewModel extends Notifier<JobsState> {
  late final AdminJobService _jobsService;

  @override
  JobsState build() {
    _jobsService = ref.read(adminJobServiceProvider);
    Future.microtask(() => loadJobs());
    return JobsState(isLoading: true);
  }

  Future<void> loadJobs({int? page, String? search}) async {
    final newPage = page ?? state.pageNumber;
    final newSearch = search ?? state.searchQuery;
    
    state = state.copyWith(isLoading: true, error: null, pageNumber: newPage, searchQuery: newSearch);

    try {
      final result = await _jobsService.getJobs(
        search: newSearch,
        pageNumber: newPage,
        pageSize: 10,
      );
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> lockJob(int jobId) async {
    try {
      await _jobsService.updateJobStatus(jobId, 5); // 5 is Locked
      _updateJobStatusLocally(jobId, 5);
    } catch (e) {
      throw Exception('Failed to lock job: $e');
    }
  }

  Future<void> unlockJob(int jobId) async {
    try {
      await _jobsService.updateJobStatus(jobId, 1); // 1 is Active
      _updateJobStatusLocally(jobId, 1);
    } catch (e) {
      throw Exception('Failed to unlock job: $e');
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      await _jobsService.deleteJob(jobId);
      // Reload after delete
      await loadJobs(page: state.pageNumber);
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }

  void _updateJobStatusLocally(int jobId, int newStatus) {
    if (state.data != null) {
      final updatedItems = state.data!.items.map((job) {
        if (job.id == jobId) {
          return job.copyWith(status: newStatus);
        }
        return job;
      }).toList();
      
      final updatedData = PaginatedListDto<AdminJobDto>(
        items: updatedItems,
        totalCount: state.data!.totalCount,
        pageNumber: state.data!.pageNumber,
        totalPages: state.data!.totalPages,
        hasPreviousPage: state.data!.hasPreviousPage,
        hasNextPage: state.data!.hasNextPage,
      );
      state = state.copyWith(data: updatedData);
    }
  }
}

final jobsViewModelProvider = NotifierProvider<JobsViewModel, JobsState>(() {
  return JobsViewModel();
});
