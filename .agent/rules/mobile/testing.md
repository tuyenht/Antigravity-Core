# Mobile Testing Strategies Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Coverage Target:** 80%+ Unit, 60%+ Integration  
> **Priority:** P0 - Load for quality assurance

---

You are an expert in Mobile Testing strategies and automation.

## Core Principles

- Test early and often
- Pyramid of testing (Unit > Integration > E2E)
- Test on real devices, not just simulators
- Automate regression testing

---

## 1) Testing Pyramid

### Test Distribution
```
┌─────────────────────────────────────────┐
│            TESTING PYRAMID              │
├─────────────────────────────────────────┤
│                                         │
│                  /\                     │
│                 /  \                    │
│                / E2E\     5-10%         │
│               /──────\    (Slow, Costly)│
│              /        \                 │
│             /Integration\   20-30%      │
│            /────────────\  (Medium)     │
│           /              \              │
│          /   Unit Tests   \  60-70%     │
│         /──────────────────\ (Fast,Cheap)│
│                                         │
│  COVERAGE TARGETS:                      │
│  • Unit:        80%+ code coverage     │
│  • Integration: 60%+ critical paths    │
│  • E2E:         20-30 key user flows   │
│                                         │
│  EXECUTION TIME BUDGET:                 │
│  • Unit:        < 2 minutes            │
│  • Integration: < 10 minutes           │
│  • E2E:         < 30 minutes           │
│                                         │
└─────────────────────────────────────────┘
```

---

## 2) Unit Testing

### React Native (Jest)
```tsx
// ==========================================
// UNIT TEST SETUP
// ==========================================

// jest.config.js
module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|@react-navigation)/)',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{ts,tsx}',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};


// ==========================================
// UTILITY FUNCTION TESTS
// ==========================================

// utils/validation.ts
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function formatCurrency(amount: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount);
}

// utils/__tests__/validation.test.ts
import { isValidEmail, formatCurrency } from '../validation';

describe('isValidEmail', () => {
  it('returns true for valid emails', () => {
    expect(isValidEmail('test@example.com')).toBe(true);
    expect(isValidEmail('user.name@domain.co.uk')).toBe(true);
  });

  it('returns false for invalid emails', () => {
    expect(isValidEmail('')).toBe(false);
    expect(isValidEmail('invalid')).toBe(false);
    expect(isValidEmail('missing@domain')).toBe(false);
    expect(isValidEmail('@nodomain.com')).toBe(false);
  });
});

describe('formatCurrency', () => {
  it('formats USD correctly', () => {
    expect(formatCurrency(1234.56)).toBe('$1,234.56');
    expect(formatCurrency(0)).toBe('$0.00');
  });

  it('formats other currencies', () => {
    expect(formatCurrency(1234.56, 'EUR')).toBe('€1,234.56');
  });
});


// ==========================================
// HOOK TESTS
// ==========================================

// hooks/useDebounce.ts
import { useState, useEffect } from 'react';

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

// hooks/__tests__/useDebounce.test.ts
import { renderHook, act } from '@testing-library/react-hooks';
import { useDebounce } from '../useDebounce';

describe('useDebounce', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('returns initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('initial', 500));
    expect(result.current).toBe('initial');
  });

  it('debounces value changes', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 500),
      { initialProps: { value: 'initial' } }
    );

    rerender({ value: 'updated' });
    
    // Value shouldn't change immediately
    expect(result.current).toBe('initial');

    // Fast-forward time
    act(() => {
      jest.advanceTimersByTime(500);
    });

    // Now it should be updated
    expect(result.current).toBe('updated');
  });
});


// ==========================================
// VIEWMODEL/STORE TESTS
// ==========================================

// stores/authStore.ts
import { create } from 'zustand';

interface AuthState {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: false,
  error: null,
  
  login: async (email, password) => {
    set({ isLoading: true, error: null });
    try {
      const user = await authService.login(email, password);
      set({ user, isLoading: false });
    } catch (error) {
      set({ error: error.message, isLoading: false });
    }
  },
  
  logout: () => {
    set({ user: null });
  },
}));

// stores/__tests__/authStore.test.ts
import { useAuthStore } from '../authStore';
import { authService } from '@/services/auth';

// Mock the service
jest.mock('@/services/auth');

describe('authStore', () => {
  beforeEach(() => {
    // Reset store between tests
    useAuthStore.setState({ user: null, isLoading: false, error: null });
    jest.clearAllMocks();
  });

  describe('login', () => {
    it('sets user on successful login', async () => {
      const mockUser = { id: '1', email: 'test@example.com', name: 'Test' };
      (authService.login as jest.Mock).mockResolvedValue(mockUser);

      await useAuthStore.getState().login('test@example.com', 'password');

      expect(useAuthStore.getState().user).toEqual(mockUser);
      expect(useAuthStore.getState().isLoading).toBe(false);
      expect(useAuthStore.getState().error).toBeNull();
    });

    it('sets error on failed login', async () => {
      (authService.login as jest.Mock).mockRejectedValue(new Error('Invalid credentials'));

      await useAuthStore.getState().login('test@example.com', 'wrong');

      expect(useAuthStore.getState().user).toBeNull();
      expect(useAuthStore.getState().error).toBe('Invalid credentials');
    });
  });

  describe('logout', () => {
    it('clears user', () => {
      useAuthStore.setState({ user: { id: '1', email: 'test@example.com', name: 'Test' } });
      
      useAuthStore.getState().logout();

      expect(useAuthStore.getState().user).toBeNull();
    });
  });
});
```

