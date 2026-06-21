class CompanyRequestDto {
  final int id;
  final int userId;
  final String companyName;
  final String taxCode;
  final String? website;
  final String? description;
  final String? businessLicenseUrl;
  final String status;
  final DateTime createdAt;

  CompanyRequestDto({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.taxCode,
    this.website,
    this.description,
    this.businessLicenseUrl,
    required this.status,
    required this.createdAt,
  });

  factory CompanyRequestDto.fromJson(Map<String, dynamic> json) {
    return CompanyRequestDto(
      id: json['id'] as int? ?? 0,
      userId: json['requesterId'] as int? ?? 0,
      companyName: json['companyName'] as String? ?? '',
      taxCode: json['taxCode'] as String? ?? '',
      website: json['website'] as String?,
      description: json['description'] as String?,
      businessLicenseUrl: json['businessLicenseUrl'] as String?,
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
