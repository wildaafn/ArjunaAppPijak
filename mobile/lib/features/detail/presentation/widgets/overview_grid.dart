import 'package:flutter/material.dart';
import '../../../../shared/domain/models.dart';

class CommodityOverviewGrid extends StatelessWidget {
  final Commodity commodity;
  final Color themeColor;

  const CommodityOverviewGrid({
    super.key,
    required this.commodity,
    required this.themeColor,
  });

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isForecastUp = commodity.forecastPct > 0;
    final isForecastDown = commodity.forecastPct < 0;
    final Color forecastColor = isForecastUp
        ? const Color(0xFF10B981) // emerald
        : (isForecastDown ? const Color(0xFFEF4444) : Colors.amber);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildOverviewItem(
          context,
          'Tren Pasar',
          _capitalize(commodity.trend),
          Icons.show_chart,
          themeColor,
        ),
        _buildOverviewItem(
          context,
          'Prediksi AI',
          '${commodity.forecastPct > 0 ? "+" : ""}${commodity.forecastPct.toStringAsFixed(1)}%',
          Icons.auto_awesome_outlined,
          forecastColor,
        ),
      ],
    );
  }

  Widget _buildOverviewItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
