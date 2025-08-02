# Product Requirements Document: One Click 2 service Customer App

## Introduction/Overview

One Click 2 Service is a service marketplace app that connects customers with verified service providers (electricians, plumbers, mechanics, cleaners, glass workers) in Vijayawada city. The customer app enables users to book services with real-time tracking, instant pricing, and seamless communication with service providers.
 
**Problem Statement:** Customers struggle to find reliable, verified service providers quickly and often face uncertainty about pricing and arrival times.

**Solution:** A mobile app that provides instant booking, real-time tracking, transparent pricing, and verified service providers.

## Goals

1. **Enable instant service booking** with real-time provider tracking
2. **Provide transparent pricing** through standard service catalog and instant quotes
3. **Ensure service quality** through background-verified providers
4. **Facilitate seamless communication** between customers and providers
5. **Build trust** through ratings, reviews, and verification systems
6. **Scale from Vijayawada to statewide coverage** after successful trials

## User Stories

### Core Booking Flow
- **As a customer**, I want to browse standard services with fixed prices so that I can book quickly without negotiation
- **As a customer**, I want to submit custom service requests with audio/video/text so that I can get instant quotes for specific problems
- **As a customer**, I want to track my service provider's location in real-time so that I know when they will arrive
- **As a customer**, I want to see provider ratings and reviews so that I can choose the best service provider

### Communication & Support
- **As a customer**, I want to chat with my service provider so that I can provide additional details or ask questions
- **As a customer**, I want to receive push notifications about booking status so that I stay informed
- **As a customer**, I want to rate and review my service experience so that I can help other customers

### Account & Profile
- **As a customer**, I want to save my address and payment methods so that I can book services quickly
- **As a customer**, I want to view my booking history so that I can track my service requests
- **As a customer**, I want to manage my profile and preferences so that I can personalize my experience

## Functional Requirements

### 1. User Authentication & Onboarding
1.1. The app must allow users to register using phone number and OTP verification
1.2. The app must provide a welcome screen with app introduction
1.3. The app must collect user's name, address, and basic preferences during onboarding
1.4. The app must allow users to set their primary service location (Vijayawada city)
1.5. The app must support both individual and corporate user accounts

### 2. Service Discovery & Booking
2.1. The app must display a catalog of standard services with fixed prices:
   - Electrical services (wiring, repairs, installations)
   - Plumbing services (repairs, installations, maintenance)
   - Cleaning services (home, office, specialized cleaning)
   - Glass work (repairs, installations, replacements)
   - Mechanical services (appliance repairs, installations)
2.2. The app must allow customers to submit custom service requests with:
   - Audio recording capability
   - Video recording capability
   - Photo upload capability
   - Text description input
2.3. The app must provide instant pricing for custom requests
2.4. The app must show available service providers with ratings, reviews, and estimated arrival time
2.5. The app must allow customers to book services with one-click confirmation

### 3. Real-time Tracking & Communication
3.1. The app must display service provider's real-time location on a map
3.2. The app must show estimated arrival time based on provider's location
3.3. The app must provide in-app chat functionality between customer and provider
3.4. The app must send push notifications via Supabase real-time for:
   - Booking confirmation
   - Provider assigned
   - Provider en route
   - Provider arrived
   - Service completed
   - New chat messages
3.5. The app must allow customers to call service providers directly

### 4. Payment & Billing
4.1. The app must support multiple payment methods (UPI, cards, digital wallets)
4.2. The app must provide transparent pricing with no hidden fees
4.3. The app must generate digital receipts for all transactions
4.4. The app must support corporate billing for business accounts

### 5. Rating & Review System
5.1. The app must allow customers to rate service providers (1-5 stars)
5.2. The app must allow customers to write detailed reviews with photos
5.3. The app must display provider ratings and reviews prominently
5.4. The app must allow customers to rate specific aspects of service (punctuality, quality, communication)

### 6. Profile & History Management
6.1. The app must allow customers to manage their profile information
6.2. The app must save customer addresses for quick booking
6.3. The app must display complete booking history with status
6.4. The app must allow customers to rebook previous service providers
6.5. The app must support multiple addresses for customers

### 7. Service Provider Verification Display
6.1. The app must display verification badges for background-checked providers
6.2. The app must show provider's experience, certifications, and specializations
6.3. The app must display provider's service area and availability

## Non-Goals (Out of Scope)

- Service provider app development (separate project)
- Payment processing backend (third-party integration)
- Background check implementation (external service)
- Corporate portal (same app for all users)
- International expansion (Vijayawada focus initially)
- Advanced analytics dashboard (basic metrics only)
- Multi-language support (English and Telugu only)

## Design Considerations

