class ApiConfig {
  static const String baseUrl =
      'https://api.arjunapijak.web.id'; // Change to server IP for physical device
  static const String marketSummary = '/api/market-summary';
  static const String globalAnalysis = '/api/market-summary/global-analysis';
  static const String historical = '/historical';
  static const String predict = '/predict';
  static const String insight = '/insight';
  static const String audit = '/audit';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 45);

  // GNews.io — https://gnews.io (free: 100 req/day, no mobile restriction)
  // Gunakan --dart-define=GNEWS_API_KEY=key_anda atau --dart-define-from-file=secrets.json
  static const String newsApiKey = String.fromEnvironment(
    'GNEWS_API_KEY',
    defaultValue: '',
  );
  static const String newsApiBaseUrl = 'https://gnews.io/api/v4';
  static const String newsQuery =
      '"harga pangan" OR "harga beras" OR "harga cabai" OR "harga bawang" OR "harga daging" OR "harga telur" OR "komoditas pangan"';
}
