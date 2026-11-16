# AI Chef - Premium AI-Powered Recipe Discovery Platform

<div align="center">

**A Production-Ready, White-Label Micro-SaaS Built for Scale**

[Flutter](https://flutter.dev) · [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) · [Supabase](https://supabase.com) · [Firebase](https://firebase.google.com)

[Investor Deck](#commercial-potential) · [Technical Architecture](#tech-stack--architecture) · [Deployment Guide](DEVELOPER_HANDOFF.md)

</div>

---

## 🚀 Project Vision

**AI Chef** is a highly scalable, white-label production Micro-SaaS platform that transforms how users discover recipes through artificial intelligence. Built on Flutter's cross-platform framework with enterprise-grade Clean Architecture, this application leverages Google's Gemini 1.5 Flash AI via Supabase Edge Functions to generate personalized recipes from ingredient lists or photos.

Designed for immediate market deployment, AI Chef features a premium Material Design 3 interface with custom micro-animations, multi-provider authentication (Email/Password, Anonymous, Google OAuth), and a built-in premium paywall system ready for Stripe or RevenueCat integration. The architecture supports seamless rebranding and rapid market entry across iOS and Android ecosystems.

---

## ✨ Key Value Propositions

### 🎨 Premium User Experience

- **Material Design 3 UI**: Modern, adaptive interface following Google's latest design guidelines with dynamic color theming
- **Custom Micro-Animations**: Smooth transitions and delightful interactions that enhance user engagement
- **Responsive Design**: Optimized for all screen sizes using flutter_screenutil for pixel-perfect scaling
- **Intuitive Navigation**: Streamlined user flow from ingredient input to recipe discovery

### 🏗️ Enterprise-Grade Backend

- **Production-Ready Serverless Edge Functions**: Supabase Edge Functions powered by Deno for scalable AI recipe generation
- **Multi-Provider Authentication**: Flexible auth system supporting Email/Password, Anonymous sessions, and Google OAuth
- **Built-in Premium Paywall Layout**: Pre-designed subscription screens ready for monetization integration
- **Secure Token Management**: Optimized JSON token structure for efficient API communication
- **Firebase Cloud Storage Integration**: Robust image upload system for ingredient photos

### 🔧 Developer Excellence

- **Clean Architecture Implementation**: Strict separation of concerns with Data, Domain, and Presentation layers
- **Type-Safe Codebase**: Freezed + json_serializable for immutable data models with compile-time safety
- **Comprehensive Error Handling**: Either pattern with custom Failure types for predictable error management
- **SOLID Principles**: Single responsibility, dependency inversion, and open/closed principles throughout
- **Professional Documentation**: Extensive inline documentation and architectural clarity

---

## 🏗️ Tech Stack & Architecture

### Core Framework

- **Flutter 3.19+**: Cross-platform mobile framework for iOS, Android, Web, and Desktop
- **Dart 3.3+**: Type-safe, object-oriented programming language with null safety
- **Riverpod 2.4+**: Reactive state management and dependency injection with compile-time safety

### Backend Infrastructure

- **Supabase**: Backend-as-a-Service providing:
  - PostgreSQL Database with Row-Level Security
  - Authentication (Email, Anonymous, OAuth)
  - Edge Functions (Deno runtime for AI integration)
  - Real-time subscriptions
- **Firebase Cloud Storage**: Scalable image storage for ingredient photos
- **Google Gemini 1.5 Flash**: AI model for recipe generation via Edge Functions

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Widgets    │  │  Providers   │  │   Pages      │      │
│  │  (UI Components) │ (Riverpod State) │ (Screens)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Entities   │  │  Use Cases   │  │ Repositories │      │
│  │ (Business Objects) │ (Application Logic) │ (Contracts)│ │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Data Sources │  │   Models     │  │  Mappers     │      │
│  │ (API, DB, Cache) │ (DTOs)      │ (Data Transform)│     │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants (AppStrings, AppColors)
│   ├── errors/              # Custom exceptions and Failure types
│   ├── network/             # Dio HTTP client with interceptors
│   ├── providers/           # Global Riverpod providers
│   ├── security/            # Environment config & token management
│   └── theme/               # Material Design 3 app theme
├── features/
│   ├── auth/
│   │   ├── data/            # Supabase auth data sources
│   │   ├── domain/          # Auth entities, repositories, use cases
│   │   └── presentation/    # Auth UI components and providers
│   ├── premium/
│   │   ├── data/            # Subscription data sources
│   │   ├── domain/          # Premium entities, repositories, use cases
│   │   └── presentation/    # Paywall UI components and providers
│   └── recipe/
│       ├── data/            # API, Firebase data sources
│       ├── domain/          # Recipe entities, repositories, use cases
│       └── presentation/    # Recipe UI components and providers
└── main.dart                # Application entry point
```

### Key Dependencies

| Package            | Purpose             | Version |
| ------------------ | ------------------- | ------- |
| flutter_riverpod   | State management    | ^2.4.9  |
| supabase_flutter   | Backend integration | ^2.3.4  |
| firebase_storage   | Image storage       | ^11.6.0 |
| dio                | HTTP client         | ^5.4.0  |
| freezed            | Immutable classes   | ^2.4.6  |
| json_serializable  | JSON parsing        | ^6.7.1  |
| flutter_screenutil | Responsive design   | ^5.9.0  |
| go_router          | Navigation          | ^13.0.0 |

---

## 💼 Commercial Potential

### White-Label Ready

AI Chef is architected for rapid rebranding and market deployment:

- **2-Minute Rebranding**: Change app logo, bundle ID, and color scheme via `app_theme.dart`
- **Multi-Tenant Architecture**: Supabase project structure supports multiple deployments
- **Custom Brand Assets**: Isolated asset folders for easy logo and icon replacement

### Monetization Strategy

- **Premium Paywall Integration**: Pre-built subscription screens compatible with:
  - **Stripe**: Direct payment processing with webhooks
  - **RevenueCat**: Cross-platform subscription management
  - **In-App Purchases**: Native iOS/Android billing
- **Freemium Model**: Anonymous user access with premium feature gates
- **API-First Design**: Easy integration with third-party recipe services

### Market Opportunities

- **Food & Beverage Industry**: Corporate wellness programs, restaurant chains
- **Health & Fitness**: Nutrition-focused meal planning platforms
- **Education**: Culinary schools and cooking academies
- **E-commerce**: Grocery delivery and meal kit services

### Scalability Features

- **Serverless Architecture**: Auto-scaling Edge Functions handle traffic spikes
- **Database Optimization**: PostgreSQL with Row-Level Security for multi-tenant data
- **CDN-Ready Assets**: Firebase Storage with global CDN distribution
- **Cross-Platform Deployment**: Single codebase for iOS, Android, Web, and Desktop

---

## 📊 Technical Highlights

### Performance Optimizations

- **Lazy Loading**: On-demand recipe fetching reduces initial load time
- **Image Compression**: Automatic optimization for ingredient photos
- **Caching Strategy**: Intelligent local storage for offline recipe access
- **Token Optimization**: Structured JSON minimizes API payload size

### Security Measures

- **Row-Level Security**: Database-level access control via Supabase policies
- **Environment Variables**: Sensitive configuration isolated from codebase
- **Token Refresh**: Automatic authentication token renewal
- **Input Validation**: Comprehensive sanitization for user-generated content

### Code Quality Metrics

- **100% Type Safety**: Null-safe Dart with strict static analysis
- **Test Coverage**: Unit, widget, and integration test infrastructure
- **Lint Rules**: Enforced code style via `analysis_options.yaml`
- **Documentation**: Professional inline documentation throughout

---

## 🚀 Quick Start

For immediate deployment, refer to the **[DEVELOPER_HANDOFF.md](DEVELOPER_HANDOFF.md)** guide, which provides a 10-minute blueprint for:

- Flutter environment setup
- Supabase/Firebase connection
- Code generation and compilation
- White-label customization

---

## 📄 License

**Proprietary - All Rights Reserved**

This codebase is offered for acquisition with full intellectual property rights transfer. Contact for licensing and acquisition opportunities.

---

<div align="center">

**Built for Scale · Designed for Acquisition · Ready for Market**

[View Deployment Guide](DEVELOPER_HANDOFF.md) · [Contact for Acquisition]

</div>
