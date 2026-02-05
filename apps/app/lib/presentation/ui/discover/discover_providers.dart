
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_app/composition_root/repositories/health_repository.dart';

part 'discover_providers.g.dart';

@riverpod
Future<List<dynamic>> discoverFeed(DiscoverFeedRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getDiscoverFeed();
}