### Mocking Dependencies
```tsx
// ==========================================
// MOCKING PATTERNS
// ==========================================

// __mocks__/react-native-keychain.ts
export const setGenericPassword = jest.fn().mockResolvedValue(true);
export const getGenericPassword = jest.fn().mockResolvedValue({
  username: 'user',
  password: 'token123',
});
export const resetGenericPassword = jest.fn().mockResolvedValue(true);

// __mocks__/@react-native-async-storage/async-storage.ts
const mockStorage: Record<string, string> = {};

export default {
  setItem: jest.fn((key: string, value: string) => {
    mockStorage[key] = value;
    return Promise.resolve();
  }),
  getItem: jest.fn((key: string) => {
    return Promise.resolve(mockStorage[key] || null);
  }),
  removeItem: jest.fn((key: string) => {
    delete mockStorage[key];
    return Promise.resolve();
  }),
  clear: jest.fn(() => {
    Object.keys(mockStorage).forEach(key => delete mockStorage[key]);
    return Promise.resolve();
  }),
};


// ==========================================
// MOCK API RESPONSES
// ==========================================

// test/mocks/handlers.ts (MSW)
import { rest } from 'msw';

export const handlers = [
  rest.post('/api/auth/login', (req, res, ctx) => {
    const { email, password } = req.body as any;
    
    if (email === 'test@example.com' && password === 'password123') {
      return res(
        ctx.status(200),
        ctx.json({
          user: { id: '1', email, name: 'Test User' },
          accessToken: 'mock-token',
        })
      );
    }
    
    return res(
      ctx.status(401),
      ctx.json({ error: 'Invalid credentials' })
    );
  }),
  
  rest.get('/api/products', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json({
        products: [
          { id: '1', name: 'Product 1', price: 29.99 },
          { id: '2', name: 'Product 2', price: 49.99 },
        ],
      })
    );
  }),
];

// test/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// jest.setup.ts
import { server } from './test/mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

---

## 3) Component Testing

### React Native Testing Library
```tsx
// ==========================================
// COMPONENT TESTS
// ==========================================

import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import { LoginScreen } from '../LoginScreen';

// Mock navigation
const mockNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({
    navigate: mockNavigate,
  }),
}));

describe('LoginScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders correctly', () => {
    const { getByText, getByPlaceholderText } = render(<LoginScreen />);

    expect(getByText('Welcome Back')).toBeTruthy();
    expect(getByPlaceholderText('Email')).toBeTruthy();
    expect(getByPlaceholderText('Password')).toBeTruthy();
    expect(getByText('Sign In')).toBeTruthy();
  });

  it('shows validation errors for empty fields', async () => {
    const { getByText, getByTestId } = render(<LoginScreen />);

    fireEvent.press(getByText('Sign In'));

    await waitFor(() => {
      expect(getByText('Email is required')).toBeTruthy();
      expect(getByText('Password is required')).toBeTruthy();
    });
  });

  it('shows error for invalid email', async () => {
    const { getByText, getByPlaceholderText } = render(<LoginScreen />);

    fireEvent.changeText(getByPlaceholderText('Email'), 'invalid-email');
    fireEvent.changeText(getByPlaceholderText('Password'), 'password123');
    fireEvent.press(getByText('Sign In'));

    await waitFor(() => {
      expect(getByText('Invalid email format')).toBeTruthy();
    });
  });

  it('submits form with valid credentials', async () => {
    const { getByText, getByPlaceholderText } = render(<LoginScreen />);

    fireEvent.changeText(getByPlaceholderText('Email'), 'test@example.com');
    fireEvent.changeText(getByPlaceholderText('Password'), 'password123');
    fireEvent.press(getByText('Sign In'));

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('Home');
    });
  });

  it('shows loading state during submission', async () => {
    const { getByText, getByPlaceholderText, getByTestId } = render(<LoginScreen />);

    fireEvent.changeText(getByPlaceholderText('Email'), 'test@example.com');
    fireEvent.changeText(getByPlaceholderText('Password'), 'password123');
    fireEvent.press(getByText('Sign In'));

    expect(getByTestId('loading-indicator')).toBeTruthy();
  });
});


