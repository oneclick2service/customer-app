# Tech Stack: One Click 2 Service Customer App

## Overview
The One Click 2 Service customer app uses a **unified Supabase approach** to simplify architecture, reduce costs, and improve maintainability. All backend services are consolidated through Supabase, eliminating the need for multiple service providers.

## Core Technology Stack

### Frontend
- **Framework**: Flutter 3.8+
- **Language**: Dart
- **State Management**: Provider (MVVM Architecture)
- **UI Components**: Material Design 3 with custom theming
- **Platforms**: Android (API 21+) and iOS (12.0+)

### Backend (Unified Supabase Platform)
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth (Phone + OTP)
- **Real-time Features**: Supabase Realtime (WebSocket)
- **Storage**: Supabase Storage (for media files)
- **Push Notifications**: Supabase real-time database triggers + Flutter Local Notifications
- **API**: Supabase REST and GraphQL APIs

### External Services
- **Maps**: Google Maps API (for location services)
- **Payment**: UPI integration + Cash payments
- **Media**: CameraX (Android) and AVFoundation (iOS)

## Architecture Benefits

### 1. **Simplified Architecture**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Supabase      │    │   Google Maps   │
│                 │◄──►│   (Unified)     │    │   API           │
│ - UI/UX        │    │                 │    │                 │
│ - State Mgmt   │    │ - Database      │    │ - Location      │
│ - Local Storage│    │ - Auth          │    │ - Geocoding     │
│ - Notifications│    │ - Real-time     │    │ - Directions    │
│                 │    │ - Storage       │    │                 │
│                 │    │ - Notifications │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2. **Cost Optimization**
- **Single Platform**: All backend services through Supabase
- **Reduced Complexity**: No Firebase setup/maintenance
- **Lower Latency**: Direct database triggers for notifications
- **Better Integration**: Real-time notifications with chat and tracking

### 3. **Development Efficiency**
- **Unified SDK**: Single Supabase Flutter SDK
- **Consistent APIs**: All services follow same patterns
- **Real-time Sync**: Database changes trigger notifications automatically
- **Simplified Testing**: One platform to test and debug

## Key Features Implementation

### Authentication
```dart
// Supabase Auth for phone verification
final auth = Supabase.instance.client.auth;
await auth.signInWithOtp(phoneNumber: phone);
```

### Real-time Notifications
```dart
// Database triggers automatically send notifications
supabase
  .channel('booking_notifications')
  .on('UPDATE', table: 'bookings')
  .listen((payload) => showNotification(payload));
```

### Chat System
```dart
// Real-time chat using Supabase
supabase
  .channel('chat_room')
  .on('INSERT', table: 'messages')
  .listen((payload) => updateChat(payload));
```

### Live Tracking
```dart
// Real-time location updates
supabase
  .channel('provider_location')
  .on('UPDATE', table: 'provider_locations')
  .listen((payload) => updateMap(payload));
```

## Database Schema (Supabase)

### Core Tables
```sql
-- Users table (extends Supabase auth.users)
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users(id),
  name TEXT,
  phone TEXT,
  address JSONB,
  preferences JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Service providers
CREATE TABLE service_providers (
  id UUID PRIMARY KEY,
  name TEXT,
  phone TEXT,
  rating DECIMAL,
  specializations TEXT[],
  is_verified BOOLEAN,
  location JSONB,
  is_available BOOLEAN
);

-- Bookings
CREATE TABLE bookings (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES user_profiles(id),
  provider_id UUID REFERENCES service_providers(id),
  service_type TEXT,
  status TEXT,
  price DECIMAL,
  location JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Chat messages
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY,
  booking_id UUID REFERENCES bookings(id),
  sender_id UUID,
  message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Notifications (for local storage)
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES user_profiles(id),
  title TEXT,
  body TEXT,
  payload JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Real-time Features

### 1. **Booking Status Updates**
- Database triggers automatically notify users
- Real-time status synchronization across app
- Instant UI updates without polling

### 2. **Chat System**
- Real-time message delivery
- Typing indicators
- Message status (sent/delivered/read)

### 3. **Live Tracking**
- Real-time provider location updates
- Automatic ETA calculations
- Route optimization

### 4. **Push Notifications**
- Database-driven notifications
- Local notification display
- Deep linking to specific screens

## Security & Privacy

### Data Protection
- **Row Level Security (RLS)** on all tables
- **Encrypted data transmission** via HTTPS
- **User data isolation** through RLS policies
- **GDPR compliance** with data export/deletion

### Authentication Security
- **Phone verification** via OTP
- **Session management** through Supabase
- **Secure token handling**
- **Automatic session refresh**

## Performance Optimization

### 1. **Offline Support**
- Local SQLite database for offline data
- Sync when connection restored
- Offline booking capabilities

### 2. **Caching Strategy**
- Image caching for provider photos
- Service catalog caching
- User preferences caching

### 3. **Real-time Optimization**
- Efficient WebSocket connections
- Minimal data transfer
- Connection state management

## Development Workflow

### 1. **Local Development**
```bash
# Setup Supabase local development
supabase start
supabase db reset
supabase functions serve
```

### 2. **Testing Strategy**
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for Supabase features
- E2E tests for critical user flows

### 3. **Deployment Pipeline**
- **Development**: Supabase dev environment
- **Staging**: Supabase staging project
- **Production**: Supabase production project

## Monitoring & Analytics

### 1. **Error Tracking**
- Supabase error logging
- Flutter crash reporting
- Performance monitoring

### 2. **User Analytics**
- Booking conversion rates
- Feature usage tracking
- User engagement metrics

### 3. **Business Metrics**
- Revenue tracking
- Provider performance
- Customer satisfaction

## Migration from Firebase

### Benefits of Migration
1. **Reduced Complexity**: Single platform instead of multiple services
2. **Cost Savings**: No Firebase costs for notifications
3. **Better Integration**: Seamless real-time features
4. **Simplified Maintenance**: One platform to manage

### Migration Steps
1. **Database Migration**: Move from Firestore to PostgreSQL
2. **Auth Migration**: Switch from Firebase Auth to Supabase Auth
3. **Notification Migration**: Replace FCM with Supabase real-time
4. **Storage Migration**: Move from Firebase Storage to Supabase Storage

## Future Scalability

### 1. **Geographic Expansion**
- Multi-city support
- Regional pricing
- Local service providers

### 2. **Feature Enhancements**
- AI-powered service matching
- Advanced analytics dashboard
- Corporate account features

### 3. **Performance Scaling**
- Database optimization
- CDN integration
- Load balancing

## Conclusion

The unified Supabase approach provides:
- **Simplified architecture** with fewer moving parts
- **Cost optimization** through single platform
- **Better developer experience** with consistent APIs
- **Improved user experience** with seamless real-time features
- **Easier maintenance** and deployment

This approach eliminates the complexity of managing multiple services while providing all the functionality needed for a modern service marketplace app. 