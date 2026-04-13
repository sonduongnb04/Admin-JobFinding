import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://mock.api.jobfind.com/api', // Mock URL
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm các Interceptors để handle việc gửi token và log lỗi nếu cần thiết
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Bạn có thể chắp thêm token từ SharedPreferences ở đây nếu có
          // Ví dụ: 
          // final token = prefs.getString('access_token');
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Xử lý các thay đổi chung trên response nếu cần
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Log lỗi chung hoặc xử lý phân loại Unauthorized (401), v.v.
          // Để dev dễ theo dõi
          return handler.next(e);
        },
      ),
    );
  }
}
