import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/arjuna_brand.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../../../shared/widgets/error_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/top_movers_section.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/news_section.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late ScrollController _scrollController;
  bool _showAppBar = false;
  bool _playEntrance = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _playEntrance = true;
      });
    });
  }

  void _scrollListener() {
    final show = _scrollController.offset > 50;
    if (show != _showAppBar) {
      setState(() {
        _showAppBar = show;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commoditiesAsync = ref.watch(commoditiesProvider);
    final metadataAsync = ref.watch(metadataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: AnimatedOpacity(
          opacity: _showAppBar ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ArjunaLogoMark(size: 30, padding: 2, radius: 10),
              const SizedBox(width: 8),
              const Text(
                'Arjuna',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? const Color(0xFF031827).withValues(alpha: _showAppBar ? 1.0 : 0.0)
            : Colors.white.withValues(alpha: _showAppBar ? 1.0 : 0.0),
        elevation: _showAppBar ? 2 : 0,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
        surfaceTintColor: Colors.transparent,
      ),
      body: commoditiesAsync.when(
        data: (commodities) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(commoditiesProvider);
              ref.refresh(metadataProvider);
              ref.refresh(newsProvider);
            },
            color: Theme.of(context).colorScheme.primary,
            edgeOffset: MediaQuery.of(context).padding.top,
            displacement: MediaQuery.of(context).padding.top + 24,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 8,
                      20,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EntranceReveal(
                          visible: _playEntrance,
                          beginOffset: const Offset(0, 0.05),
                          duration: const Duration(milliseconds: 360),
                          child: metadataAsync.when(
                            data: (meta) =>
                                DashboardHeader(lastUpdatedAt: meta.updatedAt),
                            loading: () => const DashboardHeader(),
                            error: (e, st) => const DashboardHeader(),
                          ),
                        ),

                        const SizedBox(height: 8),
                        _EntranceReveal(
                          visible: _playEntrance,
                          beginOffset: const Offset(0, 0.075),
                          duration: const Duration(milliseconds: 460),
                          curve: Curves.easeOutCubic,
                          child: MarketPulseCard(commodities: commodities),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _EntranceReveal(
                    visible: _playEntrance,
                    beginOffset: const Offset(0, 0.04),
                    duration: const Duration(milliseconds: 560),
                    curve: Curves.easeOutCubic,
                    child: Container(
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
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.18 : 0.035,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (commodities.isNotEmpty) ...[
                            QuickAccessGrid(commodities: commodities),
                            const SizedBox(height: 28),
                          ],
                          if (commodities.isNotEmpty) ...[
                            TopMoversSection(commodities: commodities),
                            const SizedBox(height: 28),
                          ],
                          const NewsSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const DashboardShimmer(),
        error: (error, _) => AppErrorWidget(
          title: 'Gagal Memuat Dashboard',
          message: error.toString(),
          onRetry: () {
            ref.refresh(commoditiesProvider);
            ref.refresh(metadataProvider);
          },
        ),
      ),
    );
  }
}

class _EntranceReveal extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final Curve curve;

  const _EntranceReveal({
    required this.visible,
    required this.child,
    required this.beginOffset,
    required this.duration,
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : beginOffset,
      duration: duration,
      curve: curve,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: curve,
        child: child,
      ),
    );
  }
}
