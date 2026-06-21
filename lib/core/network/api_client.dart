import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'exceptions/api_exception.dart';


class ApiClient {
  late final Dio dio;
  bool _isRefreshing = false;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: Constants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final prefs = await SharedPreferences.getInstance();
              final refreshToken = prefs.getString('refreshToken');

              if (refreshToken == null || refreshToken.isEmpty) {
                await _forceLogout(prefs);
                return handler.next(error);
              }

              final refreshResponse = await dio.post(
                '/auth/refresh',
                data: {'refreshToken': refreshToken},
                options: Options(headers: {'Authorization': ''}),
              );

              final responseData = refreshResponse.data;
              final data = responseData is Map<String, dynamic> && responseData['success'] == true
                  ? responseData['data']
                  : null;

              if (data == null) {
                await _forceLogout(prefs);
                return handler.next(error);
              }

              final newAccessToken = data['accessToken'] as String? ?? '';
              final newRefreshToken = data['refreshToken'] as String? ?? '';
              await prefs.setString('accessToken', newAccessToken);
              await prefs.setString('refreshToken', newRefreshToken);

              final originalRequest = error.requestOptions;
              originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(originalRequest);
              return handler.resolve(retryResponse);

            } catch (_) {
              final prefs = await SharedPreferences.getInstance();
              await _forceLogout(prefs);
              return handler.next(error);
            } finally {
              _isRefreshing = false;
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _forceLogout(SharedPreferences prefs) async {
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    // navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  dynamic _handleResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      final success = response.data['success'];
      if (success == true) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['message'] ?? 'Lỗi không xác định từ máy chủ', response.statusCode);
      }
    }
    return response.data;
  }

  ApiException _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      if (e.response?.data is Map<String, dynamic> && e.response?.data['message'] != null) {
        return ApiException(e.response?.data['message'], e.response?.statusCode);
      }
      return ApiException('Đã xảy ra lỗi hệ thống: ${e.response?.statusCode}', e.response?.statusCode);
    }
    return ApiException(e.message ?? 'Lỗi kết nối mạng');
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.post(path, data: data, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.put(path, data: data, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.delete(path, data: data, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
