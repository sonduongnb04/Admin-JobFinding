import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company_dto.dart';
import '../services/company_service.dart';
import '../../../core/network/models/paginated_list_dto.dart';

class CompanyState {
  final bool isLoading;
  final String? error;
  final PaginatedListDto<CompanyDto>? data;
  final int pageNumber;

  CompanyState({
    this.isLoading = false,
    this.error,
    this.data,
    this.pageNumber = 1,
  });

  CompanyState copyWith({
    bool? isLoading,
    String? error,
    PaginatedListDto<CompanyDto>? data,
    int? pageNumber,
  }) {
    return CompanyState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class CompanyViewModel extends Notifier<CompanyState> {
  late final CompanyService _service;

  @override
  CompanyState build() {
    _service = ref.read(companyServiceProvider);
    Future.microtask(() => loadCompanies());
    return CompanyState(isLoading: true);
  }

  Future<void> loadCompanies({int? page}) async {
    final newPage = page ?? state.pageNumber;
    state = state.copyWith(isLoading: true, error: null, pageNumber: newPage);

    try {
      final result = await _service.getApprovedCompanies(pageNumber: newPage, pageSize: 10);
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final companyViewModelProvider = NotifierProvider<CompanyViewModel, CompanyState>(() {
  return CompanyViewModel();
});
