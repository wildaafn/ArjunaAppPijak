import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../data/news_article.dart';
import '../screens/news_detail_screen.dart';

class NewsSection extends ConsumerWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newsAsync = ref.watch(newsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────
        Row(
          children: [
            Icon(
              Icons.newspaper_rounded,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              'Berita Pangan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            _PoweredByBadge(isDark: isDark),
          ],
        ),

        const SizedBox(height: 12),

        // ── News cards ──────────────────────────────────────────────────
        newsAsync.when(
          data: (articles) {
            if (articles.isEmpty) {
              return _EmptyNews(isDark: isDark);
            }
            return SizedBox(
              height: 205,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: articles.length,
                separatorBuilder: (_, i) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _NewsCard(article: articles[i], isDark: isDark),
              ),
            );
          },
          loading: () => _NewsShimmer(),
          error: (e, _) => _NewsError(
            isDark: isDark,
            onRetry: () => ref.refresh(newsProvider),
          ),
        ),
      ],
    );
  }
}

// ── "Powered by GNews" badge ──────────────────────────────────────────────

class _PoweredByBadge extends StatelessWidget {
  final bool isDark;
  const _PoweredByBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        'GNews',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white38 : Colors.black38,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Single news card ──────────────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  final bool isDark;

  const _NewsCard({required this.article, required this.isDark});

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Thumbnail ────────────────────────────────────────────
                _Thumbnail(imageUrl: article.imageUrl, isDark: isDark),

                // ── Content ──────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source + time
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                article.sourceName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF10B981),
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              article.relativeTime,
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Title
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F0F0F),
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Thumbnail ─────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String? imageUrl;
  final bool isDark;

  const _Thumbnail({this.imageUrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        height: 96,
        width: double.infinity,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const _ThumbnailLoading();
        },
        errorBuilder: (_, e, st) => _FallbackThumbnail(isDark: isDark),
      );
    }
    return _FallbackThumbnail(isDark: isDark);
  }
}

class _ThumbnailLoading extends StatelessWidget {
  const _ThumbnailLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF0B2637)
        : const Color(0xFFE6EEEB);
    final highlightColor = isDark
        ? const Color(0xFF12384C)
        : const Color(0xFFF7FAF8);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 96,
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
      ),
    );
  }
}

class _FallbackThumbnail extends StatelessWidget {
  final bool isDark;
  const _FallbackThumbnail({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.03),
      child: Center(
        child: Icon(
          Icons.article_rounded,
          size: 32,
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
    );
  }
}

// ── Shimmer loading ───────────────────────────────────────────────────────

class _NewsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, i) => const SizedBox(width: 12),
        itemBuilder: (_, i) => const NewsCardShimmer(),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────

class _NewsError extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _NewsError({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark
        ? const Color(0xFF34D399)
        : const Color(0xFF10B981);
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(width: 10),
          Text(
            'Berita tidak tersedia',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onRetry,
            child: Text('Coba lagi', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyNews extends StatelessWidget {
  final bool isDark;
  const _EmptyNews({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          'Belum ada berita terbaru',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ),
    );
  }
}
