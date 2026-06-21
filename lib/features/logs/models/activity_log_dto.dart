class ActivityLogDto {
  final int id;
  final int? userId;
  final String method;
  final String path;
  final String? queryString;
  final String? ipAddress;
  final int statusCode;
  final int durationMs;
  final String? details;
  final DateTime timestamp;

  ActivityLogDto({
    required this.id,
    this.userId,
    required this.method,
    required this.path,
    this.queryString,
    this.ipAddress,
    required this.statusCode,
    required this.durationMs,
    this.details,
    required this.timestamp,
  });

  factory ActivityLogDto.fromJson(Map<String, dynamic> json) {
    return ActivityLogDto(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int?,
      method: json['method'] as String? ?? '',
      path: json['path'] as String? ?? '',
      queryString: json['queryString'] as String?,
      ipAddress: json['ipAddress'] as String?,
      statusCode: json['statusCode'] as int? ?? 0,
      durationMs: json['durationMs'] as int? ?? 0,
      details: json['details'] as String?,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }
}
