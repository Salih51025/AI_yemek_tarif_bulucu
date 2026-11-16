/// Most Liked / Trending Recipes screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/debug/session_debug_log.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/presentation/widgets/language_selector.dart';
import '../providers/trending_provider.dart';
import '../widgets/premium_recipe_card.dart';

class TrendingScreen extends ConsumerStatefulWidget {
  const TrendingScreen({super.key});

  @override
  ConsumerState<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends ConsumerState<TrendingScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load on first mount; no-op if already loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(trendingNotifierProvider);
      if (s.recipes.isEmpty && !s.isLoading) {
        ref.read(trendingNotifierProvider.notifier).load();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(trendingNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trendingNotifierProvider);
    final l10n = AppLocalizations.of(context);
    // #region agent log
    SessionDebugLog.log(
      location: 'trending_screen.dart:build',
      message: 'trending_ui_labels_snapshot',
      hypothesisId: 'H-LUI3',
      runId: 'pre-fix',
      data: {
        'locale': Localizations.localeOf(context).toLanguageTag(),
        'emptyTitle': 'No trending recipes yet',
        'retryLabel': 'Retry',
        'localizedNavTrending': l10n.navTrending,
      },
    );
    // #endregion

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTrending),
        actions: [
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(trendingNotifierProvider.notifier).load(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(TrendingState state) {
    if (state.isLoading) return const _TrendingSkeleton();

    if (state.error != null && state.recipes.isEmpty) {
      return _ErrorView(
        message: state.error!,
        onRetry: () => ref.read(trendingNotifierProvider.notifier).load(),
      );
    }

    if (state.recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 72.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              context.l10n.noTrendingRecipesYet,
              style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.beFirstToSaveRecipe,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
      itemCount: state.recipes.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        if (index >= state.recipes.length) {
          return const _LoadingMoreIndicator();
        }
        final recipe = state.recipes[index];
        return PremiumRecipeCard(
          key: ValueKey(recipe.id),
          recipe: recipe,
        );
      },
    );
  }
}

class _TrendingSkeleton extends StatelessWidget {
  const _TrendingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
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

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56.sp, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
