import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UserProfile? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _repository.getAccessToken();
      if (token != null) {
        // Try fetching cached profile first
        _currentUser = await _repository.getCachedProfile();
        if (_currentUser != null) {
           _isAuthenticated = true;
           notifyListeners();
        }

        // Validate and refresh profile
        _currentUser = await _repository.fetchProfile();
        _isAuthenticated = true;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        try {
          await _repository.refreshToken();
          _currentUser = await _repository.fetchProfile();
          _isAuthenticated = true;
        } catch (_) {
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.login(username, password);
      _currentUser = await _repository.fetchProfile();
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _error = 'Login failed. Please check your credentials.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
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