// ==========================================
// SNAPSHOT TESTING
// ==========================================

import renderer from 'react-test-renderer';
import { ProductCard } from '../ProductCard';

describe('ProductCard', () => {
  const mockProduct = {
    id: '1',
    name: 'Test Product',
    price: 29.99,
    imageUrl: 'https://example.com/image.jpg',
  };

  it('matches snapshot', () => {
    const tree = renderer.create(
      <ProductCard product={mockProduct} onPress={() => {}} />
    ).toJSON();
    
    expect(tree).toMatchSnapshot();
  });

  it('matches snapshot in loading state', () => {
    const tree = renderer.create(
      <ProductCard product={mockProduct} onPress={() => {}} isLoading />
    ).toJSON();
    
    expect(tree).toMatchSnapshot();
  });
});
```

---

## 4) E2E Testing

### Detox (React Native)
```tsx
// ==========================================
// DETOX SETUP
// ==========================================

// .detoxrc.js
module.exports = {
  testRunner: {
    $0: 'jest',
    args: {
      config: 'e2e/jest.config.js',
      _: ['e2e'],
    },
  },
  apps: {
    'ios.debug': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Debug-iphonesimulator/MyApp.app',
      build: 'xcodebuild -workspace ios/MyApp.xcworkspace -scheme MyApp -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build',
    },
    'android.debug': {
      type: 'android.apk',
      binaryPath: 'android/app/build/outputs/apk/debug/app-debug.apk',
      build: 'cd android && ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug',
    },
  },
  devices: {
    simulator: {
      type: 'ios.simulator',
      device: { type: 'iPhone 15' },
    },
    emulator: {
      type: 'android.emulator',
      device: { avdName: 'Pixel_7_API_34' },
    },
  },
  configurations: {
    'ios.sim.debug': {
      device: 'simulator',
      app: 'ios.debug',
    },
    'android.emu.debug': {
      device: 'emulator',
      app: 'android.debug',
    },
  },
};


// ==========================================
// DETOX E2E TESTS
// ==========================================

// e2e/login.e2e.ts
import { device, element, by, expect } from 'detox';

describe('Login Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should show login screen', async () => {
    await expect(element(by.text('Welcome Back'))).toBeVisible();
    await expect(element(by.id('email-input'))).toBeVisible();
    await expect(element(by.id('password-input'))).toBeVisible();
  });

  it('should show validation errors for empty submission', async () => {
    await element(by.id('login-button')).tap();
    
    await expect(element(by.text('Email is required'))).toBeVisible();
    await expect(element(by.text('Password is required'))).toBeVisible();
  });

  it('should login successfully with valid credentials', async () => {
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();
    
    // Wait for navigation
    await waitFor(element(by.text('Home')))
      .toBeVisible()
      .withTimeout(5000);
  });

  it('should show error for invalid credentials', async () => {
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('wrongpassword');
    await element(by.id('login-button')).tap();
    
    await expect(element(by.text('Invalid credentials'))).toBeVisible();
  });
});


