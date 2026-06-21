class AdminJobDto {
  final int id;
  final String title;
  final String? companyName;
  final int status;
  final DateTime createdAt;
  final int viewCount;
  final int applicationCount;
  final String? location;
  final String? workType;

  AdminJobDto({
    required this.id,
    required this.title,
    this.companyName,
    required this.status,
    required this.createdAt,
    required this.viewCount,
    required this.applicationCount,
    this.location,
    this.workType,
  });

  factory AdminJobDto.fromJson(Map<String, dynamic> json) {
    return AdminJobDto(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      companyName: json['companyName'],
      status: json['status'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      viewCount: json['viewCount'] ?? 0,
      applicationCount: json['applicationCount'] ?? 0,
      location: json['location'],
      workType: json['workType'],
    );
  }

  AdminJobDto copyWith({
    int? id,
    String? title,
    String? companyName,
    int? status,
    DateTime? createdAt,
    int? viewCount,
    int? applicationCount,
    String? location,
    String? workType,
  }) {
    return AdminJobDto(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
      applicationCount: applicationCount ?? this.applicationCount,
      location: location ?? this.location,
      workType: workType ?? this.workType,
    );
  }

  String get statusName {
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Active';
      case 2:
        return 'Closed';
      case 3:
        return 'Expired';
      case 4:
        return 'Archived';
      case 5:
        return 'Locked';
      default:
        return 'Unknown';
    }
  }
}
