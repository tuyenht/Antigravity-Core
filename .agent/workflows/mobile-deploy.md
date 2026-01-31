---
description: Deploy mobile app to App Store and Google Play
---

# /mobile-deploy - App Store Deployment Workflow

Automated deployment to iOS App Store and Google Play Store.

## Pre-Deployment Checklist

```
✅ All tests passing
✅ Version bumped (iOS: CFBundleVersion, Android: versionCode)
✅ Release notes written
✅ Screenshots updated (if UI changed)
✅ Privacy policy updated (if data collection changed)
✅ No console.logs in production
```

## iOS Deployment

### 1. Build & Archive
```bash
# React Native
cd ios && pod install
xcodebuild archive -workspace MyApp.xcworkspace -scheme MyApp

# Flutter
flutter build ipa
```

### 2. Upload to App Store Connect
```bash
# Via Xcode or Fastlane
fastlane ios release
```

### 3. TestFlight
- Upload build
- Add release notes
- Submit for internal testing
- External testing (optional)

### 4. App Store Submission
- Fill metadata (if first release)
- Submit for review
- Monitor status

**Timeline:** 24-48 hours review

---

## Android Deployment

### 1. Build Release APK/AAB
```bash
# React Native
cd android && ./gradlew bundleRelease

# Flutter
flutter build appbundle
```

### 2. Upload to Play Console
```bash
# Via Play Console UI or Fastlane
fastlane android release
```

### 3. Internal Testing
- Upload to internal testing track
- Test on real devices

### 4. Production Release
- Promote to production
- Staged rollout (10% → 50% → 100%)
- Monitor crash reports

**Timeline:** Few hours to 1 day review

---

## Fastlane Automation

**Fastfile (iOS):**
```ruby
lane :release do
  increment_build_number
  build_app(scheme: "MyApp")
  upload_to_testflight
end
```

**Fastfile (Android):**
```ruby
lane :release do
  gradle(task: "bundleRelease")
  upload_to_play_store(track: "internal")
end
```

---

## Post-Deployment

```
Monitor first 24 hours:
- Crash-free rate (target: >99%)
- User ratings (target: >4.0)
- Performance metrics
- Server load

If issues:
- Staged rollback available (Android)
- Emergency patch release (iOS: expedited review)
```

**Agent:** `devops-engineer` + `mobile-developer`
