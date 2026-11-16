/// API-related constants for external service integrations.
/// 
/// Contains endpoint configurations, timeout values, and
/// other API-specific constants used across the application.
class ApiConstants {
  ApiConstants._();

  /// Default connection timeout in milliseconds
  static const int connectionTimeoutMs = 30000;

  /// Default receive timeout in milliseconds
  static const int receiveTimeoutMs = 30000;

  /// Default send timeout in milliseconds
  static const int sendTimeoutMs = 30000;

  /// API request headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Supabase Edge Function base URL (configured at runtime)
  static const String supabaseEdgeFunctionBase = '/functions/v1';

  /// Retry count for failed API requests
  static const int maxRetryCount = 3;

  /// Retry delay in milliseconds
  static const int retryDelayMs = 1000;
}
