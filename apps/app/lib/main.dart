import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app_initializer.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_app/presentation/providers/force_update_policy_notifier_provider.dart';
import 'package:flutter_app/presentation/providers/theme_setting_provider.dart';
import 'package:flutter_app/router/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internal_debug/ui.dart';
import 'package:internal_design_theme/themes.dart';
import 'package:internal_design_ui/i18n.dart';
import 'package:flutter_app/composition_root/repositories/deep_link_repository.dart';
import 'package:internal_domain_model/operational_settings/operational_settings.dart';
import 'package:internal_domain_model/theme_setting/theme_setting.dart';
import 'package:internal_util_ui/snack_bar_manager.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      // Disable contrast enforcement to allow true transparency on Android
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  await LocaleSettings.useDeviceLocale();

  LicenseRegistry.addLicense(() async* {
    yield _yumemiMobileProjectTemplateLicense();
  });

  // Start initialization in parallel - don't await here
  final initializationFuture = AppInitializer.initialize();
  
  runApp(
    ChiAndRoseApp(initializationFuture: initializationFuture),
  );
}

class ChiAndRoseApp extends StatefulWidget {
  const ChiAndRoseApp({
    super.key,
    required this.initializationFuture,
  });

  final Future<InitializedValues> initializationFuture;

  @override
  State<ChiAndRoseApp> createState() => _ChiAndRoseAppState();
}

class _ChiAndRoseAppState extends State<ChiAndRoseApp> {
  // Cache overrides to ensure they remain stable across rebuilds (hot reloads)
  // to prevent Riverpod "Tried to change the number of overrides" error.
  List<Override>? _overrides;
  final _observers = <ProviderObserver>[];

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _observers.add(TalkerRiverpodObserver(talker: TalkerFlutter.init()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InitializedValues>(
      future: widget.initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Initialize overrides only once
          if (_overrides == null) {
            _overrides = [
              ...snapshot.data!.overrideProviders,
              if (kDebugMode)
                talkerProvider.overrideWithValue(TalkerFlutter.init()),
            ];
          }

          return ProviderScope(
            overrides: _overrides!,
            observers: _observers,
            child: TranslationProvider(child: const MainApp()),
          );
        }

        // Show a minimal loading state while initializing
        return const MaterialApp(
          home: Scaffold(
            backgroundColor: Color(0xFFF3E6F4),
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeSetting = ref.watch(themeSettingNotifierProvider);

    final enableAccessibilityTools =
        kDebugMode && ref.watch(enableAccessibilityToolsProvider);

    // Initialize Deep Link Listener
    ref.watch(deepLinkRepositoryProvider);

    ref.listen(forceUpdatePolicyNotifierProvider, (
      _,
      forceUpdatePolicy,
    ) {
      final message = switch (forceUpdatePolicy) {
        AsyncError(:final error) => 'Failed to check for updates: $error',
        AsyncData(:final value) => switch (value) {
          ForceUpdateEnabled() => 'Force Update is required.',
          ForceUpdateDisabled() => null,
        },
        _ => null,
      };

      if (message == null) {
        return;
      }

      SnackBarManager.showSnackBar(message);
      ref.read(forceUpdatePolicyNotifierProvider.notifier).disable();
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: MaterialApp.router(
        locale: TranslationProvider.of(context).flutterLocale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppLocaleUtils.supportedLocales,
        scaffoldMessengerKey: SnackBarManager.rootScaffoldMessengerKey,
        builder: enableAccessibilityTools
            ? (context, child) => AccessibilityTools(child: child)
            : null,
        routerConfig: ref.watch(routerProvider),
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: themeSetting.toThemeMode(),
        shortcuts: kDebugMode
            ? {
                LogicalKeySet(
                  LogicalKeyboardKey.shift,
                  LogicalKeyboardKey.keyD,
                ): const _DebugIntent(),
              }
            : null,
        actions: kDebugMode
            ? <Type, Action<Intent>>{
                _DebugIntent: CallbackAction<_DebugIntent>(
                  onInvoke: (_) => unawaited(
                    router.push(const DebugPageRoute().location),
                  ),
                ),
              }
            : null,
      ),
    );
  }
}

LicenseEntryWithLineBreaks _yumemiMobileProjectTemplateLicense() {
  return const LicenseEntryWithLineBreaks(
    ['YUMEMI Mobile Project Template'],
    '''
MIT License

Copyright (c) 2023 YUMEMI Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
      ''',
  );
}

class _DebugIntent extends Intent {
  const _DebugIntent();
}

extension on ThemeSetting {
  ThemeMode toThemeMode() {
    return switch (this) {
      ThemeSetting.light => ThemeMode.light,
      ThemeSetting.dark => ThemeMode.dark,
      ThemeSetting.system => ThemeMode.system,
    };
  }
}
