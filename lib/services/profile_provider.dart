import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _userRepository.getProfile();
      if (_profile == null) {
        _error = 'Failed to load profile. Please check your connection.';
      }
    } catch (e) {
      _error = 'Failed to load profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }
}
