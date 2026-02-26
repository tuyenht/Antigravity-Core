# App Store Optimization & Deployment Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Platforms:** iOS App Store | Google Play  
> **Priority:** P0 - Load for app releases

---

You are an expert in App Store Optimization (ASO) and Mobile App Deployment.

## Core Principles

- Visibility leads to downloads
- Conversion rate optimization
- Automated deployment pipelines
- Compliance with store guidelines

---

## 1) App Store Optimization (ASO)

### Keyword Strategy
```
┌─────────────────────────────────────────┐
│          ASO KEYWORD STRATEGY           │
├─────────────────────────────────────────┤
│                                         │
│  iOS APP STORE:                         │
│  ├── Title: 30 chars (highest weight)  │
│  ├── Subtitle: 30 chars (high weight)  │
│  ├── Keywords: 100 chars (hidden)       │
│  └── In-App Purchases names            │
│                                         │
│  GOOGLE PLAY:                           │
│  ├── Title: 30 chars (highest weight)  │
│  ├── Short Description: 80 chars       │
│  ├── Full Description: 4000 chars      │
│  └── Keywords in description (indexed) │
│                                         │
│  KEYWORD RESEARCH TOOLS:                │
│  • App Radar                           │
│  • Sensor Tower                        │
│  • App Annie (data.ai)                 │
│  • Mobile Action                       │
│                                         │
│  BEST PRACTICES:                        │
│  • Use long-tail keywords              │
│  • Include competitors' names wisely   │
│  • Localize for each market           │
│  • Update keywords every 2-4 weeks    │
│  • Track ranking changes              │
│                                         │
└──────────────────────────────────────┘
```

### Visual Assets
```
┌─────────────────────────────────────────┐
│            VISUAL ASSETS                │
├─────────────────────────────────────────┤
│                                         │
│  APP ICON:                              │
│  ├── Simple, recognizable              │
│  ├── Scalable (1024×1024 base)         │
│  ├── No text (too small to read)       │
│  ├── Consistent branding               │
│  └── Stand out in search results       │
│                                         │
│  SCREENSHOTS (iOS):                     │
│  ├── iPhone 6.7" (required)            │
│  ├── iPhone 6.5" (required)            │
│  ├── iPhone 5.5" (required)            │
│  ├── iPad Pro 12.9" (if universal)     │
│  └── Up to 10 screenshots              │
│                                         │
│  SCREENSHOTS (Android):                 │
│  ├── Phone (required)                  │
│  ├── 7-inch tablet                     │
│  ├── 10-inch tablet                    │
│  └── 2-8 screenshots                   │
│                                         │
│  SCREENSHOT BEST PRACTICES:             │
│  • Show key features first             │
│  • Use captions/callouts               │
│  • Consistent design language          │
│  • A/B test variations                 │
│  • Localize text overlays              │
│                                         │
│  APP PREVIEW VIDEO:                     │
│  ├── iOS: 15-30 seconds               │
│  ├── Android: 30 seconds - 2 minutes   │
│  ├── Show real app usage               │
│  ├── Capture attention in first 3s    │
│  └── Include captions (muted autoplay) │
│                                         │
└──────────────────────────────────────┘
```

### Localization Strategy
```
┌─────────────────────────────────────────┐
│         LOCALIZATION PRIORITY           │
├─────────────────────────────────────────┤
│                                         │
│  TIER 1 (Essential):                    │
│  ├── English (US)                      │
│  ├── Spanish                           │
│  ├── Chinese (Simplified)              │
│  ├── Japanese                          │
│  └── German                            │
│                                         │
│  TIER 2 (High Impact):                  │
│  ├── French                            │
│  ├── Portuguese (Brazil)               │
│  ├── Korean                            │
│  ├── Italian                           │
│  └── Russian                           │
│                                         │
│  TIER 3 (Growth Markets):               │
│  ├── Hindi                             │
│  ├── Indonesian                        │
│  ├── Thai                              │
│  ├── Vietnamese                        │
│  ├── Arabic                            │
│  └── Turkish                           │
│                                         │
│  LOCALIZE:                              │
│  • App name/title                      │
│  • Subtitle/short description          │
│  • Full description                    │
│  • Keywords                            │
│  • Screenshots (text overlays)         │
│  • In-app content                      │
│                                         │
└──────────────────────────────────────┘
```

