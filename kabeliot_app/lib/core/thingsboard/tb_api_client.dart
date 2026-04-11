import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'tb_models.dart';

class DeviceAlreadyExistsException implements Exception {
  @override
  String toString() =>
      'Bu cihaz daha önce kayıt edilmiştir. Lütfen yönetici ile görüşünüz.';
}

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
        )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (o) => debugPrint('[TbApi] $o'),
    ));
  }

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

  // ── Customers ────────────────────────────────────────────────────────────

  /// Tüm customer'ları çekip [email] ile eşleşeni bulur.
  /// Eşleşen yoksa null döner.
  Future<String?> getCustomerIdByEmail(String email) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/customers',
      queryParameters: {'pageSize': 100, 'page': 0},
    );
    final data = resp.data?['data'] as List<dynamic>? ?? [];
    for (final c in data) {
      if ((c['email'] as String?) == email) {
        return (c['id'] as Map<String, dynamic>)['id'] as String;
      }
    }
    return null;
  }

  /// Customer'ın kullanıcı listesinden ilk kullanıcı ID'sini döner.
  Future<String?> getCustomerUserId(String customerId) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/customer/$customerId/users',
      queryParameters: {'pageSize': 10, 'page': 0},
    );
    final data = resp.data?['data'] as List<dynamic>? ?? [];
    if (data.isEmpty) return null;
    return (data.first['id'] as Map<String, dynamic>)['id'] as String;
  }

  /// Tenant admin yetkisiyle bir kullanıcının JWT tokenını alır.
  Future<String?> getUserToken(String userId) async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/user/$userId/token');
    return resp.data?['token'] as String?;
  }

  // ── Devices ──────────────────────────────────────────────────────────────

  /// [customerId] verilirse cihaz ilgili customer'a atanır.
  Future<TbDevice> createDevice(
    String name, {
    String type = 'default',
    String? customerId,
  }) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        '/api/device',
        data: {
          'name': name,
          'type': type,
          if (customerId != null)
            'customerId': {'id': customerId, 'entityType': 'CUSTOMER'},
        },
      );
      return TbDevice.fromJson(resp.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw DeviceAlreadyExistsException();
      }
      rethrow;
    }
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
