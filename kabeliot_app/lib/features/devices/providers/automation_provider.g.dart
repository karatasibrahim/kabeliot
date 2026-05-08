// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$automationRulesHash() => r'1ca067ff9901556e3c10c8b92fc4ec374a28d248';

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

abstract class _$AutomationRules
    extends BuildlessAutoDisposeNotifier<List<AutomationRule>> {
  late final String deviceId;

  List<AutomationRule> build(String deviceId);
}

/// See also [AutomationRules].
@ProviderFor(AutomationRules)
const automationRulesProvider = AutomationRulesFamily();

/// See also [AutomationRules].
class AutomationRulesFamily extends Family<List<AutomationRule>> {
  /// See also [AutomationRules].
  const AutomationRulesFamily();

  /// See also [AutomationRules].
  AutomationRulesProvider call(String deviceId) {
    return AutomationRulesProvider(deviceId);
  }

  @override
  AutomationRulesProvider getProviderOverride(
    covariant AutomationRulesProvider provider,
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
  String? get name => r'automationRulesProvider';
}

/// See also [AutomationRules].
class AutomationRulesProvider
    extends
        AutoDisposeNotifierProviderImpl<AutomationRules, List<AutomationRule>> {
  /// See also [AutomationRules].
  AutomationRulesProvider(String deviceId)
    : this._internal(
        () => AutomationRules()..deviceId = deviceId,
        from: automationRulesProvider,
        name: r'automationRulesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$automationRulesHash,
        dependencies: AutomationRulesFamily._dependencies,
        allTransitiveDependencies:
            AutomationRulesFamily._allTransitiveDependencies,
        deviceId: deviceId,
      );

  AutomationRulesProvider._internal(
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
  List<AutomationRule> runNotifierBuild(covariant AutomationRules notifier) {
    return notifier.build(deviceId);
  }

  @override
  Override overrideWith(AutomationRules Function() create) {
    return ProviderOverride(
      origin: this,
      override: AutomationRulesProvider._internal(
        () => create()..deviceId = deviceId,
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
  AutoDisposeNotifierProviderElement<AutomationRules, List<AutomationRule>>
  createElement() {
    return _AutomationRulesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AutomationRulesProvider && other.deviceId == deviceId;
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
mixin AutomationRulesRef
    on AutoDisposeNotifierProviderRef<List<AutomationRule>> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _AutomationRulesProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AutomationRules,
          List<AutomationRule>
        >
    with AutomationRulesRef {
  _AutomationRulesProviderElement(super.provider);

  @override
  String get deviceId => (origin as AutomationRulesProvider).deviceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
