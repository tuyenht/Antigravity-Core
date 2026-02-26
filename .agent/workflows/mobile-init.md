---
description: "Khởi tạo mã nguồn dự án ứng dụng di động (React Native/Flutter mới)."
---

# /mobile-init — Initialize Mobile Project

// turbo-all

Scaffold a production-ready mobile project with best practices, CI/CD, and store configuration.

**Agent:** `mobile-developer` + `project-planner`  
**Skills:** `mobile-design`, `react-native-performance`, `testing-mastery`

---

## Input Required

```
1. Framework:  React Native | Expo | Flutter
2. Project name:  e.g., "my-awesome-app"
3. Target platforms:  iOS | Android | Both
4. Features needed:
   - [ ] Authentication (Firebase, OAuth, Social login)
   - [ ] Push notifications
   - [ ] Offline support
   - [ ] Analytics (Firebase, Amplitude)
   - [ ] Payment (Stripe, IAP)
   - [ ] Deep linking
   - [ ] Biometric auth
```

---

## Option A: Expo (React Native — Recommended)

```bash
# Create project with Expo Router template
npx create-expo-app@latest my-app --template tabs
cd my-app

# Essential packages
npx expo install expo-router expo-linking expo-constants
npx expo install @react-native-async-storage/async-storage
npx expo install expo-secure-store          # Secure storage
npx expo install expo-notifications         # Push notifications
npx expo install expo-local-authentication  # Biometric

# State & networking
npm install @tanstack/react-query zustand
npm install axios

# Navigation (built-in with expo-router)
# No extra install needed

# Dev dependencies
npm install -D @testing-library/react-native jest-expo
```

### Expo Config (`app.json`)
```json
{
  "expo": {
    "name": "My App",
    "slug": "my-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": { "image": "./assets/splash.png" },
    "ios": {
      "bundleIdentifier": "com.company.myapp",
      "supportsTablet": true
    },
    "android": {
      "package": "com.company.myapp",
      "adaptiveIcon": { "foregroundImage": "./assets/adaptive-icon.png" }
    },
    "plugins": [
      "expo-router",
      "expo-secure-store",
      "expo-notifications"
    ]
  }
}
```

---

## Option B: React Native CLI (Bare)

```bash
# Create project
npx react-native@latest init MyApp --template react-native-template-typescript
cd MyApp

# Navigation
npm install @react-navigation/native @react-navigation/native-stack
npm install react-native-screens react-native-safe-area-context

# State & networking
npm install @tanstack/react-query zustand axios

# Storage & security
npm install react-native-mmkv           # Fast KV storage
npm install react-native-keychain       # Secure/biometric storage

# Push notifications
npm install @notifee/react-native @react-native-firebase/app @react-native-firebase/messaging

# Dev dependencies
npm install -D @testing-library/react-native jest
```

---

## Option C: Flutter

```bash
# Create project
flutter create --org com.company my_app
cd my_app

# State management & routing
flutter pub add go_router riverpod flutter_riverpod

# Networking
flutter pub add http dio

# Storage
flutter pub add shared_preferences hive hive_flutter
flutter pub add flutter_secure_storage

# Firebase
flutter pub add firebase_core firebase_messaging firebase_analytics

# Dev dependencies
flutter pub add --dev flutter_test integration_test build_runner
```

---

## Project Structure

### Expo / React Native
```
src/
├── app/              # Expo Router pages (file-based routing)
│   ├── (tabs)/       # Tab navigator group
│   ├── (auth)/       # Auth screens group
│   └── _layout.tsx   # Root layout
├── components/       # Reusable UI components
├── hooks/            # Custom hooks
├── services/         # API clients, storage
├── store/            # Zustand stores
├── utils/            # Helpers, constants
├── types/            # TypeScript types
└── __tests__/        # Test files
```

### Flutter
```
lib/
├── app/              # App configuration, theme, router
├── models/           # Data models (freezed)
├── providers/        # Riverpod providers
├── screens/          # App screens
├── widgets/          # Reusable widgets
├── services/         # API, storage, notifications
├── utils/            # Helpers, constants
└── l10n/             # Localization files
```

---

## CI/CD Setup

### GitHub Actions for React Native / Expo
```yaml
# .github/workflows/mobile-ci.yml
name: Mobile CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm test -- --coverage --watchAll=false
      - run: npx tsc --noEmit

  # Expo builds (EAS Build)
  # eas build --platform all --non-interactive
```

### GitHub Actions for Flutter
```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x' }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
```

---

## Store Configuration

### iOS (App Store Connect)
```
Required:
├── Apple Developer Account ($99/year)
├── Bundle ID: com.company.myapp
├── App Icon: 1024x1024 PNG
├── Screenshots: 6.7" + 5.5" iPhones
├── Privacy policy URL
└── App description + keywords
```

### Android (Google Play Console)
```
Required:
├── Google Play Developer Account ($25 one-time)
├── Package name: com.company.myapp
├── App Icon: 512x512 PNG
├── Feature graphic: 1024x500
├── Screenshots: phone + tablet
├── Privacy policy URL
├── Content rating questionnaire
└── Signing key (upload key)
```

---

## Post-Init Checklist

- [ ] Project builds without errors (`npm start` / `flutter run`)
- [ ] TypeScript/Dart analysis clean
- [ ] Navigation structure working
- [ ] Storage configured (secure + regular)
- [ ] CI pipeline green
- [ ] `.gitignore` includes build artifacts, `.env`, keystore
- [ ] README.md with setup instructions
- [ ] `.env.example` with required env vars

---

## Next Steps

```
/mobile-init complete →
├── /enhance    → Add features
├── /test       → Write tests
├── /mobile-test → Platform-specific tests
└── /mobile-deploy → Build & submit to stores
```


---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Lỗi không xác định hoặc crash | Bật chế độ verbose, kiểm tra log hệ thống, cắt nhỏ phạm vi debug |
| Thiếu package/dependencies | Kiểm tra file lock, chạy lại npm/composer install |
| Xung đột context API | Reset session, tắt các plugin/extension không liên quan |
| Thời gian chạy quá lâu (timeout) | Cấu hình lại timeout, tối ưu hóa các queries nặng |



