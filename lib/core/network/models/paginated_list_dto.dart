class PaginatedListDto<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginatedListDto({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedListDto.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return PaginatedListDto<T>(
      items: (json['items'] as List<dynamic>?)?.map(fromJsonT).toList() ?? [],
      totalCount: json['totalCount'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}
