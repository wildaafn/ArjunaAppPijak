import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/domain/models.dart';
import '../../../../shared/widgets/arjuna_brand.dart';

class StickyPriceHeader extends SliverPersistentHeaderDelegate {
  final Commodity commodity;
  final NumberFormat currencyFormat;
  final Color trendColor;
  final double currentChange;
  final String heroTag;

  StickyPriceHeader({
    required this.commodity,
    required this.currencyFormat,
    required this.trendColor,
    required this.currentChange,
    required this.heroTag,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scrollRange = maxExtent - minExtent;
    final progress = (shrinkOffset / scrollRange).clamp(0.0, 1.0);

    // Calculate opacity for expanded/collapsed elements
    final expandedOpacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);
    final collapsedOpacity = (progress * 1.5 - 0.5).clamp(0.0, 1.0);

    final currentHeight = (maxExtent - shrinkOffset).clamp(
      minExtent,
      maxExtent,
    );

    return ClipRect(
      child: Container(
        height: currentHeight,
        decoration: BoxDecoration(
          color: shrinkOffset > 0
              ? ArjunaColors.appBarSurface(isDark)
              : Colors.transparent,
          border: progress > 0.5
              ? Border(
                  bottom: BorderSide(
                    color: isDark
                        ? ArjunaColors.gold.withValues(alpha: 0.1)
                        : ArjunaColors.navy.withValues(alpha: 0.05),
                  ),
                )
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
          // Expanded Header
          if (progress < 0.67)
            Opacity(
              opacity: expandedOpacity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commodity.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ArjunaColors.title(isDark),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(commodity.currentPrice),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: ArjunaColors.title(isDark),
                                  ),
                            ),
                            Text(
                              'Per ${commodity.unit}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : ArjunaColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                // Prevent text scaling issues
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: trendColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    currentChange > 0
                                        ? Icons.trending_up
                                        : (currentChange < 0
                                              ? Icons.trending_down
                                              : Icons.trending_flat),
                                    color: trendColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${currentChange.abs().toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: trendColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Hero(
                      tag: heroTag,
                      child: Image.asset(
                        commodity.imageAsset,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Collapsed Header (Sticky)
          if (progress > 0.33)
            Opacity(
              opacity: collapsedOpacity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset(
                      commodity.imageAsset,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commodity.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Per ${commodity.unit}',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : ArjunaColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(commodity.currentPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: ArjunaColors.title(isDark),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              currentChange > 0
                                  ? Icons.trending_up
                                  : (currentChange < 0
                                        ? Icons.trending_down
                                        : Icons.trending_flat),
                              color: trendColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${currentChange.abs().toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: trendColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

  @override
  double get maxExtent => 160;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant StickyPriceHeader oldDelegate) {
    return oldDelegate.commodity != commodity ||
        oldDelegate.currentChange != currentChange ||
        oldDelegate.trendColor != trendColor;
  }
}
