import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/env.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    
    final accessToken = response.data['access_token'];
    final refreshToken = response.data['refresh_token'];
    
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    
    return response.data;
  }

  Future<void> logout() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        await _dio.post(
          '/auth/logout',
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

    final response = await _dio.post('/auth/refresh', data: {
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
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    
    final profile = UserProfile.fromJson(response.data);
    await _storage.write(key: _profileKey, value: jsonEncode(profile.toJson()));
    
    return profile;
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    final accessToken = await getAccessToken();
    final response = await _dio.patch(
      '/users/profile',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    
    final profile = UserProfile.fromJson(response.data);
    await _storage.write(key: _profileKey, value: jsonEncode(profile.toJson()));
    
    return profile;
  }
}
