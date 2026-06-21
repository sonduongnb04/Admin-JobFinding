import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/models/paginated_list_dto.dart';
import '../models/admin_job_dto.dart';
import '../../auth/services/auth_service.dart';

final adminJobServiceProvider = Provider<AdminJobService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AdminJobService(apiClient);
});

class AdminJobService {
  final ApiClient _apiClient;

  AdminJobService(this._apiClient);

  Future<PaginatedListDto<AdminJobDto>> getJobs({String? search, int pageNumber = 1, int pageSize = 10}) async {
    final Map<String, dynamic> query = {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final response = await _apiClient.get('/admin/jobs', queryParameters: query);
    return PaginatedListDto.fromJson(response, (json) => AdminJobDto.fromJson(json as Map<String, dynamic>));
  }

  Future<void> updateJobStatus(int id, int status) async {
    await _apiClient.put(
      '/admin/jobs/$id/status',
      data: {'status': status},
    );
  }

  Future<void> deleteJob(int id) async {
    await _apiClient.delete('/admin/jobs/$id');
  }
}
