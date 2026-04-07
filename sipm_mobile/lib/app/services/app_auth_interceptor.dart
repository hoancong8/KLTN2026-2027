import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/app/services/secure_storage_service.dart';
import 'package:sipm_mobile/domain/entities/auth_token.dart';
import 'package:sipm_mobile/app/consts/app_router.dart';

class AppAuthInterceptor extends Interceptor {
  final Ref ref;
  final Dio baseDio;

  static bool _isShowingSessionExpiredDialog = false;
  static Dio? _refreshDio;
  static Future<AuthToken>? _refreshFuture;

  AppAuthInterceptor(this.ref, this.baseDio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Luôn gửi header FromMobile cho mọi request
    options.headers['FromMobile'] = 'true';

    final token = ref.read(authTokenProvider);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;

      if (path.contains(AppConfig.login) ||
          path.contains(AppConfig.sendTwoFactorCode) ||
          path.contains(AppConfig.refreshToken)) {
        return handler.next(err);
      }

      final currentToken = ref.read(authTokenProvider);
      if (currentToken == null) {
        _handleSessionExpired(ref);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            type: DioExceptionType.cancel,
          ),
        );
      }

      if (_refreshFuture != null) {
        try {
          final newToken = await _refreshFuture!;
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${newToken.accessToken}';

          final tenantId = await SecureStorageService.instance.getTenantId();
          if (tenantId != null) {
            opts.headers['Abp.TenantId'] = tenantId.toString();
          }

          final retryResponse = await baseDio.fetch(opts);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Chỉ session expired nếu retry cũng bị 401
          // Các lỗi khác (403, 500...) pass through bình thường
          if (e is DioException && e.response?.statusCode == 401) {
            _handleSessionExpired(ref);
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                type: DioExceptionType.cancel,
              ),
            );
          }
          return handler.next(e is DioException ? e : err);
        }
      }

      _refreshFuture = _refreshToken(baseDio, currentToken, ref);

      try {
        final newToken = await _refreshFuture!;
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${newToken.accessToken}';

        final tenantId = await SecureStorageService.instance.getTenantId();
        if (tenantId != null) {
          opts.headers['Abp.TenantId'] = tenantId.toString();
        }

        final retryResponse = await baseDio.fetch(opts);
        return handler.resolve(retryResponse);
      } catch (e) {
        // Nếu refresh thất bại → session expired
        // Nếu refresh OK nhưng retry bị lỗi khác 401 → pass through
        if (e is DioException &&
            e.response?.statusCode != null &&
            e.response!.statusCode != 401) {
          return handler.next(e);
        }
        _handleSessionExpired(ref);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            type: DioExceptionType.cancel,
          ),
        );
      } finally {
        _refreshFuture = null;
      }
    }
    return handler.next(err);
  }

  Future<AuthToken> _refreshToken(
    Dio dio,
    AuthToken currentToken,
    Ref ref,
  ) async {
    _refreshDio ??= Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'FromMobile': 'true',
        },
      ),
    )..httpClientAdapter = buildAdapter();

    try {
      final response = await _refreshDio!.post(
        AppConfig.refreshToken,
        queryParameters: {'refreshToken': currentToken.refreshToken},
      );

      final result = response.data['result'];
      final newToken = AuthToken(
        accessToken: result['accessToken'] as String,
        refreshToken:
            (result['refreshToken'] as String?) ?? currentToken.refreshToken,
        userId: currentToken.userId,
      );

      ref.read(authTokenProvider.notifier).state = newToken;
      await SecureStorageService.instance.saveAuthToken(newToken);

      return newToken;
    } catch (e) {
      rethrow;
    }
  }

  void _handleSessionExpired(Ref ref) {
    if (_isShowingSessionExpiredDialog) return;
    _isShowingSessionExpiredDialog = true;

    ref.read(authTokenProvider.notifier).state = null;
    SecureStorageService.instance.clearAuthToken();

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _isShowingSessionExpiredDialog = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text('Phiên đăng nhập hết hạn')),
          ],
        ),
        content: const Text(
          'Phiên đăng nhập của bạn đã hết hạn. Vui lòng đăng nhập lại để tiếp tục sử dụng.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Đăng nhập lại'),
          ),
        ],
      ),
    ).then((_) {
      _isShowingSessionExpiredDialog = false;
      final navContext = rootNavigatorKey.currentContext;
      if (navContext != null && navContext.mounted) {
        navContext.go(AppConfig.loginPath);
      }
    });
  }

  static IOHttpClientAdapter buildAdapter() {
    return IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        if (AppConfig.env == 'dev') {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        }
        return client;
      },
    );
  }
}
