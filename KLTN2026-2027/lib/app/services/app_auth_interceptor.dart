import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/services/secure_storage_service.dart';
import 'package:kltn2026_2027/domain/entities/auth_token.dart';
import 'package:kltn2026_2027/app/consts/app_router.dart';

import '../consts/app_log.dart';
import '../l10n_gen/app_localizations.dart';

class AppAuthInterceptor extends Interceptor {
  final Ref ref;
  final Dio baseDio;

  // Fix #1: these are static to share across parallel requests, but must be
  // reset after session expires or after a successful refresh cycle completes.
  static bool _isShowingSessionExpiredDialog = false;
  static Dio? _refreshDio;
  static Future<AuthToken>? _refreshFuture;

  /// Reset static state — call after logout or when starting a fresh session.
  static void resetStaticState() {
    _isShowingSessionExpiredDialog = false;
    _refreshFuture = null;
    // Keep _refreshDio — it is stateless and can be reused across sessions.
  }

  AppAuthInterceptor(this.ref, this.baseDio);

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = ref.read(authTokenProvider);
    options.headers['FromMobile'] = 'true';
    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }

    final tenantId = await SecureStorageService.instance.getTenantId();
    if (tenantId != null) {
      options.headers['Abp.TenantId'] = tenantId.toString();
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
        AuthToken newToken;
        try {
          newToken = await _refreshFuture!;
        } catch (_) { // Bắt mọi lỗi từ Refresh API (Timeout, 400 Bad Request...)
          _handleSessionExpired(ref);
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              type: DioExceptionType.cancel,
            ),
          );
        }

        try {
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${newToken.accessToken}';
          final retryResponse = await baseDio.request(
            opts.path,
            data: opts.data,
            queryParameters: opts.queryParameters,
            options: Options(
              method: opts.method,
              headers: opts.headers,
              responseType: opts.responseType,
              contentType: opts.contentType,
            ),
          );
          AppLog.info('[AppAuthInterceptor] Waiter Retry Response Data: ${retryResponse.data?.toString().substring(0, retryResponse.data?.toString().length.clamp(0, 500))}');
          return handler.resolve(retryResponse);
        } catch (e) {
          if (e is DioException && e.response?.statusCode == 401) {
            AppLog.info('[AppAuthInterceptor] Retry failed with 401, session expired');
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

      AppLog.info('[AppAuthInterceptor] Triggering token refresh');
      _refreshFuture = _refreshToken(baseDio, currentToken, ref);

      AuthToken newToken;
      try {
        newToken = await _refreshFuture!;
      } catch (e) {
        _refreshFuture = null;
        _handleSessionExpired(ref);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            type: DioExceptionType.cancel,
          ),
        );
      }

      try {
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${newToken.accessToken}';

        final tenantId = await SecureStorageService.instance.getTenantId();
        if (tenantId != null) {
          opts.headers['Abp.TenantId'] = tenantId.toString();
        }

        AppLog.info(
          '[AppAuthInterceptor] Retrying original request with new token: ${opts.path}',
        );
        final retryResponse = await baseDio.fetch(opts);
        AppLog.info(
          '[AppAuthInterceptor] Initiator Retry complete, status: ${retryResponse.statusCode} | Data: ${retryResponse.data?.toString().substring(0, retryResponse.data?.toString().length.clamp(0, 500))}',
        );
        return handler.resolve(retryResponse);
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 401) {
          _handleSessionExpired(ref);
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              type: DioExceptionType.cancel,
            ),
          );
        }
        if (e is DioException && e.response?.statusCode != null) {
          AppLog.info('[AppAuthInterceptor] Retry failed with ${e.response?.statusCode}');
        }
        return handler.next(e is DioException ? e : err);
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
        headers: {'Content-Type': 'application/json', 'FromMobile': 'true'},
      ),
    )..httpClientAdapter = buildAdapter();

    try {
      AppLog.info(
        '[AppAuthInterceptor] Calling /TokenAuth/RefreshToken with old refreshToken',
      );
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

      // Fix #6 + #1: notify SignalR to use the refreshed token immediately,
      // and reset the refresh future so next token expiry starts a fresh cycle.
      try {
        ref.read(signalRServiceProvider).updateToken(newToken.accessToken);
      } catch (_) {}

      AppLog.info('[AppAuthInterceptor] Refresh token successful');
      return newToken;
    } catch (e) {
      AppLog.info('[AppAuthInterceptor] Refresh token exception: $e');
      rethrow;
    }
  }

  void _handleSessionExpired(Ref ref) {
    if (_isShowingSessionExpiredDialog) return;
    _isShowingSessionExpiredDialog = true;

    // Fix #1: clear the stale refresh future immediately so the next login
    // session starts clean and doesn't inherit this session's state.
    _refreshFuture = null;

    ref.read(authTokenProvider.notifier).state = null;
    SecureStorageService.instance.clearAuthToken();

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _isShowingSessionExpiredDialog = false;
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.auth_session_expired_title)),
          ],
        ),
        content: Text(l10n.auth_session_expired_message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.auth_login_again),
          ),
        ],
      ),
    ).then((_) {
      // Fix #1: fully reset static state when dialog is dismissed so the
      // next login session doesn't inherit the expired session's flags.
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
