/// Global Flutter/Dart error hooks for startup and runtime.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../debug/debug_session_log.dart';

typedef StartupLog = void Function(String message);

/// Installs zone + framework error handlers. Safe to call once from [main].
void installStartupErrorHandlers({StartupLog? log}) {
  final write = log ?? debugPrint;

  FlutterError.onError = (details) {
    write('[FlutterError] ${details.exceptionAsString()}');
    // #region agent log
    DebugSessionLog.log(
      location: 'startup_error_handlers.dart:flutter',
      message: 'FlutterError',
      hypothesisId: 'H3',
      data: {'error': details.exceptionAsString()},
    );
    // #endregion
    if (details.stack != null) {
      write(details.stack.toString());
    }
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    write('[PlatformDispatcher] $error');
    write(stack.toString());
    // #region agent log
    DebugSessionLog.log(
      location: 'startup_error_handlers.dart:platform',
      message: 'PlatformDispatcher error',
      hypothesisId: 'H1',
      data: {'error': error.toString()},
    );
    // #endregion
    return true;
  };
}

/// Runs [body] inside [runZonedGuarded] and logs uncaught async errors.
Future<void> runAppGuarded(
  Future<void> Function() body, {
  StartupLog? log,
}) async {
  final write = log ?? debugPrint;
  await runZonedGuarded(
    body,
    (error, stack) {
      write('[Zone] Uncaught error: $error');
      write(stack.toString());
      // #region agent log
      DebugSessionLog.log(
        location: 'startup_error_handlers.dart:zone',
        message: 'zone uncaught',
        hypothesisId: 'H1',
        data: {'error': error.toString()},
      );
      // #endregion
    },
  );
}
