import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/domain/models.dart';
import '../../../../core/providers.dart';
import '../../../detail/presentation/screens/detail_screen.dart';
import '../../../../shared/widgets/bouncy_tappable.dart';

class QuickAccessGrid extends ConsumerWidget {
  final List<Commodity> commodities;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  const QuickAccessGrid({super.key, required this.commodities});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Take first 4 commodities for quick access (assume sorted by importance from API)
    final items = commodities.length > 4
        ? commodities.sublist(0, 4)
        : commodities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 18,
              color: isDark ? const Color(0xFFE8C766) : const Color(0xFF07345A),
            ),
            const SizedBox(width: 8),
            Text(
              'Akses Cepat',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF07345A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.52,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final commodity = items[index];
            return _QuickCard(
              commodity: commodity,
              isDark: isDark,
              currencyFormat: _currencyFormat,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(
                    commodity: commodity,
                    heroTag: 'quick-${commodity.name}',
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickCard extends ConsumerWidget {
  final Commodity commodity;
  final bool isDark;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const _QuickCard({
    required this.commodity,
    required this.isDark,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    final dayChange = commodity.priceChanges['day_1'] ?? 0;
    final trendColor = ref
        .read(settingsProvider.notifier)
        .getTrendColor(dayChange);
    final isPositive = dayChange > 0;
    final isFlat = dayChange == 0;
    final navy = isDark ? const Color(0xFFEAF8F4) : const Color(0xFF07345A);

    return BouncyTappable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF07345A,
              ).withValues(alpha: isDark ? 0.18 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isDark
                  ? const Color(0xFFE8C766).withValues(alpha: 0.12)
                  : const Color(0xFF07345A).withValues(alpha: 0.06),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF0A2638), const Color(0xFF071F31)]
                          : [Colors.white, const Color(0xFFF9FCFA)],
                    ),
                  ),
                ),
              ),

              // Left accent strip
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: trendColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
              ),

              // Decorative circle & Commodity Image (Centered together)
              Positioned(
                right: -8,
                bottom: -8,
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child: Stack(
                     alignment: Alignment.center,
                     children: [
                       Container(
                         width: 86,
                         height: 86,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           color: trendColor.withValues(alpha: 0.05),
                         ),
                       ),
                       Hero(
                         tag: 'quick-${commodity.name}',
                         child: Image.asset(
                           commodity.imageAsset,
                           width: 66,
                           height: 66,
                           fit: BoxFit.contain,
                           errorBuilder: (_, e, st) =>
                               Icon(Icons.eco_rounded, color: trendColor, size: 34),
                         ),
                       ),
                     ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            commodity.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                  color: navy,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 42),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomPaint(
                          size: const Size(68, 16),
                          painter: _MiniSparklinePainter(
                            color: trendColor.withValues(alpha: 0.7),
                            history: commodity.chart.history,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(commodity.currentPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: navy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: trendColor.withValues(
                              alpha: isDark ? 0.16 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.arrow_upward_rounded
                                    : (isFlat
                                          ? Icons.trending_flat_rounded
                                          : Icons.arrow_downward_rounded),
                                size: 12,
                                color: trendColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${dayChange.abs().toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: trendColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final Color color;
  final List<PricePoint> history;

  const _MiniSparklinePainter({required this.color, required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.62),
      Offset(size.width, size.height * 0.62),
      guide,
    );

    if (history.length < 2) return;

    final path = Path();
    final prices = history.map((p) => p.price).toList();

    double minPrice = prices.reduce((a, b) => a < b ? a : b);
    double maxPrice = prices.reduce((a, b) => a > b ? a : b);

    // Add small padding to min and max to keep sparkline clean
    final priceRange = maxPrice - minPrice;
    final padding = priceRange == 0 ? 1.0 : priceRange * 0.15;
    minPrice -= padding;
    maxPrice += padding;

    final range = maxPrice - minPrice;

    for (int i = 0; i < prices.length; i++) {
      final double x = (i / (prices.length - 1)) * size.width;
      final double ratio = (prices[i] - minPrice) / range;
      // Invert Y coordinate because 0 is at the top in Flutter
      final double y = size.height - (ratio * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.history != history;
  }
}
