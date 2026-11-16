# Supabase Configuration Guide

This guide provides step-by-step instructions for configuring the Supabase backend for the AI Chef application.

## Prerequisites

- A Supabase account (free tier available at https://supabase.com)
- Your AI API key (GEMINI_API_KEY or OPENAI_API_KEY)

## Step 1: Create a New Supabase Project

1. Log in to your Supabase dashboard at https://supabase.com/dashboard
2. Click "New Project"
3. Fill in the project details:
   - **Name**: AI Chef (or your preferred name)
   - **Database Password**: Generate a strong password and save it securely
   - **Region**: Choose the region closest to your target users
   - **Pricing Plan**: Free tier is sufficient for development and initial production
4. Click "Create new project"
5. Wait for the project to be provisioned (typically 2-3 minutes)

## Step 2: Execute the Database Schema

1. Navigate to the **SQL Editor** in your Supabase dashboard
2. Click "New Query"
3. Copy the contents of `supabase/schema.sql` from this repository
4. Paste the SQL code into the editor
5. Click "Run" to execute the schema
6. Verify that all tables, indexes, and RLS policies were created successfully

## Step 3: Configure API Keys in Supabase Secrets

### For Gemini API (Google)

1. Navigate to **Edge Functions** in your Supabase dashboard
2. Click **Secrets** (or go to Settings → Edge Functions → Secrets)
3. Add the following secret:
   - **Name**: `GEMINI_API_KEY`
   - **Value**: Your Gemini API key from Google AI Studio
4. Click "Save"

### For OpenAI API

1. Navigate to **Edge Functions** in your Supabase dashboard
2. Click **Secrets** (or go to Settings → Edge Functions → Secrets)
3. Add the following secret:
   - **Name**: `OPENAI_API_KEY`
   - **Value**: Your OpenAI API key from https://platform.openai.com/api-keys
4. Click "Save"

**Note**: You only need to configure one of these API keys depending on which AI provider you're using for recipe generation.

## Step 4: Get Your Supabase Credentials

1. Navigate to **Project Settings** → **API** in your Supabase dashboard
2. Copy the following values:
   - **Project URL**: Found under "Project URL"
   - **anon/public key**: Found under "anon/public" (this is safe to use in your Flutter app)
3. Save these credentials securely

## Step 5: Configure Your Flutter Application

1. Open your Flutter project
2. Navigate to `lib/core/security/env_config.dart`
3. Update the environment configuration with your Supabase credentials:

```dart
class EnvConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String firebaseStorageBucket = 'YOUR_FIREBASE_STORAGE_BUCKET';
  
  static bool validate() {
    return supabaseUrl.isNotEmpty &&
           supabaseAnonKey.isNotEmpty &&
           firebaseStorageBucket.isNotEmpty;
  }
}
```

4. Replace the placeholder values with your actual Supabase credentials
5. If using Firebase Storage for recipe images, also configure your Firebase credentials

## Step 6: Configure Firebase Storage (Optional)

If you're using Firebase Storage for recipe image uploads:

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Storage for your project
3. Set up Firebase Authentication (Anonymous or Email/Password)
4. Configure your Firebase credentials in the Flutter app
5. Update `firebaseStorageBucket` in `env_config.dart`

## Step 7: Test the Configuration

1. Run your Flutter application:
   ```bash
   flutter run
   ```

2. Test the authentication flow:
   - Try signing up a new user
   - Verify that a profile is automatically created in the `profiles` table
   - Check the Supabase dashboard to confirm the user was created

3. Test recipe generation:
   - Navigate to the ingredient input screen
   - Add some ingredients
   - Click "Generate Recipes"
   - Verify that recipes are saved to the `recipes` table
   - Check the `recipes_history` table for generation records

4. Test favorites:
   - Tap the heart icon on a recipe card
   - Verify the recipe is added to the `favorites` table
   - Check that the animation plays smoothly

## Step 8: Deploy Edge Functions (Optional)

If you're using Supabase Edge Functions for AI recipe generation:

1. Install the Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

4. Deploy your Edge Functions:
   ```bash
   supabase functions deploy generate-recipes
   ```

## Security Best Practices

1. **Never commit API keys to version control** - Always use environment variables or Supabase Secrets
2. **Use Row Level Security (RLS)** - The schema.sql includes RLS policies to ensure users can only access their own data
3. **Enable authentication** - Require users to sign in before accessing recipe generation
4. **Monitor usage** - Set up alerts in Supabase for unusual activity
5. **Backup your database** - Enable daily backups in Supabase settings

## Troubleshooting

### Issue: "Failed to initialize Supabase"
- Verify your `supabaseUrl` and `supabaseAnonKey` are correct
- Check that your Supabase project is active (not paused)
- Ensure you have internet connectivity

### Issue: "Recipe generation failed"
- Verify your AI API key is correctly configured in Supabase Secrets
- Check the Edge Function logs in the Supabase dashboard
- Ensure you have available API quota with your AI provider

### Issue: "RLS policy violation"
- Verify the RLS policies were executed from schema.sql
- Check that the user is authenticated
- Review the policy definitions in the SQL Editor

### Issue: "Firebase Storage upload failed"
- Verify your Firebase Storage rules allow uploads
- Check that Firebase Authentication is properly configured
- Ensure the storage bucket name in env_config.dart is correct

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/guides/flutter)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Firebase Documentation](https://firebase.google.com/docs)

## Support

For issues specific to this project, please refer to the project repository or contact the development team.
