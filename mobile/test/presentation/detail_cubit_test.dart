import 'package:flutter_test/flutter_test.dart';
import 'package:komoditas_ai/features/detail/presentation/cubit/detail_cubit.dart';
import 'package:komoditas_ai/features/detail/presentation/cubit/detail_state.dart';
import 'package:komoditas_ai/shared/data/commodity_repository.dart';
import 'package:komoditas_ai/shared/domain/models.dart';

class FakeCommodityRepository implements ICommodityRepository {
  bool failLiveInsight = false;

  @override
  Future<List<Commodity>> getCommodities() async => [];

  @override
  Future<AppMetadata> getMetadata() async {
    return AppMetadata(
      updatedAt: '',
      globalAnalysis: '',
      disclaimer: '',
      aboutUs: {},
    );
  }

  @override
  Future<List<PricePoint>> getHistoricalData(String subcategory) async {
    return [
      PricePoint(date: '2026-06-01', price: 10000),
      PricePoint(date: '2026-06-02', price: 10500),
    ];
  }

  @override
  Future<Map<String, dynamic>> getPredictionData(String subcategory) async {
    return {
      'trend': 1.5,
      'horizon': 7,
      'last_historical_price': 10500,
      'predicted_price': 11000,
      'model_used': 'sarimax',
      'last_historical_date': '2026-06-02',
      'predictions': [
        {'date': '2026-06-03', 'predicted_price': 11000}
      ]
    };
  }

  @override
  Future<Insight> getLiveInsight(
    String subcategory,
    double trend,
    int horizon,
    double currentPrice,
    double predictedPrice,
  ) async {
    if (failLiveInsight) {
      throw Exception("Simulated connection error");
    }
    return Insight(
      masyarakat: "Tips masyarakat tiruan",
      pedagang: "Tips pedagang tiruan",
      disclaimer: "Aman",
    );
  }

  @override
  Future<List<AuditPoint>> getAuditData(String subcategory) async => [];

  @override
  Future<String> getGlobalAnalysis() async => 'Analisis tiruan';
}

void main() {
  late FakeCommodityRepository repository;
  late DetailCubit cubit;

  setUp(() {
    repository = FakeCommodityRepository();
    cubit = DetailCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('DetailCubit Tests', () {
    test('initial state should be DetailInitial', () {
      expect(cubit.state, isA<DetailInitial>());
    });

    test('should emit DetailLoading and then DetailLoaded with Insight successfully', () async {
      final states = <DetailState>[];
      cubit.stream.listen((s) {
        states.add(s);
      });

      await cubit.fetchDetailData('beras');
      await Future.delayed(Duration.zero);

      // Verifikasi transisi state:
      // 1. DetailLoading
      // 2. DetailLoaded (isInsightLoading: true)
      // 3. DetailLoaded (isInsightLoading: false, liveInsight filled)
      expect(states.length, 3);
      expect(states[0], isA<DetailLoading>());
      
      expect(states[1], isA<DetailLoaded>());
      expect((states[1] as DetailLoaded).isInsightLoading, true);

      expect(states[2], isA<DetailLoaded>());
      final finalState = states[2] as DetailLoaded;
      expect(finalState.isInsightLoading, false);
      expect(finalState.liveInsight?.masyarakat, 'Tips masyarakat tiruan');
      expect(finalState.lastPrice, 10500.0);
      expect(finalState.predictedPrice, 11000.0);
    });

    test('should emit DetailLoaded with error insight description if getLiveInsight fails', () async {
      repository.failLiveInsight = true;
      final states = <DetailState>[];
      cubit.stream.listen((s) {
        states.add(s);
      });

      await cubit.fetchDetailData('beras');
      await Future.delayed(Duration.zero);

      expect(states.length, 3);
      expect(states[0], isA<DetailLoading>());

      expect(states[1], isA<DetailLoaded>());
      expect((states[1] as DetailLoaded).isInsightLoading, true);

      expect(states[2], isA<DetailLoaded>());
      final finalState = states[2] as DetailLoaded;
      expect(finalState.isInsightLoading, false);
      expect(finalState.history.length, 2);
      expect(finalState.liveInsight?.masyarakat, contains('Gagal memuat'));
    });

    test('refreshLiveInsight should refresh insight specifically without loading entire page', () async {
      // Setup initial state as loaded but failed
      repository.failLiveInsight = true;
      await cubit.fetchDetailData('beras');
      await Future.delayed(Duration.zero);
      
      final loadedState = cubit.state as DetailLoaded;
      expect(loadedState.liveInsight?.masyarakat, contains('Gagal memuat'));

      // Setup success for refresh
      repository.failLiveInsight = false;

      final states = <DetailState>[];
      cubit.stream.listen((s) {
        states.add(s);
      });

      await cubit.refreshLiveInsight('beras');
      await Future.delayed(Duration.zero);

      // Harus ada state loading parsial dan disusul state sukses
      expect(states.length, 2);
      
      // State pertama: isInsightLoading = true & liveInsight di-clear (null)
      final loadingPartial = states[0] as DetailLoaded;
      expect(loadingPartial.isInsightLoading, true);
      expect(loadingPartial.liveInsight, isNull);

      // State kedua: isInsightLoading = false & liveInsight terisi sukses
      final loadedSuccess = states[1] as DetailLoaded;
      expect(loadedSuccess.isInsightLoading, false);
      expect(loadedSuccess.liveInsight?.masyarakat, 'Tips masyarakat tiruan');
    });
  });
}
