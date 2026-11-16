# Developer Handoff Guide - 10-Minute Deployment

<div align="center">

**AI Chef - Production Deployment Blueprint**

Complete deployment guide for developers and acquisition buyers

</div>

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Flutter Environment Setup](#step-1-flutter-environment-setup)
3. [Step 2: Supabase/Firebase Connection](#step-2-supabasefirebase-connection)
4. [Step 3: Code Generation & Compilation](#step-3-code-generation--compilation)
5. [Step 4: White-Label Customization](#step-4-white-label-customization)
6. [Troubleshooting](#troubleshooting)
7. [Production Checklist](#production-checklist)

---

## Prerequisites

Before starting, ensure you have:

- **Flutter SDK** 3.19 or higher
- **Dart SDK** 3.3 or higher
- **Git** for version control
- **Node.js** 18+ (for Supabase CLI, optional)
- **Supabase Account** (free tier sufficient)
- **Firebase Project** (free tier sufficient)
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA

---

## Step 1: Flutter Environment Setup

### 1.1 Verify Flutter Installation

```bash
flutter --version
```

Expected output:
```
Flutter 3.19.0+ • channel stable
Dart 3.3.0+ •
```

### 1.2 Install Project Dependencies

Navigate to the project root and run:

```bash
flutter pub get
```

This installs all dependencies specified in `pubspec.yaml`.

### 1.3 Verify Device Connection

Check available devices:

```bash
flutter devices
```

For Android, ensure USB debugging is enabled. For iOS, ensure Xcode is installed and simulator is running.

---

## Step 2: Supabase/Firebase Connection

### 2.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click **"New Project"**
3. Choose a region closest to your target audience
4. Set a strong database password (save this securely)
5. Wait for project initialization (~2 minutes)

### 2.2 Configure Supabase Environment Variables

Navigate to your Supabase project dashboard:

1. Go to **Settings → API**
2. Copy the following values:
   - **Project URL** (e.g., `https://xyz.supabase.co`)
   - **anon public** key (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

### 2.3 Set Environment Variables

Create a `.env` file in the project root:

```bash
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Firebase Configuration
FIREBASE_STORAGE_BUCKET=your_firebase_storage_bucket
```

**Alternative: Dart-Define (Recommended for Production)**

```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key --dart-define=FIREBASE_STORAGE_BUCKET=your_bucket
```

### 2.4 Execute Database Schema

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **"New Query"**
4. Paste the schema SQL from `supabase/schema.sql` (if provided)
5. Click **"Run"** to execute the schema

**If no schema file exists**, create these tables manually:

```sql
-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recipes table
CREATE TABLE public.recipes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id),
  title TEXT NOT NULL,
  ingredients JSONB NOT NULL,
  instructions TEXT NOT NULL,
  image_url TEXT,
  is_favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own recipes" ON public.recipes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recipes" ON public.recipes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recipes" ON public.recipes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recipes" ON public.recipes
  FOR DELETE USING (auth.uid() = user_id);
```

### 2.5 Set Up Firebase Storage

1. Go to [firebase.google.com](https://firebase.google.com) and create a project
2. Navigate to **Storage** in the Firebase console
3. Click **"Get Started"**
4. Choose **"Start in Test Mode"** (update rules for production later)
5. Copy your **Storage Bucket URL** (e.g., `gs://your-project.appspot.com`)
6. Add this to your `.env` file as `FIREBASE_STORAGE_BUCKET`

### 2.6 Configure Firebase in Flutter

Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS):

**Android:**
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/`
3. Add to `android/app/build.gradle.kts`:
```kotlin
apply(plugin = "com.google.gms.google-services")
```

**iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place in `ios/Runner/`
3. Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

---

## Step 3: Code Generation & Compilation

### 3.1 Run Code Generation

This generates Freezed models, JSON serialization, and Riverpod providers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Expected output:**
```
[INFO] Generating build script...
[INFO] Build completed successfully
```

**If you encounter issues, try:**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 3.2 Verify Generated Code

Check that `.g.dart` and `.freezed.dart` files are generated in your model directories.

### 3.3 Run Static Analysis

```bash
flutter analyze
```

Fix any reported issues before proceeding.

### 3.4 Compile for Android

```bash
# Debug build
flutter run

# Release build (APK)
flutter build apk --release

# Release build (App Bundle - for Play Store)
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

### 3.5 Compile for iOS

```bash
# Debug build
flutter run

# Release build (requires macOS with Xcode)
flutter build ios --release
```

**Note:** iOS release builds require:
- macOS with Xcode 15+
- Apple Developer Account ($99/year)
- Proper code signing configuration

### 3.6 Test the Application

Before deployment, run the app on a physical device:

```bash
flutter run --release
```

Test critical flows:
- User registration/login
- Ingredient photo upload
- Recipe generation
- Premium paywall display
- Recipe saving/favoriting

---

## Step 4: White-Label Customization

Complete rebranding in under 2 minutes by modifying these key files:

### 4.1 Change App Logo

**Android:**
1. Replace `android/app/src/main/res/mipmap-*/ic_launcher.png` with your logo
2. Use [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/) to generate all sizes

**iOS:**
1. Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with your logo
2. Use [AppIconGenerator](https://appicon.co/) to generate all sizes

### 4.2 Rename Bundle/Package ID

**Android:**
1. Open `android/app/build.gradle.kts`
2. Change `namespace` and `applicationId`:
```kotlin
namespace = "com.yourcompany.yourapp"
defaultConfig {
    applicationId = "com.yourcompany.yourapp"
}
```

**iOS:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** in the project navigator
3. Go to **General → Bundle Identifier**
4. Change to `com.yourcompany.yourapp`

### 4.3 Change Brand Color Scheme

Navigate to `lib/core/theme/app_theme.dart` and modify:

```dart
static const Color primaryColor = Color(0xFFYOUR_HEX_CODE);
static const Color secondaryColor = Color(0xFFYOUR_HEX_CODE);
static const Color accentColor = Color(0xFFYOUR_HEX_CODE);
```

**Material Design 3 Dynamic Colors:**
```dart
static ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: primaryColor, // Change this to your brand color
  brightness: Brightness.light,
);
```

### 4.4 Update App Name

**Android:**
1. Open `android/app/src/main/res/values/strings.xml`
2. Change `<string name="app_name">AI Chef</string>` to your app name

**iOS:**
1. Open `ios/Runner/Info.plist`
2. Change `CFBundleDisplayName` and `CFBundleName` to your app name

### 4.5 Update Display Name in Flutter

Open `lib/main.dart` and modify:

```dart
MaterialApp(
  title: 'Your App Name', // Change this
  // ...
)
```

---

## Troubleshooting

### Common Issues

**Issue: "flutter: command not found"**
```bash
# Add Flutter to your PATH (macOS/Linux)
export PATH="$PATH:/path/to/flutter/bin"

# Windows
set PATH=%PATH%;C:\path\to\flutter\bin
```

**Issue: "Could not resolve dependencies"**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Issue: "build_runner failed"**
```bash
flutter pub run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Issue: Supabase connection error**
- Verify your SUPABASE_URL and SUPABASE_ANON_KEY are correct
- Check that your Supabase project is not paused
- Ensure Row Level Security policies allow your operations

**Issue: Firebase upload fails**
- Verify Firebase Storage rules allow uploads
- Check that FIREBASE_STORAGE_BUCKET is correct
- Ensure user is authenticated before uploading

---

## Production Checklist

Before deploying to production, verify:

### Security
- [ ] Environment variables are set (not hardcoded)
- [ ] Supabase Row Level Security policies are configured
- [ ] Firebase Storage rules are set to production mode
- [ ] API keys are restricted to production domains
- [ ] Debug mode is disabled in release builds

### Performance
- [ ] Images are compressed before upload
- [ ] Lazy loading is implemented for large lists
- [ ] Caching strategy is configured
- [ ] ProGuard/R8 obfuscation is enabled (Android)

### Compliance
- [ ] Privacy policy is implemented
- [ ] Terms of service are added
- [ ] App Store guidelines are followed
- [ ] GDPR/CCPA compliance is addressed

### Monetization
- [ ] Stripe/RevenueCat is configured
- [ ] Premium paywall is tested
- [ ] Subscription tiers are defined
- [ ] Webhook endpoints are secured

### Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass
- [ ] Manual testing on physical devices completed

---

## Additional Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)

### Support
- For technical issues, check the [Troubleshooting](#troubleshooting) section
- Review inline code documentation in `lib/` directory
- Consult `analysis_options.yaml` for code quality standards

---

## Deployment Platforms

### Google Play Store (Android)
1. Create a Google Play Console account ($25 one-time fee)
2. Upload the `.aab` file from `build/app/outputs/bundle/release/`
3. Complete store listing, screenshots, and privacy policy
4. Submit for review (typically 1-3 days)

### Apple App Store (iOS)
1. Enroll in Apple Developer Program ($99/year)
2. Upload the `.ipa` file via Xcode or Transporter
3. Complete store listing, screenshots, and privacy policy
4. Submit for review (typically 1-5 days)

---

<div align="center">

**Deployment Complete! 🚀**

Your AI Chef application is now production-ready and fully customizable.

</div>
