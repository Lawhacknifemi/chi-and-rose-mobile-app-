import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/composition_root/data_sources/shared_preference_data_source.dart';
import 'package:flutter_app/configuration/api_configuration.dart';

part 'flow_repository.g.dart';

@riverpod
FlowRepository flowRepository(FlowRepositoryRef ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  final apiConfiguration = ref.watch(apiConfigurationProvider);
  return FlowRepository(sharedPreferences, apiConfiguration);
}

@riverpod
Future<Map<String, dynamic>?> flowSettings(FlowSettingsRef ref) {
  return ref.watch(flowRepositoryProvider).getSettings();
}

@riverpod
Future<Map<String, dynamic>> flowCalendarData(FlowCalendarDataRef ref, {required int month, required int year}) {
  return ref.watch(flowRepositoryProvider).getCalendarData(month, year);
}

class FlowRepository {
  FlowRepository(this._sharedPreferences, this._apiConfiguration);
  final SharedPreferences _sharedPreferences;
  final ApiConfiguration _apiConfiguration;

  String get _baseUrl => _apiConfiguration.baseUrl;

  Future<String?> get _token async {
    return _sharedPreferences.getString('auth_token');
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final token = await _token;
    if (token == null) return null;

    try {
      final url = Uri.parse('$_baseUrl/rpc/flow/getSettings');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'json': {}}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? data['json'] ?? data;
      } else {
        debugPrint('Failed to fetch flow settings: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching flow settings: $e');
      return null;
    }
  }

  Future<void> updateSettings({
    int? averageCycleLength,
    int? averagePeriodLength,
  }) async {
    final token = await _token;
    if (token == null) throw Exception('Not authenticated');

    try {
      final url = Uri.parse('$_baseUrl/rpc/flow/updateSettings');
      final body = <String, dynamic>{};
      if (averageCycleLength != null) body['averageCycleLength'] = averageCycleLength;
      if (averagePeriodLength != null) body['averagePeriodLength'] = averagePeriodLength;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'json': body}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update settings: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating flow settings: $e');
      rethrow;
    }
  }

  Future<void> logPeriodStart(DateTime date) async {
    final token = await _token;
    if (token == null) throw Exception('Not authenticated');

    try {
      final url = Uri.parse('$_baseUrl/rpc/flow/logPeriodStart');
      // Format date as YYYY-MM-DD
      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'json': {'date': dateStr}}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to log period start: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error logging period start: $e');
      rethrow;
    }
  }

  Future<void> logDailyEntry({
    required DateTime date,
    String? flowIntensity,
    List<String>? symptoms,
    String? mood,
    String? notes,
  }) async {
    final token = await _token;
    if (token == null) throw Exception('Not authenticated');

    try {
      final url = Uri.parse('$_baseUrl/rpc/flow/logDailyEntry');
      final dateStr = date.toIso8601String().split('T')[0];
      
      final body = {
        'date': dateStr,
        if (flowIntensity != null) 'flowIntensity': flowIntensity,
        if (symptoms != null) 'symptoms': symptoms,
        if (mood != null) 'mood': mood,
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'json': body}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to log daily entry: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error logging daily entry: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCalendarData(int month, int year) async {
    final token = await _token;
    if (token == null) return {'cycles': [], 'logs': []};

    try {
      final url = Uri.parse('$_baseUrl/rpc/flow/getCalendarData');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'json': {'month': month, 'year': year}}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? data['json'] ?? data;
      } else {
        debugPrint('Failed to get calendar data: ${response.statusCode}');
        return {'cycles': [], 'logs': []};
      }
    } catch (e) {
      debugPrint('Error fetching calendar data: $e');
      return {'cycles': [], 'logs': []};
    }
  }
}