---

## 2) Fastlane Automation

### iOS Configuration
```ruby
# ==========================================
# FASTLANE - iOS CONFIGURATION
# ==========================================

# fastlane/Fastfile

default_platform(:ios)

platform :ios do
  
  # ========================================
  # SETUP & CERTIFICATES
  # ========================================
  
  desc "Sync certificates and profiles"
  lane :sync_certificates do
    match(
      type: "appstore",
      readonly: true,
      git_url: ENV["MATCH_GIT_URL"],
      app_identifier: "com.myapp.ios"
    )
    
    match(
      type: "development",
      readonly: true,
      git_url: ENV["MATCH_GIT_URL"],
      app_identifier: "com.myapp.ios"
    )
  end
  
  
  # ========================================
  # BUILD LANES
  # ========================================
  
  desc "Build app for App Store"
  lane :build_release do
    sync_certificates
    
    # Increment build number
    increment_build_number(
      build_number: ENV["BUILD_NUMBER"] || latest_testflight_build_number + 1
    )
    
    # Build
    build_app(
      workspace: "MyApp.xcworkspace",
      scheme: "MyApp",
      configuration: "Release",
      export_method: "app-store",
      output_directory: "./build",
      output_name: "MyApp.ipa",
      include_bitcode: false,
      clean: true
    )
  end
  
  
  # ========================================
  # DEPLOYMENT LANES
  # ========================================
  
  desc "Deploy to TestFlight"
  lane :beta do
    build_release
    
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      changelog: ENV["RELEASE_NOTES"] || "Bug fixes and improvements",
      distribute_external: false,
      notify_external_testers: false
    )
    
    # Notify team
    slack(
      message: "New TestFlight build uploaded! 🚀",
      slack_url: ENV["SLACK_WEBHOOK_URL"],
      default_payloads: [:git_branch, :git_author]
    )
  end
  
  desc "Deploy to App Store"
  lane :release do
    build_release
    
    # Upload to App Store Connect
    deliver(
      submit_for_review: false,
      automatic_release: false,
      force: true,
      skip_metadata: false,
      skip_screenshots: true,
      precheck_include_in_app_purchases: false,
      submission_information: {
        add_id_info_uses_idfa: false
      }
    )
    
    # Create GitHub release
    set_github_release(
      repository_name: "myorg/myapp-ios",
      api_token: ENV["GITHUB_TOKEN"],
      name: "v#{get_version_number}",
      tag_name: "v#{get_version_number}-#{get_build_number}",
      description: ENV["RELEASE_NOTES"] || "Release notes"
    )
    
    slack(
      message: "App submitted to App Store Review! 🎉",
      slack_url: ENV["SLACK_WEBHOOK_URL"]
    )
  end
  
  
  # ========================================
  # SCREENSHOTS
  # ========================================
  
  desc "Generate screenshots"
  lane :screenshots do
    capture_screenshots(
      workspace: "MyApp.xcworkspace",
      scheme: "MyAppUITests",
      output_directory: "./fastlane/screenshots",
      clear_previous_screenshots: true,
      devices: [
        "iPhone 15 Pro Max",
        "iPhone 15",
        "iPhone SE (3rd generation)",
        "iPad Pro (12.9-inch) (6th generation)"
      ],
      languages: [
        "en-US",
        "es-ES",
        "ja",
        "de-DE",
        "zh-Hans"
      ]
    )
    
    # Frame screenshots
    frame_screenshots(
      path: "./fastlane/screenshots",
      white: true
    )
  end
  
  
  # ========================================
  # ERROR HANDLING
  # ========================================
  
  error do |lane, exception|
    slack(
      message: "Error in lane #{lane}: #{exception.message}",
      success: false,
      slack_url: ENV["SLACK_WEBHOOK_URL"]
    )
  end
end
```

