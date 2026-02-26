---
description: "Triển khai app lên Store"
---

# /mobile-deploy - App Store Deployment Workflow

// turbo-all

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
**Skills:** `mobile-design, deployment-procedures`

---

##  Mobile Deploy Checklist

- [ ] All tests passing (unit + integration + E2E)
- [ ] Version bumped (iOS CFBundleVersion + Android versionCode)
- [ ] Release notes written
- [ ] No console.logs or debug flags in production build
- [ ] Build succeeds without warnings
- [ ] TestFlight / Internal track tested on real devices
- [ ] Staged rollout configured (Android)
- [ ] Crash monitoring active (Crashlytics / Sentry)
- [ ] Post-deploy 24h monitoring plan ready

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| iOS build fails | cd ios && pod install --repo-update, check Xcode version |
| Android signing error | Verify keystore path and passwords in gradle.properties |
| App rejected by Apple | Check rejection reason, fix and re-submit (expedited review) |
| Play Store rejected | Check policy violations, content rating, target API level |
| Crash spike after release | Staged rollback (Android), emergency patch (iOS expedited) |
| Fastlane auth expired | fastlane spaceauth -u email@example.com |


