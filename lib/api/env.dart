import 'dart:io';
import 'package:flutter/foundation.dart';

class Env {
  // If running on Android Emulator, localhost is 10.0.2.2.
  // If running on iOS Simulator, localhost is 127.0.0.1.
  // If running on Web/Desktop, localhost is 127.0.0.1.
  
  static String get baseUrl {
    const String apiUrl = String.fromEnvironment('API_URL', defaultValue: '');
    if (apiUrl.isNotEmpty) {
      return apiUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:3002';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3002';
    } else {
      return 'http://127.0.0.1:3002';
    }
  }
}
