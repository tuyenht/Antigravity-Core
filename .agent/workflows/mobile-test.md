---
description: Test mobile đa nền tảng
---

# /mobile-test - Mobile Testing Workflow

Run platform-specific tests for iOS and Android.

## Test Types

### 1. Unit Tests
```bash
# React Native
npm test

# Flutter
flutter test
```

### 2. Component/Widget Tests
```javascript
// React Native
import { render, fireEvent } from '@testing-library/react-native';

test('button press works', () => {
  const { getByText } = render(<LoginScreen />);
  fireEvent.press(getByText('Login'));
  expect(mockLogin).toHaveBeenCalled();
});
```

```dart
// Flutter
testWidgets('Counter increments', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('0'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('1'), findsOneWidget');
});
```

### 3. Integration Tests
```bash
# React Native (Detox)
detox test --configuration ios.sim.debug

# Flutter
flutter test integration_test/
```

### 4. Platform-Specific Tests
```bash
# iOS only
npm test -- --testPathPattern=ios

# Android only  
npm test -- --testPathPattern=android
```

## Success Criteria

✅ All unit tests pass  
✅ Component tests pass  
✅ Integration tests pass (both platforms)  
✅ No memory leaks  
✅ Performance within targets

**Agent:** `test-engineer` + `mobile-developer`
