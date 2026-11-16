/// Reliable expandable recipe card (no broken SizeTransition on summary).
library;

import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/recipe_model.dart';

class RecipeCard extends StatefulWidget {
  const RecipeCard({required this.recipe, super.key});

  final RecipeModel recipe;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final r = widget.recipe;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 140,
            color: theme.colorScheme.primaryContainer,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: _Chip(label: r.difficulty),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _Chip(label: '${r.cookingTimeMinutes} min'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (r.description != null && r.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    r.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _expanded
                            ? l10n.showLess
                            : '${l10n.showMore}: ${l10n.ingredientsLabel} & ${l10n.stepsLabel}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_expanded) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.ingredientsLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...r.ingredients.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        i.quantity != null && i.quantity!.isNotEmpty
                            ? '• ${i.name} — ${i.quantity}'
                            : '• ${i.name}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.stepsLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...r.steps.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            child: Text('${e.key + 1}',
                                style: const TextStyle(fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(e.value.instruction)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
