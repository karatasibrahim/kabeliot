import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'tb_api_client.dart';

part 'tb_auth_provider.g.dart';

const tbBaseUrl = 'http://smartio.kabelteknoloji.com:8080';

/// ThingsBoard JWT tokenını Firestore settings koleksiyonundan okur.
/// Token yönetimi backend tarafında yapılır — uygulama sadece okur.
@Riverpod(keepAlive: true)
class TbAuth extends _$TbAuth {
  @override
  Future<String?> build() async {
    return _fetchToken();
  }

  Future<String?> _fetchToken() async {
    // settings/thingsboard dokümanından TB tenant credentials oku
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('thingsboard')
        .get();

    if (!doc.exists) {
      throw Exception('Firestore settings/thingsboard dokümanı bulunamadı.');
    }

    final email    = doc.data()?['email']    as String?;
    final password = doc.data()?['password'] as String?;

    if (email == null || password == null) {
      throw Exception(
        'settings/thingsboard dokümanında email veya password alanı eksik.',
      );
    }

    debugPrint('[TbAuth] TB login: $email');
    // TB'ye giriş yap → taze JWT al
    final client = TbApiClient(baseUrl: tbBaseUrl);
    return await client.login(email, password);
  }

  /// Firestore'dan tokeni yeniden çek.
  Future<void> reconnect() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchToken());
  }

  /// Mevcut JWT ile yapılandırılmış [TbApiClient] döner. Token yoksa null.
  TbApiClient? apiClient() {
    final token = state.valueOrNull;
    if (token == null) return null;
    return TbApiClient(baseUrl: tbBaseUrl, jwtToken: token);
  }
}
