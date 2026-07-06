import 'dart:io';

class Env {
  // If running on Android Emulator, localhost is 10.0.2.2.
  // If running on iOS Simulator, localhost is 127.0.0.1.
  // If running on Web/Desktop, localhost is 127.0.0.1.
  
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      return 'http://127.0.0.1:3000/api/v1';
    }
  }
}
