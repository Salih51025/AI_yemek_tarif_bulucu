/// Premium profile: collapsing header, stats, settings, edit flow.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/presentation/widgets/language_selector.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../favorites/presentation/favorite_providers.dart';
import '../../../location/presentation/location_provider.dart';
import '../../../theme/presentation/theme_provider.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import 'region_onboarding_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).load();
      ref.read(favoritesNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileNotifierProvider);
    final favCount = ref.watch(
      favoritesNotifierProvider.select((s) => s.byId.length),
    );
    final themeMode = ref.watch(themeModeProvider);
    final locationPrefs = ref.watch(locationPrefsProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Signed in';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(profile.profile?.displayName ?? 'Chef'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 48.h),
                      child: Hero(
                        tag: 'profile-avatar',
                        child: CircleAvatar(
                          radius: 44.r,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Icon(Icons.person, size: 48.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              const LanguageSelector(),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EditProfileScreen(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    ref.read(appStateProvider.notifier).setUnauthenticated();
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email, style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 16.h),
                  _StatsRow(favoriteCount: favCount),
                  SizedBox(height: 24.h),
                  _SectionHeader(title: l10n.preferencesTitle),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: l10n.appearanceTitle,
                    subtitle: _themeLabel(themeMode),
                    onTap: () => ref.read(themeModeProvider.notifier).cycleTheme(),
                  ),
                  _SettingsTile(
                    icon: Icons.location_on_outlined,
                    title: l10n.hometownTitle,
                    subtitle: _regionLabel(profile, locationPrefs),
                    onTap: () => _showRegionSheet(context),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.pin_drop_outlined),
                    title: Text(l10n.rememberLocationTitle),
                    value: locationPrefs.rememberLocation,
                    onChanged: (v) => ref
                        .read(locationPrefsProvider.notifier)
                        .setRememberLocation(v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => AppLocalizations.of(context).appearanceLight,
        ThemeMode.dark => AppLocalizations.of(context).appearanceDark,
        ThemeMode.system => AppLocalizations.of(context).appearanceSystem,
      };

  String _regionLabel(dynamic profile, dynamic locationPrefs) {
    final city = profile.profile?.regionCity ?? locationPrefs.savedCity;
    final country = profile.profile?.regionCountry ?? locationPrefs.savedCountry;
    if (country != null && country.isNotEmpty) {
      return '${city ?? ''} $country'.trim();
    }
    return 'Set your region for local recipes';
  }

  void _showRegionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: RegionOnboardingScreen(
          onComplete: () {
            final p = ref.read(profileNotifierProvider).profile;
            if (p?.hasRegion == true) {
              ref.read(locationPrefsProvider.notifier).saveRegion(
                    country: p!.regionCountry!,
                    city: p.regionCity ?? '',
                  );
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.favoriteCount});

  final int favoriteCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.favorite,
            label: 'Saved',
            value: '$favoriteCount',
            color: Colors.red[400]!,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            icon: Icons.auto_awesome,
            label: 'AI Chef',
            value: 'Pro',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
