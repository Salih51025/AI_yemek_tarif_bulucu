import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Debug-session NDJSON logger (session `271baf`, file `debug-271baf.log`).
abstract final class SessionDebugLog {
  static const _sessionId = '271baf';
  static const _logFileName = 'debug-271baf.log';
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
    debugPrint('[dbg:$hypothesisId] $message $data');
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
          r'c:\Users\Healer\Desktop\AI_yemek_tarif_bulucu\debug-271baf.log');
      await workspaceFile.writeAsString(line, mode: FileMode.append);
      return;
    } catch (_) {}
    try {
      final dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/$_logFileName')
          .writeAsString(line, mode: FileMode.append);
    } catch (_) {}
  }
}
