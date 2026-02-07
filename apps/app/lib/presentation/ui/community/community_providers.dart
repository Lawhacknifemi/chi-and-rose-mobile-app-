
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../composition_root/repositories/health_repository.dart';

part 'community_providers.g.dart';

@riverpod
Future<List<dynamic>> communityGroups(CommunityGroupsRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getCommunityGroups();
}

@riverpod
Future<List<dynamic>> communityFeed(CommunityFeedRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getCommunityFeed();
}

@riverpod
Future<List<dynamic>> groupPosts(GroupPostsRef ref, String groupId) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getGroupPosts(groupId);
}

@riverpod
Future<Map<String, dynamic>> groupDetails(GroupDetailsRef ref, String groupId) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getGroupDetails(groupId);
}

@riverpod
Future<Map<String, dynamic>> postDetails(PostDetailsRef ref, String postId) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getPostDetails(postId);
}
