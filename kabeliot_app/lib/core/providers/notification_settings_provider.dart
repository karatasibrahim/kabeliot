import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_settings_provider.g.dart';

const _kDeviceOnline  = 'notif_device_online';
const _kDeviceOffline = 'notif_device_offline';
const _kSensorAlert   = 'notif_sensor_alert';
const _kRelayChange   = 'notif_relay_change';

class NotificationSettingsData {
  const NotificationSettingsData({
    this.deviceOnline  = true,
    this.deviceOffline = true,
    this.sensorAlert   = true,
    this.relayChange   = false,
  });

  final bool deviceOnline;
  final bool deviceOffline;
  final bool sensorAlert;
  final bool relayChange;

  NotificationSettingsData copyWith({
    bool? deviceOnline,
    bool? deviceOffline,
    bool? sensorAlert,
    bool? relayChange,
  }) =>
      NotificationSettingsData(
        deviceOnline:  deviceOnline  ?? this.deviceOnline,
        deviceOffline: deviceOffline ?? this.deviceOffline,
        sensorAlert:   sensorAlert   ?? this.sensorAlert,
        relayChange:   relayChange   ?? this.relayChange,
      );
}

@Riverpod(keepAlive: true)
class NotificationSettings extends _$NotificationSettings {
  @override
  Future<NotificationSettingsData> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettingsData(
      deviceOnline:  prefs.getBool(_kDeviceOnline)  ?? true,
      deviceOffline: prefs.getBool(_kDeviceOffline) ?? true,
      sensorAlert:   prefs.getBool(_kSensorAlert)   ?? true,
      relayChange:   prefs.getBool(_kRelayChange)   ?? false,
    );
  }

  Future<void> toggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    final current = state.valueOrNull ?? const NotificationSettingsData();
    state = AsyncData(switch (key) {
      _kDeviceOnline  => current.copyWith(deviceOnline:  value),
      _kDeviceOffline => current.copyWith(deviceOffline: value),
      _kSensorAlert   => current.copyWith(sensorAlert:   value),
      _kRelayChange   => current.copyWith(relayChange:   value),
      _                => current,
    });
  }

  static const keyDeviceOnline  = _kDeviceOnline;
  static const keyDeviceOffline = _kDeviceOffline;
  static const keySensorAlert   = _kSensorAlert;
  static const keyRelayChange   = _kRelayChange;
}
