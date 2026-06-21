import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/models/paginated_list_dto.dart';
import '../models/user_dto.dart';
import '../../auth/services/auth_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return UserService(apiClient);
});

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<PaginatedListDto<UserDto>> getUsers({String? search, int pageNumber = 1, int pageSize = 10}) async {
    final Map<String, dynamic> query = {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final response = await _apiClient.get('/admin/users', queryParameters: query);
    return PaginatedListDto.fromJson(response, (json) => UserDto.fromJson(json as Map<String, dynamic>));
  }

  Future<void> lockUser(int id) async {
    await _apiClient.post('/admin/users/$id/lock');
  }

  Future<void> unlockUser(int id) async {
    await _apiClient.post('/admin/users/$id/unlock');
  }
}
