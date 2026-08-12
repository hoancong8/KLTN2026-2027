import 'dart:io';
import 'dart:ui';

import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:flutter/material.dart';
import '../consts/app_config.dart';
import '../consts/app_log.dart';
import '../../domain/exceptions/app_exception.dart';
import '../../domain/services/i_signalr_service.dart';

class SignalRService with WidgetsBindingObserver implements ISignalRService {
  HubConnection? hubConnection;

  String? _accessToken;
  /// Optional getter that always returns the latest token (e.g. after refresh).
  /// If provided, it takes priority over [_accessToken].
  /// Fix #6: prevents stale token after AppAuthInterceptor refreshes the token.
  String? Function()? _tokenGetter;

  bool _isConnecting = false;
  bool _isDisconnecting = false; // Fix #4: guard against resume-before-disconnect
  bool _observing = false;

  Function(Map<String, dynamic>)? _onMessageReceived;
  Function(Map<String, dynamic>)? _onUserConnectionChange;
  Function(Map<String, dynamic>)? _onAllUnreadMessagesRead;

  // Secondary listeners dùng cho ChatDetailViewModel
  final List<Function(Map<String, dynamic>)> _chatMessageListeners = [];
  final List<Function(Map<String, dynamic>)> _connectionListeners = [];

  @override
  void addChatMessageListener(Function(Map<String, dynamic>) listener) {
    if (!_chatMessageListeners.contains(listener)) {
      _chatMessageListeners.add(listener);
    }
  }

  @override
  void removeChatMessageListener(Function(Map<String, dynamic>) listener) {
    _chatMessageListeners.remove(listener);
  }

  @override
  void addConnectionListener(Function(Map<String, dynamic>) listener) {
    if (!_connectionListeners.contains(listener)) {
      _connectionListeners.add(listener);
    }
  }

  @override
  void removeConnectionListener(Function(Map<String, dynamic>) listener) {
    _connectionListeners.remove(listener);
  }

  void startObserve() {
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  void stopObserve() {
    if (!_observing) return;
    WidgetsBinding.instance.removeObserver(this);
    _observing = false;
  }

  @override
  Future<void> connect(
      String accessToken, {
        Function(Map<String, dynamic>)? onMessageReceived,
        Function(Map<String, dynamic>)? onUserConnectionChange,
        Function(Map<String, dynamic>)? onAllUnreadMessagesRead,
        /// Fix #6: supply a getter so the accessTokenFactory always uses the
        /// freshest token after AppAuthInterceptor refreshes it.
        String? Function()? tokenGetter,
      }) async {
    if (_isConnecting || _isDisconnecting) return;
    if (isConnected) return;

    _isConnecting = true;
    try {
      _accessToken = accessToken;
      _tokenGetter = tokenGetter;
      _onMessageReceived = onMessageReceived;
      _onUserConnectionChange = onUserConnectionChange;
      _onAllUnreadMessagesRead = onAllUnreadMessagesRead;

      startObserve();

      // chỉ build 1 lần
      hubConnection ??= _buildConnection();

      // đảm bảo không bị lặp listener
      _registerListeners();

      await hubConnection!.start();
      await _register();
      AppLog.info('[SignalR] Connected');
    } finally {
      _isConnecting = false;
    }
  }

  HubConnection _buildConnection() {
    final httpOptions = HttpConnectionOptions(
      // Fix #6: always read the freshest token via _tokenGetter if available
      accessTokenFactory: () async => _tokenGetter?.call() ?? _accessToken!,
      requestTimeout: 60000,
    );

    final conn = HubConnectionBuilder()
        .withUrl('${AppConfig.baseUrl}/signalr-chat', options: httpOptions)
        .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000])
        .build();

    conn.onclose(({error}) => AppLog.error('[SignalR] Closed: $error'));
    conn.onreconnecting(({error}) => AppLog.error('[SignalR] Reconnecting...'));
    conn.onreconnected(({connectionId}) async {
      AppLog.info('[SignalR] Reconnected: $connectionId');
      await _register();
    });

    return conn;
  }

  void _registerListeners() {
    // OFF trước khi ON để tránh lặp
    hubConnection?.off('getChatMessage');
    hubConnection?.off('getUserConnectNotification');
    hubConnection?.off('getallUnreadMessagesOfUserRead');

    hubConnection?.on('getChatMessage', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _onMessageReceived?.call(data);
      for (final listener in List.of(_chatMessageListeners)) {
        listener(data);
      }
    });

    hubConnection?.on('getUserConnectNotification', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _onUserConnectionChange?.call(data);
      for (final listener in List.of(_connectionListeners)) {
        listener(data);
      }
    });

    hubConnection?.on('getallUnreadMessagesOfUserRead', (args) {
      if (_onAllUnreadMessagesRead != null && args != null && args.isNotEmpty) {
        _onAllUnreadMessagesRead!(args[0] as Map<String, dynamic>);
      }
    });
  }

  Future<void> _register() async {
    try {
      await hubConnection?.invoke('register');
      AppLog.info('[SignalR] Registered');
    } catch (e) {
      AppLog.error('[SignalR] Register failed: ', e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_accessToken == null) return;

    if (state == AppLifecycleState.paused) {
      // Fix #4: set flag before disconnecting so the resumed branch won't
      // try to connect before disconnect completes.
      _isDisconnecting = true;
      disconnect().whenComplete(() => _isDisconnecting = false);
    } else if (state == AppLifecycleState.resumed) {
      // Fix #4: wait if still disconnecting, then reconnect if needed
      if (!isConnected && !_isDisconnecting) {
        connect(
          _accessToken!,
          onMessageReceived: _onMessageReceived,
          onUserConnectionChange: _onUserConnectionChange,
          onAllUnreadMessagesRead: _onAllUnreadMessagesRead,
          tokenGetter: _tokenGetter,
        );
      }
    }
  }

  @override
  Future<void> disconnect({bool clear = false}) async {
    try {
      await hubConnection?.stop();
      AppLog.info('[SignalR] Disconnected');
    } catch (e) {
      AppLog.error('[SignalR] Disconnect error: ', e);
    }

    if (clear) {
      // dọn sạch để logout/login user khác không bị dính callback cũ
      _accessToken = null;
      _tokenGetter = null;
      _onMessageReceived = null;
      _onUserConnectionChange = null;
      _onAllUnreadMessagesRead = null;
      _chatMessageListeners.clear();
      _connectionListeners.clear();

      stopObserve(); // Fix #3: observer removed on full clear

      // nếu muốn “reset hoàn toàn” connection object:
      hubConnection = null;
    }
  }

  /// Fix #6: Update the stored token. Called by AppAuthInterceptor after refresh
  /// so SignalR reconnects will use the new token immediately.
  @override
  void updateToken(String newToken) {
    _accessToken = newToken;
  }

  @override
  Future<void> sendMessage({
    required int tenantId,
    required int userId,
    required String message,
  }) async {
    AppLog.info('[SignalR] Sending message to user $userId...');
    if (!isConnected) {
      AppLog.info('[SignalR] Cannot send - not connected');
      throw const SignalRNotConnectedException();
    }

    await hubConnection?.invoke(
      'sendMessage',
      args: [
        {
          'tenantId': tenantId == 0 ? null : tenantId,
          'userId': userId,
          'message': message,
        },
      ],
    );

    AppLog.info('[SignalR] Message sent successfully');
  }

  bool get isConnected => hubConnection?.state == HubConnectionState.Connected;
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
