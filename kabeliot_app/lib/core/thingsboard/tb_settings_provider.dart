import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'tb_settings_provider.g.dart';

const _kHost     = 'tb_host';
const _kPort     = 'tb_port';
const _kEmail    = 'tb_email';
const _kPassword = 'tb_password';

const tbDefaultHost = 'smartio.kabelteknoloji.com';
const tbDefaultPort = 8080;

class TbSettings {
  const TbSettings({
    this.host     = tbDefaultHost,
    this.port     = tbDefaultPort,
    this.email    = '',
    this.password = '',
  });

  final String host;
  final int port;
  final String email;
  final String password;

  String get baseUrl => 'http://$host:$port';

  bool get isConfigured => email.isNotEmpty && password.isNotEmpty;

  TbSettings copyWith({
    String? host,
    int? port,
    String? email,
    String? password,
  }) =>
      TbSettings(
        host:     host     ?? this.host,
        port:     port     ?? this.port,
        email:    email    ?? this.email,
        password: password ?? this.password,
      );
}

@Riverpod(keepAlive: true)
class TbSettingsNotifier extends _$TbSettingsNotifier {
  @override
  Future<TbSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return TbSettings(
      host:     prefs.getString(_kHost)     ?? tbDefaultHost,
      port:     prefs.getInt(_kPort)        ?? tbDefaultPort,
      email:    prefs.getString(_kEmail)    ?? '',
      password: prefs.getString(_kPassword) ?? '',
    );
  }

  Future<void> save({
    required String host,
    required int port,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHost,     host);
    await prefs.setInt(_kPort,        port);
    await prefs.setString(_kEmail,    email);
    await prefs.setString(_kPassword, password);
    state = AsyncData(TbSettings(host: host, port: port, email: email, password: password));
  }
}
