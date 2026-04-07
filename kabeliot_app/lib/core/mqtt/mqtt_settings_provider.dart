import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'mqtt_settings_provider.g.dart';

const _kHost = 'mqtt_host';
const _kPort = 'mqtt_port';
const _kUser = 'mqtt_user';
const _kPass = 'mqtt_pass';

class MqttSettingsData {
  const MqttSettingsData({
    this.host = 'mqtt.kabelteknoloji.com',
    this.port = 1883,
    this.user = '',
    this.password = '',
  });

  final String host;
  final int port;
  final String user;
  final String password;

  MqttSettingsData copyWith({
    String? host,
    int? port,
    String? user,
    String? password,
  }) =>
      MqttSettingsData(
        host: host ?? this.host,
        port: port ?? this.port,
        user: user ?? this.user,
        password: password ?? this.password,
      );
}

@Riverpod(keepAlive: true)
class MqttSettings extends _$MqttSettings {
  @override
  Future<MqttSettingsData> build() async {
    final prefs = await SharedPreferences.getInstance();
    return MqttSettingsData(
      host: prefs.getString(_kHost) ?? 'mqtt.kabelteknoloji.com',
      port: prefs.getInt(_kPort) ?? 1883,
      user: prefs.getString(_kUser) ?? '',
      password: prefs.getString(_kPass) ?? '',
    );
  }

  Future<void> save({
    required String host,
    required int port,
    required String user,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHost, host);
    await prefs.setInt(_kPort, port);
    await prefs.setString(_kUser, user);
    await prefs.setString(_kPass, password);
    state = AsyncData(MqttSettingsData(
      host: host,
      port: port,
      user: user,
      password: password,
    ));
  }
}