### Android Configuration
```ruby
# ==========================================
# FASTLANE - ANDROID CONFIGURATION
# ==========================================

# fastlane/Fastfile

default_platform(:android)

platform :android do
  
  # ========================================
  # BUILD LANES
  # ========================================
  
  desc "Build release AAB"
  lane :build_release do
    # Increment version code
    android_set_version_code(
      version_code: ENV["BUILD_NUMBER"].to_i || 
                    google_play_track_version_codes(track: "internal").max + 1
    )
    
    # Build AAB
    gradle(
      task: "bundle",
      build_type: "Release",
      project_dir: "./android",
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"]
      }
    )
  end
  
  
  # ========================================
  # DEPLOYMENT LANES
  # ========================================
  
  desc "Deploy to Internal Testing"
  lane :internal do
    build_release
    
    upload_to_play_store(
      track: "internal",
      aab: "./android/app/build/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      release_status: "completed"
    )
    
    slack(
      message: "New Android internal build uploaded! 🤖",
      slack_url: ENV["SLACK_WEBHOOK_URL"]
    )
  end
  
  desc "Deploy to Closed Beta"
  lane :beta do
    build_release
    
    upload_to_play_store(
      track: "beta",
      aab: "./android/app/build/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: false,
      skip_upload_images: true,
      release_status: "completed"
    )
    
    slack(
      message: "New Android beta build uploaded! 🚀",
      slack_url: ENV["SLACK_WEBHOOK_URL"]
    )
  end
  
  desc "Deploy to Production (Staged Rollout)"
  lane :release do
    build_release
    
    upload_to_play_store(
      track: "production",
      aab: "./android/app/build/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: false,
      skip_upload_images: false,
      rollout: "0.1",  # Start with 10%
      release_status: "inProgress"
    )
    
    # Create GitHub release
    set_github_release(
      repository_name: "myorg/myapp-android",
      api_token: ENV["GITHUB_TOKEN"],
      name: "v#{android_get_version_name}",
      tag_name: "v#{android_get_version_name}-#{android_get_version_code}",
      description: ENV["RELEASE_NOTES"]
    )
    
    slack(
      message: "Android release started (10% rollout)! 🎉",
      slack_url: ENV["SLACK_WEBHOOK_URL"]
    )
  end
  
  desc "Increase rollout percentage"
  lane :increase_rollout do |options|
    percentage = options[:percentage] || "0.5"
    
    upload_to_play_store(
      track: "production",
      rollout: percentage,
      skip_upload_aab: true,
      skip_upload_metadata: true
    )
    
    slack(
      message: "Rollout increased to #{(percentage.to_f * 100).to_i}%",
      slack_url: ENV["SLACK_WEBHOOK_URL"]
    )
  end
  
  desc "Complete rollout to 100%"
  lane :complete_rollout do
    upload_to_play_store(
      track: "production",
      rollout: "1.0",
      skip_upload_aab: true,
      skip_upload_metadata: true,
      release_status: "completed"
    )
    
    slack(
      message: "Full rollout completed! 🎊",
      slack_url: ENV["SLACK_WEBHOOK_URL"]
    )
  end
  
  
  # ========================================
  # SCREENSHOTS
  # ========================================
  
  desc "Generate screenshots"
  lane :screenshots do
    capture_android_screenshots(
      app_apk_path: "./android/app/build/outputs/apk/debug/app-debug.apk",
      tests_apk_path: "./android/app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk",
      output_directory: "./fastlane/screenshots/android",
      clear_previous_screenshots: true,
      locales: ["en-US", "es-ES", "ja-JP", "de-DE", "zh-CN"],
      device_type: "phone"
    )
  end
end
```

### Metadata Structure
```
# ==========================================
# FASTLANE METADATA STRUCTURE
# ==========================================

fastlane/
├── Fastfile
├── Appfile
├── Matchfile
├── Deliverfile
├── metadata/
│   ├── copyright.txt
│   ├── primary_category.txt
│   ├── secondary_category.txt
│   ├── en-US/
│   │   ├── name.txt
│   │   ├── subtitle.txt
│   │   ├── keywords.txt
│   │   ├── description.txt
│   │   ├── release_notes.txt
│   │   ├── promotional_text.txt
│   │   └── privacy_url.txt
│   ├── es-ES/
│   │   └── ...
│   └── ja/
│       └── ...
└── screenshots/
    ├── en-US/
    │   ├── iPhone 15 Pro Max-1_home.png
    │   ├── iPhone 15 Pro Max-2_feature.png
    │   └── ...
    ├── es-ES/
    │   └── ...
    └── android/
        ├── en-US/
        │   └── ...
        └── ...
```

