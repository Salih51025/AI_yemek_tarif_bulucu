/// Supabase access for `recipes_history` favorites.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/debug/session_debug_log.dart';
import '../../recipe/data/mappers/recipe_supabase_mapper.dart';
import '../../recipe/domain/models/recipe_model.dart';

class FavoriteRemoteDataSource {
  FavoriteRemoteDataSource({
    required SupabaseClient client,
    Uuid? uuid,
  })  : _client = client,
        _uuid = uuid ?? const Uuid();

  final SupabaseClient _client;
  final Uuid _uuid;

  /// Cached after first Postgrest error about missing `is_favorite`.
  bool? _hasIsFavoriteColumn;

  Future<List<RecipeModel>> fetchFavorites(String userId) async {
    var query = _client.from('recipes_history').select().eq('user_id', userId);

    if (_hasIsFavoriteColumn != false) {
      query = query.eq('is_favorite', true);
    }

    try {
      final response = await query.order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((e) => RecipeSupabaseMapper.fromRow(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } on PostgrestException catch (e) {
      if (_isMissingIsFavoriteColumn(e)) {
        _hasIsFavoriteColumn = false;
        return fetchFavorites(userId);
      }
      rethrow;
    }
  }

  Future<RecipeModel> saveFavorite({
    required RecipeModel recipe,
    required String userId,
  }) async {
    final recipeId = recipe.id.isEmpty ? _uuid.v4() : recipe.id;
    final row = RecipeSupabaseMapper.toRow(
      recipe.copyWith(id: recipeId, isFavorite: true),
      userId: userId,
      isFavorite: true,
      includeIsFavoriteColumn: _hasIsFavoriteColumn != false,
    );

    // #region agent log
    SessionDebugLog.log(
      location: 'favorite_remote_data_source.dart:saveFavorite',
      message: 'upsert row',
      hypothesisId: 'H3',
      data: {
        'recipeId': recipeId,
        'includeIsFavorite': _hasIsFavoriteColumn != false,
        'keys': row.keys.take(14).toList(),
      },
      runId: 'post-fix',
    );
    // #endregion

    try {
      final response = await _client
          .from('recipes_history')
          .upsert(row, onConflict: 'id')
          .select()
          .single();
      return RecipeSupabaseMapper.fromRow(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (e) {
      if (_isMissingIsFavoriteColumn(e)) {
        _hasIsFavoriteColumn = false;
        return saveFavorite(recipe: recipe, userId: userId);
      }
      if (e.code == 'PGRST204' && e.message.contains('is_favorite')) {
        _hasIsFavoriteColumn = false;
        return saveFavorite(recipe: recipe, userId: userId);
      }
      rethrow;
    }
  }

  Future<void> removeFavorite({
    required String recipeId,
    required String userId,
  }) async {
    await _client
        .from('recipes_history')
        .delete()
        .eq('id', recipeId)
        .eq('user_id', userId);
  }

  bool _isMissingIsFavoriteColumn(PostgrestException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('is_favorite') &&
        (msg.contains('does not exist') || e.code == '42703');
  }
}
