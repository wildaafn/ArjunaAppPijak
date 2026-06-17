import '../../../../shared/domain/models.dart';

abstract class DetailState {}

class DetailInitial extends DetailState {}

class DetailLoading extends DetailState {}

class DetailLoaded extends DetailState {
  final List<PricePoint> history;
  final List<PricePoint> forecast;
  final Insight? liveInsight;
  final bool isInsightLoading;
  final double trend;
  final int horizon;
  final double lastPrice;
  final double predictedPrice;
  final String modelUsed;
  final String lastHistoricalDate;

  DetailLoaded({
    required this.history,
    required this.forecast,
    this.liveInsight,
    this.isInsightLoading = false,
    required this.trend,
    required this.horizon,
    required this.lastPrice,
    required this.predictedPrice,
    this.modelUsed = '',
    this.lastHistoricalDate = '',
  });

  DetailLoaded copyWith({
    List<PricePoint>? history,
    List<PricePoint>? forecast,
    Insight? liveInsight,
    bool? isInsightLoading,
    double? trend,
    int? horizon,
    double? lastPrice,
    double? predictedPrice,
    String? modelUsed,
    String? lastHistoricalDate,
    bool clearLiveInsight = false,
  }) {
    return DetailLoaded(
      history: history ?? this.history,
      forecast: forecast ?? this.forecast,
      liveInsight: clearLiveInsight ? null : (liveInsight ?? this.liveInsight),
      isInsightLoading: isInsightLoading ?? this.isInsightLoading,
      trend: trend ?? this.trend,
      horizon: horizon ?? this.horizon,
      lastPrice: lastPrice ?? this.lastPrice,
      predictedPrice: predictedPrice ?? this.predictedPrice,
      modelUsed: modelUsed ?? this.modelUsed,
      lastHistoricalDate: lastHistoricalDate ?? this.lastHistoricalDate,
    );
  }
}

class DetailError extends DetailState {
  final String message;

  DetailError(this.message);
}

