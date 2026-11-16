/// Premium generate screen: ingredients + photo → AI recipes.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/debug/agent_debug_log.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/presentation/widgets/language_selector.dart';
import '../../../../core/navigation/app_page_route.dart';
import '../../../../core/security/env_config.dart';
import '../../../../core/theme/semantic_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../ai_loading/presentation/premium_ai_overlay.dart';
import '../../../generate/presentation/widgets/generate_cta_button.dart';
import '../../../generate/presentation/widgets/ingredient_chips_card.dart';
import '../../../generate/presentation/widgets/ingredient_photo_card.dart';
import '../providers/recipe_generation_notifier.dart';
import 'recipe_list_screen.dart';

class IngredientInputScreen extends ConsumerStatefulWidget {
  const IngredientInputScreen({super.key});

  @override
  ConsumerState<IngredientInputScreen> createState() =>
      _IngredientInputScreenState();
}

class _IngredientInputScreenState extends ConsumerState<IngredientInputScreen> {
  final _ingredientController = TextEditingController();
  final List<String> _ingredients = [];
  Uint8List? _imageBytes;
  String? _imageMimeType;

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticFeedback.selectionClick();
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (!mounted || image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageMimeType = _mimeFromName(image.name);
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.couldNotPickImage}: $e')),
      );
    }
  }

  static String _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isEmpty || _ingredients.contains(ingredient)) return;
    HapticFeedback.lightImpact();
    setState(() {
      _ingredients.add(ingredient);
      _ingredientController.clear();
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() => _ingredients.remove(ingredient));
  }

  void _clearImage() => setState(() {
        _imageBytes = null;
        _imageMimeType = null;
      });

  Future<void> _generateRecipes() async {
    if (_ingredients.isEmpty && _imageBytes == null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addIngredientsOrUpload)),
      );
      return;
    }

    final response = await ref
        .read(recipeGenerationNotifierProvider.notifier)
        .generate(
          ingredients: _ingredients,
          imageBytes: _imageBytes,
          imageMimeType: _imageMimeType,
        );

    if (!mounted) return;

    if (response != null) {
      HapticFeedback.mediumImpact();
      await Navigator.of(context).push(
        AppPageRoute<void>(
          page: RecipeListScreen(initialResponse: response),
          transition: AppTransition.slideUp,
        ),
      );
      if (mounted) {
        setState(() {
          _ingredients.clear();
          _imageBytes = null;
          _imageMimeType = null;
          _ingredientController.clear();
        });
      }
    } else {
      final state = ref.read(recipeGenerationNotifierProvider);
      final message = state is RecipeGenerationFailure
          ? state.message
          : 'Generation failed';
      if (!mounted) return;
      await _showFailureDialog(message);
    }
  }

  Future<void> _showFailureDialog(String message) async {
    final lastLog = await AgentDebugLog.readLastFromPrefs();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).recipeGenerationFailedTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                Text(
                  'Model: ${EnvConfig.geminiModel}',
                  style: TextStyle(fontSize: 12.sp, color: context.semantic.mutedText),
                ),
                if (lastLog != null) ...[
                  const SizedBox(height: 8),
                  Text(lastLog, style: const TextStyle(fontSize: 10)),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx).okLabel)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      recipeGenerationNotifierProvider.select((s) => s is RecipeGenerationLoading),
    );
    final l10n = AppLocalizations.of(context);
    final semantic = context.semantic;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.generateTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: semantic.primaryText,
          ),
        ),
        centerTitle: false,
        actions: const [LanguageSelector()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : () => _pickImage(ImageSource.camera),
        icon: const Icon(Icons.camera_alt_outlined),
        label: Text(l10n.scanButton),
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
      ),
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              l10n.generateHero,
                              style: TextStyle(
                                fontSize: 22.sp,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: semantic.primaryText,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          IngredientPhotoCard(
                            imageBytes: _imageBytes,
                            onPickGallery: () => _pickImage(ImageSource.gallery),
                            onClear: _clearImage,
                          ),
                          SizedBox(height: 16.h),
                          IngredientChipsCard(
                            controller: _ingredientController,
                            ingredients: _ingredients,
                            onAdd: _addIngredient,
                            onRemove: _removeIngredient,
                          ),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    child: GenerateCtaButton(
                      isLoading: isLoading,
                      onPressed: _generateRecipes,
                    ),
                  ),
                  if (kDebugMode) const _AgentDebugFooter(),
                ],
              ),
            ),
            if (isLoading) const Positioned.fill(child: PremiumAiOverlay()),
          ],
        ),
      ),
    );
  }
}

class _AgentDebugFooter extends ConsumerStatefulWidget {
  const _AgentDebugFooter();

  @override
  ConsumerState<_AgentDebugFooter> createState() => _AgentDebugFooterState();
}

class _AgentDebugFooterState extends ConsumerState<_AgentDebugFooter> {
  String? _line;
  Map<String, dynamic>? _parsed;
  ProviderSubscription<RecipeGenerationUiState>? _generationSubscription;

  @override
  void initState() {
    super.initState();
    _generationSubscription = ref.listenManual(
      recipeGenerationNotifierProvider,
      (_, __) => _load(),
    );
    _load();
  }

  @override
  void dispose() {
    _generationSubscription?.close();
    super.dispose();
  }

  Future<void> _load() async {
    final log = await AgentDebugLog.readLastFromPrefs();
    if (!mounted) return;
    Map<String, dynamic>? parsed;
    if (log != null) {
      try {
        parsed = jsonDecode(log) as Map<String, dynamic>;
      } catch (_) {}
    }
    setState(() {
      _line = log;
      _parsed = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_line == null || _parsed == null) return const SizedBox.shrink();
    return Material(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          '${_parsed!['message']} ${_parsed!['data']}',
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
