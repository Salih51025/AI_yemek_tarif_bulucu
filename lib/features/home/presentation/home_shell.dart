/// Main app shell with bottom navigation bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../favorites/presentation/screens/favorites_screen.dart';
import '../../recipe/presentation/screens/ingredient_input_screen.dart';
import '../../recipe/presentation/screens/trending_screen.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      _TabItem(
          icon: Icons.auto_awesome_outlined,
          activeIcon: Icons.auto_awesome,
          label: l10n.navGenerate),
      _TabItem(
          icon: Icons.trending_up_outlined,
          activeIcon: Icons.trending_up,
          label: l10n.navTrending),
      _TabItem(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: l10n.navSaved),
      _TabItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: l10n.navProfile),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          IngredientInputScreen(),
          TrendingScreen(),
          FavoritesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: const Duration(milliseconds: 280),
        destinations: tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
