import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:prashant/main_screen.dart';
import 'package:prashant/screens/login_screen.dart';
import 'package:prashant/services/auth_provider.dart';
import 'package:prashant/services/home_provider.dart';
import 'package:prashant/services/player_provider.dart';
import 'package:prashant/services/search_provider.dart';
import 'package:prashant/services/library_provider.dart';
import 'package:prashant/services/playlist_provider.dart';
import 'package:prashant/services/profile_provider.dart';
import 'package:prashant/services/settings_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prashant/api/env.dart';
import 'package:prashant/api/api_client.dart';
import 'package:prashant/theme/neo_theme.dart';

class _RealNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..idleTimeout = Duration.zero
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class TrackingInterceptor extends Interceptor {
  final Map<RequestOptions, DateTime> _startTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTimes[options] = DateTime.now();
    print('🌐 [DIO REQUEST START] ${options.method} ${options.uri} at ${_startTimes[options]}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = _startTimes[response.requestOptions] ?? DateTime.now();
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    print('🌐 [DIO RESPONSE OK] ${response.requestOptions.method} ${response.requestOptions.uri} -> Status: ${response.statusCode} in ${duration}ms');
    _startTimes.remove(response.requestOptions);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = _startTimes[err.requestOptions] ?? DateTime.now();
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    print('🌐 [DIO RESPONSE ERROR] ${err.requestOptions.method} ${err.requestOptions.uri} -> Status: ${err.response?.statusCode} Error: ${err.message} in ${duration}ms');
    _startTimes.remove(err.requestOptions);
    super.onError(err, handler);
  }

  void printPendingRequests() {
    if (_startTimes.isEmpty) {
      print('🌐 [PENDING CHECK] No Dio requests are currently in flight.');
    } else {
      print('🌐 [PENDING CHECK] Found ${_startTimes.length} uncompleted Dio request(s):');
      _startTimes.forEach((req, startTime) {
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        print('   ⏳ HANGING REQUEST: ${req.method} ${req.uri} (started ${duration}ms ago)');
      });
    }
  }
}

final tracker = TrackingInterceptor();

void main() {
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    HttpOverrides.global = _RealNetworkHttpOverrides();
    ApiClient().dio.interceptors.add(tracker);
    print('💡 Test setup complete. Env.baseUrl is: ${Env.baseUrl}');
  });

  testWidgets('Reproduce login hang and capture network/provider traces', (tester) async {
    print('💡 Starting NeoApp widget test reproduction...');
    
    late AuthProvider authProvider;
    late HomeProvider homeProvider;
    late PlayerProvider playerProvider;
    late LibraryProvider libraryProvider;
    late ProfileProvider profileProvider;

    await tester.runAsync(() async {
      authProvider = AuthProvider();
      authProvider.repository.dio.interceptors.add(tracker);
      homeProvider = HomeProvider();
      playerProvider = PlayerProvider();
      libraryProvider = LibraryProvider();
      profileProvider = ProfileProvider();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: homeProvider),
          ChangeNotifierProvider.value(value: playerProvider),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
          ChangeNotifierProvider.value(value: libraryProvider),
          ChangeNotifierProvider(create: (_) => PlaylistProvider()),
          ChangeNotifierProvider.value(value: profileProvider),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: MaterialApp(
          theme: NeoTheme.theme,
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();
    print('💡 LoginScreen rendered. Entering credentials...');

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'admin');
    await tester.enterText(textFields.at(1), 'Admin@123');
    await tester.pump();

    print('💡 Pressing Login button...');
    final startTime = DateTime.now();
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.runAsync(() async {
      await tester.tap(loginButton, warnIfMissed: true);
    });
    await tester.pump();
    
    // Also trigger onFieldSubmitted just in case
    await tester.runAsync(() async {
      await tester.testTextInput.receiveAction(TextInputAction.done);
    });
    await tester.pump();

    bool navigatedToMain = false;
    for (int i = 0; i < 140; i++) {
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      print('⏱️ [$elapsed ms] Auth: isAuthenticated=${authProvider.isAuthenticated}, isLoading=${authProvider.isLoading}, error=${authProvider.error}');
      print('⏱️ [$elapsed ms] Home: isLoading=${homeProvider.isLoading}, error=${homeProvider.error}, sections=${homeProvider.sections.length}');
      print('⏱️ [$elapsed ms] Library: isLoading=${libraryProvider.isLoading}, error=${libraryProvider.error}, playlists=${libraryProvider.playlists.length}');
      print('⏱️ [$elapsed ms] Profile: isLoading=${profileProvider.isLoading}, error=${profileProvider.error}, user=${profileProvider.profile?.username}');
      tracker.printPendingRequests();
      
      if (find.byType(MainScreen).evaluate().isNotEmpty) {
        if (!navigatedToMain) {
          print('✅ Navigated to MainScreen!');
          navigatedToMain = true;
        }
        if (!homeProvider.isLoading && !libraryProvider.isLoading && !profileProvider.isLoading) {
          print('✅ All initial data loaded successfully!');
          break;
        }
      } else if (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
        print('⏳ Still displaying CircularProgressIndicator...');
      }
    }

    authProvider.repository.dio.close(force: true);
    ApiClient().dio.close(force: true);
    await tester.pump(const Duration(seconds: 5));
  });
}
