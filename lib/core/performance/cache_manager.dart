/// Performance Cache Manager
///
/// Enterprise-grade caching system with TTL, LRU eviction, memory management,
/// and multi-level caching strategy (memory + disk).
library;

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// CACHE ENTRY
// ============================================================================

class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int accessCount;
  final DateTime lastAccessedAt;

  CacheEntry({
    required this.data,
    required this.expiresAt,
    DateTime? createdAt,
    this.accessCount = 0,
    DateTime? lastAccessedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastAccessedAt = lastAccessedAt ?? DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  CacheEntry<T> withAccess() {
    return CacheEntry(
      data: data,
      expiresAt: expiresAt,
      createdAt: createdAt,
      accessCount: accessCount + 1,
      lastAccessedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toString(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'accessCount': accessCount,
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
    };
  }
}

// ============================================================================
// CACHE CONFIGURATION
// ============================================================================

class CacheConfig {
  final int maxMemoryEntries;
  final Duration defaultTTL;
  final bool enableDiskCache;
  final int maxDiskEntries;
  final Duration diskCleanupInterval;

  const CacheConfig({
    this.maxMemoryEntries = 100,
    this.defaultTTL = const Duration(minutes: 30),
    this.enableDiskCache = true,
    this.maxDiskEntries = 500,
    this.diskCleanupInterval = const Duration(hours: 1),
  });

  static const CacheConfig aggressive = CacheConfig(
    maxMemoryEntries: 500,
    defaultTTL: Duration(hours: 2),
    enableDiskCache: true,
    maxDiskEntries: 2000,
  );

  static const CacheConfig conservative = CacheConfig(
    maxMemoryEntries: 50,
    defaultTTL: Duration(minutes: 10),
    enableDiskCache: false,
  );
}

// ============================================================================
// CACHE STATISTICS
// ============================================================================

class CacheStats {
  final int hits;
  final int misses;
  final int evictions;
  final int size;
  final double hitRate;

  CacheStats({
    required this.hits,
    required this.misses,
    required this.evictions,
    required this.size,
  }) : hitRate = hits + misses > 0 ? hits / (hits + misses) : 0.0;

  @override
  String toString() {
    return 'CacheStats(hits: $hits, misses: $misses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, size: $size, evictions: $evictions)';
  }
}

// ============================================================================
// CACHE MANAGER
// ============================================================================

class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._();

  CacheManager._();

  final Map<String, CacheEntry> _memoryCache = {};
  late final CacheConfig _config;
  late final SharedPreferences? _prefs;
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;
  Timer? _cleanupTimer;

  CacheStats get stats => CacheStats(
        hits: _hits,
        misses: _misses,
        evictions: _evictions,
        size: _memoryCache.length,
      );

  CacheManager({
    CacheConfig? config,
    SharedPreferences? prefs,
  }) : _prefs = prefs {
    _config = config ?? const CacheConfig();
    _startCleanupTimer();
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_config.diskCleanupInterval, (_) {
      _cleanupExpired();
    });
  }

  /// Get value from cache
  T? get<T>(String key) {
    final entry = _memoryCache[key];
    if (entry != null && !entry.isExpired) {
      _hits++;
      _memoryCache[key] = entry.withAccess();
      return entry.data as T;
    }
    _misses++;
    return null;
  }

  /// Set value in cache with optional TTL
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
  }) async {
    final expiresAt = DateTime.now().add(ttl ?? _config.defaultTTL);
    final entry = CacheEntry(
      data: value,
      expiresAt: expiresAt,
    );

    // LRU eviction if cache is full
    if (_memoryCache.length >= _config.maxMemoryEntries) {
      _evictLRU();
    }

    _memoryCache[key] = entry;

    // Also persist to disk if enabled
    if (_config.enableDiskCache && _prefs != null) {
      await _persistToDisk(key, entry);
    }
  }

  /// Remove specific key from cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    if (_config.enableDiskCache && _prefs != null) {
      await _prefs.remove('cache_$key');
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();
    if (_config.enableDiskCache && _prefs != null) {
      final keys =
          _prefs.getKeys().where((k) => k.toString().startsWith('cache_'));
      for (final key in keys) {
        await _prefs.remove(key);
      }
    }
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }

  /// Get or set pattern - fetch from cache or compute and cache
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
  }) async {
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }

    final value = await compute();
    await set(key, value, ttl: ttl);
    return value;
  }

  /// Preload multiple keys
  Future<void> preload<T>(Map<String, T> items, {Duration? ttl}) async {
    for (final entry in items.entries) {
      await set(entry.key, entry.value, ttl: ttl);
    }
  }

  /// Evict least recently used entry
  void _evictLRU() {
    if (_memoryCache.isEmpty) return;

    String? lruKey;
    DateTime? oldestAccess;

    for (final entry in _memoryCache.entries) {
      if (oldestAccess == null ||
          entry.value.lastAccessedAt.isBefore(oldestAccess)) {
        oldestAccess = entry.value.lastAccessedAt;
        lruKey = entry.key;
      }
    }

    if (lruKey != null) {
      _memoryCache.remove(lruKey);
      _evictions++;
    }
  }

  /// Clean up expired entries
  void _cleanupExpired() {
    final expiredKeys = <String>[];
    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _evictions++;
    }
  }

  /// Persist entry to disk
  Future<void> _persistToDisk(String key, CacheEntry entry) async {
    if (_prefs == null) return;
    try {
      final json = jsonEncode({
        'data': entry.data,
        'createdAt': entry.createdAt.toIso8601String(),
        'expiresAt': entry.expiresAt.toIso8601String(),
        'accessCount': entry.accessCount,
        'lastAccessedAt': entry.lastAccessedAt.toIso8601String(),
      });
      await _prefs.setString('cache_$key', json);
    } catch (e) {
      // Silently fail on disk persistence errors
    }
  }

  /// Reset statistics
  void resetStats() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
  }
}
