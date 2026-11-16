import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// NDJSON debug logger — session `21a6f9`, file `debug-21a6f9.log`.
abstract final class DebugSessionLog {
  static const _sessionId = '21a6f9';
  static const _logFileName = 'debug-21a6f9.log';
  static const _ingestPath =
      '/ingest/c50e630d-b5c6-4859-9e01-aa5d26587ff2';

  static String get _host {
    if (!kIsWeb && Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  static Uri get _endpoint =>
      Uri.parse('http://$_host:7393$_ingestPath');

  static void log({
    required String location,
    required String message,
    required String hypothesisId,
    Map<String, Object?> data = const {},
    String runId = 'pre-fix',
  }) {
    if (!kDebugMode) return;
    final payload = <String, Object?>{
      'sessionId': _sessionId,
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    final line = '${jsonEncode(payload)}\n';
    debugPrint('[dbg21:$hypothesisId] $message $data');
    unawaited(_persist(line));
    http
        .post(
          _endpoint,
          headers: {
            'Content-Type': 'application/json',
            'X-Debug-Session-Id': _sessionId,
          },
          body: jsonEncode(payload),
        )
        .ignore();
  }

  static Future<void> _persist(String line) async {
    const paths = [_logFileName, '.cursor/$_logFileName'];
    for (final path in paths) {
      try {
        final file = File(path);
        if (path.contains('/') || path.contains(r'\')) {
          await file.parent.create(recursive: true);
        }
        await file.writeAsString(line, mode: FileMode.append);
        return;
      } catch (_) {}
    }
    try {
      final workspaceFile = File(
        r'c:\Users\Healer\Desktop\AI_yemek_tarif_bulucu\debug-21a6f9.log',
      );
      await workspaceFile.writeAsString(line, mode: FileMode.append);
    } catch (_) {}
    try {
      final dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/$_logFileName')
          .writeAsString(line, mode: FileMode.append);
    } catch (_) {}
  }
}
