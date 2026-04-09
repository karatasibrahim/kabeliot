// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_websocket_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tbWebSocketServiceHash() =>
    r'b9d3fd4edb284255b7b60dd83ae359112a218fe0';

/// Manages a single persistent WebSocket connection to ThingsBoard.
/// Each subscription gets a unique cmdId so multiple providers can share one socket.
///
/// Copied from [tbWebSocketService].
@ProviderFor(tbWebSocketService)
final tbWebSocketServiceProvider = Provider<TbWebSocketService>.internal(
  tbWebSocketService,
  name: r'tbWebSocketServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tbWebSocketServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TbWebSocketServiceRef = ProviderRef<TbWebSocketService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
