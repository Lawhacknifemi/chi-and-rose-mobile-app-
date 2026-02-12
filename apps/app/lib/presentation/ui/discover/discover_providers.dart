import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_app/composition_root/repositories/health_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'discover_providers.g.dart';

@riverpod
Future<List<dynamic>> discoverFeed(DiscoverFeedRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getDiscoverFeed();
}

final searchQueryProvider = StateProvider<String>((ref) => "");

final filteredDiscoverFeedProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  final discoverAsync = ref.watch(discoverFeedProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return discoverAsync.whenData((products) {
    if (query.isEmpty) return products;
    return products.where((p) {
      final name = p['productName']?.toString().toLowerCase() ?? "";
      final brand = p['brand']?.toString().toLowerCase() ?? "";
      return name.contains(query) || brand.contains(query);
    }).toList();
  });
});
