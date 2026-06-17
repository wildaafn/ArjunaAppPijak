import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/news_article.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/arjuna_brand.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  Future<void> _openFullArticle() async {
    final uri = Uri.tryParse(article.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            // ── Dynamic Sliver Header ───────────────────────────────────────
            SliverAppBar(
              expandedHeight: 280.0,
              pinned: true,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(
                    alpha: 0.72,
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: isDark ? Colors.white : ArjunaColors.navy,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              backgroundColor: isDark ? const Color(0xFF031827) : Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: article.imageUrl != null
                    ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(isDark),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildImageLoadingPlaceholder(isDark);
                        },
                      )
                    : _buildImagePlaceholder(isDark),
              ),
            ),

            // ── Content Area ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF061525).withValues(alpha: 0.96)
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      width: 1.5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Publisher & Date Info Row
                    Row(
                      children: [
                        // Publisher Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF16C7B7).withValues(alpha: 0.1)
                                : const Color(
                                    0xFF0B9F91,
                                  ).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isDark
                                  ? const Color(
                                      0xFF16C7B7,
                                    ).withValues(alpha: 0.2)
                                  : const Color(
                                      0xFF0B9F91,
                                    ).withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            article.sourceName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF16C7B7)
                                  : const Color(0xFF0B9F91),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Date text
                        Expanded(
                          child: Text(
                            article.relativeTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF6A7D85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Article Title
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: isDark ? Colors.white : ArjunaColors.navy,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Date & Time Detail text
                    Text(
                      _formatDate(article.publishedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white30 : Colors.black38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(height: 32, thickness: 1),

                    // Content Body / Summary Description
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.65,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF2C3E50),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Button to Read More
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF16C7B7)
                              : const Color(0xFF0B9F91),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _openFullArticle,
                        icon: const Icon(
                          Icons.open_in_browser_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Baca Selengkapnya di Website',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48), // Padding below button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageLoadingPlaceholder(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF0B2637) : const Color(0xFFE6EEEB),
      highlightColor: isDark
          ? const Color(0xFF12384C)
          : const Color(0xFFF7FAF8),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0B1B2A) : const Color(0xFFEAF8F4),
      child: Center(
        child: Icon(
          Icons.newspaper_rounded,
          size: 64,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
    );
  }
}
