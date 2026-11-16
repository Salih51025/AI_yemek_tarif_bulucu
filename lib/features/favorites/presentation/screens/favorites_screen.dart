/// Premium favorites tab — grid, skeletons, empty state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/presentation/widgets/language_selector.dart';
import '../../../recipe/domain/models/recipe_model.dart';
import '../../../recipe/presentation/screens/recipe_detail_screen.dart';
import '../favorite_providers.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../../../../shared/widgets/staggered_entrance.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      favoritesNotifierProvider.select((s) => s.isLoading && !s.hydrated),
    );
    final recipes = ref.watch(
      favoritesNotifierProvider.select((s) => s.recipes),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(AppLocalizations.of(context).favoritesTitle),
            floating: true,
            actions: [
              const LanguageSelector(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    ref.read(favoritesNotifierProvider.notifier).load(),
              ),
            ],
          ),
          if (isLoading)
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => _GridSkeleton(),
                  childCount: 4,
                ),
              ),
            )
          else if (recipes.isEmpty)
            SliverFillRemaining(child: _EmptyFavorites())
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 96.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = recipes[index];
                    return StaggeredEntrance(
                      index: index,
                      child: _FavoriteGridTile(
                        recipe: recipe,
                        onTap: () => _openDetail(context, recipe),
                        onRemove: () => ref
                            .read(favoritesNotifierProvider.notifier)
                            .toggle(recipe),
                      ),
                    );
                  },
                  childCount: recipes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, RecipeModel recipe) {
    Navigator.of(context).push(
      AppPageRoute(
        page: RecipeDetailScreen(recipe: recipe),
        transition: AppTransition.slideUp,
        settings: RouteSettings(name: '/recipe/${recipe.id}'),
      ),
    );
  }
}

class _FavoriteGridTile extends ConsumerWidget {
  const _FavoriteGridTile({
    required this.recipe,
    required this.onTap,
    required this.onRemove,
  });

  final RecipeModel recipe;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return PressableScale(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'recipe-image-${recipe.id}',
                child: Container(
                  color: scheme.primaryContainer,
                  child: Icon(Icons.restaurant, color: scheme.onPrimaryContainer, size: 40.sp),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12.sp, color: scheme.outline),
                      SizedBox(width: 4.w),
                      Text(
                        '${recipe.cookingTimeMinutes} min',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.favorite, color: Colors.red[400], size: 20.sp),
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Card(child: Container(color: Colors.white)),
    );
  }
}

class _EmptyFavorites extends StatefulWidget {
  @override
  State<_EmptyFavorites> createState() => _EmptyFavoritesState();
}

class _EmptyFavoritesState extends State<_EmptyFavorites>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.05).animate(
          CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border,
                size: 72.sp, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            SizedBox(height: 20.h),
            Text(l10n.favoritesEmptyTitle,
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                l10n.favoritesEmptyBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
