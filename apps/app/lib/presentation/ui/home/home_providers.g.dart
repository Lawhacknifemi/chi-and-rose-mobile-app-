// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore, deprecated_member_use

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyInsightHash() => r'4ef02df010bae26818456693a24f87771d718a9c';

/// See also [dailyInsight].
@ProviderFor(dailyInsight)
final dailyInsightProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
      dailyInsight,
      name: r'dailyInsightProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailyInsightHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyInsightRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$recentScansHash() => r'b6b32b3526a092e84d07714663f5533d54c2df65';

/// See also [recentScans].
@ProviderFor(recentScans)
final recentScansProvider = AutoDisposeFutureProvider<List<dynamic>>.internal(
  recentScans,
  name: r'recentScansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentScansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentScansRef = AutoDisposeFutureProviderRef<List<dynamic>>;
String _$wellnessFeedHash() => r'daa9e39324de381edcda5955ee22053828250966';

/// See also [wellnessFeed].
@ProviderFor(wellnessFeed)
final wellnessFeedProvider = AutoDisposeFutureProvider<List<dynamic>>.internal(
  wellnessFeed,
  name: r'wellnessFeedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wellnessFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WellnessFeedRef = AutoDisposeFutureProviderRef<List<dynamic>>;
String _$articleDetailsHash() => r'4085eda5111ebb4c65bba8ac8c89fb5a08993fcb';

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

/// See also [articleDetails].
@ProviderFor(articleDetails)
const articleDetailsProvider = ArticleDetailsFamily();

/// See also [articleDetails].
class ArticleDetailsFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [articleDetails].
  const ArticleDetailsFamily();

  /// See also [articleDetails].
  ArticleDetailsProvider call(String id) {
    return ArticleDetailsProvider(id);
  }

  @override
  ArticleDetailsProvider getProviderOverride(
    covariant ArticleDetailsProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articleDetailsProvider';
}

/// See also [articleDetails].
class ArticleDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// See also [articleDetails].
  ArticleDetailsProvider(String id)
    : this._internal(
        (ref) => articleDetails(ref as ArticleDetailsRef, id),
        from: articleDetailsProvider,
        name: r'articleDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleDetailsHash,
        dependencies: ArticleDetailsFamily._dependencies,
        allTransitiveDependencies:
            ArticleDetailsFamily._allTransitiveDependencies,
        id: id,
      );

  ArticleDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(ArticleDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArticleDetailsProvider._internal(
        (ref) => create(ref as ArticleDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _ArticleDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleDetailsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticleDetailsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ArticleDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with ArticleDetailsRef {
  _ArticleDetailsProviderElement(super.provider);

  @override
  String get id => (origin as ArticleDetailsProvider).id;
}

String _$userProfileHash() => r'b6f4091dd962d558112316a22473142216bd9907';

/// See also [userProfile].
@ProviderFor(userProfile)
final userProfileProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>?>.internal(
      userProfile,
      name: r'userProfileProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRef = AutoDisposeFutureProviderRef<Map<String, dynamic>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
