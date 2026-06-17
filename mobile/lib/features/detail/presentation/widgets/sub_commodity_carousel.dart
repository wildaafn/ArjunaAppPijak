import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/domain/models.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/bouncy_tappable.dart';
import '../screens/detail_screen.dart';

class SubCommodityCarousel extends ConsumerWidget {
  final List<SubCommodity> subCommodities;
  final NumberFormat currencyFormat;
  final String parentUnit;

  const SubCommodityCarousel({
    super.key,
    required this.subCommodities,
    required this.currencyFormat,
    required this.parentUnit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subCommodities.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final sub = subCommodities[index];
          return _buildSubCommodityItem(context, ref, sub, currencyFormat);
        },
      ),
    );
  }

  Widget _buildSubCommodityItem(
    BuildContext context,
    WidgetRef ref,
    SubCommodity sub,
    NumberFormat format,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trendColor =
        ref.read(settingsProvider.notifier).getTrendColor(sub.changePct);

    return BouncyTappable(
      onTap: () {
        final virtualCommodity = Commodity(
          name: sub.name,
          currentPrice: sub.price,
          unit: parentUnit,
          priceChanges: {
            'day_1': sub.changePct,
            'day_7': sub.changePct,
            'day_30': sub.changePct,
          },
          forecastPct: 0.0,
          trend: sub.trend,
          reliability: 'Tinggi',
          marketAlert: 'Menganalisis harga sub-komoditas.',
          imageAsset: sub.imageAsset,
          insight: Insight(masyarakat: '', pedagang: '', disclaimer: ''),
          chart: ChartData(history: [], forecast: []),
          subCommodities: [], // Sub-commodities don't have further sub-commodities
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(commodity: virtualCommodity),
          ),
        );
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.asset(
                    sub.imageAsset,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.shopping_basket_outlined,
                      size: 20,
                      color: trendColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sub.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              format.format(sub.price),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '${sub.changePct > 0 ? "+" : ""}${sub.changePct}%',
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  sub.changePct > 0
                      ? Icons.arrow_upward
                      : (sub.changePct < 0 ? Icons.arrow_downward : Icons.trending_flat),
                  size: 10,
                  color: trendColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
