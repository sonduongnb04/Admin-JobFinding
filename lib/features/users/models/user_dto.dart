class UserDto {
  final int id;
  final String email;
  final String? fullName;
  final List<String> roles;
  final bool isLocked;
  final DateTime createdAt;

  UserDto({
    required this.id,
    required this.email,
    this.fullName,
    required this.roles,
    required this.isLocked,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isLocked: json['isLocked'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  UserDto copyWith({
    int? id,
    String? email,
    String? fullName,
    List<String>? roles,
    bool? isLocked,
    DateTime? createdAt,
  }) {
    return UserDto(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      roles: roles ?? this.roles,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
