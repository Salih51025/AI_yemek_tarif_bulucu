/// Offline Storage Service
///
/// Enterprise-grade offline-first architecture using Hive for local data persistence.
/// Provides caching, sync queue, and optimistic updates for seamless offline experience.
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// ============================================================================
// STORAGE KEYS
// ============================================================================

class StorageKeys {
  static const String recipes = 'recipes';
  static const String favorites = 'favorites';
  static const String syncQueue = 'sync_queue';
  static const String userPreferences = 'user_preferences';
  static const String cachedRecipes = 'cached_recipes';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
}

// ============================================================================
// SYNC QUEUE ITEM
// ============================================================================

class SyncQueueItem {
  late String id;
  final String operation; // 'create', 'update', 'delete'
  final String entityType; // 'recipe', 'favorite', 'preference'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  SyncQueueItem({
    required this.operation,
    required this.entityType,
    required this.data,
    this.retryCount = 0,
  })  : id = const Uuid().v4(),
        createdAt = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation,
      'entityType': entityType,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      operation: json['operation'] as String,
      entityType: json['entityType'] as String,
      data: json['data'] as Map<String, dynamic>,
      retryCount: json['retryCount'] as int? ?? 0,
    )..id = json['id'] as String;
  }
}

// ============================================================================
// OFFLINE STORAGE SERVICE
// ============================================================================

class OfflineStorageService {
  static OfflineStorageService? _instance;
  static OfflineStorageService get instance =>
      _instance ??= OfflineStorageService._();

  OfflineStorageService._();

  late Box _recipesBox;
  late Box _favoritesBox;
  late Box _syncQueueBox;
  late Box _preferencesBox;
  late Box _cachedRecipesBox;

  bool _isInitialized = false;

  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters if needed
    // Hive.registerAdapter(SyncQueueItemAdapter());

    // Open boxes
    _recipesBox = await Hive.openBox(StorageKeys.recipes);
    _favoritesBox = await Hive.openBox(StorageKeys.favorites);
    _syncQueueBox = await Hive.openBox(StorageKeys.syncQueue);
    _preferencesBox = await Hive.openBox(StorageKeys.userPreferences);
    _cachedRecipesBox = await Hive.openBox(StorageKeys.cachedRecipes);

    _isInitialized = true;
  }

  /// Check if storage is initialized
  bool get isInitialized => _isInitialized;

  // ============================================================================
  // RECIPE STORAGE
  // ============================================================================

  /// Cache a recipe locally
  Future<void> cacheRecipe(
      String recipeId, Map<String, dynamic> recipeData) async {
    await _cachedRecipesBox.put(recipeId, recipeData);
  }

  /// Get cached recipe
  Map<String, dynamic>? getCachedRecipe(String recipeId) {
    return _cachedRecipesBox.get(recipeId) as Map<String, dynamic>?;
  }

  /// Cache multiple recipes
  Future<void> cacheRecipes(List<Map<String, dynamic>> recipes) async {
    final Map<String, dynamic> recipesMap = {};
    for (final recipe in recipes) {
      recipesMap[recipe['id'] as String] = recipe;
    }
    await _cachedRecipesBox.putAll(recipesMap);
  }

  /// Get all cached recipes
  List<Map<String, dynamic>> getAllCachedRecipes() {
    return _cachedRecipesBox.values
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Clear cached recipes
  Future<void> clearCachedRecipes() async {
    await _cachedRecipesBox.clear();
  }

  /// Remove specific cached recipe
  Future<void> removeCachedRecipe(String recipeId) async {
    await _cachedRecipesBox.delete(recipeId);
  }

  // ============================================================================
  // FAVORITES STORAGE
  // ============================================================================

  /// Add recipe to favorites
  Future<void> addToFavorites(
      String recipeId, Map<String, dynamic> recipeData) async {
    await _favoritesBox.put(recipeId, recipeData);
    // Also add to sync queue
    await addToSyncQueue(SyncQueueItem(
      operation: 'create',
      entityType: 'favorite',
      data: {'recipeId': recipeId},
    ));
  }

  /// Remove recipe from favorites
  Future<void> removeFromFavorites(String recipeId) async {
    await _favoritesBox.delete(recipeId);
    // Add to sync queue
    await addToSyncQueue(SyncQueueItem(
      operation: 'delete',
      entityType: 'favorite',
      data: {'recipeId': recipeId},
    ));
  }

  /// Check if recipe is favorited
  bool isFavorited(String recipeId) {
    return _favoritesBox.containsKey(recipeId);
  }

  /// Get all favorite recipes
  List<Map<String, dynamic>> getFavorites() {
    return _favoritesBox.values.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await _favoritesBox.clear();
  }

  // ============================================================================
  // SYNC QUEUE
  // ============================================================================

  /// Add operation to sync queue
  Future<void> addToSyncQueue(SyncQueueItem item) async {
    await _syncQueueBox.put(item.id, item.toJson());
  }

  /// Get all sync queue items
  List<SyncQueueItem> getSyncQueue() {
    return _syncQueueBox.values
        .map((e) => SyncQueueItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Remove item from sync queue
  Future<void> removeFromSyncQueue(String itemId) async {
    await _syncQueueBox.delete(itemId);
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    await _syncQueueBox.clear();
  }

  /// Increment retry count for sync item
  Future<void> incrementRetryCount(String itemId) async {
    final itemJson = _syncQueueBox.get(itemId) as Map<String, dynamic>?;
    if (itemJson != null) {
      final item = SyncQueueItem.fromJson(itemJson);
      itemJson['retryCount'] = item.retryCount + 1;
      await _syncQueueBox.put(itemId, itemJson);
    }
  }

  // ============================================================================
  // USER PREFERENCES
  // ============================================================================

  /// Save user preference
  Future<void> setPreference(String key, dynamic value) async {
    await _preferencesBox.put(key, value);
  }

  /// Get user preference
  T? getPreference<T>(String key) {
    return _preferencesBox.get(key) as T?;
  }

  /// Remove user preference
  Future<void> removePreference(String key) async {
    await _preferencesBox.delete(key);
  }

  /// Clear all preferences
  Future<void> clearPreferences() async {
    await _preferencesBox.clear();
  }

  // ============================================================================
  // SYNC METADATA
  // ============================================================================

  /// Set last sync timestamp
  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    await _preferencesBox.put(
        StorageKeys.lastSyncTimestamp, timestamp.toIso8601String());
  }

  /// Get last sync timestamp
  DateTime? getLastSyncTimestamp() {
    final timestampStr =
        _preferencesBox.get(StorageKeys.lastSyncTimestamp) as String?;
    if (timestampStr != null) {
      return DateTime.parse(timestampStr);
    }
    return null;
  }

  // ============================================================================
  // STORAGE MANAGEMENT
  // ============================================================================

  /// Get storage size in bytes
  Future<int> getStorageSize() async {
    int totalSize = 0;

    totalSize += _recipesBox.length;
    totalSize += _favoritesBox.length;
    totalSize += _syncQueueBox.length;
    totalSize += _preferencesBox.length;
    totalSize += _cachedRecipesBox.length;

    return totalSize;
  }

  /// Clear all storage (use with caution)
  Future<void> clearAll() async {
    await _recipesBox.clear();
    await _favoritesBox.clear();
    await _syncQueueBox.clear();
    await _preferencesBox.clear();
    await _cachedRecipesBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _recipesBox.close();
    await _favoritesBox.close();
    await _syncQueueBox.close();
    await _preferencesBox.close();
    await _cachedRecipesBox.close();
    _isInitialized = false;
  }
}
