import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/arjuna_brand.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../../../core/providers.dart';
import '../widgets/insight_content.dart';

class InsightScreen extends ConsumerWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commoditiesAsync = ref.watch(commoditiesProvider);
    final metadataAsync = ref.watch(metadataProvider);
    ref.watch(settingsProvider);

    const loadingPlaceholder = InsightContentShimmer();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Insight Pasar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const ArjunaAppBarBackground(),
      ),
      body: metadataAsync.when(
        data: (metadata) {
          return commoditiesAsync.when(
            data: (commodities) => InsightContent(
              commodities: commodities,
              metadata: metadata,
              onRefresh: () async {
                ref.refresh(commoditiesProvider);
                ref.refresh(metadataProvider);
                ref.refresh(globalAnalysisProvider);
              },
            ),
            loading: () => loadingPlaceholder,
            error: (e, s) => AppErrorWidget(
              title: 'Gagal Memuat Data',
              message: e.toString(),
              onRetry: () {
                ref.refresh(commoditiesProvider);
                ref.refresh(metadataProvider);
                ref.refresh(globalAnalysisProvider);
              },
            ),
          );
        },
        loading: () => loadingPlaceholder,
        error: (e, s) => AppErrorWidget(
          title: 'Gagal Memuat Data',
          message: e.toString(),
          onRetry: () {
            ref.refresh(commoditiesProvider);
            ref.refresh(metadataProvider);
            ref.refresh(globalAnalysisProvider);
          },
        ),
      ),
    );
  }
}
