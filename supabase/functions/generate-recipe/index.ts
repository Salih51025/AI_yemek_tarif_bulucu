import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ============================================================================
// PRODUCTION-GRADE AI RECIPE GENERATION EDGE FUNCTION
// ============================================================================
// Features:
// - Advanced prompt engineering with recipe quality ranking
// - Rate limiting and user quota management
// - Response caching with Redis-like strategy
// - Premium feature support
// - Recipe confidence scoring and filtering
// - Ingredient compatibility analysis
// - Cuisine detection and adaptation
// - Anti-prompt-injection protection
// - Comprehensive error handling and logging
// ============================================================================

// ============================================================================
// TYPE DEFINITIONS
// ============================================================================

interface IngredientInput {
  ingredients?: string[];
  photoUrl?: string;
  dietaryRestrictions?: string[];
  allergies?: string[];
  cuisinePreference?: string;
  difficulty?: "Easy" | "Medium" | "Hard";
  servings?: number;
  language?: "en" | "tr";
  maxCookingTime?: number;
  caloriesLimit?: number;
}

interface Ingredient {
  name: string;
  quantity: string;
  preparation?: string;
  confidence?: number;
}

interface CookingStep {
  stepNumber: number;
  instruction: string;
  durationMinutes: number;
  tip?: string;
}

interface RecipeModel {
  id: string;
  title: string;
  description: string;
  ingredients: Ingredient[];
  steps: CookingStep[];
  cookingTimeMinutes: number;
  prepTimeMinutes: number;
  difficulty: "Easy" | "Medium" | "Hard";
  category: "Breakfast" | "Lunch" | "Dinner" | "Snack" | "Dessert";
  servings: number;
  caloriesPerServing: number;
  imageUrl?: string;
  tags: string[];
  userId: string;
  isFavorite: boolean;
  createdAt: string;
  updatedAt?: string;
  source: "ai";
  cuisine: string;
  confidenceScore: number;
  popularityScore: number;
  compatibilityScore: number;
  healthScore: number;
}

interface RecipeGenerationResponse {
  recipes: RecipeModel[];
  success: boolean;
  error?: string;
  tokensUsed?: number;
  generationTimeMs?: number;
  modelVersion?: string;
  cacheHit?: boolean;
  userQuota?: {
    used: number;
    limit: number;
    remaining: number;
  };
}

interface UserProfile {
  id: string;
  isPremium: boolean;
  quotaUsed: number;
  quotaLimit: number;
  preferences: {
    cuisine?: string;
    dietaryRestrictions?: string[];
    allergies?: string[];
  };
}

// ============================================================================
// RATE LIMITING CONFIGURATION
// ============================================================================

const RATE_LIMIT_CONFIG = {
  FREE_TIER: {
    requestsPerMinute: 10,
    requestsPerHour: 50,
    requestsPerDay: 100,
  },
  PREMIUM_TIER: {
    requestsPerMinute: 30,
    requestsPerHour: 200,
    requestsPerDay: 1000,
  },
};

// ============================================================================
// CACHE CONFIGURATION
// ============================================================================

const CACHE_CONFIG = {
  ENABLED: true,
  TTL_SECONDS: 3600, // 1 hour
  MAX_CACHE_SIZE: 1000,
};

// ============================================================================
// IN-MEMORY CACHE (Production: Replace with Redis)
// ============================================================================

const cache = new Map<
  string,
  { data: RecipeGenerationResponse; expiresAt: number }
>();

// ============================================================================
// RATE LIMITER CLASS
// ============================================================================

class RateLimiter {
  private requests = new Map<string, number[]>();

