class CompanyDto {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? website;
  final String? logoUrl;
  final String? taxCode;
  final String? industry;
  final int? employeeCount;
  final DateTime? foundedYear;
  final bool isVerified;
  final DateTime createdAt;

  CompanyDto({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.website,
    this.logoUrl,
    this.taxCode,
    this.industry,
    this.employeeCount,
    this.foundedYear,
    required this.isVerified,
    required this.createdAt,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    return CompanyDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      taxCode: json['taxCode'] as String?,
      industry: json['industry'] as String?,
      employeeCount: json['employeeCount'] as int?,
      foundedYear: json['foundedYear'] != null ? DateTime.tryParse(json['foundedYear'] as String) : null,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }
}
