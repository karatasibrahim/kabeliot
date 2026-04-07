import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// MQTT bağlantı durumu
enum MqttConnectionStatus { disconnected, connecting, connected, error }

/// Gelen MQTT mesajı
class MqttMessage {
  const MqttMessage({required this.topic, required this.payload});
  final String topic;
  final String payload;
}

/// Core MQTT wrapper — singleton, tüm providerlar buradan erişir.
/// mqtt_client kütüphanesini soyutlar, reconnect ve stream yönetimini yapar.
class MqttService {
  MqttService._();
  static final instance = MqttService._();

  MqttServerClient? _client;

  final _statusController =
      StreamController<MqttConnectionStatus>.broadcast();
  final _messageController = StreamController<MqttMessage>.broadcast();

  Stream<MqttConnectionStatus> get statusStream => _statusController.stream;
  Stream<MqttMessage> get messageStream => _messageController.stream;

  MqttConnectionStatus _status = MqttConnectionStatus.disconnected;
  MqttConnectionStatus get status => _status;

  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;

  String? _host;
  int? _port;
  String? _clientId;
  String? _user;
  String? _password;

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<void> connect({
    required String host,
    required int port,
    required String clientId,
    String? user,
    String? password,
  }) async {
    _host = host;
    _port = port;
    _clientId = clientId;
    _user = user;
    _password = password;
    _intentionalDisconnect = false;

    await _doConnect();
  }

  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _client = null;
    _setStatus(MqttConnectionStatus.disconnected);
  }

  void publish(String topic, String payload) {
    if (_client == null ||
        _client!.connectionStatus!.state != MqttConnectionState.connected) {
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void subscribe(String topic) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<void> _doConnect() async {
    _reconnectTimer?.cancel();
    _setStatus(MqttConnectionStatus.connecting);

    final host = _host!;
    final port = _port!;
    final clientId = _clientId!;

    _client = MqttServerClient.withPort(host, clientId, port)
      ..logging(on: kDebugMode)
      ..keepAlivePeriod = 30
      ..connectTimeoutPeriod = 8000
      ..autoReconnect = false
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = (_) {}
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .withWillQos(MqttQos.atLeastOnce)
          .startClean();

    if (_user != null && _user!.isNotEmpty) {
      _client!.connectionMessage =
          _client!.connectionMessage!.authenticateAs(_user!, _password ?? '');
    }

    try {
      await _client!.connect();
    } on NoConnectionException catch (e) {
      debugPrint('MQTT NoConnectionException: $e');
      _setStatus(MqttConnectionStatus.error);
      _scheduleReconnect();
      return;
    } on SocketException catch (e) {
      debugPrint('MQTT SocketException: $e');
      _setStatus(MqttConnectionStatus.error);
      _scheduleReconnect();
      return;
    } catch (e) {
      debugPrint('MQTT connect error: $e');
      _setStatus(MqttConnectionStatus.error);
      _scheduleReconnect();
      return;
    }

    if (_client!.connectionStatus!.state != MqttConnectionState.connected) {
      debugPrint('MQTT bağlanamadı: ${_client!.connectionStatus}');
      _setStatus(MqttConnectionStatus.error);
      _scheduleReconnect();
      return;
    }

    // Gelen mesajları dinle
    _client!.updates!.listen((events) {
      for (final event in events) {
        final recMsg = event.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
            recMsg.payload.message);
        _messageController.add(MqttMessage(
          topic: event.topic,
          payload: payload,
        ));
      }
    });
  }

  void _onConnected() {
    debugPrint('MQTT bağlandı: $_host:$_port');
    _setStatus(MqttConnectionStatus.connected);
  }

  void _onDisconnected() {
    debugPrint('MQTT bağlantısı kesildi');
    _setStatus(MqttConnectionStatus.disconnected);
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_intentionalDisconnect) {
        debugPrint('MQTT yeniden bağlanıyor...');
        _doConnect();
      }
    });
  }

  void _setStatus(MqttConnectionStatus s) {
    _status = s;
    _statusController.add(s);
  }
}
