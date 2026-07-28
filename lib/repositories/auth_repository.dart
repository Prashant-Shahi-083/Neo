import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/env.dart';
import '../models/user_profile.dart';
import '../interceptors/logging_interceptor.dart';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  AuthRepository() {
    _dio.interceptors.add(LoggingInterceptor());
  }

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _profileKey = 'user_profile';

  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);

  Future<UserProfile?> getCachedProfile() async {
    final str = await _storage.read(key: _profileKey);
    if (str != null) {
      return UserProfile.fromJson(jsonDecode(str));
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    print('💡 AuthRepository.login() entered. Calling _dio.post(/api/v1/auth/login)...');
    try {
      final response = await _dio.post('/api/v1/auth/login', data: {
        'username': username,
        'password': password,
      });
      print('💡 AuthRepository.login() got response: ${response.statusCode}');
      
      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      
      print('💡 AuthRepository.login() writing tokens to secure storage...');
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      print('💡 AuthRepository.login() tokens written to secure storage.');
      
      return response.data;
    } catch (e, st) {
      print('❌ AuthRepository.login() exception: $e\n$st');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        await _dio.post(
          '/api/v1/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
      }
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<String?> refreshToken() async {
    final token = await getRefreshToken();
    if (token == null) throw Exception('No refresh token');

    final response = await _dio.post('/api/v1/auth/refresh', data: {
      'refresh_token': token,
    });

    final newAccess = response.data['access_token'];
    final newRefresh = response.data['refresh_token'];

    await _storage.write(key: _accessTokenKey, value: newAccess);
    await _storage.write(key: _refreshTokenKey, value: newRefresh);

    return newAccess;
  }

  Future<UserProfile> fetchProfile() async {
    final accessToken = await getAccessToken();
    final response = await _dio.get(
      '/api/v1/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    
    final profile = UserProfile.fromJson(response.data);
    await _storage.write(key: _profileKey, value: jsonEncode(profile.toJson()));
    
    return profile;
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    final accessToken = await getAccessToken();
    final response = await _dio.patch(
      '/api/v1/users/profile',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    
    final profile = UserProfile.fromJson(response.data);
    await _storage.write(key: _profileKey, value: jsonEncode(profile.toJson()));
    
    return profile;
  }
}
