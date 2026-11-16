/// DI + derived providers for favorites.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_state_provider.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../application/favorite_service.dart';
import '../data/favorite_remote_data_source.dart';
import '../data/favorite_repository_impl.dart';
import '../domain/favorite_repository.dart';
import 'favorite_notifier.dart';
import 'favorite_state.dart';

final favoriteRemoteDataSourceProvider =
    Provider<FavoriteRemoteDataSource>((ref) {
  return FavoriteRemoteDataSource(client: ref.read(supabaseClientProvider));
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(
    remote: ref.read(favoriteRemoteDataSourceProvider),
    prefs: ref.read(sharedPreferencesProvider),
  );
});

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  return FavoriteService(ref.read(favoriteRepositoryProvider));
});

final favoritesNotifierProvider =
    StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  final notifier = FavoriteNotifier(ref.read(favoriteServiceProvider));

  ref.listen(appStateProvider, (previous, next) {
    if (next.isAuthenticated &&
        (previous == null || !previous.isAuthenticated)) {
      notifier.load();
    }
    if (next.isUnauthenticated) {
      notifier.reset();
    }
  });

  if (ref.read(appStateProvider).isAuthenticated) {
    Future.microtask(notifier.load);
  }

  return notifier;
});

/// O(1) favorite lookup — cards watch only their recipe id.
final isFavoriteProvider = Provider.family<bool, String>((ref, recipeId) {
  return ref.watch(
    favoritesNotifierProvider.select((s) => s.isFavorite(recipeId)),
  );
});

/// Alias matching product naming in requirements.
final favoriteProvider = isFavoriteProvider;
