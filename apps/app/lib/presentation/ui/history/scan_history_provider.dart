import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_app/composition_root/repositories/scan_repository.dart';

part 'scan_history_provider.g.dart';

@riverpod
Future<List<dynamic>> scanHistory(ScanHistoryRef ref) async {
  final repository = ref.watch(scanRepositoryProvider);
  // Fetch up to 100 recent scans for the history page
  return repository.getRecentScans(limit: 100);
}
