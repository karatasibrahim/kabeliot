import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'tb_api_client.dart';
import 'tb_settings_provider.dart';

part 'tb_auth_provider.g.dart';

/// Holds the current ThingsBoard JWT token, or null if not logged in.
@Riverpod(keepAlive: true)
class TbAuth extends _$TbAuth {
  Timer? _refreshTimer;

  @override
  Future<String?> build() async {
    ref.onDispose(() => _refreshTimer?.cancel());
    return _login();
  }

  Future<String?> _login() async {
    final settingsAsync = ref.read(tbSettingsNotifierProvider);
    final settings = settingsAsync.valueOrNull;
    if (settings == null || !settings.isConfigured) return null;

    try {
      final client = TbApiClient(baseUrl: settings.baseUrl);
      final token = await client.login(settings.email, settings.password);
      _scheduleRefresh(settings);
      return token;
    } catch (e) {
      debugPrint('[TbAuth] login failed: $e');
      return null;
    }
  }

  void _scheduleRefresh(TbSettings settings) {
    _refreshTimer?.cancel();
    // TB JWT expires in 2.5 h — refresh every 2 hours
    _refreshTimer = Timer(const Duration(hours: 2), () async {
      try {
        final client = TbApiClient(baseUrl: settings.baseUrl);
        final token = await client.login(settings.email, settings.password);
        state = AsyncData(token);
        _scheduleRefresh(settings);
      } catch (e) {
        debugPrint('[TbAuth] refresh failed: $e');
      }
    });
  }

  /// Force a fresh login (e.g. after settings change).
  Future<void> reconnect() async {
    _refreshTimer?.cancel();
    state = const AsyncLoading();
    state = AsyncData(await _login());
  }

  /// Returns a [TbApiClient] configured with the current JWT, or null.
  TbApiClient? apiClient() {
    final settings = ref.read(tbSettingsNotifierProvider).valueOrNull;
    final token = state.valueOrNull;
    if (settings == null || token == null) return null;
    return TbApiClient(baseUrl: settings.baseUrl, jwtToken: token);
  }
}
