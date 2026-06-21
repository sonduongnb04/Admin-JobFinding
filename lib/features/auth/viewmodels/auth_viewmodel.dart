import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

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
      // 1. Login to get tokens
      final loginData = await _authService.login(email, password);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', loginData['accessToken'] ?? '');
      await prefs.setString('refreshToken', loginData['refreshToken'] ?? '');

      // 2. Check role from login data directly
      final roles = loginData['roles'];
      bool isAdmin = false;
      
      if (roles is List) {
        isAdmin = roles.contains('ADMIN');
      } else if (roles is String) {
        isAdmin = roles == 'ADMIN';
      } else if (loginData['role'] == 'ADMIN') {
        isAdmin = true;
      }

      if (!isAdmin) {
        // Not admin, clear tokens
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Không đủ quyền truy cập (Yêu cầu tài khoản Admin)',
        );
        return;
      }
      
      state = state.copyWith(status: AuthStatus.success);
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

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
