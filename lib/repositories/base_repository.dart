import 'package:dio/dio.dart';
import '../api/api_client.dart';
import 'package:logger/logger.dart';

abstract class BaseRepository {
  final Dio dio = ApiClient().dio;
  final Logger logger = Logger();

  /// Helper to handle exceptions consistently
  Future<T> safeApiCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      logger.e('API Error: \${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      logger.e('Unknown Error: \$e');
      throw Exception('An unexpected error occurred: \$e');
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timed out. Please check your internet.');
    }
    
    if (error.response != null) {
      final data = error.response?.data;
      final message = (data is Map && data['message'] != null) 
          ? data['message'] 
          : 'Server returned \${error.response?.statusCode}';
      return Exception(message);
    }
    
    return Exception('Network error occurred. Please check your connection.');
  }
}
