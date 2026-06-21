class ErrorLogDto {
  final int id;
  final String level;
  final String message;
  final String? exceptionType;
  final String? stackTrace;
  final String? requestPath;
  final String? requestMethod;
  final DateTime timestamp;

  ErrorLogDto({
    required this.id,
    required this.level,
    required this.message,
    this.exceptionType,
    this.stackTrace,
    this.requestPath,
    this.requestMethod,
    required this.timestamp,
  });

  factory ErrorLogDto.fromJson(Map<String, dynamic> json) {
    return ErrorLogDto(
      id: json['id'] as int? ?? 0,
      level: json['level'] as String? ?? 'Error',
      message: json['message'] as String? ?? '',
      exceptionType: json['exceptionType'] as String?,
      stackTrace: json['stackTrace'] as String?,
      requestPath: json['requestPath'] as String?,
      requestMethod: json['requestMethod'] as String?,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }
}
