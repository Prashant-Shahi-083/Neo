
class Env {
  static const String defaultProductionUrl = 'https://neo-backend-r9f2.onrender.com';
  
  static String get baseUrl {
    const String apiUrl = String.fromEnvironment('API_URL', defaultValue: '');
    if (apiUrl.isNotEmpty) {
      return apiUrl;
    }
    return defaultProductionUrl;
  }
}
