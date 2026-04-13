class LoginResponse {
  final String token;
  // Các field thêm nếu backend có (vd: id, name, role...)

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '', // Giả định field tên là 'token'
    );
  }
}
