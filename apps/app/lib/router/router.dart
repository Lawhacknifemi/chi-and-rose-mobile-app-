import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main_page.dart';
import 'package:flutter_app/presentation/providers/force_update_policy_notifier_provider.dart';
import 'package:flutter_app/presentation/providers/maintenance_policy_notifier_provider.dart';
import 'package:flutter_app/presentation/providers/onboarding_provider.dart';
import 'package:flutter_app/presentation/ui/home_page.dart';
import 'package:flutter_app/presentation/ui/onboarding/onboarding_page.dart';
import 'package:flutter_app/presentation/ui/operational_settings/maintenance_page.dart';
import 'package:flutter_app/presentation/ui/setting/setting_page.dart';
import 'package:flutter_app/presentation/ui/splash_page.dart';
import 'package:flutter_app/presentation/ui/period_tracker/period_tracker_page.dart';
import 'package:flutter_app/presentation/ui/scan/scan_page.dart';
import 'package:flutter_app/presentation/ui/community/community_page.dart';
import 'package:flutter_app/presentation/ui/profile/profile_page.dart';
import 'package:flutter_app/presentation/ui/discover/discover_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:internal_debug/ui.dart';
import 'package:internal_design_ui/common_assets.dart';
import 'package:internal_domain_model/operational_settings/operational_settings.dart';
import 'package:internal_util_ui/custom_app_lifecycle_listener.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_app/router/routes/auth_routes.dart';
import 'package:flutter_app/router/routes/personalization_routes.dart';
import 'package:flutter_app/router/routes/auth_callback_page_route.dart';
import 'package:flutter_app/presentation/ui/scan_history_page.dart';
import 'package:flutter_app/presentation/ui/details/product_details_page.dart';
import 'package:flutter_app/presentation/ui/home/article_details_page.dart';


part 'package:flutter_app/router/routes/main/home/debug_page_route.dart';
part 'package:flutter_app/router/routes/main/home/home_shell_branch.dart';
part 'package:flutter_app/router/routes/main/discover/discover_shell_branch.dart';
part 'package:flutter_app/router/routes/main/period_tracker/period_tracker_shell_branch.dart';
part 'package:flutter_app/router/routes/main/scan/scan_shell_branch.dart';
part 'package:flutter_app/router/routes/main/community/community_shell_branch.dart';
part 'package:flutter_app/router/routes/main/profile/profile_shell_branch.dart';
part 'package:flutter_app/router/routes/main/main_page_shell_route.dart';
part 'package:flutter_app/router/routes/maintenance_page_route.dart';
part 'package:flutter_app/router/routes/onboarding_page_route.dart';
part 'package:flutter_app/router/routes/splash_page_route.dart';
part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final isMaintenanceModeEnabled = ref.watch(
    maintenancePolicyNotifierProvider.select(
      (state) => state.valueOrNull is MaintenanceEnabled,
    ),
  );
  
  final hasCompletedOnboarding = ref.watch(
    onboardingNotifierProvider.select(
      (state) => state.valueOrNull ?? false,
    ),
  );
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: [
      ...$appRoutes.where((route) {
        if (route is GoRoute) {
          return route.path != DebugPageRoute.path;
        }

        return true;
      }),
      AuthPageRoute.route, // Manual route for Auth
      SignupPageRoute.route,
      PasswordPageRoute.route,
      OtpPageRoute.route,
      UserInfoPageRoute.route,
      PersonalizationPageRoute.route,
      AuthCallbackPageRoute.route,
      GoRoute(
        path: '/scan-history',
        builder: (context, state) => const ScanHistoryPage(),
      ),
      GoRoute(
        path: '/product-details',
        builder: (context, state) {
           final extra = state.extra as Map<String, dynamic>;
           return ProductDetailsPage(
             product: extra['product'],
             analysis: extra['analysis'],
             scannedAt: extra['scannedAt'],
           );
        },
      ),
      GoRoute(
        path: '/article-details/:id',
        builder: (context, state) {
            final id = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>?;
            return ArticleDetailsPage(
                articleId: id,
                initialData: extra,
            );
        },
      ),

      if (kDebugMode) $debugPageRoute,
    ],
    debugLogDiagnostics: kDebugMode,
    initialLocation: SplashPageRoute.path,
    redirect: (context, state) {
      final currentPath = state.matchedLocation;
      
      debugPrint('Router: Checking redirect for: $currentPath');
      debugPrint('Router: hasCompletedOnboarding: $hasCompletedOnboarding');

      // Maintenance mode takes priority
      if (isMaintenanceModeEnabled) {
        debugPrint('Router: Redirecting to Maintenance');
        return MaintenancePageRoute.path;
      }
      
      // Check onboarding status
      final isOnSplash = currentPath == SplashPageRoute.path;
      final isOnOnboarding = currentPath == OnboardingPageRoute.path;
      final isOnAuth = currentPath?.startsWith('/auth') ?? false;
      final isOnPersonalization = currentPath?.startsWith('/personalization') ?? false;

      debugPrint('Router: Flags - Splash:$isOnSplash, Onboarding:$isOnOnboarding, Auth:$isOnAuth, Personalization:$isOnPersonalization');
      
      // If not completed onboarding and not on splash/onboarding/auth, redirect to onboarding
      if (!hasCompletedOnboarding && !isOnSplash && !isOnOnboarding && !isOnAuth && !isOnPersonalization) {
        debugPrint('Router: Redirecting to Onboarding (Safety Guard)');
        return OnboardingPageRoute.path;
      }
      
      debugPrint('Router: No redirect needed');
      return null;
    },
  );
}
