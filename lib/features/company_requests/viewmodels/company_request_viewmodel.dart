import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company_request_dto.dart';
import '../services/company_request_service.dart';
import '../../../core/network/models/paginated_list_dto.dart';

class CompanyRequestState {
  final bool isLoading;
  final String? error;
  final PaginatedListDto<CompanyRequestDto>? data;
  final int pageNumber;

  CompanyRequestState({
    this.isLoading = false,
    this.error,
    this.data,
    this.pageNumber = 1,
  });

  CompanyRequestState copyWith({
    bool? isLoading,
    String? error,
    PaginatedListDto<CompanyRequestDto>? data,
    int? pageNumber,
  }) {
    return CompanyRequestState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class CompanyRequestViewModel extends Notifier<CompanyRequestState> {
  late final CompanyRequestService _service;

  @override
  CompanyRequestState build() {
    _service = ref.read(companyRequestServiceProvider);
    Future.microtask(() => loadPendingRequests());
    return CompanyRequestState(isLoading: true);
  }

  Future<void> loadPendingRequests({int? page}) async {
    final newPage = page ?? state.pageNumber;
    state = state.copyWith(isLoading: true, error: null, pageNumber: newPage);

    try {
      final result = await _service.getPendingRequests(pageNumber: newPage, pageSize: 10);
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approveRequest(int requestId) async {
    try {
      await _service.approveRequest(requestId);
      // Remove from current list visually instead of full reload, or reload
      await loadPendingRequests(page: state.pageNumber);
    } catch (e) {
      throw Exception('Lỗi khi duyệt: $e');
    }
  }

  Future<void> rejectRequest(int requestId, String reason) async {
    try {
      await _service.rejectRequest(requestId, reason);
      // Reload
      await loadPendingRequests(page: state.pageNumber);
    } catch (e) {
      throw Exception('Lỗi khi từ chối: $e');
    }
  }
}

final companyRequestViewModelProvider = NotifierProvider<CompanyRequestViewModel, CompanyRequestState>(() {
  return CompanyRequestViewModel();
});