---

## 3) CI/CD Pipelines

### GitHub Actions - React Native
```yaml
# ==========================================
# COMPLETE CI/CD PIPELINE
# ==========================================

# .github/workflows/release.yml
name: Release Mobile App

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      platform:
        description: 'Platform to build'
        required: true
        default: 'both'
        type: choice
        options:
          - ios
          - android
          - both
      track:
        description: 'Release track'
        required: true
        default: 'beta'
        type: choice
        options:
          - internal
          - beta
          - production

env:
  NODE_VERSION: '20'
  RUBY_VERSION: '3.2'

jobs:
  # ========================================
  # PREPARE RELEASE
  # ========================================
  prepare:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
      build_number: ${{ steps.version.outputs.build_number }}
      release_notes: ${{ steps.notes.outputs.notes }}
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Get version info
        id: version
        run: |
          VERSION=$(node -p "require('./package.json').version")
          BUILD_NUMBER=${{ github.run_number }}
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "build_number=$BUILD_NUMBER" >> $GITHUB_OUTPUT
      
      - name: Generate release notes
        id: notes
        run: |
          NOTES=$(git log --pretty=format:"- %s" $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~10)..HEAD)
          echo "notes<<EOF" >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

  # ========================================
  # BUILD & DEPLOY iOS
  # ========================================
  ios:
    needs: prepare
    if: ${{ github.event.inputs.platform != 'android' }}
    runs-on: macos-14
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'yarn'
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
      
      - name: Install dependencies
        run: |
          yarn install --frozen-lockfile
          cd ios && pod install
      
      - name: Setup certificates
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
          MATCH_GIT_PRIVATE_KEY: ${{ secrets.MATCH_GIT_PRIVATE_KEY }}
        run: |
          echo "$MATCH_GIT_PRIVATE_KEY" > ~/.ssh/match_key
          chmod 600 ~/.ssh/match_key
          cd ios && bundle exec fastlane sync_certificates
      
      - name: Build and upload
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY: ${{ secrets.ASC_PRIVATE_KEY }}
          BUILD_NUMBER: ${{ needs.prepare.outputs.build_number }}
          RELEASE_NOTES: ${{ needs.prepare.outputs.release_notes }}
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        run: |
          cd ios
          if [ "${{ github.event.inputs.track }}" = "production" ]; then
            bundle exec fastlane release
          else
            bundle exec fastlane beta
          fi
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ios-ipa
          path: ios/build/*.ipa

  # ========================================
  # BUILD & DEPLOY ANDROID
  # ========================================
  android:
    needs: prepare
    if: ${{ github.event.inputs.platform != 'ios' }}
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'yarn'
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
      
      - name: Install dependencies
        run: yarn install --frozen-lockfile
      
      - name: Decode keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: |
          echo "$KEYSTORE_BASE64" | base64 -d > android/app/release.keystore
      
      - name: Build and upload
        env:
          KEYSTORE_PATH: ${{ github.workspace }}/android/app/release.keystore
          KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          GOOGLE_PLAY_JSON_KEY: ${{ secrets.GOOGLE_PLAY_JSON_KEY }}
          BUILD_NUMBER: ${{ needs.prepare.outputs.build_number }}
          RELEASE_NOTES: ${{ needs.prepare.outputs.release_notes }}
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        run: |
          echo "$GOOGLE_PLAY_JSON_KEY" > android/google-play-key.json
          cd android
          
          TRACK="${{ github.event.inputs.track }}"
          case $TRACK in
            production) bundle exec fastlane release ;;
            beta) bundle exec fastlane beta ;;
            *) bundle exec fastlane internal ;;
          esac
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: android-aab
          path: android/app/build/outputs/bundle/release/*.aab

  # ========================================
  # CREATE GITHUB RELEASE
  # ========================================
  create-release:
    needs: [prepare, ios, android]
    if: always() && (needs.ios.result == 'success' || needs.android.result == 'success')
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download iOS artifact
        if: needs.ios.result == 'success'
        uses: actions/download-artifact@v4
        with:
          name: ios-ipa
          path: ./artifacts
      
      - name: Download Android artifact
        if: needs.android.result == 'success'
        uses: actions/download-artifact@v4
        with:
          name: android-aab
          path: ./artifacts
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v${{ needs.prepare.outputs.version }}-${{ needs.prepare.outputs.build_number }}
          name: Release ${{ needs.prepare.outputs.version }}
          body: ${{ needs.prepare.outputs.release_notes }}
          files: ./artifacts/*
          draft: false
          prerelease: ${{ github.event.inputs.track != 'production' }}
```

