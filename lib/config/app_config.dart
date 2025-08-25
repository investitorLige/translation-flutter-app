class AppConfig {
  // Environment configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      default:
        return 'https://c8a91385664a.ngrok-free.app'; // Development
    }
  }

  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}