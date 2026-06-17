import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/models.dart';
import '../../../../core/providers.dart';

class QuickStatsGrid extends ConsumerWidget {
  final List<Commodity> commodities;

  const QuickStatsGrid({super.key, required this.commodities});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final upCount = commodities
        .where((c) => (c.priceChanges['day_1'] ?? 0) > 0)
        .length;
    final downCount = commodities
        .where((c) => (c.priceChanges['day_1'] ?? 0) < 0)
        .length;
    final stableCount = commodities.length - upCount - downCount;

    final upColor = ref.read(settingsProvider.notifier).getTrendColor(1.0);
    final stableColor = ref.read(settingsProvider.notifier).getTrendColor(0.0);
    final downColor = ref.read(settingsProvider.notifier).getTrendColor(-1.0);

    return Row(
      children: [
        _StatCard(
          label: 'Meningkat',
          value: upCount.toString(),
          icon: Icons.trending_up_rounded,
          color: upColor,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Stabil',
          value: stableCount.toString(),
          icon: Icons.trending_flat_rounded,
          color: stableColor,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Menurun',
          value: downCount.toString(),
          icon: Icons.trending_down_rounded,
          color: downColor,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A2638) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.2 : 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.045),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon in a circle container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            // Big number
            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F0F0F),
                height: 1.0,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
