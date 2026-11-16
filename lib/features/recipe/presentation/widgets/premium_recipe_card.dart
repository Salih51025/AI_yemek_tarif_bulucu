/// Premium Recipe Card Widget
///
/// Enterprise-grade recipe card with advanced animations, expandable content,
/// swipe gestures, haptic feedback, and smooth transitions.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/debug/session_debug_log.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_page_route.dart';
import '../../../../core/services/image/recipe_image_service.dart';
import '../../domain/models/recipe_model.dart';
import '../../../sharing/share_providers.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../providers/favorites_notifier.dart';
import '../screens/recipe_detail_screen.dart';

// ============================================================================
// PREMIUM RECIPE CARD
// ============================================================================

class PremiumRecipeCard extends ConsumerStatefulWidget {
  final RecipeModel recipe;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final bool initiallyExpanded;

  const PremiumRecipeCard({
    required this.recipe,
    this.onTap,
    this.onShare,
    this.initiallyExpanded = false,
    super.key,
  });

  @override
  ConsumerState<PremiumRecipeCard> createState() => _PremiumRecipeCardState();
}

class _PremiumRecipeCardState extends ConsumerState<PremiumRecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        HapticFeedback.lightImpact();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleFavorite() {
    HapticFeedback.mediumImpact();
    ref.read(favoritesNotifierProvider.notifier).toggle(widget.recipe);
  }

  Future<void> _handleShare() async {
    // #region agent log
    SessionDebugLog.log(
      location: 'premium_recipe_card.dart:_handleShare',
      message: 'share tapped',
      hypothesisId: 'H1',
      data: {
        'recipeId': widget.recipe.id,
        'hasOnShareCallback': widget.onShare != null,
      },
      runId: 'post-fix',
    );
    // #endregion
    if (widget.onShare != null) {
      widget.onShare!();
      return;
    }
    await ref.read(shareServiceProvider).shareRecipe(widget.recipe);
    // #region agent log
    SessionDebugLog.log(
      location: 'premium_recipe_card.dart:_handleShare',
      message: 'share invoked via ShareService',
      hypothesisId: 'H1',
      data: {'recipeId': widget.recipe.id},
      runId: 'post-fix',
    );
    // #endregion
  }

  void _openDetail() {
    Navigator.of(context).push(
      AppPageRoute<void>(
        page: RecipeDetailScreen(recipe: widget.recipe),
        transition: AppTransition.slideUp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: widget.onTap ?? _openDetail,
      child: Card(
        elevation: _isExpanded ? 8 : 3,
        shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        _buildImage(),
        _buildOverlay(),
        _buildDifficultyBadge(),
        _buildFavoriteButton(),
      ],
    );
  }

  Widget _buildImage() {
    final source = RecipeImageService.resolve(
      imageUrl: widget.recipe.imageUrl,
      imagePrompt: widget.recipe.tags.isNotEmpty ? widget.recipe.tags.first : null,
      title: widget.recipe.title,
      category: widget.recipe.category,
    );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: switch (source) {
        RecipeNetworkImage(:final url) => CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            // Shimmer skeleton while loading — no layout shift.
            placeholder: (_, __) => Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor: Theme.of(context).colorScheme.surface,
              child: Container(color: Theme.of(context).colorScheme.surface),
            ),
            errorWidget: (_, __, ___) => _buildPlaceholderImage(),
          ),
        RecipeGradientImage(:final colors) => _buildGradientImage(colors),
      },
    );
  }

  Widget _buildGradientImage(List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 64,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return _buildGradientImage([
      _getCategoryColor().withValues(alpha: 0.6),
      _getCategoryColor().withValues(alpha: 0.3),
    ]);
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getDifficultyColor(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.recipe.difficulty,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: _handleFavorite,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              // select() means only this icon rebuilds, not the whole card.
              final fav = ref.watch(isFavoriteProvider(widget.recipe.id));
              return Icon(
                fav ? Icons.favorite : Icons.favorite_border,
                color: fav ? Colors.red : Colors.grey,
                size: 24,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Summary (title, meta, expand control) stays visible; only details animate.
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 8),
          _buildDescription(),
          const SizedBox(height: 12),
          _buildMetadata(),
          const SizedBox(height: 12),
          _buildTags(),
          const SizedBox(height: 8),
          _buildExpandButton(),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildIngredients(),
                const SizedBox(height: 16),
                _buildSteps(),
                const SizedBox(height: 16),
                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.recipe.title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    final desc = widget.recipe.description?.trim();
    if (desc == null || desc.isEmpty) return const SizedBox.shrink();
    return Text(
      desc,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: _isExpanded ? null : 2,
      overflow: _isExpanded ? null : TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _buildMetadataItem(
          Icons.access_time,
          l10n.minutesShort(widget.recipe.cookingTimeMinutes),
        ),
        const SizedBox(width: 16),
        _buildMetadataItem(
          Icons.restaurant,
          l10n.servingsLabel(widget.recipe.servings),
        ),
        const SizedBox(width: 16),
        if (widget.recipe.caloriesPerServing != null)
          _buildMetadataItem(
            Icons.local_fire_department,
            l10n.caloriesLabel(widget.recipe.caloriesPerServing!),
          ),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    if (widget.recipe.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.recipe.tags.take(4).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIngredients() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ingredientsLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.recipe.ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ingredient.quantity != null && ingredient.quantity!.isNotEmpty
                        ? '${ingredient.name} — ${ingredient.quantity}'
                        : ingredient.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSteps() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.instructionsLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.recipe.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.instruction,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (step.tip != null && step.tip!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '💡 ${step.tip}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActions() {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleShare,
            icon: const Icon(Icons.share, size: 18),
            label: Text(l10n.shareButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Builder(
            builder: (context) {
              final fav = ref.watch(isFavoriteProvider(widget.recipe.id));
              return ElevatedButton.icon(
                onPressed: _handleFavorite,
                icon: Icon(
                  fav ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                ),
                label: Text(fav ? l10n.savedButton : l10n.saveButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getCategoryColor(),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpandButton() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: TextButton.icon(
        onPressed: () {
          _toggleExpand();
        },
        icon: AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: const Icon(Icons.expand_more),
        ),
        label: Text(_isExpanded ? l10n.showLess : l10n.showMore),
        style: TextButton.styleFrom(
          foregroundColor: _getCategoryColor(),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.recipe.category.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.red;
      case 'snack':
        return Colors.purple;
      case 'dessert':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  Color _getDifficultyColor() {
    switch (widget.recipe.difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
