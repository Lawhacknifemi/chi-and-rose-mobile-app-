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
    // Use localhost for all platforms (requires `adb reverse tcp:3000 tcp:3000` on Android)
    // This allows sharing cookies (like auth state) between the app/webview and the server.
    return 'http://localhost:3000';
  }
}
