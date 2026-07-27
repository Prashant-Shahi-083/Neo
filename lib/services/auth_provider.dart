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

  Future<void> restoreSession() async {
    _logger.i('AuthProvider: Restoring session from secure storage...');
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _repository.getAccessToken();
      if (token != null) {
        _logger.i('AuthProvider: Found stored access token. Checking cached profile...');
        // Try fetching cached profile first
        _currentUser = await _repository.getCachedProfile();
        if (_currentUser != null) {
           _logger.i('AuthProvider: Cached profile loaded for ${_currentUser?.username}');
           _isAuthenticated = true;
           notifyListeners();
        }

        // Validate and refresh profile
        _logger.i('AuthProvider: Validating profile against server...');
        _currentUser = await _repository.fetchProfile();
        _isAuthenticated = true;
        _logger.i('AuthProvider: Session restored successfully.');
      } else {
        _logger.i('AuthProvider: No stored access token found.');
      }
    } catch (e) {
      _logger.w('AuthProvider: Error restoring session: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        _logger.i('AuthProvider: Token expired (401). Attempting token refresh...');
        try {
          await _repository.refreshToken();
          _currentUser = await _repository.fetchProfile();
          _isAuthenticated = true;
          _logger.i('AuthProvider: Token refresh and session restore succeeded.');
        } catch (_) {
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
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _logger.i('AuthProvider: Attempting login for user: $username');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.login(username, password);
      _logger.i('AuthProvider: Login repository call succeeded. Fetching user profile...');
      _currentUser = await _repository.fetchProfile();
      _logger.i('AuthProvider: User profile fetched successfully: ${_currentUser?.username}');
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _logger.e('AuthProvider: Login failed with error: $e');
      _error = 'Login failed. Please check your credentials.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
