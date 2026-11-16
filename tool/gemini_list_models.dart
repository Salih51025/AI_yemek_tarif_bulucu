import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final key = _readKey();
  if (key.isEmpty) {
    print('no key');
    exit(1);
  }
  final client = HttpClient();
  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=$key',
  );
  final req = await client.getUrl(uri);
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  if (res.statusCode != 200) {
    print('HTTP ${res.statusCode}: $body');
    exit(2);
  }
  final json = jsonDecode(body) as Map<String, dynamic>;
  final models = (json['models'] as List?) ?? [];
  for (final m in models) {
    final name = (m as Map)['name'] as String?;
    final methods = m['supportedGenerationMethods'];
    if (methods != null && methods.toString().contains('generateContent')) {
      print(name);
    }
  }
}

String _readKey() {
  final env = File('.env');
  if (!env.existsSync()) return '';
  for (final line in env.readAsLinesSync()) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      return line.substring('GEMINI_API_KEY='.length).trim();
    }
  }
  return '';
}
