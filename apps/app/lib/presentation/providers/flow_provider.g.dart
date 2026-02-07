// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore, deprecated_member_use

part of 'flow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flowSettingsHash() => r'2b049d2683376e106706da9757991f8493ff0076';

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
String _$calendarDataHash() => r'538636745bc7d4fee50373288a8e9ec31c628704';

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

/// See also [calendarData].
@ProviderFor(calendarData)
const calendarDataProvider = CalendarDataFamily();

/// See also [calendarData].
class CalendarDataFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [calendarData].
  const CalendarDataFamily();

  /// See also [calendarData].
  CalendarDataProvider call({required int month, required int year}) {
    return CalendarDataProvider(month: month, year: year);
  }

  @override
  CalendarDataProvider getProviderOverride(
    covariant CalendarDataProvider provider,
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
  String? get name => r'calendarDataProvider';
}

/// See also [calendarData].
class CalendarDataProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [calendarData].
  CalendarDataProvider({required int month, required int year})
    : this._internal(
        (ref) => calendarData(ref as CalendarDataRef, month: month, year: year),
        from: calendarDataProvider,
        name: r'calendarDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$calendarDataHash,
        dependencies: CalendarDataFamily._dependencies,
        allTransitiveDependencies:
            CalendarDataFamily._allTransitiveDependencies,
        month: month,
        year: year,
      );

  CalendarDataProvider._internal(
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
    FutureOr<Map<String, dynamic>> Function(CalendarDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarDataProvider._internal(
        (ref) => create(ref as CalendarDataRef),
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
    return _CalendarDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarDataProvider &&
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
mixin CalendarDataRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `month` of this provider.
  int get month;

  /// The parameter `year` of this provider.
  int get year;
}

class _CalendarDataProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with CalendarDataRef {
  _CalendarDataProviderElement(super.provider);

  @override
  int get month => (origin as CalendarDataProvider).month;
  @override
  int get year => (origin as CalendarDataProvider).year;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
