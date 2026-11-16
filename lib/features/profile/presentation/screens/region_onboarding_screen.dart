/// Regional cuisine onboarding screen — shown once after signup.
///
/// Lets the user pick country + city so the app can surface locally-relevant
/// recipes (Turkish dishes for Bursa users, etc.).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/profile_provider.dart';

class RegionOnboardingScreen extends ConsumerStatefulWidget {
  const RegionOnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  ConsumerState<RegionOnboardingScreen> createState() =>
      _RegionOnboardingScreenState();
}

class _RegionOnboardingScreenState
    extends ConsumerState<RegionOnboardingScreen> {
  String? _selectedCountry;
  final _cityController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final country = _selectedCountry;
    if (country == null) return;
    setState(() => _saving = true);
    await ref.read(profileNotifierProvider.notifier).updateRegion(
          country: country,
          city: _cityController.text.trim(),
        );
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              Text(
                'Where are you from?',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'We\'ll personalise recipes with local dishes from your region.',
                style: TextStyle(fontSize: 15.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 40.h),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                value: _selectedCountry,
                items: _countries
                    .map((c) => DropdownMenuItem(
                          value: c['code'],
                          child: Text(c['name']!),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCountry = v),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City / Region (optional)',
                  hintText: 'e.g. Bursa, Istanbul, Ankara',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _selectedCountry == null || _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue'),
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _countries = [
  {'code': 'TR', 'name': '🇹🇷 Turkey'},
  {'code': 'US', 'name': '🇺🇸 United States'},
  {'code': 'GB', 'name': '🇬🇧 United Kingdom'},
  {'code': 'DE', 'name': '🇩🇪 Germany'},
  {'code': 'FR', 'name': '🇫🇷 France'},
  {'code': 'IT', 'name': '🇮🇹 Italy'},
  {'code': 'ES', 'name': '🇪🇸 Spain'},
  {'code': 'JP', 'name': '🇯🇵 Japan'},
  {'code': 'IN', 'name': '🇮🇳 India'},
  {'code': 'MX', 'name': '🇲🇽 Mexico'},
  {'code': 'BR', 'name': '🇧🇷 Brazil'},
  {'code': 'CN', 'name': '🇨🇳 China'},
  {'code': 'KR', 'name': '🇰🇷 South Korea'},
  {'code': 'TH', 'name': '🇹🇭 Thailand'},
  {'code': 'GR', 'name': '🇬🇷 Greece'},
  {'code': 'OTHER', 'name': '🌍 Other'},
];
