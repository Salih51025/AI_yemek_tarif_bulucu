# AI Chef — Architecture

## Target folder structure

```
lib/
├── main.dart
├── app/                          # (optional) app-level router, localization
├── core/
│   ├── constants/
│   ├── debug/                    # debug-only instrumentation
│   ├── errors/                   # Failures + Exceptions
│   ├── network/
│   ├── performance/
│   ├── providers/                # global Riverpod (bootstrap, firebase, supabase)
│   ├── repositories/             # BaseRepository
│   ├── security/                 # EnvConfig, TokenManager
│   ├── services/
│   │   ├── ai/
│   │   │   ├── ai_providers.dart
│   │   │   ├── gemini_service.dart
│   │   │   ├── gemini_prompts.dart
│   │   │   ├── recipe_ai_parser.dart
│   │   │   └── recipe_generation_service.dart
│   │   └── app_bootstrap_service.dart
│   ├── theme/
│   ├── usecases/
│   ├── utils/                    # image_compressor, formatters
│   └── widgets/                  # shared UI (nav bar, buttons, skeletons)
├── features/
│   ├── auth/
│   │   ├── data/ (datasources, repositories)
│   │   ├── domain/ (entities, models, usecases)
│   │   └── presentation/ (providers, screens, widgets)
│   ├── recipe/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── premium/
└── shared/                       # cross-feature DTOs / extensions (future)
```

## Layers

| Layer | Responsibility |
|--------|----------------|
| **Presentation** | Widgets, `StateNotifier` / `AsyncNotifier`, navigation |
| **Domain** | Entities, models, use cases, repository contracts |
| **Data** | Repository impl, remote/local datasources |
| **Core services** | Gemini, compression, bootstrap — no UI |

## AI pipeline

```
UI → RecipeGenerationNotifier → RecipeRepository
  → RecipeRemoteDataSource → ImageCompressor (if image)
  → RecipeGenerationService → GeminiService (JSON mode)
  → RecipeAiParser → List<RecipeModel>
```

## State management

- **Riverpod** `Provider` for DI graph
- **`RecipeGenerationNotifier`** owns loading / success / failure for generation
- Auth via existing `appStateProvider` + Firebase stream

## Future features (hooks)

| Feature | Extension point |
|---------|-----------------|
| Favorites | `ToggleFavoriteRecipeUseCase` + Supabase `recipes_history` |
| History | `getRecipeHistory` on repository |
| Calories | optional field in AI JSON + profile settings |
| i18n | `RecipeGenerationConfig.language` + ARB files |
| Personalization | system instruction + user prefs in `GeminiPrompts` |
