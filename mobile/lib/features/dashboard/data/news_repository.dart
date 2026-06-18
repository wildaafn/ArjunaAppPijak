import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/api_config.dart';
import 'news_article.dart';

/// Repository untuk mengambil berita pangan dari backend proxy Arjuna.
///
/// GNews.io tidak mengizinkan request langsung dari browser (CORS). Oleh karena
/// itu, semua request berita diproxy melalui endpoint `/api/news` di backend
/// FastAPI kita, yang kemudian memanggil GNews.io server-side.
class NewsRepository {
  final Dio _dio;

  NewsRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

  /// Fetch up to [max] latest news articles about Indonesian food commodities.
  ///
  /// Calls our backend proxy at GET /api/news?max=N which then fetches from
  /// GNews.io server-side (avoids browser CORS restrictions).
  Future<List<NewsArticle>> fetchPanganNews({int max = 6}) async {
    try {
      final response = await _dio.get(
        ApiConfig.news,
        queryParameters: {'max': max},
      );

      final articles = (response.data['articles'] as List<dynamic>? ?? [])
          .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
          .where((a) => a.title.isNotEmpty && a.url.isNotEmpty)
          .toList();

      return articles;
    } on DioException catch (e) {
      throw Exception('Gagal memuat berita: ${e.message}');
    }
  }
}
