import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_configuration.g.dart';

@Riverpod(keepAlive: true)
ApiConfiguration apiConfiguration(ApiConfigurationRef ref) {
  return const ApiConfiguration();
}

class ApiConfiguration {
  const ApiConfiguration();

  String get baseUrl {
    // With adb reverse tcp:3000 tcp:3000, Android can access 127.0.0.1 directly.
    // This ensures cookies match the server domain.
    String url = 'http://127.0.0.1:3000';
    debugPrint('ApiConfiguration: Using baseUrl: $url');
    return url;
  }
}