// e2e/productFlow.e2e.ts
describe('Product Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
    // Login first
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();
    await waitFor(element(by.text('Home'))).toBeVisible().withTimeout(5000);
  });

  it('should navigate to product list', async () => {
    await element(by.id('products-tab')).tap();
    await expect(element(by.id('product-list'))).toBeVisible();
  });

  it('should search for products', async () => {
    await element(by.id('search-input')).typeText('iPhone');
    await waitFor(element(by.text('iPhone 15 Pro')))
      .toBeVisible()
      .withTimeout(3000);
  });

  it('should view product details', async () => {
    await element(by.text('iPhone 15 Pro')).tap();
    await expect(element(by.id('product-detail-screen'))).toBeVisible();
    await expect(element(by.text('Add to Cart'))).toBeVisible();
  });

  it('should add product to cart', async () => {
    await element(by.text('Add to Cart')).tap();
    await expect(element(by.text('Added to cart'))).toBeVisible();
    
    // Navigate to cart
    await element(by.id('cart-tab')).tap();
    await expect(element(by.text('iPhone 15 Pro'))).toBeVisible();
  });

  it('should handle pull to refresh', async () => {
    await element(by.id('products-tab')).tap();
    await element(by.id('product-list')).swipe('down', 'slow');
    
    // Verify list refreshed
    await waitFor(element(by.id('refresh-indicator')))
      .not.toBeVisible()
      .withTimeout(3000);
  });
});
```

### Maestro (Cross-platform)
```yaml
# ==========================================
# MAESTRO E2E TESTS
# ==========================================

# e2e/login.yaml
appId: com.myapp
---
- launchApp
- assertVisible: "Welcome Back"

# Test empty submission
- tapOn: "Sign In"
- assertVisible: "Email is required"

# Test successful login
- clearText
- tapOn:
    id: "email-input"
- inputText: "test@example.com"
- tapOn:
    id: "password-input"
- inputText: "password123"
- hideKeyboard
- tapOn: "Sign In"
- assertVisible: "Home"


# e2e/productFlow.yaml
appId: com.myapp
---
- launchApp

# Login first
- runFlow: login.yaml

# Navigate to products
- tapOn:
    id: "products-tab"
- assertVisible:
    id: "product-list"

# Search for product
- tapOn:
    id: "search-input"
- inputText: "iPhone"
- assertVisible: "iPhone 15 Pro"

# View product details
- tapOn: "iPhone 15 Pro"
- assertVisible: "Add to Cart"

# Add to cart
- tapOn: "Add to Cart"
- assertVisible: "Added to cart"

# Verify cart
- tapOn:
    id: "cart-tab"
- assertVisible: "iPhone 15 Pro"


# e2e/checkout.yaml
appId: com.myapp
---
- launchApp
- runFlow: login.yaml
- runFlow: addToCart.yaml

# Start checkout
- tapOn: "Proceed to Checkout"
- assertVisible: "Shipping Address"

# Fill shipping info
- inputText:
    id: "address-line-1"
    text: "123 Main St"
- inputText:
    id: "city"
    text: "New York"
- inputText:
    id: "zip"
    text: "10001"
- tapOn: "Continue"

# Payment
- assertVisible: "Payment Method"
- tapOn: "Credit Card"
- inputText:
    id: "card-number"
    text: "4242424242424242"
- tapOn: "Place Order"

# Confirmation
- assertVisible: "Order Confirmed"
- assertVisible: "Order #"
```

---

## 5) CI/CD Integration

### GitHub Actions
```yaml
# ==========================================
# CI/CD PIPELINE
# ==========================================

# .github/workflows/mobile-ci.yml
name: Mobile CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  # ==========================================
  # UNIT & INTEGRATION TESTS
  # ==========================================
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'
      
      - name: Install dependencies
        run: yarn install --frozen-lockfile
      
      - name: Run linting
        run: yarn lint
      
      - name: Run type checking
        run: yarn typecheck
      
      - name: Run unit tests
        run: yarn test --coverage --ci
      
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage/lcov.info

  # ==========================================
  # iOS E2E TESTS
  # ==========================================
  e2e-ios:
    runs-on: macos-14
    needs: test
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'
      
      - name: Install dependencies
        run: yarn install --frozen-lockfile
      
      - name: Install pods
        run: cd ios && pod install
      
      - name: Build iOS app
        run: yarn detox build --configuration ios.sim.release
      
      - name: Run Detox tests
        run: yarn detox test --configuration ios.sim.release --cleanup
      
      - name: Upload test artifacts
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: detox-artifacts-ios
          path: artifacts/

  # ==========================================
  # ANDROID E2E TESTS
  # ==========================================
  e2e-android:
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Install dependencies
        run: yarn install --frozen-lockfile
      
      - name: Build Android app
        run: yarn detox build --configuration android.emu.release
      
      - name: Enable KVM
        run: |
          echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
          sudo udevadm control --reload-rules
          sudo udevadm trigger --name-match=kvm
      
      - name: Run Detox tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          target: google_apis
          arch: x86_64
          script: yarn detox test --configuration android.emu.release --cleanup
      
      - name: Upload test artifacts
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: detox-artifacts-android
          path: artifacts/

  # ==========================================
  # MAESTRO TESTS (Alternative)
  # ==========================================
  e2e-maestro:
    runs-on: macos-14
    needs: test
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Maestro
        run: |
          curl -Ls "https://get.maestro.mobile.dev" | bash
          echo "$HOME/.maestro/bin" >> $GITHUB_PATH
      
      - name: Build iOS app
        run: |
          yarn install
          cd ios && pod install
          xcodebuild -workspace MyApp.xcworkspace -scheme MyApp -configuration Debug -sdk iphonesimulator -derivedDataPath build
      
      - name: Run Maestro tests
        run: |
          maestro test e2e/ --format junit --output maestro-results.xml
      
      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: maestro-results
          path: maestro-results.xml
