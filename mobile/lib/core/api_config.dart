class ApiConfig {
  static const String baseUrl =
      'https://api.arjunapijak.web.id'; // Routed via Cloudflare Worker proxy
  static const String marketSummary = '/api/market-summary';
  static const String globalAnalysis = '/api/market-summary/global-analysis';
  static const String historical = '/historical';
  static const String predict = '/predict';
  static const String insight = '/insight';
  static const String audit = '/audit';

  /// Backend proxy untuk GNews — menghindari CORS saat dipanggil dari browser.
  /// Backend (/api/news) memanggil GNews.io server-side menggunakan GNEWS_API_KEY
  /// yang tersimpan di GCP Secret Manager.
  static const String news = '/api/news';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 45);
}

