import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:komoditas_ai/main.dart';
import 'api_config.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (AppConfig.enableLogging) {
            debugPrint('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.enableLogging) {
            String prettyData = '';
            try {
              const encoder = JsonEncoder.withIndent('  ');
              prettyData = encoder.convert(response.data);
            } catch (_) {
              prettyData = response.data.toString();
            }

            debugPrint(
              '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n📦 DATA:\n$prettyData',
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (AppConfig.enableLogging) {
            debugPrint('❌ ERROR[${e.type}] => PATH: ${e.requestOptions.path}');
          }
          final errorMessage = _handleDioError(e);
          return handler.next(e.copyWith(message: errorMessage));
        },
      ),
    );
  }

  Dio get dio => _dio;

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau terputus. Silakan periksa sinyal internet Anda.';
      case DioExceptionType.sendTimeout:
        return 'Gagal mengirim data. Silakan coba beberapa saat lagi.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Layanan data sedang tidak tersedia saat ini.';
        }
        if (statusCode == 500) {
          return 'Ada kendala teknis di sistem kami. Mohon tunggu sebentar.';
        }
        return 'Sistem sedang sibuk (Error: $statusCode). Silakan coba lagi.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke internet. Pastikan koneksi Anda aktif.';
      default:
        return 'Terjadi kendala tidak terduga. Silakan coba lagi nanti.';
    }
  }
}
