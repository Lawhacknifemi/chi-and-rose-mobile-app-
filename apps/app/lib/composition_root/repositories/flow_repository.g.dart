// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore, deprecated_member_use

part of 'flow_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flowRepositoryHash() => r'2d1d132b07f46d88cd67b64ac0583b026ed91ad2';

/// See also [flowRepository].
@ProviderFor(flowRepository)
final flowRepositoryProvider = AutoDisposeProvider<FlowRepository>.internal(
  flowRepository,
  name: r'flowRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$flowRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FlowRepositoryRef = AutoDisposeProviderRef<FlowRepository>;
String _$flowSettingsHash() => r'7f9e53e91453b92de8d8002a2634b8fbd48c5eb3';

/// See also [flowSettings].
@ProviderFor(flowSettings)
final flowSettingsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>?>.internal(
      flowSettings,
      name: r'flowSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$flowSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FlowSettingsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>?>;
String _$flowCalendarDataHash() => r'de6d8f44365c33436819d897b26ef530f75a246c';

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

/// See also [flowCalendarData].
@ProviderFor(flowCalendarData)
const flowCalendarDataProvider = FlowCalendarDataFamily();

/// See also [flowCalendarData].
class FlowCalendarDataFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [flowCalendarData].
  const FlowCalendarDataFamily();

  /// See also [flowCalendarData].
  FlowCalendarDataProvider call({required int month, required int year}) {
    return FlowCalendarDataProvider(month: month, year: year);
  }

  @override
  FlowCalendarDataProvider getProviderOverride(
    covariant FlowCalendarDataProvider provider,
  ) {
    return call(month: provider.month, year: provider.year);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'flowCalendarDataProvider';
}

/// See also [flowCalendarData].
class FlowCalendarDataProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [flowCalendarData].
  FlowCalendarDataProvider({required int month, required int year})
    : this._internal(
        (ref) => flowCalendarData(
          ref as FlowCalendarDataRef,
          month: month,
          year: year,
        ),
        from: flowCalendarDataProvider,
        name: r'flowCalendarDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$flowCalendarDataHash,
        dependencies: FlowCalendarDataFamily._dependencies,
        allTransitiveDependencies:
            FlowCalendarDataFamily._allTransitiveDependencies,
        month: month,
        year: year,
      );

  FlowCalendarDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
    required this.year,
  }) : super.internal();

  final int month;
  final int year;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(FlowCalendarDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FlowCalendarDataProvider._internal(
        (ref) => create(ref as FlowCalendarDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _FlowCalendarDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FlowCalendarDataProvider &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FlowCalendarDataRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `month` of this provider.
  int get month;

  /// The parameter `year` of this provider.
  int get year;
}

class _FlowCalendarDataProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with FlowCalendarDataRef {
  _FlowCalendarDataProviderElement(super.provider);

  @override
  int get month => (origin as FlowCalendarDataProvider).month;
  @override
  int get year => (origin as FlowCalendarDataProvider).year;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