### UI/UX Requirements
- **Modern Material Design 3** with One Click brand colors
- **Intuitive navigation** with bottom navigation bar
- **Large, accessible buttons** for easy booking
- **Clear service categorization** with icons and descriptions
- **Real-time map integration** for location tracking
- **Dark mode support** for better user experience
- **Offline capability** for basic app functions

### Key Screens (Flutter Implementation)
1. **Welcome/Onboarding** - App introduction and phone number registration
2. **OTP Verification** - Phone verification with SMS OTP
3. **Home** - Service categories and quick booking dashboard
4. **Service Catalog** - Standard services with pricing grid
5. **Custom Request** - Audio/video/text input for specific services
6. **Provider Selection** - Available providers with ratings and ETA
7. **Booking Confirmation** - Order summary and payment (UPI/Cash)
8. **Live Tracking** - Real-time provider location and ETA on map
9. **Chat** - In-app communication with provider
10. **Profile** - User information and booking history
11. **Reviews** - Rating and feedback submission
12. **Settings** - App preferences and account management

## Technical Considerations

### Technology Stack
- **Frontend**: Flutter (Cross-platform: Android + iOS)
- **Language**: Dart
- **Backend**: Supabase (PostgreSQL, Real-time, Auth, Storage, Push Notifications)
- **Authentication**: Phone Number + OTP verification via Supabase Auth
- **Real-time Features**: Supabase Realtime (WebSocket) for live tracking, chat, and notifications
- **Maps**: Google Maps API for location services
- **Push Notifications**: Supabase real-time database triggers for local notifications
- **Media Handling**: CameraX for photo/video capture
- **Audio Recording**: MediaRecorder API
- **Payment Integration**: UPI + Cash payment methods

### Key Integrations
- **Supabase** for database, authentication, real-time features, storage, and notifications
- **Google Maps** for location tracking and provider mapping
- **Payment Methods** for UPI and cash transactions
- **Media Storage** for audio/video uploads via Supabase Storage

### Architecture Considerations
- **MVVM Architecture** with State Management
- **Simple Project Structure** (lib/screens, lib/widgets, lib/models)
- **Offline-first approach** for core functionality
- **Real-time synchronization** for live updates
- **Secure data transmission** with encryption
- **AI Agent Integration** (Copilot + Claude + GPT) for development assistance

### Development Environment
- **IDE**: VS Code + Android Studio (Hybrid approach)
- **Testing**: Unit Tests + Widget Tests (Flutter standard)
- **Deployment**: Play Store + Apple App Store
- **CI/CD**: Manual deployment initially

### Business Model
- **Monetization**: Subscription for Service Providers + Freemium Model
- **Marketing**: Comprehensive ASO + Vijayawada Local Marketing + Word-of-mouth + Referral Program
- **Privacy**: Basic GDPR/Privacy Compliance
- **Analytics**: Firebase Crashlytics + Analytics

## Success Metrics

### User Engagement
- **App downloads** target: 10,000+ in first 6 months
- **Daily active users** target: 1,000+ by month 3
- **Booking conversion rate** target: 25%+ from service browsing
- **User retention** target: 60%+ monthly retention

### Service Quality
- **Average rating** target: 4.2+ stars
- **Response time** target: <5 minutes for instant quotes
- **Provider arrival accuracy** target: 90%+ within estimated time
- **Customer satisfaction** target: 85%+ positive reviews

### Business Metrics
- **Monthly bookings** target: 500+ by month 6
- **Revenue per booking** target: ₹200+ average
- **Geographic coverage** target: Full Vijayawada city by month 3
- **Service provider retention** target: 80%+ monthly retention

## Open Questions

1. **Service Categories**: What specific services should be included in the standard catalog?
2. **Pricing Strategy**: How should dynamic pricing work based on market demand?
3. **Provider Onboarding**: What specific background check requirements are needed?
4. **Corporate Features**: What additional features do corporate clients need?
5. **Payment Terms**: Should corporate clients have different payment terms?
6. **Service Guarantee**: What warranty/guarantee should be offered for services?
7. **Dispute Resolution**: How should customer-provider disputes be handled?
8. **Data Privacy**: What specific data protection measures are required for Vijayawada compliance?

## Next Steps

1. **Technical Architecture Setup**: Configure Supabase project and basic app structure
2. **UI/UX Design**: Create detailed mockups for all key screens
3. **Backend Development**: Set up database schema and API endpoints
4. **Core Features Development**: Implement authentication, booking, and tracking
5. **Testing & QA**: Comprehensive testing across different devices and scenarios
6. **Launch Preparation**: Beta testing with limited users in Vijayawada
7. **Scale Planning**: Prepare for statewide expansion after successful trials 