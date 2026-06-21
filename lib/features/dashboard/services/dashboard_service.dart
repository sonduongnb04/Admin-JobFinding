import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/admin_stats_dto.dart';
import '../../auth/services/auth_service.dart'; // To get apiClient

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return DashboardService(apiClient);
});

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<AdminStatsDto> getStats() async {
    final response = await _apiClient.get('/admin/stats');
    return AdminStatsDto.fromJson(response);
  }
}
