import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_chef/core/providers/bootstrap_providers.dart';
import 'package:ai_chef/core/services/bootstrap_snapshot.dart';
import 'package:ai_chef/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_chef/main.dart';

void main() {
  testWidgets('App shows splash branding when Supabase is unavailable', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const snapshot = BootstrapSnapshot(
      envLoaded: true,
      supabaseReady: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bootstrapSnapshotProvider.overrideWithValue(snapshot),
        ],
        child: const AIChefApp(snapshot: snapshot),
      ),
    );

    expect(find.text('AI Chef'), findsOneWidget);
  });
}