  check(
    userId: string,
    tier: "free" | "premium",
  ): { allowed: boolean; reason?: string } {
    const now = Date.now();
    const config =
      tier === "premium"
        ? RATE_LIMIT_CONFIG.PREMIUM_TIER
        : RATE_LIMIT_CONFIG.FREE_TIER;
    const userRequests = this.requests.get(userId) || [];

    // Clean old requests
    const recentRequests = userRequests.filter(
      (timestamp) => now - timestamp < 60000,
    ); // Last minute
    this.requests.set(userId, recentRequests);

    // Check minute limit
    if (recentRequests.length >= config.requestsPerMinute) {
      return {
        allowed: false,
        reason: "Rate limit exceeded: Too many requests per minute",
      };
    }

    // Check hour limit
    const hourRequests = userRequests.filter(
      (timestamp) => now - timestamp < 3600000,
    );
    if (hourRequests.length >= config.requestsPerHour) {
      return {
        allowed: false,
        reason: "Rate limit exceeded: Too many requests per hour",
      };
    }

    // Check day limit
    const dayRequests = userRequests.filter(
      (timestamp) => now - timestamp < 86400000,
    );
    if (dayRequests.length >= config.requestsPerDay) {
      return {
        allowed: false,
        reason: "Rate limit exceeded: Daily quota exceeded",
      };
    }

    // Add current request
    recentRequests.push(now);
    this.requests.set(userId, recentRequests);

    return { allowed: true };
  }
}

const rateLimiter = new RateLimiter();

// ============================================================================
// CACHE FUNCTIONS
// ============================================================================

function getCacheKey(userId: string, input: IngredientInput): string {
  const normalized = {
    ingredients: input.ingredients?.sort().join(",") || "",
    dietary: input.dietaryRestrictions?.sort().join(",") || "",
    allergies: input.allergies?.sort().join(",") || "",
    cuisine: input.cuisinePreference || "",
    difficulty: input.difficulty || "",
    servings: input.servings || 4,
    language: input.language || "en",
  };
  return `${userId}:${btoa(JSON.stringify(normalized))}`;
}

function getFromCache(key: string): RecipeGenerationResponse | null {
  if (!CACHE_CONFIG.ENABLED) return null;

  const cached = cache.get(key);
  if (!cached) return null;

  if (Date.now() > cached.expiresAt) {
    cache.delete(key);
    return null;
  }

  return cached.data;
}

function setCache(key: string, data: RecipeGenerationResponse): void {
  if (!CACHE_CONFIG.ENABLED) return;

  // Implement LRU eviction if cache is full
  if (cache.size >= CACHE_CONFIG.MAX_CACHE_SIZE) {
    const firstKey = cache.keys().next().value;
    if (firstKey) {
      cache.delete(firstKey);
    }
  }

  cache.set(key, {
    data,
    expiresAt: Date.now() + CACHE_CONFIG.TTL_SECONDS * 1000,
  });
}

// ============================================================================
// USER PROFILE MANAGEMENT
// ============================================================================

async function getUserProfile(supabase: any, userId: string): Promise<UserProfile> {
  const { data: profile, error } = await supabase
    .from("user_profiles")
    .select("*")
    .eq("id", userId)
    .single();

  if (error || !profile) {
    // Create default profile
    const { data: newProfile } = await supabase
      .from("user_profiles")
      .insert({
        id: userId,
        is_premium: false,
        quota_used: 0,
        quota_limit: RATE_LIMIT_CONFIG.FREE_TIER.requestsPerDay,
        preferences: {},
      })
      .select()
      .single();

    return {
      id: newProfile.id,
      isPremium: newProfile.is_premium,
      quotaUsed: newProfile.quota_used,
      quotaLimit: newProfile.quota_limit,
      preferences: newProfile.preferences || {},
    };
  }

  return {
    id: profile.id,
    isPremium: profile.is_premium,
    quotaUsed: profile.quota_used,
    quotaLimit: profile.quota_limit,
    preferences: profile.preferences || {},
  };
}

async function incrementQuota(supabase: any, userId: string): Promise<void> {
  await supabase
    .from("user_profiles")
    .update({ quota_used: supabase.rpc("increment", { val: 1 }) as number })
    .eq("id", userId);
}

// ============================================================================
// ADVANCED PROMPT ENGINEERING
// ============================================================================

