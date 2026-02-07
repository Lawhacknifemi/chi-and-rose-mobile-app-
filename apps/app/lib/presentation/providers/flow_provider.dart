import 'package:flutter_app/composition_root/repositories/flow_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flow_provider.g.dart';

@riverpod
Future<Map<String, dynamic>?> flowSettings(FlowSettingsRef ref) async {
  final repository = ref.watch(flowRepositoryProvider);
  return repository.getSettings();
}

@riverpod
Future<Map<String, dynamic>> calendarData(CalendarDataRef ref, {required int month, required int year}) async {
  final repository = ref.watch(flowRepositoryProvider);
  return repository.getCalendarData(month, year);
}
