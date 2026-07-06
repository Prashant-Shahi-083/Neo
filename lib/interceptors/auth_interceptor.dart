import 'package:dio/dio.dart';
import '../services/secure_storage.dart';
import '../api/api_constants.dart';
import '../api/env.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService _storage = SecureStorageService();
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequestsQueue = [];

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip attaching token for login and refresh endpoints
    if (options.path.contains(ApiConstants.login) || options.path.contains(ApiConstants.refresh)) {
      return handler.next(options);
    }

    final accessToken = await _storage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains(ApiConstants.login)) {
      final options = err.requestOptions;
      
      // Prevent infinite loops if refresh fails
      if (options.path.contains(ApiConstants.refresh)) {
        await _storage.clearAll();
        return handler.next(err);
      }

      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken == null) {
            await _storage.clearAll();
            return handler.next(err);
          }

          // Use a new dio instance to avoid interceptor loops
          final refreshDio = Dio(BaseOptions(baseUrl: Env.baseUrl));
          final response = await refreshDio.post(
            ApiConstants.refresh,
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];

            await _storage.saveAccessToken(newAccessToken);
            await _storage.saveRefreshToken(newRefreshToken);

            // Retry the original request
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            
            // Resolve queued requests
            for (var request in _failedRequestsQueue) {
              request['options'].headers['Authorization'] = 'Bearer $newAccessToken';
              try {
                final res = await dio.fetch(request['options']);
                request['handler'].resolve(res);
              } catch (e) {
                request['handler'].reject(e as DioException);
              }
            }
            _failedRequestsQueue.clear();

            // Retry current request
            final retryResponse = await dio.fetch(options);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          _isRefreshing = false;
          await _storage.clearAll();
          // Ideally dispatch a global "logout" event here
          return handler.next(err);
        }
      } else {
        // Queue this request while refreshing is happening
        _failedRequestsQueue.add({'options': options, 'handler': handler});
        return; // Don't call handler.next, wait for resolution
      }
    }
    
    return handler.next(err);
  }
}
