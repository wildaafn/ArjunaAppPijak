import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/domain/models.dart';
import '../../../../core/providers.dart';
import '../../../detail/presentation/screens/detail_screen.dart';
import '../../../../shared/widgets/bouncy_tappable.dart';

class TopMoversSection extends ConsumerWidget {
  final List<Commodity> commodities;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  const TopMoversSection({super.key, required this.commodities});

  List<Commodity> _sortedByDailyChange() {
    return [...commodities]..sort(
      (a, b) => (b.priceChanges['day_1'] ?? 0).compareTo(
        a.priceChanges['day_1'] ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch settings to rebuild on mode change
    ref.watch(settingsProvider);
    final gainerColor = ref.read(settingsProvider.notifier).getTrendColor(1.0);
    final loserColor = ref.read(settingsProvider.notifier).getTrendColor(-1.0);

    final sorted = _sortedByDailyChange();

    final topGainers = sorted
        .where((c) => (c.priceChanges['day_1'] ?? 0) > 0)
        .take(4)
        .toList();
    final topLosers = sorted.reversed
        .where((c) => (c.priceChanges['day_1'] ?? 0) < 0)
        .take(4)
        .toList();

    if (topGainers.isEmpty && topLosers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _SectionTitle(
          icon: Icons.local_fire_department_rounded,
          label: 'Top Movers Hari Ini',
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Gainers
        if (topGainers.isNotEmpty) ...[
          _SubLabel(
            icon: Icons.arrow_upward_rounded,
            label: 'Kenaikan Terbesar',
            color: gainerColor,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topGainers.length,
              separatorBuilder: (_, i) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _MoverCard(
                commodity: topGainers[i],
                isDark: isDark,
                currencyFormat: _currencyFormat,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      commodity: topGainers[i],
                      heroTag: 'mover-${topGainers[i].name}',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        // Losers
        if (topLosers.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SubLabel(
            icon: Icons.arrow_downward_rounded,
            label: 'Penurunan Terbesar',
            color: loserColor,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topLosers.length,
              separatorBuilder: (_, i) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _MoverCard(
                commodity: topLosers[i],
                isDark: isDark,
                currencyFormat: _currencyFormat,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      commodity: topLosers[i],
                      heroTag: 'mover-${topLosers[i].name}',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? const Color(0xFFE8C766) : const Color(0xFF07345A),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF07345A),
          ),
        ),
      ],
    );
  }
}

class _SubLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _SubLabel({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white60 : const Color(0xFF6A7D85),
          ),
        ),
      ],
    );
  }
}

class _MoverCard extends ConsumerWidget {
  final Commodity commodity;
  final bool isDark;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const _MoverCard({
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

    return BouncyTappable(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A2638) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: trendColor.withValues(alpha: isDark ? 0.12 : 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF07345A,
              ).withValues(alpha: isDark ? 0.16 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + change badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'mover-${commodity.name}',
                  child: Image.asset(
                    commodity.imageAsset,
                    width: 42,
                    height: 42,
                    fit: BoxFit.contain,
                    errorBuilder: (_, e, st) =>
                        Icon(Icons.eco_rounded, color: trendColor, size: 28),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 10,
                        color: trendColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${dayChange.abs().toStringAsFixed(1)}%',
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
 
            const Spacer(),
 
            // Name
            Text(
              commodity.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F0F0F),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
 
            // Price
            Text(
              currencyFormat.format(commodity.currentPrice),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF07345A).withValues(alpha: 0.65),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
