import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_stats_dto.dart';
import '../services/dashboard_service.dart';

final dashboardViewModelProvider = FutureProvider<AdminStatsDto>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getStats();
});
