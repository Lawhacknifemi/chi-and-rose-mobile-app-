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
    // Use production server for release builds
    if (kReleaseMode) return 'https://clownfish-app-t7z9u.ondigitalocean.app';
    
    // Use localhost:3000 (Requires: adb reverse tcp:3000 tcp:3000)
    if (!kIsWeb && Platform.isAndroid) return 'https://clownfish-app-t7z9u.ondigitalocean.app';
    
    // Other local dev
    return 'https://clownfish-app-t7z9u.ondigitalocean.app';
  }
}
