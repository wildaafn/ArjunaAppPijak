import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/data/commodity_repository.dart';
import '../../../../shared/domain/models.dart';
import 'detail_state.dart';

class DetailCubit extends Cubit<DetailState> {
  final ICommodityRepository _repository;

  DetailCubit(this._repository) : super(DetailInitial());

  @override
  void emit(DetailState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> fetchDetailData(String subcategory) async {
    emit(DetailLoading());
    try {
      // 1. Fetch historical data and prediction data in parallel
      final results = await Future.wait([
        _repository.getHistoricalData(subcategory),
        _repository.getPredictionData(subcategory),
      ]);

      final history = results[0] as List<PricePoint>;
      final predictionData = results[1] as Map<String, dynamic>;

      // Extract prediction parameters
      final double trend = (predictionData['trend'] as num).toDouble();
      final int horizon = (predictionData['horizon'] as num).toInt();
      final double lastPrice = (predictionData['last_historical_price'] as num)
          .toDouble();
      final double predictedPrice = (predictionData['predicted_price'] as num)
          .toDouble();
      final String modelUsed = predictionData['model_used']?.toString() ?? '';
      final String lastHistoricalDate =
          predictionData['last_historical_date']?.toString() ?? '';

      // Extract forecast price points
      final List<dynamic> predsList = predictionData['predictions'] as List;
      final List<PricePoint> forecast = predsList.map((e) {
        return PricePoint(
          date: e['date'] as String,
          price: (e['predicted_price'] as num).toDouble(),
        );
      }).toList();

      // Emit loaded state with charts and predictions first
      emit(
        DetailLoaded(
          history: history,
          forecast: forecast,
          isInsightLoading: true,
          trend: trend,
          horizon: horizon,
          lastPrice: lastPrice,
          predictedPrice: predictedPrice,
          modelUsed: modelUsed,
          lastHistoricalDate: lastHistoricalDate,
        ),
      );

      // 2. Fetch live AI insight asynchronously
      try {
        final liveInsight = await _repository.getLiveInsight(
          subcategory,
          trend,
          horizon,
          lastPrice,
          predictedPrice,
        );
        if (state is DetailLoaded) {
          emit(
            (state as DetailLoaded).copyWith(
              liveInsight: liveInsight,
              isInsightLoading: false,
            ),
          );
        }
      } catch (insightError) {
        // Log the error but keep the charts/forecast displayed
        debugPrint("Failed to fetch live AI insight: $insightError");
        if (state is DetailLoaded) {
          emit(
            (state as DetailLoaded).copyWith(
              isInsightLoading: false,
              liveInsight: Insight(
                masyarakat:
                    "Gagal memuat rekomendasi otomatis. Silakan coba beberapa saat lagi.",
                pedagang:
                    "Gagal memuat rekomendasi otomatis. Silakan coba beberapa saat lagi.",
                disclaimer: "Terjadi gangguan koneksi ke mesin AI.",
              ),
            ),
          );
        }
      }
    } catch (e) {
      emit(DetailError(e.toString()));
    }
  }

  Future<void> refreshLiveInsight(String subcategory) async {
    final currentState = state;
    if (currentState is! DetailLoaded) return;

    emit(
      currentState.copyWith(
        isInsightLoading: true,
        clearLiveInsight: true,
      ),
    );

    try {
      final liveInsight = await _repository.getLiveInsight(
        subcategory,
        currentState.trend,
        currentState.horizon,
        currentState.lastPrice,
        currentState.predictedPrice,
      );
      if (state is DetailLoaded) {
        emit(
          (state as DetailLoaded).copyWith(
            liveInsight: liveInsight,
            isInsightLoading: false,
          ),
        );
      }
    } catch (insightError) {
      debugPrint("Failed to fetch live AI insight during refresh: $insightError");
      if (state is DetailLoaded) {
        emit(
          (state as DetailLoaded).copyWith(
            isInsightLoading: false,
            liveInsight: Insight(
              masyarakat:
                  "Gagal memuat rekomendasi otomatis. Silakan coba beberapa saat lagi.",
              pedagang:
                  "Gagal memuat rekomendasi otomatis. Silakan coba beberapa saat lagi.",
              disclaimer: "Terjadi gangguan koneksi ke mesin AI.",
            ),
          ),
        );
      }
    }
  }
}
