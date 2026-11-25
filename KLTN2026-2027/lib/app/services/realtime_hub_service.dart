import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../consts/app_config.dart';
import 'secure_storage_service.dart';

class RealtimeHubService {
  static RealtimeHubService? _instance;
  static RealtimeHubService get instance => _instance ??= RealtimeHubService._();

  RealtimeHubService._();

  HubConnection? _connection;
  final _ledgerUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _rotationChangedController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onLedgerUpdated => _ledgerUpdatedController.stream;
  Stream<Map<String, dynamic>> get onRotationChanged => _rotationChangedController.stream;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  Future<void> start() async {
    if (isConnected) return;

    try {
      final token = await SecureStorageService.instance.getAuthToken();
      if (token == null || token.accessToken.isEmpty) return;

      final hubUrl = '${AppConfig.baseUrl}/hubs/sessions';

      _connection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async {
                final current = await SecureStorageService.instance.getAuthToken();
                return current?.accessToken ?? '';
              },
            ),
          )
          .withAutomaticReconnect()
          .build();

      _connection?.on('LedgerUpdated', _handleLedgerUpdated);
      _connection?.on('RotationChanged', _handleRotationChanged);
      _connection?.on('MyMatchesChanged', _handleRotationChanged);

      _connection?.onclose(({error}) {
        if (kDebugMode) {
          debugPrint('[RealtimeHubService] Connection closed: $error');
        }
      });

      _connection?.onreconnected(({connectionId}) {
        if (kDebugMode) {
          debugPrint('[RealtimeHubService] Reconnected: $connectionId');
        }
      });

      await _connection?.start();
      if (kDebugMode) {
        debugPrint('[RealtimeHubService] SignalR Connected to $hubUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RealtimeHubService] Start failed: $e');
      }
    }
  }

  void _handleLedgerUpdated(List<Object?>? args) {
    if (args != null && args.isNotEmpty && args[0] is Map) {
      final data = Map<String, dynamic>.from(args[0] as Map);
      _ledgerUpdatedController.add(data);
    }
  }

  void _handleRotationChanged(List<Object?>? args) {
    if (args != null && args.isNotEmpty && args[0] is Map) {
      final data = Map<String, dynamic>.from(args[0] as Map);
      _rotationChangedController.add(data);
    }
  }

  Future<void> joinSession(String sessionId) async {
    if (!isConnected || _connection == null) return;
    try {
      await _connection?.invoke('JoinSession', args: [sessionId]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RealtimeHubService] JoinSession failed: $e');
      }
    }
  }

  Future<void> leaveSession(String sessionId) async {
    if (!isConnected || _connection == null) return;
    try {
      await _connection?.invoke('LeaveSession', args: [sessionId]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RealtimeHubService] LeaveSession failed: $e');
      }
    }
  }

  Future<void> stop() async {
    try {
      await _connection?.stop();
    } catch (_) {}
  }
}
