import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/composition_root/repositories/scan_repository.dart';
import 'package:flutter_app/composition_root/repositories/health_repository.dart';

part 'home_providers.g.dart';

@riverpod
Future<Map<String, dynamic>> dailyInsight(DailyInsightRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getDailyInsight();
}

@riverpod
Future<List<dynamic>> recentScans(RecentScansRef ref) async {
  debugPrint('HomeProviders: recentScans provider computing...');
  final repository = ref.watch(scanRepositoryProvider);
  return repository.getRecentScans();
}

@riverpod
Future<List<dynamic>> wellnessFeed(WellnessFeedRef ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getFeed();
}

@riverpod
Future<Map<String, dynamic>?> articleDetails(ArticleDetailsRef ref, String id) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getArticle(id);
}
