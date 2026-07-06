import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('=> ${options.method} ${options.uri}\nData: ${options.data}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('<= ${response.statusCode} ${response.requestOptions.uri}\nData: ${response.data}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      '!! ${err.response?.statusCode} ${err.requestOptions.uri}\n'
      'Message: ${err.message}\n'
      'Response Data: ${err.response?.data}',
    );
    return super.onError(err, handler);
  }
}
