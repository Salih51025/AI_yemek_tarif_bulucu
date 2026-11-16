/// Minimal UI when startup cannot load core services.
library;

import 'package:flutter/material.dart';

import '../services/bootstrap_snapshot.dart';

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({
    required this.snapshot,
    super.key,
  });

  final BootstrapSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BootstrapErrorScreen(snapshot: snapshot),
    );
  }
}

class BootstrapErrorScreen extends StatelessWidget {
  const BootstrapErrorScreen({
    required this.snapshot,
    super.key,
  });

  final BootstrapSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final message = snapshot.fatalError ??
        (snapshot.warnings.join('\n\n').trim().isEmpty
            ? 'Startup failed. Please restart the app.'
            : snapshot.warnings.join('\n\n'));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not start Ingredia',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.4),
              ),
              if (!snapshot.supabaseReady) ...[
                const SizedBox(height: 16),
                const Text(
                  'Try again when you have a stable internet connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
