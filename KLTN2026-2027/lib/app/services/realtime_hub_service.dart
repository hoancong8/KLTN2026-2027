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
  String? _userId;
  Future<void> _transition = Future.value();
  final _reputationController = StreamController<Map<String, dynamic>>.broadcast();
  final _reconnectedController = StreamController<void>.broadcast();

  Stream<Map<String, dynamic>> get onReputation => _reputationController.stream;
  Stream<void> get onReconnected => _reconnectedController.stream;

  Future<void> _serialize(Future<void> Function() action) {
    final next = _transition.then((_) => action());
    _transition = next.catchError((Object _) {});
    return next;
  }
  final _ledgerUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _rotationChangedController = StreamController<Map<String, dynamic>>.broadcast();
  final _bookingUpdatedController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onLedgerUpdated => _ledgerUpdatedController.stream;
  Stream<Map<String, dynamic>> get onRotationChanged => _rotationChangedController.stream;
  Stream<Map<String, dynamic>> get onBookingUpdated => _bookingUpdatedController.stream;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  Future<void> start() => _serialize(_start);

  Future<void> _start() async {

    try {
      final token = await SecureStorageService.instance.getAuthToken();
      if (token == null || token.accessToken.isEmpty) return;
      if (_userId == token.userId && _connection?.state != HubConnectionState.Disconnected &&
          _connection != null) {
        return;
      }
      await _stop();
      _userId = token.userId;

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
      _connection?.on('BookingUpdated', _handleBookingUpdated);
      _connection?.on('ReviewInvitation', (args) => _handleReputation(args, 'ReviewInvitationPush'));
      _connection?.on('ReputationUpdated', (args) => _handleReputation(args, 'ReputationUpdatedPush'));

      _connection?.onclose(({error}) {
        if (kDebugMode) {
          debugPrint('[RealtimeHubService] Connection closed: $error');
        }
      });

      _connection?.onreconnected(({connectionId}) {
        _reconnectedController.add(null);
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

  void _handleBookingUpdated(List<Object?>? args) {
    if (args != null && args.isNotEmpty && args[0] is Map) {
      final data = Map<String, dynamic>.from(args[0] as Map);
      _bookingUpdatedController.add(data);
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

  void _handleReputation(List<Object?>? args, String kind) {
    final data = args?.firstOrNull;
    if (data is Map) _reputationController.add({...Map<String, dynamic>.from(data), 'kind': kind});
  }

  Future<void> stop() => _serialize(_stop);

  Future<void> _stop() async {
    final connection = _connection;
    _connection = null;
    _userId = null;
    try {
      await connection?.stop();
    } catch (_) {}
  }
}
