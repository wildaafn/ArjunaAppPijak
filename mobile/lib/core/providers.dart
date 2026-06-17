import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../shared/data/commodity_repository.dart';
import '../shared/domain/models.dart';
import '../features/dashboard/data/news_article.dart';
import '../features/dashboard/data/news_repository.dart';

enum UserMode { buyer, seller }

class AppSettings {
  final UserMode mode;
  final bool isDarkMode;
  final Color upColor;
  final Color downColor;
  final Color stableColor;

  AppSettings({
    required this.mode,
    this.isDarkMode = false,
    this.upColor = const Color(0xFFE05263), // Soft Terracotta Red
    this.downColor = const Color(0xFF2A9D8F), // Soft Sage Teal/Green
    this.stableColor = const Color(0xFF6B7A82), // Soft Slate Blue-Grey
  });

  AppSettings copyWith({
    UserMode? mode,
    bool? isDarkMode,
    Color? upColor,
    Color? downColor,
    Color? stableColor,
  }) {
    return AppSettings(
      mode: mode ?? this.mode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      upColor: upColor ?? this.upColor,
      downColor: downColor ?? this.downColor,
      stableColor: stableColor ?? this.stableColor,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(_loadInitialSettings(_prefs));

  static AppSettings _loadInitialSettings(SharedPreferences prefs) {
    final modeIndex = prefs.getInt('user_mode') ?? 0;
    final isDark = prefs.getBool('is_dark_mode') ?? false;

    return AppSettings(
      mode: modeIndex < UserMode.values.length
          ? UserMode.values[modeIndex]
          : UserMode.buyer,
      isDarkMode: isDark,
    );
  }

  void toggleMode() {
    final newMode = state.mode == UserMode.buyer
        ? UserMode.seller
        : UserMode.buyer;
    state = state.copyWith(mode: newMode);
    _prefs.setInt('user_mode', newMode.index);
  }

  void toggleDarkMode() {
    final newDark = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newDark);
    _prefs.setBool('is_dark_mode', newDark);
  }

  void setMode(UserMode mode) {
    state = state.copyWith(mode: mode);
    _prefs.setInt('user_mode', mode.index);
  }

  Color getTrendColor(double change) {
    if (change.abs() < 0.25) return state.stableColor;

    if (state.mode == UserMode.buyer) {
      return change > 0 ? state.upColor : state.downColor;
    } else {
      return change > 0 ? state.downColor : state.upColor;
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final commodityRepositoryProvider = Provider<ICommodityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return CommodityRepository(apiClient, prefs);
});

final commoditiesProvider = FutureProvider<List<Commodity>>((ref) async {
  final repository = ref.watch(commodityRepositoryProvider);
  return repository.getCommodities();
});

final metadataProvider = FutureProvider<AppMetadata>((ref) async {
  final repository = ref.watch(commodityRepositoryProvider);
  return repository.getMetadata();
});

final globalAnalysisProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(commodityRepositoryProvider);
  return repository.getGlobalAnalysis();
});

/// Provider for GNews.io food/commodity news feed
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

final newsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  return repository.fetchPanganNews(max: 6);
});
