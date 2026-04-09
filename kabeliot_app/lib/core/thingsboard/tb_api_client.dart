import 'package:dio/dio.dart';
import 'tb_models.dart';

/// ThingsBoard REST API client.
/// Holds a Dio instance configured with the base URL and JWT token.
class TbApiClient {
  TbApiClient({required String baseUrl, String? jwtToken})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (jwtToken != null) 'X-Authorization': 'Bearer $jwtToken',
          },
        ));

  final Dio _dio;

  // ── Auth ─────────────────────────────────────────────────────────────────

  /// Returns JWT token string.
  Future<String> login(String email, String password) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'username': email, 'password': password},
    );
    return resp.data!['token'] as String;
  }

  // ── Devices ──────────────────────────────────────────────────────────────

  Future<TbDevice> createDevice(String name, {String type = 'default'}) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/device',
      data: {'name': name, 'type': type},
    );
    return TbDevice.fromJson(resp.data!);
  }

  Future<TbCredentials> getDeviceCredentials(String deviceId) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/device/$deviceId/credentials',
    );
    return TbCredentials.fromJson(resp.data!);
  }

  // ── Telemetry ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getLatestTelemetry(
    String deviceId,
    List<String> keys,
  ) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/plugins/telemetry/DEVICE/$deviceId/values/timeseries',
      queryParameters: {'keys': keys.join(',')},
    );
    return resp.data ?? {};
  }

  // ── RPC ───────────────────────────────────────────────────────────────────

  /// One-way RPC — fire and forget.
  Future<void> sendRpc(
    String deviceId,
    String method,
    Map<String, dynamic> params,
  ) async {
    await _dio.post<void>(
      '/api/plugins/rpc/oneway/$deviceId',
      data: {'method': method, 'params': params},
    );
  }
}
