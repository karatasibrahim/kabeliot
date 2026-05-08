// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tbAuthHash() => r'bbb6cae0faab114e76516d1b0f3fcdb8ae11c5b7';

/// ThingsBoard JWT tokenını Firestore settings koleksiyonundan okur.
/// Token yönetimi backend tarafında yapılır — uygulama sadece okur.
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
