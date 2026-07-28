import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../services/secure_storage.dart';
import '../api/api_constants.dart';
import '../api/env.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService _storage = SecureStorageService();
  final Logger _logger = Logger();
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequestsQueue = [];

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final timestamp = DateTime.now().toIso8601String();
    // Skip attaching token for login and refresh endpoints
    if (options.path.contains(ApiConstants.login) || options.path.contains(ApiConstants.refresh)) {
      print('🔐 [AUTH INTERCEPTOR] [$timestamp] Skipping token attachment for ${options.path}');
      _logger.d('AuthInterceptor: Skipping token attachment for ${options.path}');
      return handler.next(options);
    }

    final accessToken = await _storage.getAccessToken();
    if (accessToken != null) {
      print('🔐 [AUTH INTERCEPTOR] [$timestamp] Attaching Bearer token [REDACTED] to ${options.path}');
      _logger.d('AuthInterceptor: Attaching Bearer token to ${options.path}');
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      print('⚠️ [AUTH INTERCEPTOR] [$timestamp] No access token found in storage for ${options.path}');
      _logger.w('AuthInterceptor: No access token found in storage for ${options.path}');
    }

    return handler.next(options);
  }

  void _rejectQueuedRequests(DioException err) {
    _logger.w('AuthInterceptor: Rejecting ${_failedRequestsQueue.length} queued requests.');
    for (var request in _failedRequestsQueue) {
      try {
        request['handler'].reject(err);
      } catch (e) {
        _logger.e('AuthInterceptor: Error rejecting queued request: $e');
      }
    }
    _failedRequestsQueue.clear();
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains(ApiConstants.login)) {
      final options = err.requestOptions;
      _logger.w('AuthInterceptor: 401 Unauthorized encountered for ${options.path} (isRefreshing: $_isRefreshing)');
      
      // Prevent infinite loops if refresh fails
      if (options.path.contains(ApiConstants.refresh)) {
        _logger.e('AuthInterceptor: Refresh endpoint itself returned 401. Clearing storage.');
        await _storage.clearAll();
        return handler.next(err);
      }

      if (!_isRefreshing) {
        _isRefreshing = true;
        _logger.i('AuthInterceptor: Initiating token refresh sequence...');

        try {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken == null) {
            _logger.e('AuthInterceptor: No refresh token available in storage. Clearing storage and rejecting queued requests.');
            _isRefreshing = false;
            _rejectQueuedRequests(err);
            await _storage.clearAll();
            return handler.next(err);
          }

          _logger.i('AuthInterceptor: Sending refresh request to ${ApiConstants.refresh}');
          // Use a new dio instance to avoid interceptor loops
          final refreshDio = Dio(BaseOptions(
            baseUrl: Env.baseUrl,
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
          ));
          final response = await refreshDio.post(
            ApiConstants.refresh,
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            _logger.i('AuthInterceptor: Token refresh successful. Updating secure storage.');
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];

            await _storage.saveAccessToken(newAccessToken);
            await _storage.saveRefreshToken(newRefreshToken);

            // Retry the original request
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            
            // Resolve queued requests
            _logger.i('AuthInterceptor: Retrying ${_failedRequestsQueue.length} queued requests with new token.');
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
            _logger.i('AuthInterceptor: Retrying original request to ${options.path}');
            final retryResponse = await dio.fetch(options);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          } else {
            _logger.e('AuthInterceptor: Refresh endpoint returned unexpected status code ${response.statusCode}.');
            _isRefreshing = false;
            _rejectQueuedRequests(err);
            await _storage.clearAll();
            return handler.next(err);
          }
        } catch (e) {
          _logger.e('AuthInterceptor: Exception during token refresh: $e');
          _isRefreshing = false;
          _rejectQueuedRequests(err);
          await _storage.clearAll();
          // Ideally dispatch a global "logout" event here
          return handler.next(err);
        }
      } else {
        // Queue this request while refreshing is happening
        _logger.i('AuthInterceptor: Refresh already in progress. Queueing request to ${options.path}. Queue size: ${_failedRequestsQueue.length + 1}');
        _failedRequestsQueue.add({'options': options, 'handler': handler});
        return; // Don't call handler.next, wait for resolution
      }
    }
    
    return handler.next(err);
  }
}
