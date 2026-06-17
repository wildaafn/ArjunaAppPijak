import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers.dart';
import '../../../../shared/domain/models.dart';
import '../../../../shared/widgets/arjuna_brand.dart';
import '../../../../shared/widgets/bouncy_tappable.dart';

class CommodityCard extends ConsumerWidget {
  final Commodity commodity;
  final VoidCallback onTap;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  const CommodityCard({
    super.key,
    required this.commodity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayChange = commodity.priceChanges['day_1'] ?? 0;
    final trendColor = ref
        .read(settingsProvider.notifier)
        .getTrendColor(dayChange);

    return Semantics(
      button: true,
      label:
          '${commodity.name}, harga ${_currencyFormat.format(commodity.currentPrice)} per ${commodity.unit}, perubahan ${dayChange.toStringAsFixed(2)} persen',
      child: BouncyTappable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF071F31).withValues(alpha: 0.96)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? ArjunaColors.gold.withValues(alpha: 0.1)
                  : ArjunaColors.navy.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: ArjunaColors.navy.withValues(
                  alpha: isDark ? 0.16 : 0.05,
                ),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Hero(
                  tag: 'list-${commodity.name}',
                  child: Container(
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(
                        alpha: isDark ? 0.12 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      commodity.imageAsset,
 
                      fit: BoxFit.contain,
                      errorBuilder: (_, e, st) => Icon(
                        Icons.eco_rounded,
                        color: trendColor,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commodity.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ArjunaColors.title(isDark),
                          ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _TrendPill(change: dayChange, color: trendColor),
                        if (commodity.trend.isNotEmpty) ...[
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              commodity.trend,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.46)
                                    : ArjunaColors.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currencyFormat.format(commodity.currentPrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: ArjunaColors.title(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'per ${commodity.unit}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : ArjunaColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final double change;
  final Color color;

  const _TrendPill({required this.change, required this.color});

  @override
  Widget build(BuildContext context) {
    final icon = change > 0
        ? Icons.arrow_upward_rounded
        : (change < 0
              ? Icons.arrow_downward_rounded
              : Icons.trending_flat_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            '${change.abs().toStringAsFixed(2)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
