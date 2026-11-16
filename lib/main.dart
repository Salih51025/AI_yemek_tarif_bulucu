/// AI Chef — Clean Architecture entry point with Riverpod DI.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_constants.dart';
import 'core/navigation/app_page_route.dart';
import 'core/presentation/bootstrap_error_app.dart';
import 'core/providers/app_state_provider.dart';
import 'core/providers/bootstrap_providers.dart';
import 'core/debug/debug_session_log.dart';
import 'core/services/app_bootstrap_service.dart';
import 'core/services/bootstrap_snapshot.dart';
import 'core/services/startup_error_handlers.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/presentation/locale_provider.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/home/presentation/home_shell.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/premium/presentation/screens/premium_paywall_screen.dart';
import 'features/recipe/presentation/screens/ingredient_input_screen.dart';
import 'features/recipe/presentation/screens/recipe_list_screen.dart';
import 'features/theme/presentation/theme_provider.dart';

Future<void> main() async {
  await runAppGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // #region agent log
    DebugSessionLog.log(
      location: 'main.dart:main',
      message: 'main entered',
      hypothesisId: 'H1',
      data: {'platform': defaultTargetPlatform.name},
    );
    // #endregion
    installStartupErrorHandlers();

    BootstrapSnapshot snapshot;
    try {
      final bootstrapService = AppBootstrapService();
      snapshot = await bootstrapService.initialize();

      if (!snapshot.isFullyReady) {
        debugPrint(
          '[Bootstrap] Degraded startup: supabase=${snapshot.supabaseReady}, '
          'warnings=${snapshot.warnings}',
        );
      }
    } catch (e, stack) {
      debugPrint('[Bootstrap] CRITICAL: $e\n$stack');
      // #region agent log
      DebugSessionLog.log(
        location: 'main.dart:main',
        message: 'bootstrap outer catch',
        hypothesisId: 'H1',
        data: {'error': e.toString()},
      );
      // #endregion
      snapshot = BootstrapSnapshot(
        envLoaded: false,
        supabaseReady: false,
        fatalError: 'Startup failed: $e',
      );
    }

    // #region agent log
    DebugSessionLog.log(
      location: 'main.dart:main',
      message: 'bootstrap finished',
      hypothesisId: 'H1',
      data: {
        'canLaunchApp': snapshot.canLaunchApp,
        'supabaseReady': snapshot.supabaseReady,
        'warningCount': snapshot.warnings.length,
      },
    );
    // #endregion

    if (!snapshot.canLaunchApp) {
      runApp(BootstrapErrorApp(snapshot: snapshot));
      return;
    }

    // #region agent log
    DebugSessionLog.log(
      location: 'main.dart:main',
      message: 'calling runApp AIChefApp',
      hypothesisId: 'H3',
    );
    // #endregion
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            snapshot.sharedPreferences!,
          ),
          bootstrapSnapshotProvider.overrideWithValue(snapshot),
        ],
        child: AIChefApp(snapshot: snapshot),
      ),
    );
  });
}

class AIChefApp extends ConsumerStatefulWidget {
  const AIChefApp({required this.snapshot, super.key});

  final BootstrapSnapshot snapshot;

  @override
  ConsumerState<AIChefApp> createState() => _AIChefAppState();
}

class _AIChefAppState extends ConsumerState<AIChefApp> {
  bool _splashDone = false;
  static bool _loggedFirstBuild = false;

  @override
  Widget build(BuildContext context) {
    if (!_loggedFirstBuild) {
      _loggedFirstBuild = true;
      // #region agent log
      DebugSessionLog.log(
        location: 'main.dart:AIChefApp.build',
        message: 'first frame build',
        hypothesisId: 'H3',
        data: {'supabaseReady': widget.snapshot.supabaseReady},
      );
      // #endregion
    }
    final appState = ref.watch(appStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          locale: locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeInOut,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/auth':
                return AppPageRoute(
                    page: const AuthScreen(), settings: settings);
              case '/ingredients':
                return AppPageRoute(
                  page: const IngredientInputScreen(),
                  settings: settings,
                );
              case '/recipes':
                return AppPageRoute(
                  page: const RecipeListScreen(),
                  transition: AppTransition.slideUp,
                  settings: settings,
                );
              case '/premium':
                return AppPageRoute(
                    page: const PremiumPaywallScreen(), settings: settings);
            }
            return null;
          },
          home: SplashScreen(
            onFinished: () => setState(() => _splashDone = true),
            child: _buildHome(appState),
          ),
        );
      },
    );
  }

  Widget _buildHome(AppState appState) {
    if (!_splashDone) {
      return const SizedBox.shrink();
    }
    if (!widget.snapshot.supabaseReady) {
      return BootstrapErrorScreen(snapshot: widget.snapshot);
    }
    return switch (appState.status) {
      AppStatus.loading => const _BootstrapLoadingScreen(),
      AppStatus.authenticated => const HomeShell(),
      AppStatus.unauthenticated => const AuthScreen(),
    };
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu,
                size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(l10n.preparingKitchen,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
