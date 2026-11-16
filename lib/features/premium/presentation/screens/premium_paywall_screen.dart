/// Premium paywall screen for subscription upgrade.
///
/// Features a high-conversion subscription placeholder with
/// feature comparison grid (Free vs. Premium Pro) and payment buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Premium paywall screen widget.
class PremiumPaywallScreen extends StatelessWidget {
  const PremiumPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 64.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Upgrade to Premium',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Unlock unlimited AI recipe generation and advanced features',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Feature Comparison Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _FeatureComparisonGrid(),
              ),

              SizedBox(height: 32.h),

              // Pricing Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Free Plan Card
                    _PricingCard(
                      title: 'Free',
                      price: '\$0',
                      period: 'forever',
                      features: const [
                        '5 recipe generations per day',
                        'Basic ingredient recognition',
                        'Standard recipe database',
                        'Community support',
                      ],
                      isSelected: false,
                      onTap: () {
                        // Navigate back to free tier
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Premium Plan Card
                    _PricingCard(
                      title: 'Premium Pro',
                      price: '\$9.99',
                      period: '/month',
                      features: const [
                        'Unlimited recipe generations',
                        'Advanced AI ingredient recognition',
                        'Premium recipe database',
                        'Priority customer support',
                        'Save unlimited favorites',
                        'Custom dietary preferences',
                        'Offline recipe access',
                        'Ad-free experience',
                      ],
                      isSelected: true,
                      onTap: () {
                        // TODO: Implement Stripe/RevenueCat payment flow
                        _showPaymentDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Trust Badges
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TrustBadge(
                      icon: Icons.security,
                      label: 'Secure Payment',
                    ),
                    _TrustBadge(
                      icon: Icons.cancel,
                      label: 'Cancel Anytime',
                    ),
                    _TrustBadge(
                      icon: Icons.star,
                      label: '30-Day Trial',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Integration'),
        content: const Text(
          'Payment processing via Stripe or RevenueCat will be integrated here. This is a placeholder for the payment flow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Feature comparison grid widget.
class _FeatureComparisonGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Feature Rows
          const _FeatureRow(
            feature: 'Recipe Generations',
            freeValue: '5/day',
            premiumValue: 'Unlimited',
          ),
          const _FeatureRow(
            feature: 'AI Recognition',
            freeValue: 'Basic',
            premiumValue: 'Advanced',
          ),
          const _FeatureRow(
            feature: 'Recipe Database',
            freeValue: 'Standard',
            premiumValue: 'Premium',
          ),
          const _FeatureRow(
            feature: 'Customer Support',
            freeValue: 'Community',
            premiumValue: 'Priority',
          ),
          const _FeatureRow(
            feature: 'Favorites',
            freeValue: 'Limited',
            premiumValue: 'Unlimited',
          ),
          const _FeatureRow(
            feature: 'Dietary Preferences',
            freeValue: 'Basic',
            premiumValue: 'Custom',
          ),
          const _FeatureRow(
            feature: 'Offline Access',
            freeValue: 'No',
            premiumValue: 'Yes',
          ),
          const _FeatureRow(
            feature: 'Ads',
            freeValue: 'Yes',
            premiumValue: 'No',
          ),
        ],
      ),
    );
  }
}

/// Feature row widget for comparison grid.
class _FeatureRow extends StatelessWidget {
  final String feature;
  final String freeValue;
  final String premiumValue;

  const _FeatureRow({
    required this.feature,
    required this.freeValue,
    required this.premiumValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              freeValue,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              premiumValue,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pricing card widget.
class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[800],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'POPULAR',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[800],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Features
              ...features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20.sp,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.green,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              SizedBox(height: 20.h),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[200],
                    foregroundColor: isSelected ? Colors.white : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    isSelected ? 'Start Premium Trial' : 'Continue with Free',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trust badge widget.
class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24.sp,
          color: Colors.grey[600],
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