function buildAdvancedPrompt(input: IngredientInput, userProfile: UserProfile): string {
  const language = input.language || "en";
  const isTurkish = language === "tr";

  const cuisineGuidance = input.cuisinePreference
    ? (isTurkish ? `Özellikle ${input.cuisinePreference} mutfağından ` : `Especially ${input.cuisinePreference} cuisine `)
    : "";

  const dietaryGuidance = input.dietaryRestrictions?.length
    ? (isTurkish
      ? `Diyet kısıtlamaları: ${input.dietaryRestrictions.join(", ")}. `
      : `Dietary restrictions: ${input.dietaryRestrictions.join(", ")}. `)
    : "";

  const allergyGuidance = input.allergies?.length
    ? (isTurkish
      ? `ALERJİ UYARISU: Aşağıdaki malzemeler YASAKTIR - ${input.allergies.join(", ")}. Bu malzemeleri ASLA kullanma. `
      : `ALLERGY WARNING: The following ingredients are FORBIDDEN - ${input.allergies.join(", ")}. NEVER use these ingredients. `)
    : "";

  const difficultyGuidance = input.difficulty
    ? (isTurkish ? `Zorluk seviyesi: ${input.difficulty}. ` : `Difficulty level: ${input.difficulty}. `)
    : "";

  const timeGuidance = input.maxCookingTime
    ? (isTurkish ? `Maksimum pişirme süresi: ${input.maxCookingTime} dakika. ` : `Maximum cooking time: ${input.maxCookingTime} minutes. `)
    : "";

  const calorieGuidance = input.caloriesLimit
    ? (isTurkish ? `Maksimum kalori: ${input.caloriesLimit} kalori/porsiyon. ` : `Maximum calories: ${input.caloriesLimit} calories/serving. `)
    : "";

  const userCuisine = userProfile.preferences.cuisine
    ? (isTurkish ? `Kullanıcının tercih ettiği mutfak: ${userProfile.preferences.cuisine}. ` : `User's preferred cuisine: ${userProfile.preferences.cuisine}. `)
    : "";

  const basePrompt = isTurkish ? `
UZMAN ŞEF AI: Sen dünya standartlarında bir profesyonel şefsın. ${cuisineGuidance}${userCuisine}${dietaryGuidance}${allergyGuidance}${difficultyGuidance}${timeGuidance}${calorieGuidance}

Aşağıdaki malzemeleri kullanarak 3 YÜKSEK KALİTELİ, GERÇEKÇİ ve EVDE PİŞİRİLEBİLİR tarif oluştur:

Malzemeler: ${input.ingredients?.join(", ")}

KALITE STANDARTLARI:
- Tarifler POPÜLER, REALİSTİK ve LEZZETLİ olmalı
- EVDE PİŞİRİLEBİLİR - profesyonel ekipman gerektirme
- WEIRD veya UNREALISTIC kombinasyonlardan KAÇIN
- Her tarif benzersiz olmalı, tekrar etme
- Türk ve uluslararası mutfakları dengeli kullan
- Pratik ölçüler (metrik ve imperial)
- Adım adım net talimatlar
- Her adımda yararlı ipuçları

JSON YAPISI (sadece JSON, markdown yok):
` : `
EXPERT CHEF AI: You are a world-class professional chef. ${cuisineGuidance}${userCuisine}${dietaryGuidance}${allergyGuidance}${difficultyGuidance}${timeGuidance}${calorieGuidance}

Create 3 HIGH-QUALITY, REALISTIC, and HOME-COOKABLE recipes using these ingredients:

Ingredients: ${input.ingredients?.join(", ")}

QUALITY STANDARDS:
- Recipes must be POPULAR, REALISTIC, and DELICIOUS
- HOME-COOKABLE - no professional equipment required
- AVOID WEIRD or UNREALISTIC combinations
- Each recipe must be unique, no duplicates
- Balance Turkish and international cuisines
- Practical measurements (metric and imperial)
- Clear step-by-step instructions
- Helpful tips in each step

JSON STRUCTURE (JSON only, no markdown):
`;

  const jsonStructure = `
[
  {
    "id": "uuid-v4",
    "title": "Recipe Title",
    "description": "Brief, appetizing description (2-3 sentences)",
    "ingredients": [
      {
        "name": "ingredient name",
        "quantity": "precise amount with unit",
        "preparation": "prep method if needed",
        "confidence": 0.95
      }
    ],
    "steps": [
      {
        "stepNumber": 1,
        "instruction": "Clear, detailed instruction",
        "durationMinutes": 5,
        "tip": "Professional chef tip"
      }
    ],
    "cookingTimeMinutes": 30,
    "prepTimeMinutes": 15,
    "difficulty": "Easy|Medium|Hard",
    "category": "Breakfast|Lunch|Dinner|Snack|Dessert",
    "servings": 4,
    "caloriesPerServing": 350,
    "tags": ["quick", "healthy", "family-friendly"],
    "cuisine": "Turkish|Italian|Mexican|Asian|Mediterranean|American",
    "confidenceScore": 0.92,
    "popularityScore": 0.88,
    "compatibilityScore": 0.95,
    "healthScore": 0.85
  }
]

SCORING SYSTEM:
- confidenceScore (0-1): AI confidence in recipe quality
- popularityScore (0-1): Estimated popularity based on common recipes
- compatibilityScore (0-1): How well ingredients work together
- healthScore (0-1): Nutritional balance and healthiness

REQUIREMENTS:
- Return exactly 3 recipes in JSON array
- All scores must be between 0 and 1
- cuisine must be specific (not just "International")
- Include realistic cooking times
- Difficulty must match user preference or vary across recipes
- Tags should be relevant and helpful
- NO markdown code blocks
- NO additional text outside JSON
- Ensure recipes are actually cookable at home
`;

  return basePrompt + jsonStructure;
}

