import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'tb_auth_provider.dart';

part 'tb_websocket_service.g.dart';

/// Manages a single persistent WebSocket connection to ThingsBoard.
/// Each subscription gets a unique cmdId so multiple providers can share one socket.
@Riverpod(keepAlive: true)
TbWebSocketService tbWebSocketService(Ref ref) {
  final service = TbWebSocketService(ref);
  ref.onDispose(service.dispose);
  return service;
}

class TbWebSocketService {
  TbWebSocketService(this._ref) {
    _ref.listen(tbAuthProvider, (_, next) {
      final token = next.valueOrNull;
      if (token != null && token != _currentToken) {
        _currentToken = token;
        _reconnect();
      }
    }, fireImmediately: true);
  }

  final Ref _ref;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSub;
  String? _currentToken;
  int _cmdId = 0;
  bool _disposed = false;

  // cmdId → StreamController for that subscription
  final Map<int, StreamController<Map<String, dynamic>>> _controllers = {};
  // cmdId → subscription command JSON (reconnect'te tekrar gönderilir)
  final Map<int, String> _pendingCmds = {};

  void _reconnect() {
    _socketSub?.cancel();
    _channel?.sink.close();
    // Controller'ları KAPATMA — mevcut stream listener'lar yaşamaya devam etmeli
    // Pending commands reconnect sonrası yeniden gönderilecek

    if (_currentToken == null) return;

    final wsUrl = 'ws://smartio.kabelteknoloji.com:8080/api/ws/plugins/telemetry?token=$_currentToken';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _socketSub = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          debugPrint('[TbWS] error: $e');
          if (!_disposed) {
            Future.delayed(const Duration(seconds: 5), _reconnect);
          }
        },
        onDone: () {
          debugPrint('[TbWS] connection closed');
          if (!_disposed) {
            Future.delayed(const Duration(seconds: 5), _reconnect);
          }
        },
      );
      debugPrint('[TbWS] connected to $wsUrl');
      // Reconnect sonrası tüm aktif subscription'ları yeniden gönder
      for (final cmd in _pendingCmds.values) {
        _channel!.sink.add(cmd);
        debugPrint('[TbWS] resent pending cmd after reconnect');
      }
    } catch (e) {
      debugPrint('[TbWS] connect failed: $e');
    }
  }

  void _onMessage(dynamic raw) {
    try {
      debugPrint('[TbWS] raw message: $raw');
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final cmdId = data['subscriptionId'] as int?;
      if (cmdId == null) return;
      final controller = _controllers[cmdId];
      if (controller == null || controller.isClosed) return;

      // TB returns: { "data": { "key": [[ts, value], ...] } }
      final dataMap = data['data'] as Map<String, dynamic>?;
      if (dataMap == null) return;

      final flat = <String, dynamic>{};
      for (final entry in dataMap.entries) {
        final list = entry.value as List<dynamic>;
        if (list.isNotEmpty) {
          flat[entry.key] = (list.first as List<dynamic>)[1];
        }
      }
      debugPrint('[TbWS] parsed data cmdId=$cmdId flat=$flat');
      if (flat.isNotEmpty) controller.add(flat);
    } catch (e) {
      debugPrint('[TbWS] parse error: $e');
    }
  }

  /// Subscribe to telemetry keys for a device. Returns a broadcast stream.
  Stream<Map<String, dynamic>> subscribeToTelemetry(
    String deviceId,
    List<String> keys,
  ) {
    final id = ++_cmdId;
    final controller = StreamController<Map<String, dynamic>>.broadcast(
      onCancel: () => _unsubscribe(id),
    );
    _controllers[id] = controller;

    final cmd = jsonEncode({
      'tsSubCmds': [
        {
          'entityType': 'DEVICE',
          'entityId': deviceId,
          'scope': 'LATEST_TELEMETRY',
          'cmdId': id,
          'keys': keys.join(','),
        }
      ],
      'historyCmds': [],
      'attrSubCmds': [],
    });
    _pendingCmds[id] = cmd; // reconnect'te yeniden gönderilmek üzere sakla
    debugPrint('[TbWS] subscribe cmdId=$id deviceId=$deviceId keys=${keys.join(",")}');
    if (_channel == null) {
      debugPrint('[TbWS] WARNING: channel null, cmd queued for next reconnect');
    } else {
      _channel!.sink.add(cmd);
    }
    return controller.stream;
  }

  void _unsubscribe(int cmdId) {
    _controllers.remove(cmdId);
    _pendingCmds.remove(cmdId); // artık yeniden gönderilmemeli
    final cmd = jsonEncode({
      'tsSubCmds': [
        {'cmdId': cmdId, 'unsubscribe': true}
      ],
      'historyCmds': [],
      'attrSubCmds': [],
    });
    _channel?.sink.add(cmd);
  }

  void dispose() {
    _disposed = true;
    _socketSub?.cancel();
    _channel?.sink.close();
    for (final c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
    _pendingCmds.clear();
  }
}
