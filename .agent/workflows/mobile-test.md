---
description: Test mobile đa nền tảng
---

# /mobile-test — Mobile Testing Workflow

// turbo-all

Chạy toàn bộ test suite cho mobile app (React Native / Flutter) trên cả iOS và Android.

**Agent:** `test-engineer` + `mobile-developer`  
**Skills:** `testing-mastery`, `react-native-performance`, `mobile-design`

---

## Pre-Check

1. Detect mobile framework:

```
Auto-detect:
├── package.json + "react-native"  → React Native
├── package.json + "expo"          → Expo (React Native)
├── pubspec.yaml                   → Flutter
└── Không tìm thấy                → STOP: "Không phát hiện mobile project"
```

2. Kiểm tra dependencies:

```bash
# React Native / Expo
npm ls @testing-library/react-native jest || echo "⚠️ Missing test dependencies"

# Flutter
flutter doctor
```

---

## Step 1: Unit Tests

```bash
# React Native / Expo
npm test -- --coverage --watchAll=false

# Flutter
flutter test --coverage
```

**Target:** Coverage ≥ 80% cho business logic

---

## Step 2: Component / Widget Tests

```javascript
// React Native — Testing Library
import { render, fireEvent, waitFor } from '@testing-library/react-native';

test('login button triggers auth flow', async () => {
  const { getByText, getByPlaceholderText } = render(<LoginScreen />);
  
  fireEvent.changeText(getByPlaceholderText('Email'), 'user@test.com');
  fireEvent.changeText(getByPlaceholderText('Password'), 'pass123');
  fireEvent.press(getByText('Login'));
  
  await waitFor(() => {
    expect(mockLogin).toHaveBeenCalledWith('user@test.com', 'pass123');
  });
});
```

```dart
// Flutter — Widget Tests
testWidgets('Counter increments', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('0'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
});
```

---

## Step 3: Integration / E2E Tests

```bash
# React Native — Detox
detox build --configuration ios.sim.debug
detox test --configuration ios.sim.debug

# React Native — Maestro (alternative)
maestro test .maestro/

# Flutter
flutter test integration_test/
```

---

## Step 4: Platform-Specific Tests

```bash
# iOS only
npm test -- --testPathPattern=ios --watchAll=false

# Android only
npm test -- --testPathPattern=android --watchAll=false

# Flutter — iOS simulator
flutter test --device-id=iPhone
# Flutter — Android emulator
flutter test --device-id=emulator
```

---

## Step 5: Performance & Memory Check

```bash
# React Native — Perf monitor
npx react-native-performance-monitor

# Flutter — DevTools
flutter run --profile
# → Mở DevTools → Memory tab → Check for leaks
```

**Targets:**
- App startup: < 2s (cold), < 500ms (warm)
- Screen transitions: < 300ms
- Memory: No leaks after 10 navigation cycles
- FPS: ≥ 58 (target 60)

---

## Step 6: Mobile Audit Script

```bash
python .agent/skills/mobile-design/scripts/mobile_audit.py --root .
```

---

## Success Criteria

- [ ] All unit tests pass
- [ ] Component/widget tests pass
- [ ] Coverage ≥ 80%
- [ ] Integration tests pass (both platforms)
- [ ] No memory leaks detected
- [ ] Performance within targets
- [ ] Mobile audit clean
- [ ] No console warnings/errors

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Detox build fails | `detox clean-framework-cache && detox build` |
| iOS simulator crash | `xcrun simctl shutdown all && xcrun simctl delete unavailable` |
| Flutter test timeout | `flutter test --timeout 120s` |
| Jest out of memory | `NODE_OPTIONS=--max-old-space-size=4096 npm test` |
