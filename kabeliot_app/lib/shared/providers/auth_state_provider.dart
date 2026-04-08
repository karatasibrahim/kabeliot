import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/firebase/auth_repository.dart';
import '../../core/firebase/company_repository.dart';

part 'auth_state_provider.g.dart';

/// Oturum bilgisi — null = giriş yapılmamış
class AuthSession {
  const AuthSession({
    required this.uid,
    required this.companyId,
    required this.email,
    required this.role,
  });

  final String uid;
  final String companyId;
  final String email;
  final String role; // admin / editor / viewer
}

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  final _authRepo = AuthRepository();
  final _companyRepo = CompanyRepository();

  @override
  AuthSession? build() {
    _restoreSession();
    return null;
  }

  /// Uygulama açılışında Firebase Auth'daki mevcut oturumu geri yükler.
  Future<void> _restoreSession() async {
    final user = _authRepo.currentUser;
    if (user == null) return;
    try {
      final result = await _companyRepo.findCompanyAndRole(user.uid);
      if (result == null) return;
      state = AuthSession(
        uid: user.uid,
        companyId: result.companyId,
        email: user.email ?? '',
        role: result.role,
      );
    } catch (_) {
      // Restore başarısız olursa sessizce geç — kullanıcı login ekranını görür
    }
  }

  Future<void> signIn(String email, String password) async {
    final credential = await _authRepo.signIn(email, password);
    final user = credential.user!;
    debugPrint('AUTH: uid=${user.uid}, looking up company...');
    final result = await _companyRepo.findCompanyAndRole(user.uid);
    debugPrint('AUTH: findCompanyAndRole result=$result');
    if (result == null) {
      await _authRepo.signOut();
      throw FirebaseAuthException(
        code: 'company-not-found',
        message: 'Hesabınız sisteme tanımlı değil.',
      );
    }
    state = AuthSession(
      uid: user.uid,
      companyId: result.companyId,
      email: user.email ?? email,
      role: result.role,
    );
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    state = null;
  }
}