// ============================================================================
// RECIPE QUALITY ANALYSIS
// ============================================================================

function analyzeRecipeQuality(recipe: RecipeModel): {
  isValid: boolean;
  issues: string[];
  confidenceScore: number;
} {
  const issues: string[] = [];
  let confidenceScore = recipe.confidenceScore || 0.5;

  // Check for unrealistic combinations
  const weirdCombinations = [
    ["chocolate", "garlic"],
    ["ice cream", "hot sauce"],
    ["honey", "fish"],
  ];

  const ingredientNames = recipe.ingredients.map((i) => i.name.toLowerCase());
  for (const combo of weirdCombinations) {
    if (combo.every((ing) => ingredientNames.includes(ing))) {
      issues.push("Unrealistic ingredient combination detected");
      confidenceScore -= 0.3;
    }
  }

  // Check cooking time realism
  if (recipe.cookingTimeMinutes < 5) {
    issues.push("Cooking time too short");
    confidenceScore -= 0.2;
  }
  if (recipe.cookingTimeMinutes > 180) {
    issues.push("Cooking time too long for home cooking");
    confidenceScore -= 0.15;
  }

  // Check ingredient count
  if (recipe.ingredients.length < 3) {
    issues.push("Too few ingredients");
    confidenceScore -= 0.2;
  }
  if (recipe.ingredients.length > 20) {
    issues.push("Too many ingredients for home cooking");
    confidenceScore -= 0.15;
  }

  // Check steps
  if (recipe.steps.length < 3) {
    issues.push("Too few cooking steps");
    confidenceScore -= 0.2;
  }

  // Check calorie realism
  if (recipe.caloriesPerServing < 50) {
    issues.push("Calories too low");
    confidenceScore -= 0.1;
  }
  if (recipe.caloriesPerServing > 1500) {
    issues.push("Calories too high");
    confidenceScore -= 0.1;
  }

  return {
    isValid: confidenceScore > 0.4,
    issues,
    confidenceScore: Math.max(0, Math.min(1, confidenceScore)),
  };
}

