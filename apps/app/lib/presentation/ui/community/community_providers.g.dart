// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore, deprecated_member_use

part of 'community_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityGroupsHash() => r'4ac521f2d40f4a219c25b116fe7ff70758be9d0d';

/// See also [communityGroups].
@ProviderFor(communityGroups)
final communityGroupsProvider =
    AutoDisposeFutureProvider<List<dynamic>>.internal(
      communityGroups,
      name: r'communityGroupsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityGroupsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityGroupsRef = AutoDisposeFutureProviderRef<List<dynamic>>;
String _$communityFeedHash() => r'e91ed9391423ebcf359f5a919c0e4a0542e55144';

/// See also [communityFeed].
@ProviderFor(communityFeed)
final communityFeedProvider = AutoDisposeFutureProvider<List<dynamic>>.internal(
  communityFeed,
  name: r'communityFeedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$communityFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityFeedRef = AutoDisposeFutureProviderRef<List<dynamic>>;
String _$groupPostsHash() => r'13cc004c0977429a7f15a338f09ec317327e12a9';

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

/// See also [groupPosts].
@ProviderFor(groupPosts)
const groupPostsProvider = GroupPostsFamily();

/// See also [groupPosts].
class GroupPostsFamily extends Family<AsyncValue<List<dynamic>>> {
  /// See also [groupPosts].
  const GroupPostsFamily();

  /// See also [groupPosts].
  GroupPostsProvider call(String groupId) {
    return GroupPostsProvider(groupId);
  }

  @override
  GroupPostsProvider getProviderOverride(
    covariant GroupPostsProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupPostsProvider';
}

/// See also [groupPosts].
class GroupPostsProvider extends AutoDisposeFutureProvider<List<dynamic>> {
  /// See also [groupPosts].
  GroupPostsProvider(String groupId)
    : this._internal(
        (ref) => groupPosts(ref as GroupPostsRef, groupId),
        from: groupPostsProvider,
        name: r'groupPostsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupPostsHash,
        dependencies: GroupPostsFamily._dependencies,
        allTransitiveDependencies: GroupPostsFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupPostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<List<dynamic>> Function(GroupPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupPostsProvider._internal(
        (ref) => create(ref as GroupPostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<dynamic>> createElement() {
    return _GroupPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupPostsProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupPostsRef on AutoDisposeFutureProviderRef<List<dynamic>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupPostsProviderElement
    extends AutoDisposeFutureProviderElement<List<dynamic>>
    with GroupPostsRef {
  _GroupPostsProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupPostsProvider).groupId;
}

String _$groupDetailsHash() => r'1583bafbf3f7d3753c752aac5249806433f5e6eb';

/// See also [groupDetails].
@ProviderFor(groupDetails)
const groupDetailsProvider = GroupDetailsFamily();

/// See also [groupDetails].
class GroupDetailsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [groupDetails].
  const GroupDetailsFamily();

  /// See also [groupDetails].
  GroupDetailsProvider call(String groupId) {
    return GroupDetailsProvider(groupId);
  }

  @override
  GroupDetailsProvider getProviderOverride(
    covariant GroupDetailsProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupDetailsProvider';
}

/// See also [groupDetails].
class GroupDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [groupDetails].
  GroupDetailsProvider(String groupId)
    : this._internal(
        (ref) => groupDetails(ref as GroupDetailsRef, groupId),
        from: groupDetailsProvider,
        name: r'groupDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupDetailsHash,
        dependencies: GroupDetailsFamily._dependencies,
        allTransitiveDependencies:
            GroupDetailsFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(GroupDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupDetailsProvider._internal(
        (ref) => create(ref as GroupDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _GroupDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDetailsProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupDetailsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with GroupDetailsRef {
  _GroupDetailsProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupDetailsProvider).groupId;
}

String _$postDetailsHash() => r'10d52d11131dba4de399aeaf74fb697a473f9fb9';

/// See also [postDetails].
@ProviderFor(postDetails)
const postDetailsProvider = PostDetailsFamily();

/// See also [postDetails].
class PostDetailsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [postDetails].
  const PostDetailsFamily();

  /// See also [postDetails].
  PostDetailsProvider call(String postId) {
    return PostDetailsProvider(postId);
  }

  @override
  PostDetailsProvider getProviderOverride(
    covariant PostDetailsProvider provider,
  ) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postDetailsProvider';
}

/// See also [postDetails].
class PostDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [postDetails].
  PostDetailsProvider(String postId)
    : this._internal(
        (ref) => postDetails(ref as PostDetailsRef, postId),
        from: postDetailsProvider,
        name: r'postDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$postDetailsHash,
        dependencies: PostDetailsFamily._dependencies,
        allTransitiveDependencies: PostDetailsFamily._allTransitiveDependencies,
        postId: postId,
      );

  PostDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(PostDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostDetailsProvider._internal(
        (ref) => create(ref as PostDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _PostDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostDetailsProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostDetailsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with PostDetailsRef {
  _PostDetailsProviderElement(super.provider);

  @override
  String get postId => (origin as PostDetailsProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
