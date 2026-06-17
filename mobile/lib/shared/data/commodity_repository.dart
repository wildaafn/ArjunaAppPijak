import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../domain/models.dart';

abstract class ICommodityRepository {
  Future<List<Commodity>> getCommodities();
  Future<AppMetadata> getMetadata();
  Future<List<PricePoint>> getHistoricalData(String subcategory);
  Future<Map<String, dynamic>> getPredictionData(String subcategory);
  Future<Insight> getLiveInsight(
    String subcategory,
    double trend,
    int horizon,
    double currentPrice,
    double predictedPrice,
  );
  Future<List<AuditPoint>> getAuditData(String subcategory);
  Future<String> getGlobalAnalysis();
}

class CommodityRepository implements ICommodityRepository {
  static const String _marketSummaryCacheKey = 'market_summary_cache_v2';

  final ApiClient _apiClient;

  CommodityRepository(this._apiClient, SharedPreferences prefs);

  // Synchronous access to the opened Hive Box
  Box get _cacheBox => Hive.box('commodity_cache');

  Future<Map<String, dynamic>> _fetchFullData() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.marketSummary);
      final data = response.data as Map<String, dynamic>;
      await _cacheBox.put(_marketSummaryCacheKey, data);
      return data;
    } on DioException catch (error) {
      final cachedData = _readCachedMarketSummary();
      if (cachedData != null) {
        debugPrint(
          'Using cached market summary from Hive after network failure: ${error.message}',
        );
        return cachedData;
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Map<String, dynamic>? _readCachedMarketSummary() {
    final cached = _cacheBox.get(_marketSummaryCacheKey);
    if (cached == null) return null;

    try {
      if (cached is Map<String, dynamic>) return cached;
      if (cached is Map) return Map<String, dynamic>.from(cached);
    } catch (error) {
      debugPrint('Failed to read cached market summary from Hive: $error');
    }
    return null;
  }

  @override
  Future<List<Commodity>> getCommodities() async {
    final data = await _fetchFullData();
    return (data['commodities'] as List)
        .map((e) => Commodity.fromJson(e))
        .toList();
  }

  @override
  Future<AppMetadata> getMetadata() async {
    final data = await _fetchFullData();
    return AppMetadata.fromJson(data['metadata'] as Map<String, dynamic>);
  }

  @override
  Future<List<PricePoint>> getHistoricalData(String subcategory) async {
    final cacheKey = 'historical_cache_$subcategory';
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.historical,
        queryParameters: {'subcategory': subcategory, 'days': 30},
      );
      final list = response.data as List;
      await _cacheBox.put(cacheKey, list);
      return list.map((e) => PricePoint.fromJson(e)).toList();
    } on DioException catch (error) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        debugPrint(
          'Using cached historical data from Hive for $subcategory: ${error.message}',
        );
        final list = cached as List;
        return list.map((e) => PricePoint.fromJson(e)).toList();
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getPredictionData(String subcategory) async {
    final cacheKey = 'prediction_cache_$subcategory';
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.predict,
        queryParameters: {
          'subcategory': subcategory,
          'model_type': 'sarimax',
          'steps': 7,
        },
      );
      final data = response.data as Map<String, dynamic>;
      await _cacheBox.put(cacheKey, data);
      return data;
    } on DioException catch (error) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        debugPrint(
          'Using cached prediction data from Hive for $subcategory: ${error.message}',
        );
        if (cached is Map<String, dynamic>) return cached;
        if (cached is Map) return Map<String, dynamic>.from(cached);
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Insight> getLiveInsight(
    String subcategory,
    double trend,
    int horizon,
    double currentPrice,
    double predictedPrice,
  ) async {
    // Unique cache key based on parameters to avoid hitting AI when values are unchanged
    final specificCacheKey =
        'live_insight_cache_${subcategory}_${trend}_${horizon}_${currentPrice}_$predictedPrice';
    final fallbackCacheKey = 'live_insight_cache_$subcategory';

    try {
      // 1. Check if we already have an insight for these EXACT input parameters
      final cachedSpecific = _cacheBox.get(specificCacheKey);
      if (cachedSpecific != null) {
        if (AppConfig.enableLogging) {
          debugPrint(
            'Using cached live insight for $subcategory (parameters unchanged, API call skipped to save AI tokens)',
          );
        }
        return Insight.fromJson(cachedSpecific);
      }

      // 2. Fetch new live insight if parameters changed
      final response = await _apiClient.dio.get(
        ApiConfig.insight,
        queryParameters: {
          'subcategory': subcategory,
          'trend': trend,
          'horizon': horizon,
          'current_price': currentPrice,
          'predicted_price': predictedPrice,
        },
      );
      final data = response.data['insight'];
      
      // Save to both specific and fallback boxes
      await _cacheBox.put(specificCacheKey, data);
      await _cacheBox.put(fallbackCacheKey, data);
      
      return Insight.fromJson(data);
    } on DioException catch (error) {
      // 3. Fallback to the last successfully loaded insight if offline
      final cachedFallback = _cacheBox.get(fallbackCacheKey);
      if (cachedFallback != null) {
        debugPrint(
          'Using fallback cached live insight from Hive for $subcategory: ${error.message}',
        );
        return Insight.fromJson(cachedFallback);
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<AuditPoint>> getAuditData(String subcategory) async {
    final cacheKey = 'audit_cache_$subcategory';
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.audit,
        queryParameters: {'subcategory': subcategory, 'days': 30},
      );
      final list = response.data as List;
      await _cacheBox.put(cacheKey, list);
      return list.map((e) => AuditPoint.fromJson(e)).toList();
    } on DioException catch (error) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        debugPrint(
          'Using cached audit data from Hive for $subcategory: ${error.message}',
        );
        final list = cached as List;
        return list.map((e) => AuditPoint.fromJson(e)).toList();
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> getGlobalAnalysis() async {
    final cacheKey = 'global_analysis_cache';
    try {
      final response = await _apiClient.dio.get(ApiConfig.globalAnalysis);
      final data = response.data as Map<String, dynamic>;
      final analysis = data['global_analysis'] as String? ?? '';
      await _cacheBox.put(cacheKey, analysis);
      return analysis;
    } on DioException catch (error) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null && cached is String) {
        debugPrint('Using cached global analysis from Hive: ${error.message}');
        return cached;
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
