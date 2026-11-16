/// Recipe list: premium expandable cards driven by [recipeGenerationNotifierProvider].
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/debug/session_debug_log.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/recipe_generation_response.dart';
import '../../domain/models/recipe_model.dart';
import '../providers/recipe_generation_notifier.dart';

import '../../../../shared/widgets/staggered_entrance.dart';
import '../widgets/premium_recipe_card.dart';

/// Stateful wrapper so we can reset the notifier when the screen is disposed.
/// This ensures the ingredient screen never sees stale Success/Failure state
/// when the user navigates back and starts a new search.
class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key, this.initialResponse});

  final RecipeGenerationResponse? initialResponse;

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeGenerationNotifierProvider);
    final l10n = AppLocalizations.of(context);

    final response = widget.initialResponse ??
        (state is RecipeGenerationSuccess ? state.response : null);
    // #region agent log
    SessionDebugLog.log(
      location: 'recipe_list_screen.dart:build',
      message: 'list_ui_labels_snapshot',
      hypothesisId: 'H-LUI1',
      runId: 'pre-fix',
      data: {
        'locale': Localizations.localeOf(context).toLanguageTag(),
        'titleFallback': 'Generated Recipes',
        'newSearchLabel': 'New Search',
        'localizedNavGenerate': l10n.navGenerate,
      },
    );
    // #endregion

    return Scaffold(
      appBar: AppBar(
        title: Text(
          response != null
              ? l10n.recipesFound(response.recipes.length)
              : l10n.generatedRecipesTitle,
        ),
        elevation: 0,
      ),
      body: _buildBody(context, ref, state, response),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.search),
        label: Text(l10n.newSearch),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    RecipeGenerationUiState state,
    RecipeGenerationResponse? response,
  ) {
    if (response != null && response.recipes.isNotEmpty) {
      return _RecipeListBody(recipes: response.recipes);
    }
    return switch (state) {
      RecipeGenerationLoading() => const _RecipeListSkeleton(),
      RecipeGenerationFailure(:final message) => _ErrorBody(
          message: message, onRetry: () => Navigator.of(context).pop()),
      RecipeGenerationSuccess(:final response) => response.recipes.isNotEmpty
          ? _RecipeListBody(recipes: response.recipes)
          : _EmptyBody(onNewSearch: () => Navigator.of(context).pop()),
      RecipeGenerationIdle() =>
        _EmptyBody(onNewSearch: () => Navigator.of(context).pop()),
    };
  }
}

class _RecipeListBody extends StatelessWidget {
  const _RecipeListBody({required this.recipes});

  final List<RecipeModel> recipes;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return _EmptyBody(onNewSearch: () => Navigator.of(context).pop());
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        // #region agent log
        if (kDebugMode) {
          debugPrint(
            '[_RecipeListBody] card[$index] | id=${recipe.id} | '
            'title=${recipe.title} | desc=${recipe.description != null}',
          );
        }
        // #endregion
        return StaggeredEntrance(
          index: index,
          child: PremiumRecipeCard(
            key: ValueKey(recipe.id),
            recipe: recipe,
          ),
        );
      },
    );
  }
}

class _RecipeListSkeleton extends StatelessWidget {
  const _RecipeListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 3,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 280.h,
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({this.onNewSearch});

  final VoidCallback? onNewSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 72.sp, color: Colors.grey[300]),
            SizedBox(height: 24.h),
            Text(
              l10n.noRecipesYetTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.noRecipesYetBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            if (onNewSearch != null)
              ElevatedButton.icon(
                onPressed: onNewSearch,
                icon: const Icon(Icons.search),
                label: Text(l10n.startNewSearch),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72.sp, color: Colors.red[300]),
            SizedBox(height: 24.h),
            Text(
              l10n.recipeGenerationFailedTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.red[700],
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.tryAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
