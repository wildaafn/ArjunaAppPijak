import 'package:flutter_test/flutter_test.dart';
import 'package:komoditas_ai/shared/domain/models.dart';

void main() {
  group('Insight Model Tests', () {
    test('should parse Insight from json map correctly', () {
      final json = {
        'masyarakat': 'Tips untuk masyarakat',
        'pedagang': 'Tips untuk pedagang',
        'disclaimer': 'Ini disclaimer',
      };

      final result = Insight.fromJson(json);

      expect(result.masyarakat, 'Tips untuk masyarakat');
      expect(result.pedagang, 'Tips untuk pedagang');
      expect(result.disclaimer, 'Ini disclaimer');
    });

    test('should parse Insight from a single raw string safely', () {
      const String rawInsight = 'Insight tunggal gabungan';

      final result = Insight.fromJson(rawInsight);

      expect(result.masyarakat, 'Insight tunggal gabungan');
      expect(result.pedagang, 'Insight tunggal gabungan');
      expect(result.disclaimer, '');
    });
  });

  group('Commodity Model Tests', () {
    test('should parse Commodity from json map safely', () {
      final json = {
        'name': 'Beras Premium',
        'current_price': 14500,
        'unit': 'kg',
        'price_changes': {
          'day_1': 1.5,
          'day_7': -0.5,
          'day_30': 4.2,
        },
        'forecast_pct': 2.3,
        'trend': 'Naik',
        'reliability': 'Tinggi',
        'market_alert': 'Pasokan stabil',
        'image_asset': 'assets/images/beras.png',
        'insight': {
          'masyarakat': 'Beli secukupnya',
          'pedagang': 'Jaga stok',
          'disclaimer': 'Aman',
        },
        'history': [
          {'date': '2026-06-01', 'price': 14000},
          {'date': '2026-06-02', 'price': 14500},
        ],
        'forecast': [
          {'date': '2026-06-03', 'price': 14700},
        ],
        'sub_commodities': [
          {
            'name': 'Beras Cianjur',
            'price': 15000,
            'change_pct': 0.8,
            'trend': 'Stabil',
            'image_asset': 'assets/images/beras.png',
          }
        ]
      };

      final result = Commodity.fromJson(json);

      expect(result.name, 'Beras Premium');
      expect(result.currentPrice, 14500.0);
      expect(result.priceChanges['day_1'], 1.5);
      expect(result.chart.history.length, 2);
      expect(result.chart.forecast.length, 1);
      expect(result.subCommodities.first.name, 'Beras Cianjur');
    });
  });
}
