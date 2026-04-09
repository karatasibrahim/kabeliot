// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tbAuthHash() => r'1c64f4f351454a95f764584f0a451bd303523ef8';

/// Holds the current ThingsBoard JWT token, or null if not logged in.
///
/// Copied from [TbAuth].
@ProviderFor(TbAuth)
final tbAuthProvider = AsyncNotifierProvider<TbAuth, String?>.internal(
  TbAuth.new,
  name: r'tbAuthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tbAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TbAuth = AsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
