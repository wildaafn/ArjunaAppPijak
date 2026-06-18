/// Model untuk satu artikel berita dari GNews.io
class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String sourceName;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    required this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] as String?;
    String? proxiedImage;
    if (rawImage != null && rawImage.isNotEmpty) {
      proxiedImage = 'https://images.weserv.nl/?url=${Uri.encodeComponent(rawImage.trim())}&w=400&fit=cover';
    }

    return NewsArticle(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageUrl: proxiedImage,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      sourceName:
          (json['source'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    );
  }

  /// Relative time string — "2 jam lalu", "3 hari lalu", etc.
  String get relativeTime {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${(diff.inDays / 7).floor()} minggu lalu';
  }
}
