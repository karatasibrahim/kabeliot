// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sensorConfigsHash() => r'6526fbbff8d72132d5f7b6e10dd9c803ee38c093';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SensorConfigs
    extends BuildlessAutoDisposeAsyncNotifier<List<SensorConfig>> {
  late final String deviceId;
  late final int sensorCount;

  FutureOr<List<SensorConfig>> build(String deviceId, int sensorCount);
}

/// Belirli bir cihazın tüm sensörlerinin kullanıcı yapılandırmaları
///
/// Copied from [SensorConfigs].
@ProviderFor(SensorConfigs)
const sensorConfigsProvider = SensorConfigsFamily();

/// Belirli bir cihazın tüm sensörlerinin kullanıcı yapılandırmaları
///
/// Copied from [SensorConfigs].
class SensorConfigsFamily extends Family<AsyncValue<List<SensorConfig>>> {
  /// Belirli bir cihazın tüm sensörlerinin kullanıcı yapılandırmaları
  ///
  /// Copied from [SensorConfigs].
  const SensorConfigsFamily();

  /// Belirli bir cihazın tüm sensörlerinin kullanıcı yapılandırmaları
  ///
  /// Copied from [SensorConfigs].
  SensorConfigsProvider call(String deviceId, int sensorCount) {
    return SensorConfigsProvider(deviceId, sensorCount);
  }

  @override
  SensorConfigsProvider getProviderOverride(
    covariant SensorConfigsProvider provider,
  ) {
    return call(provider.deviceId, provider.sensorCount);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sensorConfigsProvider';
}

/// Belirli bir cihazın tüm sensörlerinin kullanıcı yapılandırmaları
///
/// Copied from [SensorConfigs].
class SensorConfigsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          SensorConfigs,
          List<SensorConfig>
        > {
  /// Belirli bir cihazın tüm sensörlerinin kullanıcı yapılandırmaları
  ///
  /// Copied from [SensorConfigs].
  SensorConfigsProvider(String deviceId, int sensorCount)
    : this._internal(
        () => SensorConfigs()
          ..deviceId = deviceId
          ..sensorCount = sensorCount,
        from: sensorConfigsProvider,
        name: r'sensorConfigsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sensorConfigsHash,
        dependencies: SensorConfigsFamily._dependencies,
        allTransitiveDependencies:
            SensorConfigsFamily._allTransitiveDependencies,
        deviceId: deviceId,
        sensorCount: sensorCount,
      );

  SensorConfigsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deviceId,
    required this.sensorCount,
  }) : super.internal();

  final String deviceId;
  final int sensorCount;

  @override
  FutureOr<List<SensorConfig>> runNotifierBuild(
    covariant SensorConfigs notifier,
  ) {
    return notifier.build(deviceId, sensorCount);
  }

  @override
  Override overrideWith(SensorConfigs Function() create) {
    return ProviderOverride(
      origin: this,
      override: SensorConfigsProvider._internal(
        () => create()
          ..deviceId = deviceId
          ..sensorCount = sensorCount,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deviceId: deviceId,
        sensorCount: sensorCount,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SensorConfigs, List<SensorConfig>>
  createElement() {
    return _SensorConfigsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SensorConfigsProvider &&
        other.deviceId == deviceId &&
        other.sensorCount == sensorCount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);
    hash = _SystemHash.combine(hash, sensorCount.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SensorConfigsRef
    on AutoDisposeAsyncNotifierProviderRef<List<SensorConfig>> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;

  /// The parameter `sensorCount` of this provider.
  int get sensorCount;
}

class _SensorConfigsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          SensorConfigs,
          List<SensorConfig>
        >
    with SensorConfigsRef {
  _SensorConfigsProviderElement(super.provider);

  @override
  String get deviceId => (origin as SensorConfigsProvider).deviceId;
  @override
  int get sensorCount => (origin as SensorConfigsProvider).sensorCount;
}

String _$relayStatesHash() => r'686041db6f035994e46b7624cf4bff30dd6d8ed8';

abstract class _$RelayStates
    extends BuildlessAutoDisposeNotifier<List<RelayConfig>> {
  late final String deviceId;
  late final int relayCount;

  List<RelayConfig> build(String deviceId, int relayCount);
}

/// Röle durumları — toggle MQTT'ye publish eder, optimistic local güncelleme yapar
///
/// Copied from [RelayStates].
@ProviderFor(RelayStates)
const relayStatesProvider = RelayStatesFamily();

/// Röle durumları — toggle MQTT'ye publish eder, optimistic local güncelleme yapar
///
/// Copied from [RelayStates].
class RelayStatesFamily extends Family<List<RelayConfig>> {
  /// Röle durumları — toggle MQTT'ye publish eder, optimistic local güncelleme yapar
  ///
  /// Copied from [RelayStates].
  const RelayStatesFamily();

  /// Röle durumları — toggle MQTT'ye publish eder, optimistic local güncelleme yapar
  ///
  /// Copied from [RelayStates].
  RelayStatesProvider call(String deviceId, int relayCount) {
    return RelayStatesProvider(deviceId, relayCount);
  }

  @override
  RelayStatesProvider getProviderOverride(
    covariant RelayStatesProvider provider,
  ) {
    return call(provider.deviceId, provider.relayCount);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'relayStatesProvider';
}

/// Röle durumları — toggle MQTT'ye publish eder, optimistic local güncelleme yapar
///
/// Copied from [RelayStates].
class RelayStatesProvider
    extends AutoDisposeNotifierProviderImpl<RelayStates, List<RelayConfig>> {
  /// Röle durumları — toggle MQTT'ye publish eder, optimistic local güncelleme yapar
  ///
  /// Copied from [RelayStates].
  RelayStatesProvider(String deviceId, int relayCount)
    : this._internal(
        () => RelayStates()
          ..deviceId = deviceId
          ..relayCount = relayCount,
        from: relayStatesProvider,
        name: r'relayStatesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$relayStatesHash,
        dependencies: RelayStatesFamily._dependencies,
        allTransitiveDependencies: RelayStatesFamily._allTransitiveDependencies,
        deviceId: deviceId,
        relayCount: relayCount,
      );

  RelayStatesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deviceId,
    required this.relayCount,
  }) : super.internal();

  final String deviceId;
  final int relayCount;

  @override
  List<RelayConfig> runNotifierBuild(covariant RelayStates notifier) {
    return notifier.build(deviceId, relayCount);
  }

  @override
  Override overrideWith(RelayStates Function() create) {
    return ProviderOverride(
      origin: this,
      override: RelayStatesProvider._internal(
        () => create()
          ..deviceId = deviceId
          ..relayCount = relayCount,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deviceId: deviceId,
        relayCount: relayCount,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<RelayStates, List<RelayConfig>>
  createElement() {
    return _RelayStatesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RelayStatesProvider &&
        other.deviceId == deviceId &&
        other.relayCount == relayCount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);
    hash = _SystemHash.combine(hash, relayCount.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RelayStatesRef on AutoDisposeNotifierProviderRef<List<RelayConfig>> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;

  /// The parameter `relayCount` of this provider.
  int get relayCount;
}

class _RelayStatesProviderElement
    extends AutoDisposeNotifierProviderElement<RelayStates, List<RelayConfig>>
    with RelayStatesRef {
  _RelayStatesProviderElement(super.provider);

  @override
  String get deviceId => (origin as RelayStatesProvider).deviceId;
  @override
  int get relayCount => (origin as RelayStatesProvider).relayCount;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
