library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/semantic_colors.dart';

class IngredientChipsCard extends StatelessWidget {
  const IngredientChipsCard({
    required this.controller,
    required this.ingredients,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final TextEditingController controller;
  final List<String> ingredients;
  final VoidCallback onAdd;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: semantic.cardSurface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ingredientsCardTitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: semantic.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.ingredientsCardSubtitle,
            style: TextStyle(fontSize: 13.sp, color: semantic.mutedText),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: l10n.ingredientHint,
                    hintStyle: TextStyle(color: semantic.mutedText),
                    filled: true,
                    fillColor: semantic.elevatedSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              SizedBox(width: 8.w),
              FilledButton(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (ingredients.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  l10n.noIngredientsYet,
                  style: TextStyle(color: semantic.mutedText),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: ingredients.map((ing) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: InputChip(
                    key: ValueKey(ing),
                    label: Text(ing),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onRemove(ing),
                    backgroundColor: scheme.primaryContainer.withValues(alpha: 0.5),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
