import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/composition_root/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deep_link_repository.g.dart';

@riverpod
DeepLinkRepository deepLinkRepository(DeepLinkRepositoryRef ref) {
  return DeepLinkRepository(ref);
}

class DeepLinkRepository {
  final DeepLinkRepositoryRef _ref;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkRepository(this._ref) {
    _init();
  }

  void _init() {
    /*
    try {
      _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
        _handleDeepLink(uri);
      }, onError: (err) {
        debugPrint('DeepLink Error: $err');
      });
    } catch (e) {
      debugPrint('Failed to initialize AppLinks: $e');
    }
    */
  }

  void _handleDeepLink(Uri uri) {
    // Only handle auth callback for now
    if (uri.scheme == 'chiandrose' && uri.host == 'auth' && uri.path == '/callback') {
      _ref.read(authRepositoryProvider).handleDeepLink(uri);
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
