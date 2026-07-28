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
    print('👤 [PROFILE PROVIDER] [${DateTime.now().toIso8601String()}] ProfileProvider instantiated. Calling loadProfile()...');
    loadProfile();
  }

  Future<void> loadProfile() async {
    print('👤 [PROFILE PROVIDER] [${DateTime.now().toIso8601String()}] loadProfile() started');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('👤 [PROFILE PROVIDER] [${DateTime.now().toIso8601String()}] Calling _userRepository.getProfile()...');
      _profile = await _userRepository.getProfile();
      if (_profile == null) {
        print('⚠️ [PROFILE PROVIDER] [${DateTime.now().toIso8601String()}] _userRepository.getProfile() returned null.');
        _error = 'Failed to load profile. Please check your connection.';
      } else {
        print('👤 [PROFILE PROVIDER] [${DateTime.now().toIso8601String()}] loadProfile() succeeded for user: ${_profile?.username}');
      }
    } catch (e) {
      print('❌ [PROFILE PROVIDER] [${DateTime.now().toIso8601String()}] loadProfile() threw exception: $e');
      _error = 'Failed to load profile.';
    } finally {
      _isLoading = false;
      print('👤 [PROFILE PROVIDER] [${DateTime.now().toIso8601String()}] loadProfile() finally: setting _isLoading=false, calling notifyListeners()');
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    print('👤 [PROFILE PROVIDER] [${DateTime.now().toIso8601String()}] refreshProfile() called');
    await loadProfile();
  }
}
