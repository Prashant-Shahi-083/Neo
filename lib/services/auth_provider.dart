import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final Logger _logger = Logger();

  UserProfile? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthRepository get repository => _repository;

  Future<void> restoreSession() async {
    print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] restoreSession() started');
    _logger.i('AuthProvider: Restoring session from secure storage...');
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _repository.getAccessToken();
      if (token != null) {
        print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Stored access token found. Checking cached profile...');
        _logger.i('AuthProvider: Found stored access token. Checking cached profile...');
        // Try fetching cached profile first
        _currentUser = await _repository.getCachedProfile();
        if (_currentUser != null) {
           print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Cached profile loaded for ${_currentUser?.username}');
           _logger.i('AuthProvider: Cached profile loaded for ${_currentUser?.username}');
           _isAuthenticated = true;
           notifyListeners();
        }

        // Validate and refresh profile
        print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Validating profile against server...');
        _logger.i('AuthProvider: Validating profile against server...');
        _currentUser = await _repository.fetchProfile();
        _isAuthenticated = true;
        print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Session restored successfully for ${_currentUser?.username}');
        _logger.i('AuthProvider: Session restored successfully.');
      } else {
        print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] No stored access token found.');
        _logger.i('AuthProvider: No stored access token found.');
      }
    } catch (e) {
      print('⚠️ [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Error restoring session: $e');
      _logger.w('AuthProvider: Error restoring session: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Token expired (401). Attempting token refresh...');
        _logger.i('AuthProvider: Token expired (401). Attempting token refresh...');
        try {
          await _repository.refreshToken();
          _currentUser = await _repository.fetchProfile();
          _isAuthenticated = true;
          print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Token refresh and session restore succeeded.');
          _logger.i('AuthProvider: Token refresh and session restore succeeded.');
        } catch (_) {
          print('❌ [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Token refresh failed.');
          _logger.e('AuthProvider: Token refresh failed. User must log in again.');
          _isAuthenticated = false;
          _currentUser = null;
        }
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    }

    _isLoading = false;
    print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] restoreSession() completed. _isLoading=false, _isAuthenticated=$_isAuthenticated');
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] login() started for user: $username');
    _logger.i('AuthProvider: Attempting login for user: $username');
    _error = null;

    try {
      print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Calling _repository.login...');
      await _repository.login(username, password);
      print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Login repository call succeeded. Fetching user profile...');
      _logger.i('AuthProvider: Login repository call succeeded. Fetching user profile...');
      _currentUser = await _repository.fetchProfile();
      print('🔑 [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] User profile fetched successfully: ${_currentUser?.username}');
      _logger.i('AuthProvider: User profile fetched successfully: ${_currentUser?.username}');
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ [AUTH PROVIDER] [${DateTime.now().toIso8601String()}] Login failed with error: $e');
      _logger.e('AuthProvider: Login failed with error: $e');
      _error = 'Login failed. Please check your credentials.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _logger.i('AuthProvider: Logging out user...');
    await _repository.logout();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _currentUser = await _repository.updateProfile(data);
    notifyListeners();
  }
}
