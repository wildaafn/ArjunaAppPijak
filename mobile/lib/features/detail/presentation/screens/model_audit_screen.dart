import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/arjuna_brand.dart';
import '../../../../shared/domain/models.dart';
import '../../../../core/providers.dart';
import '../cubit/audit_cubit.dart';
import '../cubit/audit_state.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';

class ModelAuditScreen extends ConsumerStatefulWidget {
  final String subcategory;
  final Color themeColor;

  const ModelAuditScreen({
    super.key,
    required this.subcategory,
    required this.themeColor,
  });

  @override
  ConsumerState<ModelAuditScreen> createState() => _ModelAuditScreenState();
}

class _ModelAuditScreenState extends ConsumerState<ModelAuditScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repository = ref.read(commodityRepositoryProvider);

    return BlocProvider(
      create: (context) =>
          AuditCubit(repository)..fetchAuditData(widget.subcategory),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Audit Akurasi AI'),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: ArjunaColors.appBarSurface(isDark),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: const ArjunaAppBarBackground(),
          ),
          body: BlocBuilder<AuditCubit, AuditState>(
            builder: (context, state) {
              if (state is AuditLoading || state is AuditInitial) {
                return const AuditShimmerPlaceholder();
              } else if (state is AuditError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuditCubit>().fetchAuditData(
                              widget.subcategory,
                            );
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is AuditLoaded) {
                final points = state.auditPoints;
                final accuracy = state.averageAccuracy;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card: Rata-rata Akurasi
                      _buildAccuracySummaryCard(context, accuracy, isDark),
                      const SizedBox(height: 20),

                      // Chart Card: Harga Aktual vs Estimasi AI
                      if (points.isNotEmpty) ...[
                        _buildEvaluationChartCard(context, points, isDark),
                        const SizedBox(height: 20),
                      ],

                      // Model Explanation Card
                      _buildModelExplanationCard(context, isDark),
                      const SizedBox(height: 24),

                      // Daily Log Title
                      Text(
                        'Tabel Log Audit (30 Hari Terakhir)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Daily Log Table/List
                      if (points.isEmpty)
                        const Center(
                          child: Text('Tidak ada data audit harian.'),
                        )
                      else ...[
                        _buildAuditLogList(context, points, isDark),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            icon: Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: widget.themeColor,
                            ),
                            label: Text(
                              _isExpanded
                                  ? 'Tampilkan Lebih Sedikit'
                                  : 'Lihat Seluruh Log (30 Hari)',
                              style: TextStyle(
                                color: widget.themeColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracySummaryCard(
    BuildContext context,
    double accuracy,
    bool isDark,
  ) {
    String rating;
    Color ratingColor;
    if (accuracy >= 98.0) {
      rating = 'Sangat Tinggi';
      ratingColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    } else if (accuracy >= 95.0) {
      rating = 'Tinggi';
      ratingColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    } else if (accuracy >= 90.0) {
      rating = 'Cukup';
      ratingColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    } else {
      rating = 'Rendah';
      ratingColor = Colors.red;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kredibilitas Model AI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ratingColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ratingColor,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Akurasi Rata-rata',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${accuracy.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? ArjunaColors.gold : ArjunaColors.navy,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Akurasi dihitung secara dinamis dari tingkat deviasi (MAPE) antara harga pasar aktual dan prediksi mundur (backtesting) model SARIMAX.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationChartCard(
    BuildContext context,
    List<AuditPoint> points,
    bool isDark,
  ) {
    final allActuals = points.map((e) => e.actualPrice).toList();
    final allFitteds = points.map((e) => e.fittedPrice).toList();
    final minPrice = [
      ...allActuals,
      ...allFitteds,
    ].reduce((a, b) => a < b ? a : b);
    final maxPrice = [
      ...allActuals,
      ...allFitteds,
    ].reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    final double padding = priceRange > 0 ? priceRange * 0.15 : 1000.0;
    final double minY = (minPrice - padding).clamp(0.0, double.infinity);
    final double maxY = maxPrice + padding;
    final double yInterval = (maxY - minY) / 4;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Perbandingan Evaluasi',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    tooltipRoundedRadius: 12,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final isActual = barSpot.barIndex == 0;
                        final label = isActual ? 'Aktual' : 'Estimasi AI';
                        final formattedVal = NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(barSpot.y);

                        return LineTooltipItem(
                          '$label: $formattedVal',
                          TextStyle(
                            color: isActual
                                ? widget.themeColor
                                : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Outfit',
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) {
                          return const SizedBox.shrink();
                        }
                        String text;
                        if (value >= 1000000) {
                          text = '${(value / 1000000).toStringAsFixed(1)}jt';
                        } else if (value >= 1000) {
                          final isDecimalNeeded = (yInterval % 1000) != 0;
                          if (isDecimalNeeded) {
                            text = NumberFormat('#,###', 'id_ID').format(value);
                          } else {
                            text = '${(value / 1000).toStringAsFixed(0)}rb';
                          }
                        } else {
                          text = value.toStringAsFixed(0);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey[isDark ? 500 : 400],
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Outfit',
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: points.length > 10 ? 7 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        if (points.length > 10) {
                          final isMultipleOf7 = index % 7 == 0;
                          final isLastItem = index == points.length - 1;
                          final distanceToLastMultipleOf7 =
                              (points.length - 1) % 7;
                          if (!isMultipleOf7) {
                            if (!isLastItem || distanceToLastMultipleOf7 < 3) {
                              return const SizedBox.shrink();
                            }
                          }
                        }
                        final date = DateTime.parse(points[index].date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: TextStyle(
                              color: Colors.grey[isDark ? 500 : 400],
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  // Actual Price (Solid line) - Index 0
                  LineChartBarData(
                    spots: points
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(e.key.toDouble(), e.value.actualPrice),
                        )
                        .toList(),
                    isCurved: true,
                    color: widget.themeColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  // Fitted Price (Dashed line) - Index 1
                  LineChartBarData(
                    spots: points
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(e.key.toDouble(), e.value.fittedPrice),
                        )
                        .toList(),
                    isCurved: true,
                    dashArray: [5, 5],
                    color: isDark ? Colors.white54 : Colors.black38,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                context,
                'Harga Aktual',
                widget.themeColor,
                isDashed: false,
              ),
              const SizedBox(width: 24),
              _buildLegendItem(
                context,
                'Estimasi Model AI',
                isDark ? Colors.white54 : Colors.black38,
                isDashed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color, {
    required bool isDashed,
  }) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isDashed
              ? Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        color: color,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white60
                : Colors.black54,
            fontWeight: FontWeight.w500,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildModelExplanationCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                size: 20,
                color: isDark ? ArjunaColors.gold : ArjunaColors.tealDark,
              ),
              const SizedBox(width: 8),
              Text(
                'Bagaimana Model Bekerja?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sistem peramalan Arjuna menggunakan algoritma SARIMAX (Seasonal Autoregressive Integrated Moving Average dengan variabel eksogen kalender). Model mengevaluasi riwayat tren musiman harian dan mendeteksi dampak hari libur atau akhir pekan terhadap fluktuasi harga.\n\nUntuk menjaga keakuratan tinggi, model secara berkala melakukan retraining otomatis (pelatihan ulang) setiap Senin pukul 12.00 WIB menggunakan data real-time terbaru.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black54,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogList(
    BuildContext context,
    List<AuditPoint> points,
    bool isDark,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Show in reverse chronological order (newest first)
    final reversedPoints = points.reversed.toList();
    final displayPoints = _isExpanded
        ? reversedPoints
        : reversedPoints.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayPoints.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pt = displayPoints[index];
        final devPct = pt.residualPct.abs();

        Color badgeBgColor;
        Color badgeTextColor;
        String desc;

        if (devPct < 2.0) {
          badgeBgColor = Colors.green.withValues(alpha: 0.1);
          badgeTextColor = isDark ? Colors.green[300]! : Colors.green[700]!;
          desc = 'Sangat Akurat';
        } else if (devPct <= 5.0) {
          badgeBgColor = Colors.blue.withValues(alpha: 0.1);
          badgeTextColor = isDark ? Colors.blue[300]! : Colors.blue[700]!;
          desc = 'Akurat';
        } else {
          badgeBgColor = Colors.amber.withValues(alpha: 0.1);
          badgeTextColor = isDark ? Colors.amber[300]! : Colors.amber[700]!;
          desc = 'Deviasi Sedikit';
        }

        String formattedDate;
        try {
          final parsedDate = DateTime.parse(pt.date);
          formattedDate = DateFormat('dd MMM yyyy', 'id_ID').format(parsedDate);
        } catch (_) {
          formattedDate = pt.date;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Riil: ${currencyFormat.format(pt.actualPrice)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Estimasi: ${currencyFormat.format(pt.fittedPrice)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${pt.residualPct >= 0 ? '+' : ''}${pt.residualPct.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