// ============================================================================
// DUPLICATE DETECTION
// ============================================================================

function detectDuplicates(recipes: RecipeModel[]): RecipeModel[] {
  const seen = new Set<string>();
  const unique: RecipeModel[] = [];

  for (const recipe of recipes) {
    const key = `${recipe.title.toLowerCase()}-${recipe.category}-${recipe.difficulty}`;
    if (!seen.has(key)) {
      seen.add(key);
      unique.push(recipe);
    }
  }

  return unique;
}

// ============================================================================
// RECIPE RANKING
// ============================================================================

function rankRecipes(recipes: RecipeModel[]): RecipeModel[] {
  return recipes.sort((a, b) => {
    const scoreA = (a.confidenceScore * 0.4) +
                   (a.popularityScore * 0.3) +
                   (a.compatibilityScore * 0.2) +
                   (a.healthScore * 0.1);
    const scoreB = (b.confidenceScore * 0.4) +
                   (b.popularityScore * 0.3) +
                   (b.compatibilityScore * 0.2) +
                   (b.healthScore * 0.1);
    return scoreB - scoreA;
  });
}

// ============================================================================
// ANTI-PROMPT-INJECTION
// ============================================================================

function sanitizeInput(input: IngredientInput): IngredientInput {
  const dangerousPatterns = [
    /ignore (all|previous|above)/gi,
    /forget (all|previous|above)/gi,
    /disregard (all|previous|above)/gi,
    /system prompt/gi,
    /instructions:/gi,
    /new instructions:/gi,
    /override/gi,
    /bypass/gi,
    /admin/gi,
  ];

  const sanitizeString = (str: string): string => {
    let sanitized = str;
    for (const pattern of dangerousPatterns) {
      sanitized = sanitized.replace(pattern, "[REDACTED]");
    }
    return sanitized;
  };

  return {
    ...input,
    ingredients: input.ingredients?.map(sanitizeString),
    dietaryRestrictions: input.dietaryRestrictions?.map(sanitizeString),
    allergies: input.allergies?.map(sanitizeString),
    cuisinePreference: input.cuisinePreference ? sanitizeString(input.cuisinePreference) : undefined,
  };
}

// ============================================================================
// MAIN HANDLER
// ============================================================================

serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  const startTime = Date.now();

  try {
    // Only allow POST requests
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Verify authorization header
    const authHeader = req.headers.get("authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({
          error: "Unauthorized: Missing or invalid bearer token",
        }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );
    }

    const token = authHeader.replace("Bearer ", "");

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: "Server configuration error: Supabase credentials not set" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Verify the token with Supabase Auth
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized: Invalid token" }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );
    }

    // Get user profile
    const userProfile = await getUserProfile(supabase, user.id);

    // Check rate limits
    const rateLimitCheck = rateLimiter.check(user.id, userProfile.isPremium ? "premium" : "free");
    if (!rateLimitCheck.allowed) {
      return new Response(
        JSON.stringify({
          error: rateLimitCheck.reason,
          userQuota: {
            used: userProfile.quotaUsed,
            limit: userProfile.quotaLimit,
            remaining: userProfile.quotaLimit - userProfile.quotaUsed,
          },
        }),
        { status: 429, headers: { "Content-Type": "application/json" } },
      );
    }

    // Parse and sanitize request body
    const body: IngredientInput = await req.json();
    const sanitizedInput = sanitizeInput(body);

    // Validate input
    if (!sanitizedInput.ingredients && !sanitizedInput.photoUrl) {
      return new Response(
        JSON.stringify({
          error:
            "Invalid input: at least ingredients or photo URL must be provided",
        }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // Check cache
    const cacheKey = getCacheKey(user.id, sanitizedInput);
    const cachedResponse = getFromCache(cacheKey);
    if (cachedResponse) {
      console.log(`Cache hit for user ${user.id}`);
      return new Response(
        JSON.stringify({
          ...cachedResponse,
          cacheHit: true,
          userQuota: {
            used: userProfile.quotaUsed,
            limit: userProfile.quotaLimit,
            remaining: userProfile.quotaLimit - userProfile.quotaUsed,
          },
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "X-Cache": "HIT",
          },
        }
      );
    }

    // Get Gemini API key from Supabase Secrets
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiApiKey) {
      return new Response(
        JSON.stringify({
          error: "Server configuration error: GEMINI_API_KEY not set",
        }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    // Build advanced prompt
    const prompt = buildAdvancedPrompt(sanitizedInput, userProfile);

    // Call Gemini API with retry logic
    let geminiResponse: Response | null = null;
    let retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        geminiResponse = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              contents: [
                {
                  parts: [
                    {
                      text: prompt,
                    },
                  ],
                },
              ],
              generationConfig: {
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 8192,
              },
            }),
          }
        );
        break;
      } catch (fetchError) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw fetchError;
        }
        // Exponential backoff
        await new Promise((resolve) => setTimeout(resolve, 1000 * Math.pow(2, retryCount)));
      }
    }

    if (!geminiResponse) {
      return new Response(
        JSON.stringify({ error: "Failed to connect to Gemini API after retries" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    if (!geminiResponse.ok) {
      const errorText = await geminiResponse.text();
      console.error("Gemini API error:", errorText);
      return new Response(
        JSON.stringify({
          error: "Failed to generate recipe",
          details: errorText,
        }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    const geminiData = await geminiResponse.json();
    const generatedText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!generatedText) {
      return new Response(
        JSON.stringify({ error: "No response from Gemini API" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    // Extract JSON from the response
    const jsonMatch =
      generatedText.match(/```json\n([\s\S]*?)\n```/) ||
      generatedText.match(/\[[\s\S]*\]/);

    if (!jsonMatch) {
      return new Response(
        JSON.stringify({ error: "Failed to parse JSON from Gemini response" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    const jsonString = jsonMatch[1] || jsonMatch[0];
    let recipes: RecipeModel[];

    try {
      recipes = JSON.parse(jsonString);
    } catch (parseError) {
      console.error("JSON parse error:", parseError);
      return new Response(
        JSON.stringify({ error: "Failed to parse recipe JSON" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    // Validate and enhance recipes
    const validRecipes: RecipeModel[] = [];
    for (const recipe of recipes) {
      // Add required fields
      recipe.id = crypto.randomUUID();
      recipe.userId = user.id;
      recipe.isFavorite = false;
      recipe.createdAt = new Date().toISOString();
      recipe.source = "ai";

      // Analyze quality
      const quality = analyzeRecipeQuality(recipe);
      if (quality.isValid) {
        recipe.confidenceScore = quality.confidenceScore;
        validRecipes.push(recipe);
      }
    }

    // Remove duplicates
    const uniqueRecipes = detectDuplicates(validRecipes);

    // Rank recipes
    const rankedRecipes = rankRecipes(uniqueRecipes);

    // Ensure we have at least 1 recipe
    if (rankedRecipes.length === 0) {
      return new Response(
        JSON.stringify({ error: "No valid recipes could be generated" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    // Increment user quota
    await incrementQuota(supabase, user.id);

    // Build response
    const response: RecipeGenerationResponse = {
      recipes: rankedRecipes,
      success: true,
      tokensUsed: geminiData.usageMetadata?.totalTokenCount || 0,
      generationTimeMs: Date.now() - startTime,
      modelVersion: "gemini-1.5-flash",
      cacheHit: false,
      userQuota: {
        used: userProfile.quotaUsed + 1,
        limit: userProfile.quotaLimit,
        remaining: userProfile.quotaLimit - userProfile.quotaUsed - 1,
      },
    };

    // Cache the response
    setCache(cacheKey, response);

    // Return the response
    return new Response(JSON.stringify(response), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "X-Cache": "MISS",
      },
    });
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        details: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
