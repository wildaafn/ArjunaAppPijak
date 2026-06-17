class Insight {
  final String masyarakat;
  final String pedagang;
  final String disclaimer;

  Insight({
    required this.masyarakat,
    required this.pedagang,
    required this.disclaimer,
  });

  factory Insight.fromJson(dynamic json) {
    if (json is String) {
      return Insight(masyarakat: json, pedagang: json, disclaimer: '');
    }
    return Insight(
      masyarakat: json['masyarakat'] ?? '',
      pedagang: json['pedagang'] ?? '',
      disclaimer: json['disclaimer'] ?? '',
    );
  }
}

class AppMetadata {
  final String updatedAt;
  final String globalAnalysis;
  final String disclaimer;
  final Map<String, dynamic> aboutUs;

  AppMetadata({
    required this.updatedAt,
    required this.globalAnalysis,
    required this.disclaimer,
    required this.aboutUs,
  });

  factory AppMetadata.fromJson(Map<String, dynamic> json) {
    return AppMetadata(
      updatedAt: json['updated_at'] ?? '',
      globalAnalysis: json['global_analysis'] ?? '',
      disclaimer: json['disclaimer'] ?? '',
      aboutUs: json['about_us'] ?? {},
    );
  }
}

class Commodity {
  final String name;
  final double currentPrice;
  final String unit;
  final Map<String, double> priceChanges;
  final double forecastPct;
  final String trend;
  final String reliability;
  final String marketAlert;
  final String imageAsset;
  final Insight insight;
  final ChartData chart;
  final List<SubCommodity> subCommodities;

  Commodity({
    required this.name,
    required this.currentPrice,
    required this.unit,
    required this.priceChanges,
    required this.forecastPct,
    required this.trend,
    required this.reliability,
    required this.marketAlert,
    required this.imageAsset,
    required this.insight,
    required this.chart,
    required this.subCommodities,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      name: json['name'],
      currentPrice: json['current_price'].toDouble(),
      unit: json['unit'],
      priceChanges: Map<String, double>.from(
        json['price_changes'].map((k, v) => MapEntry(k, v.toDouble())),
      ),
      forecastPct: json['forecast_pct'].toDouble(),
      trend: json['trend'],
      reliability: json['reliability'],
      marketAlert: json['market_alert'] ?? '',
      imageAsset: json['image_asset'],
      insight: Insight.fromJson(json['insight']),
      chart: ChartData.fromJson(json),
      subCommodities:
          (json['sub_commodities'] as List)
              .map((i) => SubCommodity.fromJson(i))
              .toList(),
    );
  }
}

class ChartData {
  final List<PricePoint> history;
  final List<PricePoint> forecast;

  ChartData({required this.history, required this.forecast});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    // Support both flat format and nested "chart" format
    final targetMap = json.containsKey('chart') && json['chart'] is Map<String, dynamic>
        ? json['chart'] as Map<String, dynamic>
        : json;

    return ChartData(
      history: (targetMap['history'] as List?)
              ?.map((i) => PricePoint.fromJson(i))
              .toList() ??
          [],
      forecast: (targetMap['forecast'] as List?)
              ?.map((i) => PricePoint.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class PricePoint {
  final String date;
  final double price;

  PricePoint({required this.date, required this.price});

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: json['date'],
      price: json['price'].toDouble(),
    );
  }
}

class SubCommodity {
  final String name;
  final double price;
  final double changePct;
  final String trend;
  final String imageAsset;

  SubCommodity({
    required this.name,
    required this.price,
    required this.changePct,
    required this.trend,
    required this.imageAsset,
  });

  factory SubCommodity.fromJson(Map<String, dynamic> json) {
    return SubCommodity(
      name: json['name'],
      price: json['price'].toDouble(),
      changePct: json['change_pct'].toDouble(),
      trend: json['trend'],
      imageAsset: json['image_asset'],
    );
  }
}

class AuditPoint {
  final String date;
  final double actualPrice;
  final double fittedPrice;
  final double residualPct;

  AuditPoint({
    required this.date,
    required this.actualPrice,
    required this.fittedPrice,
    required this.residualPct,
  });

  factory AuditPoint.fromJson(Map<String, dynamic> json) {
    return AuditPoint(
      date: json['date'] as String,
      actualPrice: (json['actual_price'] as num).toDouble(),
      fittedPrice: (json['fitted_price'] as num).toDouble(),
      residualPct: (json['residual_pct'] as num).toDouble(),
    );
  }
}
