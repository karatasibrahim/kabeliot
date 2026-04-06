import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_provider.g.dart';

/// Global oturum durumu.
/// true = giriş yapılmış, false = misafir
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  bool build() => false;

  void setAuthenticated(bool value) => state = value;

  void logout() => state = false;
}
