import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/models/paginated_list_dto.dart';
import '../models/company_dto.dart';
import '../../auth/services/auth_service.dart';

final companyServiceProvider = Provider<CompanyService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CompanyService(apiClient);
});

class CompanyService {
  final ApiClient _apiClient;

  CompanyService(this._apiClient);

  Future<PaginatedListDto<CompanyDto>> getApprovedCompanies({int pageNumber = 1, int pageSize = 10}) async {
    final response = await _apiClient.get(
      '/companies',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    return PaginatedListDto.fromJson(response, (json) => CompanyDto.fromJson(json as Map<String, dynamic>));
  }
}
