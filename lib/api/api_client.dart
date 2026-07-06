import 'package:dio/dio.dart';
import 'env.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/auth_interceptor.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(LoggingInterceptor());
    dio.interceptors.add(AuthInterceptor(dio));
  }
}
