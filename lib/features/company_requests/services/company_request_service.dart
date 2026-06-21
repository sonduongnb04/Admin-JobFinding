import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/models/paginated_list_dto.dart';
import '../models/company_request_dto.dart';
import '../../auth/services/auth_service.dart';

final companyRequestServiceProvider = Provider<CompanyRequestService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CompanyRequestService(apiClient);
});

class CompanyRequestService {
  final ApiClient _apiClient;

  CompanyRequestService(this._apiClient);

  Future<PaginatedListDto<CompanyRequestDto>> getPendingRequests({int pageNumber = 1, int pageSize = 10}) async {
    final response = await _apiClient.get(
      '/companyrequests/pending',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    return PaginatedListDto.fromJson(response, (json) => CompanyRequestDto.fromJson(json as Map<String, dynamic>));
  }

  Future<void> approveRequest(int requestId) async {
    await _apiClient.post(
      '/companyrequests/approve',
      data: {'requestId': requestId},
    );
  }

  Future<void> rejectRequest(int requestId, String reason) async {
    await _apiClient.post(
      '/companyrequests/reject',
      data: {'requestId': requestId, 'rejectionReason': reason},
    );
  }
}