---

## 4) Store Guidelines

### iOS App Store Review
```
┌─────────────────────────────────────────┐
│     iOS APP STORE REVIEW CHECKLIST      │
├─────────────────────────────────────────┤
│                                         │
│  COMMON REJECTION REASONS:              │
│                                         │
│  2.1 - App Completeness                │
│  □ No placeholder content              │
│  □ All features functional             │
│  □ No broken links                     │
│  □ Demo account if login required      │
│                                         │
│  2.3 - Accurate Metadata               │
│  □ Screenshots show actual app         │
│  □ Description matches functionality   │
│  □ No misleading claims                │
│                                         │
│  3.1.1 - In-App Purchase              │
│  □ Digital goods use IAP              │
│  □ Restore purchases implemented       │
│  □ Clear pricing information           │
│                                         │
│  4.2 - Minimum Functionality           │
│  □ Not a simple website wrapper       │
│  □ Sufficient native features          │
│  □ Compelling user experience          │
│                                         │
│  5.1 - Privacy                         │
│  □ Privacy policy URL                  │
│  □ App Privacy labels accurate         │
│  □ Data collection disclosed           │
│  □ User consent obtained               │
│                                         │
│  REQUIRED INFORMATION:                  │
│  □ Demo account credentials            │
│  □ Test in-app purchases               │
│  □ Notes for reviewer                  │
│  □ Contact information                 │
│                                         │
└──────────────────────────────────────┘
```

### Google Play Policy
```
┌─────────────────────────────────────────┐
│      GOOGLE PLAY POLICY CHECKLIST       │
├─────────────────────────────────────────┤
│                                         │
│  KEY POLICIES:                          │
│                                         │
│  User Data:                             │
│  □ Data Safety form completed          │
│  □ Privacy policy accessible           │
│  □ Sensitive permissions justified     │
│  □ Data deletion option available      │
│                                         │
│  Content Policy:                        │
│  □ Appropriate content rating          │
│  □ Age-gating if required              │
│  □ No restricted content               │
│                                         │
│  Monetization:                          │
│  □ Clear ad disclosure                 │
│  □ Subscription terms visible          │
│  □ Refund policy stated                │
│                                         │
│  Functionality:                         │
│  □ Works without crashes               │
│  □ Core features accessible            │
│  □ Reasonable load times               │
│                                         │
│  TARGET API REQUIREMENTS:               │
│  □ New apps: API 34 (Android 14)       │
│  □ Updates: API 34                     │
│  □ Wear OS: API 33                     │
│                                         │
│  REQUIRED DECLARATIONS:                 │
│  □ Target audience                     │
│  □ App category                        │
│  □ Contact email                       │
│  □ Privacy policy URL                  │
│                                         │
└──────────────────────────────────────┘
```

---

## 5) Release Strategies

