// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceOnlineStatusHash() =>
    r'16f43f1c144bded910128eb4e894dbba972c9a82';

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

/// Belirli bir cihazın MQTT LWT durumu.
/// Broker bağlı değilse — mock listesindeki `isOnline` değeri döner.
///
/// Copied from [deviceOnlineStatus].
@ProviderFor(deviceOnlineStatus)
const deviceOnlineStatusProvider = DeviceOnlineStatusFamily();

/// Belirli bir cihazın MQTT LWT durumu.
/// Broker bağlı değilse — mock listesindeki `isOnline` değeri döner.
///
/// Copied from [deviceOnlineStatus].
class DeviceOnlineStatusFamily extends Family<AsyncValue<bool>> {
  /// Belirli bir cihazın MQTT LWT durumu.
  /// Broker bağlı değilse — mock listesindeki `isOnline` değeri döner.
  ///
  /// Copied from [deviceOnlineStatus].
  const DeviceOnlineStatusFamily();

  /// Belirli bir cihazın MQTT LWT durumu.
  /// Broker bağlı değilse — mock listesindeki `isOnline` değeri döner.
  ///
  /// Copied from [deviceOnlineStatus].
  DeviceOnlineStatusProvider call(String deviceId) {
    return DeviceOnlineStatusProvider(deviceId);
  }

  @override
  DeviceOnlineStatusProvider getProviderOverride(
    covariant DeviceOnlineStatusProvider provider,
  ) {
    return call(provider.deviceId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deviceOnlineStatusProvider';
}

/// Belirli bir cihazın MQTT LWT durumu.
/// Broker bağlı değilse — mock listesindeki `isOnline` değeri döner.
///
/// Copied from [deviceOnlineStatus].
class DeviceOnlineStatusProvider extends AutoDisposeStreamProvider<bool> {
  /// Belirli bir cihazın MQTT LWT durumu.
  /// Broker bağlı değilse — mock listesindeki `isOnline` değeri döner.
  ///
  /// Copied from [deviceOnlineStatus].
  DeviceOnlineStatusProvider(String deviceId)
    : this._internal(
        (ref) => deviceOnlineStatus(ref as DeviceOnlineStatusRef, deviceId),
        from: deviceOnlineStatusProvider,
        name: r'deviceOnlineStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deviceOnlineStatusHash,
        dependencies: DeviceOnlineStatusFamily._dependencies,
        allTransitiveDependencies:
            DeviceOnlineStatusFamily._allTransitiveDependencies,
        deviceId: deviceId,
      );

  DeviceOnlineStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deviceId,
  }) : super.internal();

  final String deviceId;

