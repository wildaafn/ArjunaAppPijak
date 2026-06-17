import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/models.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/arjuna_brand.dart';

class MarketPulseCard extends ConsumerStatefulWidget {
  final List<Commodity> commodities;

  const MarketPulseCard({super.key, required this.commodities});

  @override
  ConsumerState<MarketPulseCard> createState() => _MarketPulseCardState();
}

class _MarketPulseCardState extends ConsumerState<MarketPulseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _mascotScale;
  late final Animation<Offset> _mascotSlide;
  late final Animation<double> _mascotLift;

  String _getMarketLabel(int upCount, int downCount, int stableCount) {
    final total = upCount + downCount + stableCount;
    if (total == 0) return 'Tidak Ada Data';
    final upRatio = upCount / total;
    final downRatio = downCount / total;
    if (upRatio >= 0.6) return 'Pasar Cenderung Naik';
    if (downRatio >= 0.6) return 'Pasar Cenderung Turun';
    if (stableCount >= upCount && stableCount >= downCount) {
      return 'Pasar Stabil';
    }
    return 'Pasar Bergerak Campuran';
  }

  IconData _getMarketIcon(int upCount, int downCount) {
    if (upCount > downCount) return Icons.trending_up_rounded;
    if (downCount > upCount) return Icons.trending_down_rounded;
    return Icons.trending_flat_rounded;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    _mascotScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.18, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _mascotSlide =
        Tween<Offset>(
          begin: const Offset(0.12, 0.02),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.14, 0.68, curve: Curves.easeOutCubic),
          ),
        );
    _mascotLift = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.82, curve: Curves.easeOutCubic),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final upColor = ref.read(settingsProvider.notifier).getTrendColor(1.0);
    final downColor = ref.read(settingsProvider.notifier).getTrendColor(-1.0);

    final commodities = widget.commodities;
    final upCount = commodities
        .where((c) => (c.priceChanges['day_1'] ?? 0) > 0)
        .length;
    final downCount = commodities
        .where((c) => (c.priceChanges['day_1'] ?? 0) < 0)
        .length;
    final stableCount = commodities.length - upCount - downCount;
    final total = commodities.length;

    final marketLabel = _getMarketLabel(upCount, downCount, stableCount);
    final marketIcon = _getMarketIcon(upCount, downCount);

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF07345A), Color(0xFF05243F)]
                    : const [Color(0xFF07345A), Color(0xFF0B756E)],
              ),
              border: Border.all(
                color: const Color(
                  0xFFE8C766,
                ).withValues(alpha: isDark ? 0.2 : 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF07345A,
                  ).withValues(alpha: isDark ? 0.28 : 0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SignalLinesPainter(
                        color: Colors.white.withValues(alpha: 0.12),
                        gold: const Color(0xFFE8C766).withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -70,
                    top: -10,
                    child: Container(
                      width: 164,
                      height: 164,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: const Color(
                            0xFFE8C766,
                          ).withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 108),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: Icon(
                                  marketIcon,
                                  color: const Color(0xFFE8C766),
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Kondisi Pasar Nasional',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFE8C766,
                                            ).withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFFE8C766,
                                              ).withValues(alpha: 0.18),
                                            ),
                                          ),
                                          child: Text(
                                            marketLabel,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFE8C766),
                                            ),
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

                        const SizedBox(height: 24),

                        if (total > 0) ...[
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              children: [
                                if (upCount > 0)
                                  Flexible(
                                    flex: upCount,
                                    child: Container(color: upColor),
                                  ),
                                if (stableCount > 0)
                                  Flexible(
                                    flex: stableCount,
                                    child: Container(
                                      color: const Color(
                                        0xFFA9B4C0,
                                      ).withValues(alpha: 0.9),
                                    ),
                                  ),
                                if (downCount > 0)
                                  Flexible(
                                    flex: downCount,
                                    child: Container(color: downColor),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          children: [
                            _LegendDot(
                              color: upColor,
                              label: 'Naik',
                              value: upCount,
                            ),
                            _LegendDot(
                              color: const Color(0xFFA9B4C0),
                              label: 'Stabil',
                              value: stableCount,
                            ),
                            _LegendDot(
                              color: downColor,
                              label: 'Turun',
                              value: downCount,
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
          Positioned(
            right: -36,
            top: -56,
            child: _MascotPeek(
              scale: _mascotScale,
              slide: _mascotSlide,
              lift: _mascotLift,
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotPeek extends StatelessWidget {
  final Animation<double> scale;
  final Animation<Offset> slide;
  final Animation<double> lift;

  const _MascotPeek({
    required this.scale,
    required this.slide,
    required this.lift,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scale, slide, lift]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, lift.value),
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
      child: SizedBox(
        width: 224,
        height: 222,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: const Color(0xFFE8C766).withValues(alpha: 0.16),
                ),
              ),
            ),
            Image.asset(
              ArjunaAssets.mascotPresenting,
              width: 156,
              height: 222,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, e, st) => Icon(
                Icons.arrow_outward_rounded,
                size: 54,
                color: const Color(0xFFE8C766).withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalLinesPainter extends CustomPainter {
  final Color color;
  final Color gold;

  const _SignalLinesPainter({required this.color, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final goldPaint = Paint()
      ..color = gold
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = color;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..lineTo(size.width * 0.28, size.height * 0.56)
      ..lineTo(size.width * 0.48, size.height * 0.62)
      ..lineTo(size.width * 0.66, size.height * 0.38)
      ..lineTo(size.width * 0.88, size.height * 0.48);
    canvas.drawPath(path, linePaint);

    final arrow = Path()
      ..moveTo(size.width * 0.08, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.02,
        size.width * 0.92,
        size.height * 0.18,
      );
    canvas.drawPath(arrow, goldPaint);

    for (final point in [
      Offset(size.width * 0.08, size.height * 0.72),
      Offset(size.width * 0.28, size.height * 0.56),
      Offset(size.width * 0.48, size.height * 0.62),
      Offset(size.width * 0.66, size.height * 0.38),
      Offset(size.width * 0.88, size.height * 0.48),
    ]) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}
