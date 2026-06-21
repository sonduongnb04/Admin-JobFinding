import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_log_dto.dart';
import '../models/error_log_dto.dart';
import '../services/logs_service.dart';
import '../../../core/network/models/paginated_list_dto.dart';

// --- Activity Logs State & Notifier ---

class ActivityLogState {
  final bool isLoading;
  final String? error;
  final PaginatedListDto<ActivityLogDto>? data;
  final int pageNumber;

  ActivityLogState({this.isLoading = false, this.error, this.data, this.pageNumber = 1});

  ActivityLogState copyWith({bool? isLoading, String? error, PaginatedListDto<ActivityLogDto>? data, int? pageNumber}) {
    return ActivityLogState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class ActivityLogViewModel extends Notifier<ActivityLogState> {
  late final LogsService _service;

  @override
  ActivityLogState build() {
    _service = ref.read(logsServiceProvider);
    Future.microtask(() => loadLogs());
    return ActivityLogState(isLoading: true);
  }

  Future<void> loadLogs({int? page}) async {
    final newPage = page ?? state.pageNumber;
    state = state.copyWith(isLoading: true, error: null, pageNumber: newPage);
    try {
      final result = await _service.getActivityLogs(pageNumber: newPage, pageSize: 20);
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final activityLogViewModelProvider = NotifierProvider<ActivityLogViewModel, ActivityLogState>(() {
  return ActivityLogViewModel();
});

// --- Error Logs State & Notifier ---

class ErrorLogState {
  final bool isLoading;
  final String? error;
  final PaginatedListDto<ErrorLogDto>? data;
  final int pageNumber;

  ErrorLogState({this.isLoading = false, this.error, this.data, this.pageNumber = 1});

  ErrorLogState copyWith({bool? isLoading, String? error, PaginatedListDto<ErrorLogDto>? data, int? pageNumber}) {
    return ErrorLogState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class ErrorLogViewModel extends Notifier<ErrorLogState> {
  late final LogsService _service;

  @override
  ErrorLogState build() {
    _service = ref.read(logsServiceProvider);
    Future.microtask(() => loadLogs());
    return ErrorLogState(isLoading: true);
  }

  Future<void> loadLogs({int? page}) async {
    final newPage = page ?? state.pageNumber;
    state = state.copyWith(isLoading: true, error: null, pageNumber: newPage);
    try {
      final result = await _service.getErrorLogs(pageNumber: newPage, pageSize: 20);
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final errorLogViewModelProvider = NotifierProvider<ErrorLogViewModel, ErrorLogState>(() {
  return ErrorLogViewModel();
});
