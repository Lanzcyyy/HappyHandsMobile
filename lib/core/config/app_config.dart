class AppConfig {
  /// Base URL for your Flask API, ending with `/api`.
  ///
  /// Example (same Wi-Fi phone + PC):
  /// - http://192.168.1.12:5500/api
  ///
  /// You can override at runtime:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.12:5500/api`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5500/api',
  );

  static const Duration connectTimeout = Duration(seconds: 8);
  static const Duration requestTimeout = Duration(seconds: 20);
  
  // Image URLs
  static const String staticBaseUrl = 'http://127.0.0.1:5500/static';
  static const String uploadsBaseUrl = 'http://127.0.0.1:5500/uploads';
  
  // Pagination
  static const int defaultPageSize = 12;
  static const int maxPageSize = 100;
  
  // Cache settings
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  // App settings
  static const String appName = 'Happy Hands';
  static const String appVersion = '1.0.0';
  
  // Debug settings
  static const bool enableLogging = true;
  static const bool enableNetworkLogging = true;
}

