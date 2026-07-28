import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: false,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = Map<String, dynamic>.from(headers);
    if (redacted.containsKey('Authorization')) {
      final val = redacted['Authorization'].toString();
      if (val.startsWith('Bearer ')) {
        redacted['Authorization'] = 'Bearer [REDACTED]';
      } else {
        redacted['Authorization'] = '[REDACTED]';
      }
    }
    return redacted;
  }

  String _truncate(dynamic data) {
    if (data == null) return 'null';
    final str = data.toString();
    if (str.length > 500) {
      return '${str.substring(0, 500)}... [TRUNCATED (${str.length} chars)]';
    }
    return str;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    final timestamp = DateTime.now().toIso8601String();
    print('🌐 [DIO REQUEST] [$timestamp] ${options.method} ${options.uri}');
    print('   Headers: ${_redactHeaders(options.headers)}');
    print('   Body: ${_truncate(options.data)}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as int?;
    final duration = startTime != null ? DateTime.now().millisecondsSinceEpoch - startTime : -1;
    final timestamp = DateTime.now().toIso8601String();
    print('✅ [DIO RESPONSE] [$timestamp] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri} (${duration}ms)');
    print('   Response Body: ${_truncate(response.data)}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['startTime'] as int?;
    final duration = startTime != null ? DateTime.now().millisecondsSinceEpoch - startTime : -1;
    final timestamp = DateTime.now().toIso8601String();
    print('❌ [DIO ERROR] [$timestamp] Status: ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri} (${duration}ms)');
    print('   Exception: ${err.message}');
    print('   Response Data: ${_truncate(err.response?.data)}');
    return super.onError(err, handler);
  }
}

