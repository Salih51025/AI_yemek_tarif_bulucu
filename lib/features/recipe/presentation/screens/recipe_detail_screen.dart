/// Premium recipe detail: hero, collapsible ingredients, animated steps.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/debug/session_debug_log.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/semantic_colors.dart';
import '../../../favorites/presentation/favorite_providers.dart';
import '../../../sharing/share_providers.dart';
import '../../domain/models/recipe_model.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({required this.recipe, super.key});

  final RecipeModel recipe;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _ingredientsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final isFav = ref.watch(isFavoriteProvider(recipe.id));
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;
    final l10n = context.l10n;
    // #region agent log
    SessionDebugLog.log(
      location: 'recipe_detail_screen.dart:build',
      message: 'detail_ui_labels_snapshot',
      hypothesisId: 'H-LUI2',
      runId: 'pre-fix',
      data: {
        'locale': Localizations.localeOf(context).toLanguageTag(),
        'ingredientsHeader': 'Ingredients',
        'stepsHeader': 'Steps',
      },
    );
    // #endregion

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260.h,
            pinned: true,
            stretch: true,
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                color: isFav ? Colors.red : null,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(favoritesNotifierProvider.notifier).toggle(recipe);
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () =>
                    ref.read(shareServiceProvider).shareRecipe(recipe),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Hero(
                tag: 'recipe-image-${recipe.id}',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primary,
                        scheme.secondary.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.restaurant_menu_rounded,
                      size: 80.sp,
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(recipe: recipe),
                  if (recipe.description != null) ...[
                    SizedBox(height: 16.h),
                    Text(
                      recipe.description!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: semantic.secondaryText,
                          ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                  Material(
                    color: semantic.cardSurface,
                    borderRadius: BorderRadius.circular(16.r),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.shopping_basket_outlined,
                              color: scheme.primary),
                          title: Text(
                            l10n.ingredientsLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: semantic.primaryText,
                            ),
                          ),
                          trailing: AnimatedRotation(
                            turns: _ingredientsExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 280),
                            child: const Icon(Icons.expand_more),
                          ),
                          onTap: () => setState(
                            () => _ingredientsExpanded = !_ingredientsExpanded,
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: Column(
                            children: recipe.ingredients.map((i) {
                              return _AnimatedLine(
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(Icons.circle,
                                      size: 8, color: scheme.primary),
                                  title: Text(
                                    i.quantity != null && i.quantity!.isNotEmpty
                                        ? '${i.name} — ${i.quantity}'
                                        : i.name,
                                    style: TextStyle(color: semantic.secondaryText),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: _ingredientsExpanded
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 280),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _SectionTitle(title: l10n.stepsLabel, icon: Icons.list_alt),
                  SizedBox(height: 8.h),
                  ...recipe.steps.asMap().entries.map(
                    (e) => _AnimatedLine(
                      delay: e.key * 40,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14.r,
                              backgroundColor: scheme.primaryContainer,
                              child: Text(
                                '${e.key + 1}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                e.value.instruction,
                                style: TextStyle(
                                  color: semantic.primaryText,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 8.w),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _Chip(label: recipe.difficulty),
        _Chip(label: context.l10n.minutesShort(recipe.cookingTimeMinutes)),
        _Chip(label: recipe.category),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}

class _AnimatedLine extends StatefulWidget {
  const _AnimatedLine({required this.child, this.delay = 0});

  final Widget child;
  final int delay;

  @override
  State<_AnimatedLine> createState() => _AnimatedLineState();
}

class _AnimatedLineState extends State<_AnimatedLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: widget.child);
  }
}