  @override
  Override overrideWith(
    Stream<bool> Function(DeviceOnlineStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeviceOnlineStatusProvider._internal(
        (ref) => create(ref as DeviceOnlineStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deviceId: deviceId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _DeviceOnlineStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceOnlineStatusProvider && other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeviceOnlineStatusRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _DeviceOnlineStatusProviderElement
    extends AutoDisposeStreamProviderElement<bool>
    with DeviceOnlineStatusRef {
  _DeviceOnlineStatusProviderElement(super.provider);

  @override
  String get deviceId => (origin as DeviceOnlineStatusProvider).deviceId;
}

String _$sensorValueStreamHash() => r'b36317a60a865ab3a0020c5f6ba5a73ca1c8c7bd';

/// Belirli bir sensörün anlık değer stream'i.
/// MQTT bağlıysa gerçek veri, değilse simülasyon.
///
/// Copied from [sensorValueStream].
@ProviderFor(sensorValueStream)
const sensorValueStreamProvider = SensorValueStreamFamily();

/// Belirli bir sensörün anlık değer stream'i.
/// MQTT bağlıysa gerçek veri, değilse simülasyon.
///
/// Copied from [sensorValueStream].
class SensorValueStreamFamily extends Family<AsyncValue<double>> {
  /// Belirli bir sensörün anlık değer stream'i.
  /// MQTT bağlıysa gerçek veri, değilse simülasyon.
  ///
  /// Copied from [sensorValueStream].
  const SensorValueStreamFamily();

  /// Belirli bir sensörün anlık değer stream'i.
  /// MQTT bağlıysa gerçek veri, değilse simülasyon.
  ///
  /// Copied from [sensorValueStream].
  SensorValueStreamProvider call(String deviceId, int sensorIndex) {
    return SensorValueStreamProvider(deviceId, sensorIndex);
  }

  @override
  SensorValueStreamProvider getProviderOverride(
    covariant SensorValueStreamProvider provider,
  ) {
    return call(provider.deviceId, provider.sensorIndex);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sensorValueStreamProvider';
}

/// Belirli bir sensörün anlık değer stream'i.
/// MQTT bağlıysa gerçek veri, değilse simülasyon.
///
/// Copied from [sensorValueStream].
class SensorValueStreamProvider extends AutoDisposeStreamProvider<double> {
  /// Belirli bir sensörün anlık değer stream'i.
  /// MQTT bağlıysa gerçek veri, değilse simülasyon.
  ///
  /// Copied from [sensorValueStream].
  SensorValueStreamProvider(String deviceId, int sensorIndex)
    : this._internal(
        (ref) => sensorValueStream(
          ref as SensorValueStreamRef,
          deviceId,
          sensorIndex,
        ),
        from: sensorValueStreamProvider,
        name: r'sensorValueStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sensorValueStreamHash,
        dependencies: SensorValueStreamFamily._dependencies,
        allTransitiveDependencies:
            SensorValueStreamFamily._allTransitiveDependencies,
        deviceId: deviceId,
        sensorIndex: sensorIndex,
      );

  SensorValueStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deviceId,
    required this.sensorIndex,
  }) : super.internal();

  final String deviceId;
  final int sensorIndex;

  @override
  Override overrideWith(
    Stream<double> Function(SensorValueStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SensorValueStreamProvider._internal(
        (ref) => create(ref as SensorValueStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deviceId: deviceId,
        sensorIndex: sensorIndex,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<double> createElement() {
    return _SensorValueStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SensorValueStreamProvider &&
        other.deviceId == deviceId &&
        other.sensorIndex == sensorIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);
    hash = _SystemHash.combine(hash, sensorIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SensorValueStreamRef on AutoDisposeStreamProviderRef<double> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;

  /// The parameter `sensorIndex` of this provider.
  int get sensorIndex;
}

class _SensorValueStreamProviderElement
    extends AutoDisposeStreamProviderElement<double>
    with SensorValueStreamRef {
  _SensorValueStreamProviderElement(super.provider);

  @override
  String get deviceId => (origin as SensorValueStreamProvider).deviceId;
  @override
  int get sensorIndex => (origin as SensorValueStreamProvider).sensorIndex;
}

String _$relayStateStreamHash() => r'7b89a307a8f55711df3c1a7b6cfb0d71c49d0487';

/// Belirli bir rölenin durumu (MQTT veya local).
///
/// Copied from [relayStateStream].
@ProviderFor(relayStateStream)
const relayStateStreamProvider = RelayStateStreamFamily();

/// Belirli bir rölenin durumu (MQTT veya local).
///
/// Copied from [relayStateStream].
class RelayStateStreamFamily extends Family<AsyncValue<bool>> {
  /// Belirli bir rölenin durumu (MQTT veya local).
  ///
  /// Copied from [relayStateStream].
  const RelayStateStreamFamily();

  /// Belirli bir rölenin durumu (MQTT veya local).
  ///
  /// Copied from [relayStateStream].
  RelayStateStreamProvider call(String deviceId, int relayIndex) {
    return RelayStateStreamProvider(deviceId, relayIndex);
  }

  @override
  RelayStateStreamProvider getProviderOverride(
    covariant RelayStateStreamProvider provider,
  ) {
    return call(provider.deviceId, provider.relayIndex);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'relayStateStreamProvider';
}

/// Belirli bir rölenin durumu (MQTT veya local).
///
/// Copied from [relayStateStream].
class RelayStateStreamProvider extends AutoDisposeStreamProvider<bool> {
  /// Belirli bir rölenin durumu (MQTT veya local).
  ///
  /// Copied from [relayStateStream].
  RelayStateStreamProvider(String deviceId, int relayIndex)
    : this._internal(
        (ref) =>
            relayStateStream(ref as RelayStateStreamRef, deviceId, relayIndex),
        from: relayStateStreamProvider,
        name: r'relayStateStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$relayStateStreamHash,
        dependencies: RelayStateStreamFamily._dependencies,
        allTransitiveDependencies:
            RelayStateStreamFamily._allTransitiveDependencies,
        deviceId: deviceId,
        relayIndex: relayIndex,
      );

  RelayStateStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deviceId,
    required this.relayIndex,
  }) : super.internal();

  final String deviceId;
  final int relayIndex;

  @override
  Override overrideWith(
    Stream<bool> Function(RelayStateStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RelayStateStreamProvider._internal(
        (ref) => create(ref as RelayStateStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deviceId: deviceId,
        relayIndex: relayIndex,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _RelayStateStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RelayStateStreamProvider &&
        other.deviceId == deviceId &&
        other.relayIndex == relayIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);
    hash = _SystemHash.combine(hash, relayIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RelayStateStreamRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;

  /// The parameter `relayIndex` of this provider.
  int get relayIndex;
}

class _RelayStateStreamProviderElement
    extends AutoDisposeStreamProviderElement<bool>
    with RelayStateStreamRef {
  _RelayStateStreamProviderElement(super.provider);

  @override
  String get deviceId => (origin as RelayStateStreamProvider).deviceId;
  @override
  int get relayIndex => (origin as RelayStateStreamProvider).relayIndex;
}

String _$mqttConnectionHash() => r'd0316fe9e666f79f821831b8adf4e781bdf92f34';

/// See also [MqttConnection].
@ProviderFor(MqttConnection)
final mqttConnectionProvider =
    NotifierProvider<MqttConnection, MqttConnectionStatus>.internal(
      MqttConnection.new,
      name: r'mqttConnectionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mqttConnectionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MqttConnection = Notifier<MqttConnectionStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