### Phased Rollout
```
┌─────────────────────────────────────────┐
│         PHASED ROLLOUT STRATEGY         │
├─────────────────────────────────────────┤
│                                         │
│  iOS (App Store):                       │
│  Day 1:    1%                          │
│  Day 2:    2%                          │
│  Day 3:    5%                          │
│  Day 4:   10%                          │
│  Day 5:   20%                          │
│  Day 6:   50%                          │
│  Day 7:  100%                          │
│                                         │
│  Android (Google Play):                 │
│  Stage 1:  1% - 5%   (1-2 days)        │
│  Stage 2: 10% - 20%  (1-2 days)        │
│  Stage 3: 50%        (2-3 days)        │
│  Stage 4: 100%       (full release)    │
│                                         │
│  HALT CONDITIONS:                       │
│  • Crash rate > 0.5%                   │
│  • ANR rate > 0.1% (Android)           │
│  • Critical bug reports                │
│  • 1-star rating spike                 │
│                                         │
│  MONITORING DURING ROLLOUT:             │
│  • Crashlytics / Firebase Crashlytics  │
│  • Play Console vitals (Android)       │
│  • App Store Connect metrics (iOS)     │
│  • User reviews                        │
│  • Support tickets                     │
│                                         │
└──────────────────────────────────────┘
```

### Feature Flags
```typescript
// ==========================================
// FEATURE FLAG SERVICE
// ==========================================

import remoteConfig from '@react-native-firebase/remote-config';

interface FeatureFlags {
  new_checkout_flow: boolean;
  dark_mode_enabled: boolean;
  max_upload_size_mb: number;
  promo_banner_text: string;
}

class FeatureFlagService {
  private static instance: FeatureFlagService;
  private flags: FeatureFlags = {
    new_checkout_flow: false,
    dark_mode_enabled: true,
    max_upload_size_mb: 10,
    promo_banner_text: '',
  };

  static getInstance(): FeatureFlagService {
    if (!FeatureFlagService.instance) {
      FeatureFlagService.instance = new FeatureFlagService();
    }
    return FeatureFlagService.instance;
  }

  async initialize(): Promise<void> {
    await remoteConfig().setDefaults(this.flags);
    
    await remoteConfig().setConfigSettings({
      minimumFetchIntervalMillis: __DEV__ ? 0 : 3600000, // 1 hour in prod
    });
    
    await this.fetch();
  }

  async fetch(): Promise<void> {
    try {
      await remoteConfig().fetchAndActivate();
      this.updateFlags();
    } catch (error) {
      console.error('Failed to fetch remote config:', error);
    }
  }

  private updateFlags(): void {
    const config = remoteConfig();
    this.flags = {
      new_checkout_flow: config.getBoolean('new_checkout_flow'),
      dark_mode_enabled: config.getBoolean('dark_mode_enabled'),
      max_upload_size_mb: config.getNumber('max_upload_size_mb'),
      promo_banner_text: config.getString('promo_banner_text'),
    };
  }

  isEnabled(flag: keyof FeatureFlags): boolean {
    return Boolean(this.flags[flag]);
  }

  getValue<K extends keyof FeatureFlags>(flag: K): FeatureFlags[K] {
    return this.flags[flag];
  }
}

export const featureFlags = FeatureFlagService.getInstance();


// ==========================================
// USAGE IN COMPONENTS
// ==========================================

function CheckoutScreen() {
  const useNewFlow = featureFlags.isEnabled('new_checkout_flow');
  
  if (useNewFlow) {
    return <NewCheckoutFlow />;
  }
  
  return <LegacyCheckoutFlow />;
}
```

---

## 6) Monitoring & Analytics

### Crash Monitoring Setup
```typescript
// ==========================================
// CRASHLYTICS SETUP
// ==========================================

import crashlytics from '@react-native-firebase/crashlytics';

class CrashReportingService {
  
  async initialize(): Promise<void> {
    // Enable crash collection
    await crashlytics().setCrashlyticsCollectionEnabled(!__DEV__);
  }

  setUser(userId: string): void {
    crashlytics().setUserId(userId);
  }

  setUserAttributes(attributes: Record<string, string>): void {
    Object.entries(attributes).forEach(([key, value]) => {
      crashlytics().setAttribute(key, value);
    });
  }

  log(message: string): void {
    crashlytics().log(message);
  }

  recordError(error: Error, context?: string): void {
    if (context) {
      crashlytics().log(context);
    }
    crashlytics().recordError(error);
  }

  // Force crash for testing
  testCrash(): void {
    crashlytics().crash();
  }
}

export const crashReporting = new CrashReportingService();


// ==========================================
// ERROR BOUNDARY WITH CRASH REPORTING
// ==========================================

class ErrorBoundary extends React.Component<Props, State> {
  state = { hasError: false };

  static getDerivedStateFromError(): State {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    crashReporting.log(`Component Stack: ${errorInfo.componentStack}`);
    crashReporting.recordError(error, 'React Error Boundary');
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback onRetry={() => this.setState({ hasError: false })} />;
    }
    return this.props.children;
  }
}
```

