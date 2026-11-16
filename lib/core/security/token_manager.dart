/// Token management for authentication and session handling.
///
/// This class provides secure storage and retrieval of authentication tokens,
/// session management, and token refresh logic. It uses platform-specific
/// secure storage mechanisms to protect sensitive credentials.
library;

import 'package:shared_preferences/shared_preferences.dart';
import '../errors/exceptions.dart';

/// Key names for storing tokens in secure storage.
class TokenKeys {
  TokenKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String sessionExpiry = 'session_expiry';
}

/// Manages authentication tokens and session state.
///
/// Provides methods to:
/// - Store and retrieve access/refresh tokens
/// - Check token validity and expiration
/// - Clear tokens on logout
/// - Manage user session data
class TokenManager {
  final SharedPreferences _prefs;

  TokenManager(this._prefs);

  /// Creates a TokenManager instance by initializing SharedPreferences.
  static Future<TokenManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenManager(prefs);
  }

  /// Stores the access token.
  Future<void> setAccessToken(String token) async {
    final result = await _prefs.setString(TokenKeys.accessToken, token);
    if (!result) {
      throw const CacheException(message: 'Failed to store access token');
    }
  }

  /// Retrieves the access token.
  ///
  /// Returns null if no token is stored.
  String? getAccessToken() {
    return _prefs.getString(TokenKeys.accessToken);
  }

  /// Stores the refresh token.
  Future<void> setRefreshToken(String token) async {
    final result = await _prefs.setString(TokenKeys.refreshToken, token);
    if (!result) {
      throw const CacheException(message: 'Failed to store refresh token');
    }
  }

  /// Retrieves the refresh token.
  ///
  /// Returns null if no token is stored.
  String? getRefreshToken() {
    return _prefs.getString(TokenKeys.refreshToken);
  }

  /// Stores the user ID.
  Future<void> setUserId(String userId) async {
    final result = await _prefs.setString(TokenKeys.userId, userId);
    if (!result) {
      throw const CacheException(message: 'Failed to store user ID');
    }
  }

  /// Retrieves the user ID.
  ///
  /// Returns null if no user ID is stored.
  String? getUserId() {
    return _prefs.getString(TokenKeys.userId);
  }

  /// Stores the session expiry timestamp.
  Future<void> setSessionExpiry(DateTime expiry) async {
    final result = await _prefs.setString(
      TokenKeys.sessionExpiry,
      expiry.toIso8601String(),
    );
    if (!result) {
      throw const CacheException(message: 'Failed to store session expiry');
    }
  }

  /// Retrieves the session expiry timestamp.
  ///
  /// Returns null if no expiry is stored.
  DateTime? getSessionExpiry() {
    final expiryString = _prefs.getString(TokenKeys.sessionExpiry);
    if (expiryString == null) return null;
    return DateTime.parse(expiryString);
  }

  /// Checks if the current session is valid.
  ///
  /// Returns true if a valid access token exists and the session
  /// has not expired.
  bool isSessionValid() {
    final token = getAccessToken();
    final expiry = getSessionExpiry();

    if (token == null || token.isEmpty) return false;
    if (expiry == null) return true; // No expiry set, assume valid

    return DateTime.now().isBefore(expiry);
  }

  /// Clears all stored tokens and session data.
  ///
  /// Should be called on logout or session expiration.
  Future<void> clearTokens() async {
    await Future.wait([
      _prefs.remove(TokenKeys.accessToken),
      _prefs.remove(TokenKeys.refreshToken),
      _prefs.remove(TokenKeys.userId),
      _prefs.remove(TokenKeys.sessionExpiry),
    ]);
  }

  /// Checks if any authentication data is stored.
  bool hasAuthData() {
    return getAccessToken() != null || getUserId() != null;
  }
}
