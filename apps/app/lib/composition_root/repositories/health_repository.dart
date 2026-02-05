import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/composition_root/data_sources/shared_preference_data_source.dart';

import 'package:flutter_app/configuration/api_configuration.dart';

part 'health_repository.g.dart';

@riverpod
HealthRepository healthRepository(HealthRepositoryRef ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  final apiConfiguration = ref.watch(apiConfigurationProvider);
  return HealthRepository(sharedPreferences, apiConfiguration);
}

class HealthRepository {
  HealthRepository(this._sharedPreferences, this._apiConfiguration);
  final SharedPreferences _sharedPreferences;
  final ApiConfiguration _apiConfiguration;

  String get _baseUrl => _apiConfiguration.baseUrl;

  Future<String?> get _token async {
    return _sharedPreferences.getString('auth_token');
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final token = await _token;
    if (token == null) return null;

    try {
      final url = Uri.parse('$_baseUrl/rpc/health/getProfile');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'json': {}}), // Wrapped in json envelope
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? data['json'] ?? data;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    DateTime? dateOfBirth,
    List<String>? goals,
    List<String>? dietaryPreferences,
    List<String>? conditions,
    List<String>? symptoms,
    List<String>? sensitivities,
  }) async {
    debugPrint('HealthRepository: updateProfile called');
    final token = await _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final url = Uri.parse('$_baseUrl/rpc/health/updateProfile');
      final Map<String, dynamic> body = {};
      
      if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (goals != null) body['goals'] = goals;
      if (dietaryPreferences != null) body['dietaryPreferences'] = dietaryPreferences;
      if (conditions != null) body['conditions'] = conditions;
      if (symptoms != null) body['symptoms'] = symptoms;
      if (sensitivities != null) body['sensitivities'] = sensitivities;

      final bodyString = jsonEncode({'json': body}); // Wrapped in json envelope
      debugPrint('HealthRepository: Sending Body: $bodyString');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyString,
      );

      debugPrint('Update Profile Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Profile Updated Successfully');
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
       debugPrint('Error updating profile: $e');
       rethrow;
    }
  }

  Future<Map<String, dynamic>> getDailyInsight() async {
    final token = await _token;
    if (token == null) return {};

    try {
      final url = Uri.parse('$_baseUrl/rpc/health/dailyInsight');
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({'json': {}}), // Wrapped in json envelope
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? data['json'] ?? data;
      } else {
        return {};
      }
    } catch (e) {
      debugPrint('Error fetch daily insight: $e');
      return {};
    }
  }

  Future<List<dynamic>> getFeed() async {
    final token = await _token;
    if (token == null) return [];

    try {
      final url = Uri.parse('$_baseUrl/rpc/health/getFeed');
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
           body: jsonEncode({'json': {}}), // Wrapped in json envelope
      );

      if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // orpc might wrap in 'result' or 'json'
          return data['result'] ?? data['json'] ?? data;
      } else {
          return [];
      }
    } catch(e) {
        debugPrint('Error fetching feed: $e');
        return [];
    }
  }

  Future<Map<String, dynamic>?> getArticle(String id) async {
    final token = await _token;
    if (token == null) return null;

    try {
      final url = Uri.parse('$_baseUrl/rpc/health/getArticle');
      final bodyString = jsonEncode({'json': {'id': id}});
      
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: bodyString,
      );

      debugPrint('HealthRepository: getArticle status: ${response.statusCode}');
      if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final result = data['result'] ?? data['json'] ?? data;
          debugPrint('HealthRepository: getArticle content field present: ${result['content'] != null}');
          return result;
      } else {
          debugPrint('Failed to fetch article: ${response.statusCode} - ${response.body}');
          return null;
      }
    } catch (e) {
        debugPrint('Error fetching article details: $e');
        return null;
    }
  }

  Future<List<dynamic>> getDiscoverFeed() async {
    final token = await _token;
    if (token == null) return [];

    try {
      final url = Uri.parse('$_baseUrl/rpc/discover/getFeed');
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({'json': {}}), // Wrapped in json envelope
      );

      if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // orpc might wrap in 'result' or 'json'
          final result = data['result'] ?? data['json'] ?? data;
          return result['recommendations'] ?? [];
      } else {
          return [];
      }
    } catch(e) {
        debugPrint('Error fetching discover feed: $e');
        return [];
    }
  }
}
