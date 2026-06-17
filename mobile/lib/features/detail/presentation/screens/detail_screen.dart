import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../../../shared/domain/models.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/arjuna_brand.dart';
import '../../../../shared/widgets/error_state.dart';
import '../widgets/sticky_price_header.dart';
import '../widgets/chart_section.dart';
import '../widgets/sub_commodity_carousel.dart';
import '../widgets/mascot_floating_insight.dart';
import '../cubit/detail_cubit.dart';
import '../cubit/detail_state.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Commodity commodity;
  final String? heroTag;

  const DetailScreen({super.key, required this.commodity, this.heroTag});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  int _selectedRange = 1; // 1, 7, 30
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  ChartData _getFilteredData(
    List<PricePoint> history,
    List<PricePoint> forecast,
  ) {
    List<PricePoint> filteredHistory;
    if (_selectedRange == 1) {
      filteredHistory = history.length >= 2
          ? history.sublist(history.length - 2)
          : history;
    } else if (_selectedRange == 7) {
      filteredHistory = history.length >= 7
          ? history.sublist(history.length - 7)
          : history;
    } else {
      filteredHistory = history;
    }

    return ChartData(history: filteredHistory, forecast: forecast);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final repository = ref.read(commodityRepositoryProvider);

    final changeKey = _selectedRange == 1
        ? 'day_1'
        : (_selectedRange == 7 ? 'day_7' : 'day_30');
    final currentChange = widget.commodity.priceChanges[changeKey] ?? 0;

    final trendColor = ref
        .read(settingsProvider.notifier)
        .getTrendColor(currentChange);

    return BlocProvider(
      create: (context) =>
          DetailCubit(repository)..fetchDetailData(widget.commodity.name),
      child: BlocBuilder<DetailCubit, DetailState>(
        builder: (context, state) {
          if (state is DetailLoading || state is DetailInitial) {
            return AppBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: Text(
                        'Detail',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      pinned: true,
                      centerTitle: true,
                      backgroundColor: ArjunaColors.appBarSurface(isDark),
                      surfaceTintColor: Colors.transparent,
                      flexibleSpace: const ArjunaAppBarBackground(),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: StickyPriceHeader(
                        commodity: widget.commodity,
                        currencyFormat: _currencyFormat,
                        trendColor: trendColor,
                        currentChange: currentChange,
                        heroTag: widget.heroTag ?? 'commodity-${widget.commodity.name}',
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: DetailShimmerPlaceholder(
                          includePriceHeader: false,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is DetailError) {
            return AppBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text(
                    'Detail',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  backgroundColor: ArjunaColors.appBarSurface(isDark),
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: const ArjunaAppBarBackground(),
                ),
                body: AppErrorWidget(
                  title: 'Gagal Memuat Detail',
                  message: state.message,
                  onRetry: () {
                    BlocProvider.of<DetailCubit>(context)
                        .fetchDetailData(widget.commodity.name);
                  },
                ),
              ),
            );
          } else if (state is DetailLoaded) {
            return AppBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: Text(
                        'Detail',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      pinned: true,
                      centerTitle: true,
                      backgroundColor: ArjunaColors.appBarSurface(isDark),
                      surfaceTintColor: Colors.transparent,
                      flexibleSpace: const ArjunaAppBarBackground(),
                    ),
                     SliverPersistentHeader(
                      pinned: true,
                      delegate: StickyPriceHeader(
                        commodity: widget.commodity,
                        currencyFormat: _currencyFormat,
                        trendColor: trendColor,
                        currentChange: currentChange,
                        heroTag: widget.heroTag ?? 'commodity-${widget.commodity.name}',
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          ChartSection(
                            subcategory: widget.commodity.name,
                            filteredData: _getFilteredData(
                              state.history,
                              state.forecast,
                            ),
                            themeColor: trendColor,
                            reliability: widget.commodity.reliability,
                            modelUsed: state.modelUsed,
                            lastHistoricalDate: state.lastHistoricalDate,
                            horizon: state.horizon,
                            selectedRange: _selectedRange,
                            onRangeSelected: (range) =>
                                setState(() => _selectedRange = range),
                            trend: widget.commodity.trend,
                          ),
                          const SizedBox(height: 32),
                          if (widget.commodity.subCommodities.isNotEmpty) ...[
                            Text(
                              'Sub-Komoditas',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            SubCommodityCarousel(
                              subCommodities: widget.commodity.subCommodities,
                              currencyFormat: _currencyFormat,
                              parentUnit: widget.commodity.unit,
                            ),
                          ],
                          const SizedBox(
                            height: 80,
                          ), // Extra bottom padding for FAB overlap
                        ]),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: MascotFloatingInsight(
                  insight: state.liveInsight,
                  isLoading: state.isInsightLoading,
                  initialPerspective: settings.mode == UserMode.seller ? 1 : 0,
                  onRefresh: () {
                    BlocProvider.of<DetailCubit>(context)
                        .refreshLiveInsight(widget.commodity.name);
                  },
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
