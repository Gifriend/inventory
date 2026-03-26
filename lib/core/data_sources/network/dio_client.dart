import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/local/secure_storage_service.dart';
import 'package:inventory/core/data_sources/network/auth_session_event.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorageService, this._ref);

  final SecureStorageService _secureStorageService;
  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401) {
      final path = err.requestOptions.path;
      final isAuthEndpoint =
          path.endsWith(Endpoint.login) || path.endsWith(Endpoint.register);

      if (!isAuthEndpoint) {
        await _secureStorageService.clearToken();
        _ref.read(authSessionExpiredEventProvider.notifier).emit();
      }
    }

    handler.next(err);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Endpoint.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(ref.watch(secureStorageServiceProvider), ref),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }

  return dio;
});
