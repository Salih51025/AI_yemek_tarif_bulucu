/// Riverpod access to startup/bootstrap state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/bootstrap_snapshot.dart';

/// Set in [main] via [ProviderScope.overrides].
final bootstrapSnapshotProvider = Provider<BootstrapSnapshot>((ref) {
  throw StateError('BootstrapSnapshot was not provided in ProviderScope');
});
