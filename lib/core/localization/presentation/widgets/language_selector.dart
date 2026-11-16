/// Premium language selector (popup → optional bottom sheet later).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../debug/session_debug_log.dart';
import '../../app_localizations.dart';
import '../locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);

    return PopupMenuButton<Locale?>(
      tooltip: AppLocalizations.of(context).languageTitle,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language),
          const SizedBox(width: 6),
          Text(_shortLabel(current ?? Localizations.localeOf(context))),
        ],
      ),
      itemBuilder: (context) {
        final l10n = AppLocalizations.of(context);
        return <PopupMenuEntry<Locale?>>[
          _item(context, const Locale('en'), '🇺🇸', l10n.languageEnglish),
          _item(context, const Locale('tr'), '🇹🇷', l10n.languageTurkish),
          _item(context, const Locale('de'), '🇩🇪', l10n.languageGerman),
          _item(context, const Locale('ja'), '🇯🇵', l10n.languageJapanese),
          const PopupMenuDivider(),
          PopupMenuItem<Locale?>(
            value: null,
            child: Row(
              children: [
                const Text('🌐'),
                const SizedBox(width: 10),
                Text(l10n.appearanceSystem), // reuse "System" label for now
              ],
            ),
          ),
        ];
      },
      onSelected: (locale) async {
        // #region agent log
        SessionDebugLog.log(
          location: 'language_selector.dart:onSelected',
          message: 'language selected',
          hypothesisId: 'L3',
          data: {'locale': locale?.toLanguageTag()},
          runId: 'locale-pre',
        );
        // #endregion

        await ref.read(localeProvider.notifier).setLocale(locale);
      },
    );
  }

  static PopupMenuItem<Locale?> _item(
    BuildContext context,
    Locale locale,
    String flag,
    String label,
  ) {
    return PopupMenuItem<Locale?>(
      value: locale,
      child: Row(
        children: [
          Text(flag),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  static String _shortLabel(Locale locale) =>
      locale.languageCode.toUpperCase();
}

