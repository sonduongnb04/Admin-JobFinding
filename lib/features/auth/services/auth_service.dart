import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthService(apiClient.dio);
});

class AuthService {
  // ignore: unused_field
  final Dio _dio;

  AuthService(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      // Vì là Mock nên tôi sẽ delay 1 chút trước khi trả về fake data
      await Future.delayed(const Duration(seconds: 1));
      
      // Đoạn này dùng Call Real API nếu có Backend:
      // final response = await _dio.post('/login', data: request.toJson());
      // return LoginResponse.fromJson(response.data);
      
      // Fake Success
      if (request.email.isNotEmpty && request.password.isNotEmpty) {
         return LoginResponse(token: 'fake_jwt_token_12345');
      } else {
         throw Exception('Email and password cannot be empty');
      }
    } catch (e) {
      // Xử lý lỗi API
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}
