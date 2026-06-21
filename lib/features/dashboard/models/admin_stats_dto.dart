class AdminStatsDto {
  final int totalUsers;
  final int totalJobs;
  final int totalCompanies;
  final int activeJobs;
  final int pendingCompanyRequests;

  AdminStatsDto({
    this.totalUsers = 0,
    this.totalJobs = 0,
    this.totalCompanies = 0,
    this.activeJobs = 0,
    this.pendingCompanyRequests = 0,
  });

  factory AdminStatsDto.fromJson(Map<String, dynamic> json) {
    return AdminStatsDto(
      totalUsers: json['users']?['total'] as int? ?? 0,
      totalJobs: json['jobs']?['total'] as int? ?? 0,
      totalCompanies: json['companies']?['total'] as int? ?? 0,
      activeJobs: json['jobs']?['active'] as int? ?? 0,
      pendingCompanyRequests: json['companies']?['pendingRequests'] as int? ?? 0,
    );
  }
}
