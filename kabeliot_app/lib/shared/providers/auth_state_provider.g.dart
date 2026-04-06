// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'0cfa592a5347aae639ad37df84d98ba541974091';

/// Global oturum durumu.
/// true = giriş yapılmış, false = misafir
///
/// Copied from [AuthState].
@ProviderFor(AuthState)
final authStateProvider = NotifierProvider<AuthState, bool>.internal(
  AuthState.new,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthState = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