### Analytics Events
```typescript
// ==========================================
// ANALYTICS SERVICE
// ==========================================

import analytics from '@react-native-firebase/analytics';

class AnalyticsService {
  
  // Screen tracking
  async logScreenView(screenName: string, screenClass?: string): Promise<void> {
    await analytics().logScreenView({
      screen_name: screenName,
      screen_class: screenClass || screenName,
    });
  }

  // E-commerce events
  async logPurchase(
    transactionId: string,
    value: number,
    currency: string,
    items: Array<{ id: string; name: string; price: number }>
  ): Promise<void> {
    await analytics().logPurchase({
      transaction_id: transactionId,
      value,
      currency,
      items: items.map(item => ({
        item_id: item.id,
        item_name: item.name,
        price: item.price,
      })),
    });
  }

  // Custom events
  async logEvent(
    eventName: string,
    params?: Record<string, any>
  ): Promise<void> {
    await analytics().logEvent(eventName, params);
  }

  // User properties
  async setUserProperty(name: string, value: string): Promise<void> {
    await analytics().setUserProperty(name, value);
  }
}

export const analyticsService = new AnalyticsService();


// ==========================================
// KEY EVENTS TO TRACK
// ==========================================

/*
ACQUISITION:
- app_install
- first_open
- registration_start
- registration_complete

ENGAGEMENT:
- login
- screen_view
- feature_used
- content_viewed

MONETIZATION:
- add_to_cart
- begin_checkout
- purchase
- subscription_started

RETENTION:
- session_start
- notification_received
- notification_opened
- app_update
*/
```

---

## 7) ASO Checklist

### Pre-Launch Checklist
```
┌─────────────────────────────────────────┐
│         PRE-LAUNCH ASO CHECKLIST        │
├─────────────────────────────────────────┤
│                                         │
│  METADATA:                              │
│  □ App name optimized with keywords    │
│  □ Subtitle/short description ready    │
│  □ Full description keyword-rich       │
│  □ Keywords field filled (iOS)         │
│  □ Localized for target markets        │
│                                         │
│  VISUALS:                               │
│  □ App icon finalized                  │
│  □ Screenshots for all required sizes  │
│  □ Screenshot text localized           │
│  □ App preview video created           │
│  □ Feature graphic (Android)           │
│                                         │
│  TECHNICAL:                             │
│  □ Version number set correctly        │
│  □ Build number incremented            │
│  □ Signing configured                  │
│  □ Privacy policy URL                  │
│  □ Support URL                         │
│                                         │
│  TESTING:                               │
│  □ Internal testing completed          │
│  □ Beta testing completed              │
│  □ Crash rate < 0.1%                   │
│  □ Critical bugs fixed                 │
│                                         │
│  MARKETING:                             │
│  □ Press kit ready                     │
│  □ Social media assets                 │
│  □ Landing page updated                │
│  □ Launch day plan                     │
│                                         │
└──────────────────────────────────────┘
```

---

## Best Practices Summary

### ASO
- [ ] Keyword research done
- [ ] Compelling screenshots
- [ ] Localized metadata
- [ ] Regular A/B testing

### Automation
- [ ] Fastlane configured
- [ ] CI/CD pipelines setup
- [ ] Automated versioning
- [ ] Screenshot automation

### Release
- [ ] Phased rollout
- [ ] Feature flags
- [ ] Crash monitoring
- [ ] Analytics tracking

### Compliance
- [ ] Store guidelines reviewed
- [ ] Privacy policy updated
- [ ] Data declarations complete
- [ ] Review notes prepared

---

**References:**
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Policy Center](https://play.google.com/console/about/policy-center/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