```

---

## 6) Device Testing Matrix

### Test Coverage Strategy
```
┌─────────────────────────────────────────┐
│         DEVICE TESTING MATRIX           │
├─────────────────────────────────────────┤
│                                         │
│  iOS DEVICES (Min 3):                   │
│  ├── Latest iPhone (iPhone 15 Pro)     │
│  ├── Mid-range (iPhone 13)             │
│  └── Oldest supported (iPhone 11)      │
│                                         │
│  iOS VERSIONS:                          │
│  ├── Latest (iOS 17)                   │
│  ├── Previous (iOS 16)                 │
│  └── Minimum supported (iOS 15)        │
│                                         │
│  ANDROID DEVICES (Min 4):               │
│  ├── Latest flagship (Pixel 8 Pro)     │
│  ├── Mid-range (Samsung A54)           │
│  ├── Budget (Xiaomi Redmi Note)        │
│  └── Oldest supported (API 24+)        │
│                                         │
│  ANDROID VERSIONS:                      │
│  ├── Latest (Android 14)               │
│  ├── Common (Android 13, 12)           │
│  └── Minimum supported (Android 8)     │
│                                         │
│  SCREEN SIZES:                          │
│  ├── Small phone (5.5")                │
│  ├── Standard phone (6.1")             │
│  ├── Large phone (6.7")                │
│  └── Tablet (iPad, Galaxy Tab)         │
│                                         │
│  NETWORK CONDITIONS:                    │
│  ├── Fast WiFi                         │
│  ├── 4G/LTE                           │
│  ├── 3G/Slow                          │
│  └── Offline                           │
│                                         │
└─────────────────────────────────────────┘
```

### Network Condition Testing
```tsx
// ==========================================
// NETWORK CONDITION SIMULATION
// ==========================================

// Using react-native-network-info
import NetInfo from '@react-native-community/netinfo';

// Mock network conditions in tests
jest.mock('@react-native-community/netinfo', () => ({
  addEventListener: jest.fn(),
  fetch: jest.fn(),
}));

describe('Offline behavior', () => {
  beforeEach(() => {
    // Simulate offline
    (NetInfo.fetch as jest.Mock).mockResolvedValue({
      isConnected: false,
      type: 'none',
    });
  });

  it('shows offline message when disconnected', async () => {
    const { getByText } = render(<ProductList />);
    
    await waitFor(() => {
      expect(getByText('You are offline')).toBeTruthy();
    });
  });

  it('loads cached data when offline', async () => {
    const { getByText } = render(<ProductList />);
    
    await waitFor(() => {
      expect(getByText('Showing cached data')).toBeTruthy();
    });
  });
});


// ==========================================
// DETOX NETWORK SIMULATION
// ==========================================

// Simulate slow network in Detox
describe('Slow network behavior', () => {
  beforeAll(async () => {
    // iOS: Use Network Link Conditioner
    // Android: Use adb shell
    await device.setURLBlacklist(['.*fastimage.*']);
  });

  it('shows loading states on slow network', async () => {
    await device.launchApp();
    
    // Images should show placeholders
    await expect(element(by.id('image-placeholder'))).toBeVisible();
  });
});
```

---

## 7) Test Utilities

### Test Helpers
```tsx
// ==========================================
// REUSABLE TEST UTILITIES
// ==========================================

// test/utils/render.tsx
import { NavigationContainer } from '@react-navigation/native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, RenderOptions } from '@testing-library/react-native';

interface WrapperProps {
  children: React.ReactNode;
}

export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: 0,
      },
    },
  });
}

