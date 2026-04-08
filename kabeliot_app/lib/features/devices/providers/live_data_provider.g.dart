// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$liveSensorDataHash() => r'2c5cf8ac96437342a4b7a7ac83887f76456235b8';

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

abstract class _$LiveSensorData
    extends BuildlessAutoDisposeNotifier<List<double>> {
  late final String deviceId;
  late final int sensorIndex;

  List<double> build(String deviceId, int sensorIndex);
}

/// Belirli bir sensörün son 60 değeri — Firestore snapshot'larından beslenir.
///
/// Copied from [LiveSensorData].
@ProviderFor(LiveSensorData)
const liveSensorDataProvider = LiveSensorDataFamily();

/// Belirli bir sensörün son 60 değeri — Firestore snapshot'larından beslenir.
///
/// Copied from [LiveSensorData].
class LiveSensorDataFamily extends Family<List<double>> {
  /// Belirli bir sensörün son 60 değeri — Firestore snapshot'larından beslenir.
  ///
  /// Copied from [LiveSensorData].
  const LiveSensorDataFamily();

  /// Belirli bir sensörün son 60 değeri — Firestore snapshot'larından beslenir.
  ///
  /// Copied from [LiveSensorData].
  LiveSensorDataProvider call(String deviceId, int sensorIndex) {
    return LiveSensorDataProvider(deviceId, sensorIndex);
  }

  @override
  LiveSensorDataProvider getProviderOverride(
    covariant LiveSensorDataProvider provider,
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
  String? get name => r'liveSensorDataProvider';
}

/// Belirli bir sensörün son 60 değeri — Firestore snapshot'larından beslenir.
///
/// Copied from [LiveSensorData].
class LiveSensorDataProvider
    extends AutoDisposeNotifierProviderImpl<LiveSensorData, List<double>> {
  /// Belirli bir sensörün son 60 değeri — Firestore snapshot'larından beslenir.
  ///
  /// Copied from [LiveSensorData].
  LiveSensorDataProvider(String deviceId, int sensorIndex)
    : this._internal(
        () => LiveSensorData()
          ..deviceId = deviceId
          ..sensorIndex = sensorIndex,
        from: liveSensorDataProvider,
        name: r'liveSensorDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$liveSensorDataHash,
        dependencies: LiveSensorDataFamily._dependencies,
        allTransitiveDependencies:
            LiveSensorDataFamily._allTransitiveDependencies,
        deviceId: deviceId,
        sensorIndex: sensorIndex,
      );

  LiveSensorDataProvider._internal(
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
  List<double> runNotifierBuild(covariant LiveSensorData notifier) {
    return notifier.build(deviceId, sensorIndex);
  }

  @override
  Override overrideWith(LiveSensorData Function() create) {
    return ProviderOverride(
      origin: this,
      override: LiveSensorDataProvider._internal(
        () => create()
          ..deviceId = deviceId
          ..sensorIndex = sensorIndex,
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
  AutoDisposeNotifierProviderElement<LiveSensorData, List<double>>
  createElement() {
    return _LiveSensorDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveSensorDataProvider &&
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
mixin LiveSensorDataRef on AutoDisposeNotifierProviderRef<List<double>> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;

  /// The parameter `sensorIndex` of this provider.
  int get sensorIndex;
}

class _LiveSensorDataProviderElement
    extends AutoDisposeNotifierProviderElement<LiveSensorData, List<double>>
    with LiveSensorDataRef {
  _LiveSensorDataProviderElement(super.provider);

  @override
  String get deviceId => (origin as LiveSensorDataProvider).deviceId;
  @override
  int get sensorIndex => (origin as LiveSensorDataProvider).sensorIndex;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
