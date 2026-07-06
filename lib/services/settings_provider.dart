import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isLoading = true;

  String _audioQuality = 'High'; // High, Medium, Low
  bool _gaplessPlayback = true;
  String _downloadQuality = 'High'; // High, Medium, Low
  bool _privateSession = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  // Getters
  bool get isLoading => _isLoading;
  String get audioQuality => _audioQuality;
  bool get gaplessPlayback => _gaplessPlayback;
  String get downloadQuality => _downloadQuality;
  bool get privateSession => _privateSession;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _audioQuality = prefs.getString('audioQuality') ?? 'High';
      _gaplessPlayback = prefs.getBool('gaplessPlayback') ?? true;
      _downloadQuality = prefs.getString('downloadQuality') ?? 'High';
      _privateSession = prefs.getBool('privateSession') ?? false;
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _emailNotifications = prefs.getBool('emailNotifications') ?? false;
    } catch (e) {
      // Fallback to defaults
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setAudioQuality(String quality) async {
    _audioQuality = quality;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioQuality', quality);
  }

  Future<void> setGaplessPlayback(bool value) async {
    _gaplessPlayback = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gaplessPlayback', value);
  }

  Future<void> setDownloadQuality(String quality) async {
    _downloadQuality = quality;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('downloadQuality', quality);
  }

  Future<void> setPrivateSession(bool value) async {
    _privateSession = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privateSession', value);
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', value);
  }

  Future<void> setEmailNotifications(bool value) async {
    _emailNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailNotifications', value);
  }

  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
  }
}