export function renderWithProviders(
  ui: React.ReactElement,
  options?: RenderOptions
) {
  const queryClient = createTestQueryClient();
  
  function Wrapper({ children }: WrapperProps) {
    return (
      <QueryClientProvider client={queryClient}>
        <NavigationContainer>
          {children}
        </NavigationContainer>
      </QueryClientProvider>
    );
  }
  
  return {
    ...render(ui, { wrapper: Wrapper, ...options }),
    queryClient,
  };
}


// ==========================================
// CUSTOM MATCHERS
// ==========================================

// test/setup.ts
expect.extend({
  toBeAccessible(received) {
    const { accessibilityLabel, accessibilityRole, accessibilityHint } = received.props;
    
    const hasLabel = !!accessibilityLabel;
    const hasRole = !!accessibilityRole;
    
    if (hasLabel && hasRole) {
      return {
        pass: true,
        message: () => 'Component is accessible',
      };
    }
    
    return {
      pass: false,
      message: () => 
        `Component is not accessible. Missing: ${!hasLabel ? 'accessibilityLabel' : ''} ${!hasRole ? 'accessibilityRole' : ''}`,
    };
  },
});


// ==========================================
// FACTORY FUNCTIONS
// ==========================================

// test/factories/user.ts
export function createMockUser(overrides: Partial<User> = {}): User {
  return {
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
    avatarUrl: 'https://example.com/avatar.jpg',
    createdAt: new Date().toISOString(),
    ...overrides,
  };
}

export function createMockProduct(overrides: Partial<Product> = {}): Product {
  return {
    id: 'product-1',
    name: 'Test Product',
    description: 'A test product description',
    price: 29.99,
    imageUrl: 'https://example.com/product.jpg',
    category: 'Electronics',
    inStock: true,
    ...overrides,
  };
}
```

---

## 8) Testing Checklist

### Pre-Release Testing
```
┌─────────────────────────────────────────┐
│         TESTING CHECKLIST               │
├─────────────────────────────────────────┤
│                                         │
│  UNIT TESTS:                            │
│  □ Coverage > 80%                       │
│  □ All critical paths tested           │
│  □ Edge cases covered                  │
│  □ No flaky tests                      │
│                                         │
│  INTEGRATION TESTS:                     │
│  □ API integration tested              │
│  □ Database operations tested          │
│  □ Navigation flows tested             │
│  □ State management tested             │
│                                         │
│  E2E TESTS:                             │
│  □ Critical user flows covered         │
│  □ Login/logout flow                   │
│  □ Main business flows                 │
│  □ Error scenarios                     │
│                                         │
│  DEVICE TESTING:                        │
│  □ iOS (3+ devices)                    │
│  □ Android (4+ devices)                │
│  □ Different screen sizes              │
│  □ Different OS versions               │
│                                         │
│  CONDITION TESTING:                     │
│  □ Offline mode                        │
│  □ Slow network                        │
│  □ Low battery                         │
│  □ Background/foreground              │
│  □ Interruptions (calls, notifications)│
│                                         │
│  ACCESSIBILITY TESTING:                 │
│  □ Screen reader compatible            │
│  □ Dynamic type supported              │
│  □ Color contrast sufficient           │
│  □ All elements labeled                │
│                                         │
│  PERFORMANCE TESTING:                   │
│  □ Startup time < 3s                   │
│  □ No frame drops                      │
│  □ Memory usage stable                 │
│  □ Battery impact acceptable           │
│                                         │
└─────────────────────────────────────────┘
```

---

## Best Practices Summary

### Strategy
- [ ] Follow test pyramid
- [ ] Automate regression
- [ ] Test on real devices
- [ ] CI/CD integration

### Unit Tests
- [ ] 80%+ coverage
- [ ] Mock dependencies
- [ ] Fast execution
- [ ] Isolated tests

### E2E Tests
- [ ] Critical flows only
- [ ] Handle flakiness
- [ ] Run in CI
- [ ] Parallel execution

### Device Matrix
- [ ] Multiple iOS devices
- [ ] Multiple Android devices
- [ ] Various screen sizes
- [ ] Network conditions

---

**References:**
- [React Native Testing Library](https://callstack.github.io/react-native-testing-library/)
- [Detox Documentation](https://wix.github.io/Detox/)
- [Maestro Documentation](https://maestro.mobile.dev/)
- [Jest Documentation](https://jestjs.io/)
