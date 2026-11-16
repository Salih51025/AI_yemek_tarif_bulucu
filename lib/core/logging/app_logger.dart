/// Centralized structured logger for the AI Chef app.
///
/// Why a dedicated logger vs debugPrint everywhere?
/// - Single place to swap out logging backend (Crashlytics, Datadog, etc.)
/// - Log levels let us filter noise in production vs debug builds
/// - Structured data makes logs machine-parseable for analytics
/// - Never crashes the app — all methods are fire-and-forget
library;

import 'package:flutter/foundation.dart';

enum LogLevel { verbose, debug, info, warning, error }

abstract final class AppLogger {
  static LogLevel _minLevel =
      kDebugMode ? LogLevel.debug : LogLevel.warning;

  static void setMinLevel(LogLevel level) => _minLevel = level;

  static void v(String tag, String message, [Map<String, Object?>? data]) =>
      _log(LogLevel.verbose, tag, message, data);

  static void d(String tag, String message, [Map<String, Object?>? data]) =>
      _log(LogLevel.debug, tag, message, data);

  static void i(String tag, String message, [Map<String, Object?>? data]) =>
      _log(LogLevel.info, tag, message, data);

  static void w(String tag, String message, [Map<String, Object?>? data]) =>
      _log(LogLevel.warning, tag, message, data);

  static void e(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    _log(LogLevel.error, tag, message, {
      if (data != null) ...data,
      if (error != null) 'error': error.toString(),
    });
    // In production: forward to Crashlytics / Sentry here.
    if (!kDebugMode && stackTrace != null) {
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  static void _log(
    LogLevel level,
    String tag,
    String message,
    Map<String, Object?>? data,
  ) {
    if (level.index < _minLevel.index) return;
    if (!kDebugMode && level.index < LogLevel.warning.index) return;

    final prefix = switch (level) {
      LogLevel.verbose => '🔍',
      LogLevel.debug => '🐛',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error => '🔴',
    };

    final dataStr = data != null && data.isNotEmpty ? ' | $data' : '';
    debugPrint('$prefix [$tag] $message$dataStr');
  }
}
