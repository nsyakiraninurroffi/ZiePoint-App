class Env {
  // Use flutter run --dart-define-from-file=.env.dev
  // Provide fallbacks so it doesn't crash if not provided
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.8:3000',
  );
  static const String envName = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => envName == 'production';
  static bool get isDevelopment => envName == 'development';
}
