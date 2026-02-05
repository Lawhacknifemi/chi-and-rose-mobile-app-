import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/composition_root/data_sources/shared_preference_data_source.dart';

import 'package:flutter_app/configuration/api_configuration.dart';

part 'scan_repository.g.dart';

@riverpod
ScanRepository scanRepository(ScanRepositoryRef ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  final apiConfiguration = ref.watch(apiConfigurationProvider);
  return ScanRepository(sharedPreferences, apiConfiguration);
}

class ScanRepository {
  ScanRepository(this._sharedPreferences, this._apiConfiguration);
  final SharedPreferences _sharedPreferences;
  final ApiConfiguration _apiConfiguration;

  String get _baseUrl => _apiConfiguration.baseUrl;

  Future<String?> get _token async {
    return _sharedPreferences.getString('auth_token');
  }

  Future<Map<String, dynamic>?> scanBarcode(String barcode) async {
    final token = await _token;
    if (token == null) return null;

    try {
      final url = Uri.parse('$_baseUrl/rpc/scanner/scanBarcode');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'barcode': barcode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? data;
      } else {
        debugPrint('Failed to scan barcode: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      return null;
    }
  }

  Future<List<dynamic>> getRecentScans({int? limit}) async {
    debugPrint('ScanRepository: getRecentScans START');
    
    String? token;
    try {
        token = await _token;
        if (token == null) {
          return [];
        }
    } catch (e) {
        return [];
    }
    
    try {
      final url = Uri.parse('$_baseUrl/rpc/scanner/getRecentScans');
      final body = {'json': {'limit': limit ?? 10}};
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        if (data is List) {
           return data;
        } else if (data is Map<String, dynamic>) {
           if (data.containsKey('result')) {
             return data['result'] as List<dynamic>;
           } else if (data.containsKey('data')) {
             return data['data'] as List<dynamic>;
           } else if (data.containsKey('json')) {
             return data['json'] as List<dynamic>;
           }
           return [];
        } else {
           return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductDetails(String barcode) async {
    final token = await _token;
    if (token == null) return null;

    try {
      final url = Uri.parse('$_baseUrl/rpc/scanner/getProductDetails');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'barcode': barcode}),
      );

      debugPrint('ScanRepository: getProductDetails status: ${response.statusCode}');
      debugPrint('ScanRepository: getProductDetails body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Helper to unwrap 'result' or 'json' or return raw
        if (data is Map<String, dynamic>) {
             if (data.containsKey('result')) {
                 return data['result']['data'] ?? data['result']; // Handle double wrapping if any
             }
             if (data.containsKey('json')) {
                 return data['json'];
             }
             return data;
        }
        return null;
      } else {
        debugPrint('Failed to get product details: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting product details: $e');
      return null;
    }
  }
}
