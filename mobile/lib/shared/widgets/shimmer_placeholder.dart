import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCardPlaceholder extends StatelessWidget {
  final double height;

  const ShimmerCardPlaceholder({super.key, this.height = 120});

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
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class CommodityCardShimmer extends StatelessWidget {
  const CommodityCardShimmer({super.key});

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
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBlock(width: 132, height: 15, radius: 5),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      _ShimmerBlock(width: 58, height: 22, radius: 999),
                      SizedBox(width: 8),
                      Expanded(child: _ShimmerBlock(height: 11, radius: 4)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _ShimmerBlock(width: 88, height: 15, radius: 5),
                SizedBox(height: 8),
                _ShimmerBlock(width: 44, height: 11, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerListPlaceholder extends StatelessWidget {
  final int itemCount;

  const ShimmerListPlaceholder({super.key, this.itemCount = 3});

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
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerGridPlaceholder extends StatelessWidget {
  final int itemCount;

  const ShimmerGridPlaceholder({super.key, this.itemCount = 4});

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
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class ShimmerInsightPlaceholder extends StatelessWidget {
  const ShimmerInsightPlaceholder({super.key});

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightContentShimmer extends StatelessWidget {
  const InsightContentShimmer({super.key});

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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                    child: Row(
                      children: const [
                        _ShimmerBlock(width: 32, height: 32, radius: 10),
                        SizedBox(width: 12),
                        _ShimmerBlock(width: 178, height: 18, radius: 6),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBlock(
                          width: double.infinity,
                          height: 14,
                          radius: 5,
                        ),
                        SizedBox(height: 10),
                        _ShimmerBlock(
                          width: double.infinity,
                          height: 14,
                          radius: 5,
                        ),
                        SizedBox(height: 10),
                        _ShimmerBlock(width: 250, height: 14, radius: 5),
                        SizedBox(height: 18),
                        Divider(height: 1),
                        SizedBox(height: 12),
                        _ShimmerBlock(
                          width: double.infinity,
                          height: 12,
                          radius: 4,
                        ),
                        SizedBox(height: 8),
                        _ShimmerBlock(width: 210, height: 12, radius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: const [
                Expanded(child: _StatCardShimmer()),
                SizedBox(width: 10),
                Expanded(child: _StatCardShimmer()),
                SizedBox(width: 10),
                Expanded(child: _StatCardShimmer()),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class SettingsAboutShimmer extends StatelessWidget {
  const SettingsAboutShimmer({super.key});

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
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                _ShimmerBlock(width: 58, height: 58, radius: 18),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBlock(width: 150, height: 20, radius: 6),
                      SizedBox(height: 8),
                      _ShimmerBlock(width: 82, height: 12, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _ShimmerBlock(width: double.infinity, height: 14, radius: 5),
            const SizedBox(height: 8),
            const _ShimmerBlock(width: 240, height: 14, radius: 5),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const _InfoRowShimmer(),
            const _InfoRowShimmer(),
            const _InfoRowShimmer(),
          ],
        ),
      ),
    );
  }
}

class NewsCardShimmer extends StatelessWidget {
  const NewsCardShimmer({super.key});

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
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ShimmerBlock(width: double.infinity, height: 96, radius: 16),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _ShimmerBlock(height: 10, radius: 4)),
                      SizedBox(width: 20),
                      _ShimmerBlock(width: 34, height: 9, radius: 4),
                    ],
                  ),
                  SizedBox(height: 10),
                  _ShimmerBlock(width: double.infinity, height: 12, radius: 5),
                  SizedBox(height: 7),
                  _ShimmerBlock(width: double.infinity, height: 12, radius: 5),
                  SizedBox(height: 7),
                  _ShimmerBlock(width: 126, height: 12, radius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailShimmerPlaceholder extends StatelessWidget {
  final bool includePriceHeader;
  final EdgeInsetsGeometry padding;

  const DetailShimmerPlaceholder({
    super.key,
    this.includePriceHeader = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  });

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
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (includePriceHeader) ...[
              const SizedBox(height: 16),
              // Price Header Shimmer
              const _ShimmerBlock(height: 24, width: 160, radius: 6),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBlock(height: 34, width: 190, radius: 8),
                        SizedBox(height: 10),
                        _ShimmerBlock(height: 13, width: 72, radius: 5),
                        SizedBox(height: 10),
                        _ShimmerBlock(height: 24, width: 76, radius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
            // Chart Section Shimmer
            const _ChartSectionShimmer(),
            const SizedBox(height: 28),
            // Sub-commodities Header Shimmer
            Container(
              height: 22,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 16),
            // Sub-commodities Carousel Shimmer
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSectionShimmer extends StatelessWidget {
  const _ChartSectionShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              _ShimmerBlock(width: 116, height: 20, radius: 6),
              Spacer(),
              _ShimmerBlock(width: 132, height: 46, radius: 12),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    _ShimmerBlock(width: 112, height: 32, radius: 10),
                    SizedBox(width: 8),
                    _ShimmerBlock(width: 96, height: 32, radius: 10),
                  ],
                ),
                SizedBox(height: 10),
                _ShimmerBlock(width: double.infinity, height: 12, radius: 4),
                SizedBox(height: 8),
                _ShimmerBlock(width: 220, height: 12, radius: 4),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: _ShimmerBlock(width: 210, height: 14, radius: 6)),
          const SizedBox(height: 12),
          Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBlock({this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _StatCardShimmer extends StatelessWidget {
  const _StatCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          _ShimmerBlock(width: 38, height: 38, radius: 19),
          SizedBox(height: 8),
          _ShimmerBlock(width: 34, height: 30, radius: 8),
          SizedBox(height: 6),
          _ShimmerBlock(width: 64, height: 12, radius: 4),
        ],
      ),
    );
  }
}

class _InfoRowShimmer extends StatelessWidget {
  const _InfoRowShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ShimmerBlock(width: 92, height: 13, radius: 4),
          _ShimmerBlock(width: 128, height: 13, radius: 4),
        ],
      ),
    );
  }
}

class _SectionHeaderShimmer extends StatelessWidget {
  final double width;

  const _SectionHeaderShimmer({required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ShimmerBlock(width: 18, height: 18, radius: 6),
        const SizedBox(width: 8),
        _ShimmerBlock(width: width, height: 18, radius: 5),
      ],
    );
  }
}

class _SubHeaderShimmer extends StatelessWidget {
  final double width;

  const _SubHeaderShimmer({required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ShimmerBlock(width: 18, height: 18, radius: 6),
        const SizedBox(width: 7),
        _ShimmerBlock(width: width, height: 12, radius: 4),
      ],
    );
  }
}

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF0B2637)
        : const Color(0xFFE6EEEB);
    final highlightColor = isDark
        ? const Color(0xFF12384C)
        : const Color(0xFFF7FAF8);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Part (Greeting & Hero Card)
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 8,
              20,
              0,
            ),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header greeting shimmer
                  Container(
                    width: 154,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    width: 260,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 220,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 170,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Market Pulse Shimmer
                  Container(
                    height: 146,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bottom content panel shimmer
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF061525).withValues(alpha: 0.98)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Akses Cepat Shimmer
                  const _SectionHeaderShimmer(width: 112),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.52,
                        ),
                    itemCount: 4,
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Top Movers Shimmer
                  const _SectionHeaderShimmer(width: 180),
                  const SizedBox(height: 12),
                  // Gainers List Shimmer
                  const _SubHeaderShimmer(width: 120),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 108,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) => Container(
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Losers List Shimmer
                  const _SubHeaderShimmer(width: 120),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 108,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) => Container(
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // News Shimmer
                  Row(
                    children: const [
                      _SectionHeaderShimmer(width: 126),
                      Spacer(),
                      _ShimmerBlock(width: 54, height: 22, radius: 6),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) => const NewsCardShimmer(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuditShimmerPlaceholder extends StatelessWidget {
  const AuditShimmerPlaceholder({super.key});

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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Accuracy Summary Card Shimmer
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Evaluation Chart Card Shimmer
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Model Explanation Card Shimmer
            Container(
              height: 142,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Section Title Shimmer
            Container(
              width: 220,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),

            // 5. Log Audit List / Table Rows Shimmer
            Column(
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  height: 64,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
