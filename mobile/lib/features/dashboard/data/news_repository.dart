import 'package:dio/dio.dart';
import '../../../core/api_config.dart';
import 'news_article.dart';

class NewsRepository {
  final Dio _dio;

  NewsRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.newsApiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  /// Fetch up to [max] latest news articles about Indonesian food commodities.
  ///
  /// GNews.io endpoint:
  /// GET /search?q=...&lang=id&country=id&max=5&token=TOKEN
  Future<List<NewsArticle>> fetchPanganNews({int max = 5}) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': ApiConfig.newsQuery,
          'lang': 'id',
          'country': 'id',
          'max': max,
          'token': ApiConfig.newsApiKey,
        },
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
