library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/semantic_colors.dart';

class IngredientPhotoCard extends StatelessWidget {
  const IngredientPhotoCard({
    required this.imageBytes,
    required this.onPickGallery,
    required this.onClear,
    super.key,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPickGallery;
  final VoidCallback onClear;

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
          Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: scheme.secondary, size: 22.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  l10n.ingredientPhotoTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: semantic.primaryText,
                  ),
                ),
              ),
              if (imageBytes != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClear,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.memory(
                imageBytes!,
                height: 160.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Material(
              color: semantic.elevatedSurface,
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                onTap: onPickGallery,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  height: 110.h,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 40.sp, color: scheme.primary),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.tapToAddPhoto,
                        style: TextStyle(
                          color: semantic.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
