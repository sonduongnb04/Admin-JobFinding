import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/models/paginated_list_dto.dart';
import '../models/activity_log_dto.dart';
import '../models/error_log_dto.dart';
import '../../auth/services/auth_service.dart';

final logsServiceProvider = Provider<LogsService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return LogsService(apiClient);
});

class LogsService {
  final ApiClient _apiClient;

  LogsService(this._apiClient);

  Future<PaginatedListDto<ActivityLogDto>> getActivityLogs({int pageNumber = 1, int pageSize = 50}) async {
    final response = await _apiClient.get(
      '/logs/activities',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    // Since logs controller returns a slightly different pagination structure inside 'logs' property
    // We parse it manually based on what the API returns. Let's assume standard response or map it.
    
    // Check if the structure is standard PaginatedList or a custom object 
    // Example from LogsController: { logs: [...], totalCount: X, pageNumber: Y, totalPages: Z }
    if (response is Map<String, dynamic> && response.containsKey('logs')) {
      return PaginatedListDto<ActivityLogDto>(
        items: (response['logs'] as List<dynamic>?)?.map((e) => ActivityLogDto.fromJson(e)).toList() ?? [],
        totalCount: response['totalCount'] as int? ?? 0,
        pageNumber: response['pageNumber'] as int? ?? 1,
        totalPages: response['totalPages'] as int? ?? 1,
        hasPreviousPage: (response['pageNumber'] ?? 1) > 1,
        hasNextPage: (response['pageNumber'] ?? 1) < (response['totalPages'] ?? 1),
      );
    }
    
    // Fallback to standard
    return PaginatedListDto.fromJson(response, (json) => ActivityLogDto.fromJson(json as Map<String, dynamic>));
  }

  Future<PaginatedListDto<ErrorLogDto>> getErrorLogs({int pageNumber = 1, int pageSize = 50}) async {
    final response = await _apiClient.get(
      '/logs/errors',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );

    if (response is Map<String, dynamic> && response.containsKey('logs')) {
      return PaginatedListDto<ErrorLogDto>(
        items: (response['logs'] as List<dynamic>?)?.map((e) => ErrorLogDto.fromJson(e)).toList() ?? [],
        totalCount: response['totalCount'] as int? ?? 0,
        pageNumber: response['pageNumber'] as int? ?? 1,
        totalPages: response['totalPages'] as int? ?? 1,
        hasPreviousPage: (response['pageNumber'] ?? 1) > 1,
        hasNextPage: (response['pageNumber'] ?? 1) < (response['totalPages'] ?? 1),
      );
    }
    
    return PaginatedListDto.fromJson(response, (json) => ErrorLogDto.fromJson(json as Map<String, dynamic>));
  }
}
