import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'mqtt_service.dart';
import 'mqtt_providers.dart';

part 'notification_provider.g.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

enum NotifType { deviceOnline, deviceOffline, sensorAlert, relayChange, info }

class AppNotification {
  AppNotification({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String deviceId;
  final String deviceName;
  final String title;
  final String body;
  final NotifType type;
  final DateTime timestamp;
  bool isRead;

  IconData get icon => switch (type) {
        NotifType.deviceOnline => Icons.wifi_rounded,
        NotifType.deviceOffline => Icons.wifi_off_rounded,
        NotifType.sensorAlert => Icons.thermostat_rounded,
        NotifType.relayChange => Icons.toggle_on_rounded,
        NotifType.info => Icons.info_rounded,
      };

  Color get color => switch (type) {
        NotifType.deviceOnline => const Color(0xFF10B981),
        NotifType.deviceOffline => const Color(0xFFEF4444),
        NotifType.sensorAlert => const Color(0xFFF59E0B),
        NotifType.relayChange => const Color(0xFF06B6D4),
        NotifType.info => const Color(0xFF6366F1),
      };

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        deviceId: deviceId,
        deviceName: deviceName,
        title: title,
        body: body,
        type: type,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
      );
}

// ─── Provider ────────────────────────────────────────────────────────────────

const _maxNotifications = 50;

@Riverpod(keepAlive: true)
class MqttNotifications extends _$MqttNotifications {
  StreamSubscription<MqttMessage>? _sub;

  @override
  List<AppNotification> build() {
    final connStatus = ref.watch(mqttConnectionProvider);

    if (connStatus == MqttConnectionStatus.connected) {
      _startListening();
    } else {
      _sub?.cancel();
    }

    ref.onDispose(() => _sub?.cancel());

    return _seedNotifications();
  }

  void _startListening() {
    _sub?.cancel();
    _sub = MqttService.instance.messageStream.listen(_handleMessage);
  }

  void _handleMessage(MqttMessage msg) {
    final parts = msg.topic.split('/');
    if (parts.length < 3) return;

    // kb/{deviceId}/status
    if (parts.length == 3 && parts[2] == 'status') {
      final deviceId = parts[1];
      final isOnline = msg.payload.trim().toLowerCase() == 'online';
      _addNotification(AppNotification(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        deviceId: deviceId,
        deviceName: deviceId,
        title: isOnline ? '$deviceId bağlandı' : '$deviceId bağlantısı kesildi',
        body: isOnline
            ? 'Cihaz MQTT sunucusuna başarıyla bağlandı.'
            : 'Cihaz yanıt vermiyor.',
        type: isOnline ? NotifType.deviceOnline : NotifType.deviceOffline,
        timestamp: DateTime.now(),
      ));
    }

    // kb/{deviceId}/relay/{index}/state
    if (parts.length == 5 && parts[2] == 'relay' && parts[4] == 'state') {
      final deviceId = parts[1];
      final relayIndex = int.tryParse(parts[3]) ?? 0;
      final isOn = msg.payload.trim() == '1';
      _addNotification(AppNotification(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        deviceId: deviceId,
        deviceName: deviceId,
        title: 'Röle ${relayIndex + 1} ${isOn ? 'açıldı' : 'kapandı'}',
        body: '$deviceId üzerindeki Röle-${relayIndex + 1} ${isOn ? 'tetiklendi' : 'devre dışı bırakıldı'}.',
        type: NotifType.relayChange,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _addNotification(AppNotification notif) {
    final updated = [notif, ...state];
    state = updated.length > _maxNotifications
        ? updated.sublist(0, _maxNotifications)
        : updated;
  }

  void markRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  /// Broker bağlı değilken gösterilecek başlangıç verileri
  static List<AppNotification> _seedNotifications() => [
        AppNotification(
          id: 'seed_0',
          deviceId: 'KB-001-A2F3',
          deviceName: 'PCB-Kontrol-001',
          title: 'PCB-Kontrol-001 bağlandı',
          body: 'Cihaz MQTT sunucusuna başarıyla bağlandı.',
          type: NotifType.deviceOnline,
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        ),
        AppNotification(
          id: 'seed_1',
          deviceId: 'KB-002-B1E9',
          deviceName: 'Sensör-Node-02',
          title: 'Sıcaklık Uyarısı',
          body: 'Sensör-Node-02: Sıcaklık 42°C sınırını aştı.',
          type: NotifType.sensorAlert,
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        AppNotification(
          id: 'seed_2',
          deviceId: 'KB-003-C7D1',
          deviceName: 'Gateway-Ana',
          title: 'Gateway-Ana bağlantısı kesildi',
          body: 'Cihaz 5 dakikadır yanıt vermiyor.',
          type: NotifType.deviceOffline,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        ),
        AppNotification(
          id: 'seed_3',
          deviceId: 'KB-004-D4F8',
          deviceName: 'PCB-Motor-04',
          title: 'Röle-01 açıldı',
          body: 'PCB-Motor-04 üzerindeki Röle-01 tetiklendi.',
          type: NotifType.relayChange,
          timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 5)),
        ),
        AppNotification(
          id: 'seed_4',
          deviceId: 'KB-005-E2A1',
          deviceName: 'Sensör-Node-05',
          title: 'Düşük Güç',
          body: "Sensör-Node-05 pil seviyesi %15'e düştü.",
          type: NotifType.sensorAlert,
          timestamp: DateTime.now().subtract(const Duration(hours: 9, minutes: 40)),
        ),
      ];
}
