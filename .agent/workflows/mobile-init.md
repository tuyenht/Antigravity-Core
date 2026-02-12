---
description: Khởi tạo dự án mobile
---

# /mobile-init - Initialize Mobile Project

Quickly scaffold a production-ready mobile project with all best practices configured.

## Input Required

```
1. Framework: React Native | Flutter
2. Project name: e.g., "my-awesome-app"
3. Features needed:
   - [ ] Authentication (Firebase, OAuth)
   - [ ] Push notifications
   - [ ] Offline support
   - [ ] Analytics
   - [ ] Payment (Stripe, IAP)
```

## React Native Setup

```bash
# Create project
npx react-native@latest init MyApp --template react-native-template-typescript

# Install essential packages
npm install @react-navigation/native @react-navigation/native-stack
npm install @tanstack/react-query zustand
npm install react-native-mmkv # Fast storage
npm install @notifee/react-native @react-native-firebase/app
npm install react-native-keychain # Secure storage

# Dev dependencies
npm install -D @testing-library/react-native jest
```

## Flutter Setup

```bash
# Create project
flutter create my_app

# Add dependencies to pubspec.yaml
flutter pub add go_router riverpod flutter_riverpod
flutter pub add http dio # Networking
flutter pub add shared_preferences hive # Storage
flutter pub add firebase_messaging firebase_analytics

# Dev dependencies
flutter pub add --dev flutter_test integration_test
```

## Configured Structure

**React Native:**
```
src/
├── components/   # Reusable UI
├── screens/      # App screens
├── navigation/   # React Navigation
├── services/     # API, Storage
├── hooks/        # Custom hooks
├── store/        # Zustand stores
└── utils/        # Helpers
```

**Flutter:**
```
lib/
├── models/       # Data models
├── providers/    # Riverpod providers
├── screens/      # App screens
├── widgets/      # Reusable widgets
├── services/     # API, Storage  
└── utils/        # Helpers
```

**Agent:** `mobile-developer` + `project-planner`
