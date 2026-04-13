import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';

// State Enum
enum AuthStatus { initial, loading, success, error }

// State Class
class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? token; // Có thể lưu token sau khi đăng nhập thành công vào state tạm

  AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
    );
  }
}

// ViewModel (Notifier)
class AuthViewModel extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);
    return AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);
      
      // Xử lý lưu SharedPreferences ở đây nếu cần (tùy nghiệp vụ)
      
      state = state.copyWith(
        status: AuthStatus.success,
        token: response.token,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = AuthState();
  }
}

// Provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
