import 'package:flutter/material.dart';
import '../../../../shared/domain/models.dart';
import '../../../../shared/widgets/arjuna_brand.dart';

class GlobalAnalysisCard extends StatelessWidget {
  final String analysis;
  final String disclaimer;
  final bool isSeller;
  final List<Commodity> commodities;
  final bool isLoading;

  const GlobalAnalysisCard({
    super.key,
    required this.analysis,
    required this.disclaimer,
    required this.isSeller,
    required this.commodities,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = ArjunaColors.accent(isDark);
    final mood = _marketMood();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF072135) : const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.22 : 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ArjunaColors.navy.withValues(alpha: isDark ? 0.24 : 0.09),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -30,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: isDark ? 0.08 : 0.10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sorotan Pasar dari Arjuna',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 22,
                                    height: 1.15,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isSeller
                                  ? 'Pantau momentum harga untuk strategi stok dan margin.'
                                  : 'Pahami sinyal harga sebelum menentukan waktu belanja.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.68)
                                    : ArjunaColors.navy.withValues(alpha: 0.66),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 96,
                        height: 118,
                        child: Image.asset(
                          mood.asset,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.045)
                          : Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: accentColor.withValues(
                          alpha: isDark ? 0.10 : 0.08,
                        ),
                      ),
                    ),
                    child: isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            analysis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              height: 1.65,
                              letterSpacing: 0.1,
                            ),
                          ),
                  ),
                  if (disclaimer.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Divider(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: isDark ? Colors.white30 : Colors.black26,
                          size: 13,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            disclaimer,
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _MascotMood _marketMood() {
    if (commodities.isEmpty) {
      return const _MascotMood(
        asset: ArjunaAssets.mascotThinking,
        label: 'Menyusun insight',
      );
    }

    var rising = 0;
    var falling = 0;
    var stable = 0;

    for (final commodity in commodities) {
      final change = commodity.priceChanges['day_1'] ?? 0;
      if (change.abs() < 0.25) {
        stable++;
      } else if (change > 0) {
        rising++;
      } else {
        falling++;
      }
    }

    final favorable = isSeller ? rising : falling;
    final unfavorable = isSeller ? falling : rising;
    final total = commodities.length;

    if (unfavorable >= (total * 0.45).ceil()) {
      return _MascotMood(
        asset: ArjunaAssets.mascotAlert,
        label: isSeller ? 'Tekanan turun' : 'Waspada naik',
      );
    }

    if (unfavorable > favorable && unfavorable > stable) {
      return const _MascotMood(
        asset: ArjunaAssets.mascotWorried,
        label: 'Perlu dicermati',
      );
    }

    if (favorable >= (total * 0.45).ceil()) {
      return _MascotMood(
        asset: ArjunaAssets.mascotCelebrate,
        label: isSeller ? 'Peluang margin' : 'Belanja nyaman',
      );
    }

    if (stable >= rising && stable >= falling) {
      return const _MascotMood(
        asset: ArjunaAssets.mascotThinking,
        label: 'Pasar stabil',
      );
    }

    return const _MascotMood(
      asset: ArjunaAssets.mascotThinking,
      label: 'Analisis AI',
    );
  }
}

class _MascotMood {
  final String asset;
  final String label;

  const _MascotMood({required this.asset, required this.label});
}
