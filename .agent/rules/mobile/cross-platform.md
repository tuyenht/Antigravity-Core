# Cross-Platform Development Strategies Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Goal:** Share code without sacrificing native experience  
> **Priority:** P0 - Load for architecture decisions

---

You are an expert in Cross-Platform Mobile Development strategies.

## Core Principles

- Share code, not user experience
- Choose the right tool for the job
- Balance development speed vs native performance
- Maintain native feel on each platform

---

## 1) Technology Decision Matrix

### Framework Comparison
```
┌───────────────────────────────────────────────────────────────────┐
│              CROSS-PLATFORM FRAMEWORK COMPARISON                  │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  REACT NATIVE                                                     │
│  ├── Language: JavaScript/TypeScript                             │
│  ├── UI: Native components                                       │
│  ├── Performance: ★★★★☆ (Near-native)                          │
│  ├── Code Share: 85-95%                                          │
│  ├── Learning Curve: ★★★☆☆ (React knowledge helps)             │
│  ├── Hot Reload: ✅ Excellent                                    │
│  ├── OTA Updates: ✅ CodePush                                    │
│  ├── Bundle Size: ~15-25MB                                       │
│  └── Best For: React teams, fast iteration                       │
│                                                                   │
│  FLUTTER                                                          │
│  ├── Language: Dart                                              │
│  ├── UI: Custom rendering (Skia)                                 │
│  ├── Performance: ★★★★★ (60-120fps)                            │
│  ├── Code Share: 90-99%                                          │
│  ├── Learning Curve: ★★★★☆ (New language)                      │
│  ├── Hot Reload: ✅ Excellent                                    │
│  ├── OTA Updates: ❌ Not supported                               │
│  ├── Bundle Size: ~5-10MB                                        │
│  └── Best For: Complex UI, animations, consistency               │
│                                                                   │
│  KOTLIN MULTIPLATFORM (KMP)                                       │
│  ├── Language: Kotlin                                            │
│  ├── UI: Native (SwiftUI/Compose) or Compose Multiplatform      │
│  ├── Performance: ★★★★★ (Native)                               │
│  ├── Code Share: 50-70% (business logic only)                   │
│  ├── Learning Curve: ★★★★☆ (Native + Kotlin)                   │
│  ├── Hot Reload: Partial (Compose)                              │
│  ├── OTA Updates: ❌                                             │
│  ├── Bundle Size: Minimal addition                               │
│  └── Best For: Native-first, shared business logic              │
│                                                                   │
│  IONIC/CAPACITOR                                                  │
│  ├── Language: HTML/CSS/JavaScript                               │
│  ├── UI: WebView-based                                           │
│  ├── Performance: ★★★☆☆ (Web performance)                      │
│  ├── Code Share: 95-100%                                         │
│  ├── Learning Curve: ★★☆☆☆ (Web developers)                    │
│  ├── Hot Reload: ✅                                              │
│  ├── OTA Updates: ✅                                             │
│  ├── Bundle Size: ~10-20MB                                       │
│  └── Best For: Web apps, simple apps, PWA                       │
│                                                                   │
└────────────────────────────────────────────────────────────────┘
```

### Decision Framework
```
┌─────────────────────────────────────────┐
│       TECHNOLOGY DECISION TREE          │
├─────────────────────────────────────────┤
│                                         │
│  START                                  │
│    │                                    │
│    ├─► Need 100% native performance?    │
│    │     YES → Native (Swift/Kotlin)    │
│    │     NO  ↓                         │
│    │                                    │
│    ├─► Need native UI on each platform?│
│    │     YES → KMP + Native UI         │
│    │     NO  ↓                         │
│    │                                    │
│    ├─► Complex animations/graphics?     │
│    │     YES → Flutter                 │
│    │     NO  ↓                         │
│    │                                    │
│    ├─► Existing React/JS team?          │
│    │     YES → React Native            │
│    │     NO  ↓                         │
│    │                                    │
│    ├─► Existing web app to convert?     │
│    │     YES → Ionic/Capacitor         │
│    │     NO  ↓                         │
│    │                                    │
│    └─► Default: React Native or Flutter│
│                                         │
└──────────────────────────────────────┘
```

### Use Case Recommendations
```
┌─────────────────────────────────────────┐
│        USE CASE RECOMMENDATIONS         │
├─────────────────────────────────────────┤
│                                         │
│  E-COMMERCE APP:                        │
│  └── React Native or Flutter           │
│      (Fast iteration, complex UI)      │
│                                         │
│  BANKING/FINTECH:                       │
│  └── KMP + Native UI or Flutter        │
│      (Security, native feel)           │
│                                         │
│  SOCIAL MEDIA:                          │
│  └── React Native                      │
│      (Fast updates, feed UI)           │
│                                         │
│  GAMING (2D):                           │
│  └── Flutter + Flame                   │
│      (Consistent rendering)            │
│                                         │
│  ENTERPRISE/B2B:                        │
│  └── React Native or Ionic            │
│      (Fast development, web overlap)   │
│                                         │
│  CONTENT/MEDIA:                         │
│  └── React Native                      │
│      (OTA updates, content changes)    │
│                                         │
│  IoT/HARDWARE INTEGRATION:              │
│  └── KMP or Native                     │
│      (Deep hardware access)            │
│                                         │
└──────────────────────────────────────┘
```

---

## 2) Code Sharing Strategies

### Layered Architecture
```
┌─────────────────────────────────────────┐
│         SHARED CODE LAYERS              │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  PLATFORM-SPECIFIC UI            │ │  ← 10-20%
│  │  (iOS/Android specific styling)  │ │
│  └────────────────────────────────┘ │
│                    ▲                    │
│  ┌───────────────────────────────────┐ │
│  │  SHARED UI COMPONENTS            │ │  ← 20-30%
│  │  (Design System, Common layouts) │ │
│  └────────────────────────────────┘ │
│                    ▲                    │
│  ┌───────────────────────────────────┐ │
│  │  SHARED STATE MANAGEMENT         │ │  ← 100% shared
│  │  (Stores, ViewModels)            │ │
│  └────────────────────────────────┘ │
│                    ▲                    │
│  ┌───────────────────────────────────┐ │
│  │  SHARED BUSINESS LOGIC           │ │  ← 100% shared
│  │  (Use Cases, Domain, Validation) │ │
│  └────────────────────────────────┘ │
│                    ▲                    │
│  ┌───────────────────────────────────┐ │
│  │  SHARED DATA LAYER               │ │  ← 100% shared
│  │  (API, Models, Repositories)     │ │
│  └────────────────────────────────┘ │
│                                         │
└──────────────────────────────────────┘
```

### Platform Abstraction (React Native)
```tsx
// ==========================================
// PLATFORM ABSTRACTION PATTERN
// ==========================================

// ==========================================
// 1. PLATFORM-SPECIFIC FILES
// ==========================================

// components/Button/Button.ios.tsx
import { TouchableOpacity, Text, StyleSheet } from 'react-native';
import * as Haptics from 'expo-haptics';

export function Button({ title, onPress, variant = 'primary' }: ButtonProps) {
  const handlePress = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    onPress?.();
  };

  return (
    <TouchableOpacity
      style={[styles.button, styles[variant]]}
      onPress={handlePress}
      activeOpacity={0.7}
    >
      <Text style={styles.text}>{title}</Text>
    </TouchableOpacity>
  );
}

// components/Button/Button.android.tsx
import { TouchableNativeFeedback, View, Text, StyleSheet } from 'react-native';

export function Button({ title, onPress, variant = 'primary' }: ButtonProps) {
  return (
    <TouchableNativeFeedback
      onPress={onPress}
      background={TouchableNativeFeedback.Ripple('#ffffff40', false)}
    >
      <View style={[styles.button, styles[variant]]}>
        <Text style={styles.text}>{title}</Text>
      </View>
    </TouchableNativeFeedback>
  );
}

// components/Button/index.ts - Auto-resolves based on platform
export { Button } from './Button';


// ==========================================
// 2. PLATFORM SERVICE ABSTRACTION
// ==========================================

// services/biometrics/types.ts
export interface BiometricsService {
  isAvailable(): Promise<boolean>;
  authenticate(reason: string): Promise<boolean>;
  getBiometryType(): Promise<'fingerprint' | 'face' | 'none'>;
}

// services/biometrics/biometrics.ios.ts
import * as LocalAuthentication from 'expo-local-authentication';

export const biometricsService: BiometricsService = {
  async isAvailable() {
    const types = await LocalAuthentication.supportedAuthenticationTypesAsync();
    return types.length > 0;
  },
  
  async authenticate(reason: string) {
    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: reason,
      fallbackLabel: 'Use Passcode',
      cancelLabel: 'Cancel',
    });
    return result.success;
  },
  
  async getBiometryType() {
    const types = await LocalAuthentication.supportedAuthenticationTypesAsync();
    if (types.includes(LocalAuthentication.AuthenticationType.FACIAL_RECOGNITION)) {
      return 'face';
    }
    if (types.includes(LocalAuthentication.AuthenticationType.FINGERPRINT)) {
      return 'fingerprint';
    }
    return 'none';
  },
};

// services/biometrics/biometrics.android.ts
import ReactNativeBiometrics from 'react-native-biometrics';

const rnBiometrics = new ReactNativeBiometrics();

export const biometricsService: BiometricsService = {
  async isAvailable() {
    const { available } = await rnBiometrics.isSensorAvailable();
    return available;
  },
  
  async authenticate(reason: string) {
    const { success } = await rnBiometrics.simplePrompt({
      promptMessage: reason,
      cancelButtonText: 'Cancel',
    });
    return success;
  },
  
  async getBiometryType() {
    const { biometryType } = await rnBiometrics.isSensorAvailable();
    if (biometryType === 'FaceID') return 'face';
    if (biometryType === 'Biometrics' || biometryType === 'TouchID') return 'fingerprint';
    return 'none';
  },
};


// ==========================================
// 3. PLATFORM-AWARE HOOKS
// ==========================================

// hooks/usePlatform.ts
import { Platform, PlatformIOSStatic, PlatformAndroidStatic } from 'react-native';

interface PlatformInfo {
  isIOS: boolean;
  isAndroid: boolean;
  version: string | number;
  isPad: boolean;
  isTV: boolean;
}

export function usePlatform(): PlatformInfo {
  return {
    isIOS: Platform.OS === 'ios',
    isAndroid: Platform.OS === 'android',
    version: Platform.Version,
    isPad: Platform.OS === 'ios' && (Platform as PlatformIOSStatic).isPad,
    isTV: Platform.isTV,
  };
}

// Usage
function MyComponent() {
  const { isIOS, isPad } = usePlatform();
  
  return (
    <View style={[styles.container, isPad && styles.padContainer]}>
      {isIOS ? <IOSHeader /> : <AndroidHeader />}
    </View>
  );
}


// ==========================================
// 4. PLATFORM-SPECIFIC STYLING
// ==========================================

// theme/platformStyles.ts
import { Platform, StyleSheet } from 'react-native';

export const platformStyles = StyleSheet.create({
  shadow: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 4,
    },
    android: {
      elevation: 4,
    },
  }),
  
  safeArea: Platform.select({
    ios: {
      paddingTop: 44,  // Notch
      paddingBottom: 34,  // Home indicator
    },
    android: {
      paddingTop: 0,  // Handled by StatusBar
      paddingBottom: 0,
    },
  }),
});

// Platform-specific font weights
export const fontWeights = Platform.select({
  ios: {
    regular: '400' as const,
    medium: '500' as const,
    semibold: '600' as const,
    bold: '700' as const,
  },
  android: {
    regular: 'normal' as const,
    medium: '500' as const,
    semibold: '600' as const,
    bold: 'bold' as const,
  },
});
```

---

## 3) Monorepo Architecture

### Nx Monorepo Setup
```
# ==========================================
# NX MONOREPO STRUCTURE
# ==========================================

my-mobile-monorepo/
├── apps/
│   ├── mobile/                    # React Native app
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── App.tsx
│   │   │   │   └── navigation/
│   │   │   ├── screens/
│   │   │   └── components/
│   │   ├── ios/
│   │   ├── android/
│   │   └── project.json
│   │
│   └── web/                       # Next.js web app
│       ├── src/
│       │   ├── app/
│       │   ├── pages/
│       │   └── components/
│       └── project.json
│
├── packages/
│   ├── core/                      # Shared business logic
│   │   ├── src/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── use-cases/
│   │   │   ├── data/
│   │   │   │   ├── api/
│   │   │   │   ├── repositories/
│   │   │   │   └── models/
│   │   │   └── index.ts
│   │   └── project.json
│   │
│   ├── ui/                        # Shared UI components
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   └── theme/
│   │   └── project.json
│   │
│   ├── state/                     # Shared state management
│   │   ├── src/
│   │   │   ├── stores/
│   │   │   └── hooks/
│   │   └── project.json
│   │
│   └── utils/                     # Shared utilities
│       ├── src/
│       │   ├── validation/
│       │   ├── formatting/
│       │   └── helpers/
│       └── project.json
│
├── tools/
│   └── scripts/
│
├── nx.json
├── package.json
└── tsconfig.base.json
```

### Nx Configuration
```json
// nx.json
{
  "$schema": "./node_modules/nx/schemas/nx-schema.json",
  "namedInputs": {
    "default": ["{projectRoot}/**/*", "sharedGlobals"],
    "sharedGlobals": []
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "inputs": ["default", "^default"],
      "cache": true
    },
    "test": {
      "inputs": ["default", "^default"],
      "cache": true
    }
  },
  "defaultBase": "main"
}


// packages/core/project.json
{
  "name": "@myapp/core",
  "$schema": "../../node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "packages/core/src",
  "projectType": "library",
  "tags": ["scope:shared", "type:core"],
  "targets": {
    "build": {
      "executor": "@nx/js:tsc",
      "outputs": ["{options.outputPath}"],
      "options": {
        "outputPath": "dist/packages/core",
        "main": "packages/core/src/index.ts",
        "tsConfig": "packages/core/tsconfig.lib.json"
      }
    },
    "test": {
      "executor": "@nx/jest:jest",
      "outputs": ["{workspaceRoot}/coverage/{projectRoot}"],
      "options": {
        "jestConfig": "packages/core/jest.config.ts"
      }
    }
  }
}
```

### Shared Package Examples
```tsx
// ==========================================
// SHARED CORE PACKAGE
// ==========================================

// packages/core/src/domain/entities/User.ts
export interface User {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
  createdAt: Date;
}

// packages/core/src/domain/use-cases/auth/loginUseCase.ts
import { authRepository } from '../../data/repositories/authRepository';
import { validateEmail, validatePassword } from '../../validation';

export interface LoginResult {
  success: boolean;
  user?: User;
  error?: string;
}

export async function loginUseCase(
  email: string,
  password: string
): Promise<LoginResult> {
  // Validation
  if (!validateEmail(email)) {
    return { success: false, error: 'Invalid email format' };
  }
  
  if (!validatePassword(password)) {
    return { success: false, error: 'Password must be at least 8 characters' };
  }
  
  try {
    const user = await authRepository.login(email, password);
    return { success: true, user };
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Login failed' 
    };
  }
}


// packages/core/src/data/api/apiClient.ts
interface ApiConfig {
  baseURL: string;
  timeout: number;
  headers: Record<string, string>;
}

class ApiClient {
  private config: ApiConfig;
  private tokenProvider?: () => Promise<string | null>;
  
  constructor(config: ApiConfig) {
    this.config = config;
  }
  
  setTokenProvider(provider: () => Promise<string | null>) {
    this.tokenProvider = provider;
  }
  
  async request<T>(
    method: string,
    endpoint: string,
    data?: unknown
  ): Promise<T> {
    const headers: Record<string, string> = {
      ...this.config.headers,
    };
    
    if (this.tokenProvider) {
      const token = await this.tokenProvider();
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
    }
    
    const response = await fetch(`${this.config.baseURL}${endpoint}`, {
      method,
      headers,
      body: data ? JSON.stringify(data) : undefined,
    });
    
    if (!response.ok) {
      throw new Error(`API Error: ${response.status}`);
    }
    
    return response.json();
  }
  
  get<T>(endpoint: string) {
    return this.request<T>('GET', endpoint);
  }
  
  post<T>(endpoint: string, data: unknown) {
    return this.request<T>('POST', endpoint, data);
  }
}

export const apiClient = new ApiClient({
  baseURL: process.env.API_BASE_URL || 'https://api.example.com',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});


// packages/core/src/index.ts
// Domain
export * from './domain/entities/User';
export * from './domain/use-cases/auth/loginUseCase';

// Data
export { apiClient } from './data/api/apiClient';

// Validation
export * from './validation';


// ==========================================
// SHARED STATE PACKAGE
// ==========================================

// packages/state/src/stores/authStore.ts
import { create } from 'zustand';
import { User, loginUseCase } from '@myapp/core';

interface AuthState {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  clearError: () => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isLoading: false,
  isAuthenticated: false,
  error: null,
  
  login: async (email, password) => {
    set({ isLoading: true, error: null });
    
    const result = await loginUseCase(email, password);
    
    if (result.success && result.user) {
      set({ 
        user: result.user, 
        isAuthenticated: true, 
        isLoading: false 
      });
      return true;
    }
    
    set({ 
      error: result.error || 'Login failed', 
      isLoading: false 
    });
    return false;
  },
  
  logout: () => {
    set({ 
      user: null, 
      isAuthenticated: false, 
      error: null 
    });
  },
  
  clearError: () => set({ error: null }),
}));
```

---

## 4) Navigation Patterns

### Platform-Adaptive Navigation
```tsx
// ==========================================
// ADAPTIVE NAVIGATION
// ==========================================

import { Platform } from 'react-native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createDrawerNavigator } from '@react-navigation/drawer';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();
const Drawer = createDrawerNavigator();

// Platform-specific tab bar options
const tabBarOptions = Platform.select({
  ios: {
    tabBarStyle: {
      backgroundColor: '#ffffff',
      borderTopWidth: 0.5,
      borderTopColor: '#e0e0e0',
    },
    tabBarActiveTintColor: '#007AFF',
    tabBarInactiveTintColor: '#8E8E93',
  },
  android: {
    tabBarStyle: {
      backgroundColor: '#ffffff',
      elevation: 8,
    },
    tabBarActiveTintColor: '#6200EE',
    tabBarInactiveTintColor: '#757575',
    tabBarIndicatorStyle: {
      backgroundColor: '#6200EE',
    },
  },
});

// Platform-specific header options
const headerOptions = Platform.select({
  ios: {
    headerLargeTitle: true,
    headerLargeTitleStyle: {
      fontWeight: '700',
    },
    headerBackTitleVisible: false,
  },
  android: {
    headerTitleAlign: 'left' as const,
    headerStyle: {
      elevation: 4,
    },
  },
});

// Tab Navigator
function MainTabs() {
  return (
    <Tab.Navigator screenOptions={tabBarOptions}>
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          ...headerOptions,
          tabBarIcon: ({ color, size }) => (
            <Icon name="home" size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen
        name="Search"
        component={SearchScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Icon name="search" size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Icon name="person" size={size} color={color} />
          ),
        }}
      />
    </Tab.Navigator>
  );
}

// Platform-specific main navigator
function RootNavigator() {
  const isTablet = useIsTablet();
  
  // Use drawer on tablets, tabs on phones
  if (isTablet) {
    return (
      <Drawer.Navigator>
        <Drawer.Screen name="Home" component={HomeScreen} />
        <Drawer.Screen name="Search" component={SearchScreen} />
        <Drawer.Screen name="Profile" component={ProfileScreen} />
      </Drawer.Navigator>
    );
  }
  
  return (
    <Stack.Navigator screenOptions={headerOptions}>
      <Stack.Screen
        name="Main"
        component={MainTabs}
        options={{ headerShown: false }}
      />
      <Stack.Screen name="ProductDetail" component={ProductDetailScreen} />
      <Stack.Screen name="Settings" component={SettingsScreen} />
    </Stack.Navigator>
  );
}
```

---

## 5) UI Paradigm Handling

### Material vs Cupertino
```tsx
// ==========================================
// PLATFORM-ADAPTIVE COMPONENTS
// ==========================================

import { Platform } from 'react-native';

// Adaptive Alert
export function showAlert(
  title: string,
  message: string,
  buttons: Array<{ text: string; onPress?: () => void; style?: 'default' | 'cancel' | 'destructive' }>
) {
  if (Platform.OS === 'ios') {
    Alert.alert(title, message, buttons);
  } else {
    // Android: Use custom dialog for better styling
    showAndroidDialog(title, message, buttons);
  }
}


// Adaptive Action Sheet
import ActionSheet from 'react-native-action-sheet';

export function showActionSheet(
  options: string[],
  cancelButtonIndex: number,
  destructiveButtonIndex: number,
  onSelect: (index: number) => void
) {
  if (Platform.OS === 'ios') {
    ActionSheet.showActionSheetWithOptions(
      {
        options,
        cancelButtonIndex,
        destructiveButtonIndex,
      },
      onSelect
    );
  } else {
    // Android: Use bottom sheet
    showBottomSheet(options, onSelect);
  }
}


// Adaptive Date Picker
import DateTimePicker from '@react-native-community/datetimepicker';

function AdaptiveDatePicker({
  value,
  onChange,
  mode = 'date',
}: {
  value: Date;
  onChange: (date: Date) => void;
  mode?: 'date' | 'time' | 'datetime';
}) {
  const [show, setShow] = useState(false);
  
  const handleChange = (event: any, selectedDate?: Date) => {
    if (Platform.OS === 'android') {
      setShow(false);
    }
    if (selectedDate) {
      onChange(selectedDate);
    }
  };
  
  if (Platform.OS === 'ios') {
    return (
      <DateTimePicker
        value={value}
        mode={mode}
        display="spinner"
        onChange={handleChange}
      />
    );
  }
  
  return (
    <>
      <TouchableOpacity onPress={() => setShow(true)}>
        <Text>{value.toLocaleDateString()}</Text>
      </TouchableOpacity>
      {show && (
        <DateTimePicker
          value={value}
          mode={mode}
          display="default"
          onChange={handleChange}
        />
      )}
    </>
  );
}


// Adaptive Icons
import { Platform } from 'react-native';
import MaterialIcons from 'react-native-vector-icons/MaterialIcons';
import SFSymbols from 'react-native-sfsymbols';

const iconMap = {
  home: {
    ios: 'house.fill',
    android: 'home',
  },
  search: {
    ios: 'magnifyingglass',
    android: 'search',
  },
  settings: {
    ios: 'gear',
    android: 'settings',
  },
  back: {
    ios: 'chevron.left',
    android: 'arrow-back',
  },
};

export function AdaptiveIcon({
  name,
  size = 24,
  color = '#000',
}: {
  name: keyof typeof iconMap;
  size?: number;
  color?: string;
}) {
  const iconName = iconMap[name][Platform.OS];
  
  if (Platform.OS === 'ios') {
    return <SFSymbols name={iconName} size={size} color={color} />;
  }
  
  return <MaterialIcons name={iconName} size={size} color={color} />;
}
```

---

## 6) Performance Optimization

### Platform-Specific Optimization
```tsx
// ==========================================
// PLATFORM-SPECIFIC PERFORMANCE
// ==========================================

// Hermes configuration (React Native)
// android/app/build.gradle
android {
    defaultConfig {
        // Enable Hermes for better performance
        hermes: true
    }
}

// iOS: Podfile
post_install do |installer|
  # Enable Hermes
  :hermes_enabled => true
end


// ==========================================
// NATIVE MODULE FOR HEAVY COMPUTATION
// ==========================================

// Create native module for intensive operations
// ios/ImageProcessor.swift
@objc(ImageProcessorModule)
class ImageProcessorModule: NSObject {
    
    @objc
    func processImage(_ uri: String, 
                      resolver: @escaping RCTPromiseResolveBlock,
                      rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Heavy image processing on background thread
            guard let image = self.loadImage(from: uri) else {
                rejecter("ERROR", "Failed to load image", nil)
                return
            }
            
            let processed = self.applyFilters(to: image)
            let resultUri = self.saveImage(processed)
            
            DispatchQueue.main.async {
                resolver(resultUri)
            }
        }
    }
}

// android/ImageProcessorModule.kt
class ImageProcessorModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {
    
    override fun getName() = "ImageProcessorModule"
    
    @ReactMethod
    fun processImage(uri: String, promise: Promise) {
        GlobalScope.launch(Dispatchers.Default) {
            try {
                val bitmap = loadBitmap(uri)
                val processed = applyFilters(bitmap)
                val resultUri = saveBitmap(processed)
                
                withContext(Dispatchers.Main) {
                    promise.resolve(resultUri)
                }
            } catch (e: Exception) {
                promise.reject("ERROR", e.message)
            }
        }
    }
}


// Usage in JS
import { NativeModules } from 'react-native';

const { ImageProcessorModule } = NativeModules;

async function processImage(uri: string): Promise<string> {
  return ImageProcessorModule.processImage(uri);
}
```

---

## 7) Testing Cross-Platform

### Shared Test Strategy
```tsx
// ==========================================
// CROSS-PLATFORM TESTING
// ==========================================

// Shared test utilities
// packages/testing/src/testUtils.ts
export function createMockUser(overrides: Partial<User> = {}): User {
  return {
    id: 'test-user-1',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: new Date(),
    ...overrides,
  };
}

export function createMockProduct(overrides: Partial<Product> = {}): Product {
  return {
    id: 'test-product-1',
    name: 'Test Product',
    price: 29.99,
    ...overrides,
  };
}


// ==========================================
// PLATFORM-SPECIFIC MOCKS
// ==========================================

// __mocks__/platformMocks.ts
import { Platform } from 'react-native';

export function mockPlatform(os: 'ios' | 'android') {
  Platform.OS = os;
  Platform.select = (options: any) => options[os] || options.default;
}

// Usage in tests
describe('Button', () => {
  beforeEach(() => {
    jest.resetModules();
  });
  
  describe('iOS', () => {
    beforeAll(() => mockPlatform('ios'));
    
    it('renders iOS style button', () => {
      const { getByTestId } = render(<Button title="Test" />);
      expect(getByTestId('ios-button')).toBeTruthy();
    });
  });
  
  describe('Android', () => {
    beforeAll(() => mockPlatform('android'));
    
    it('renders Android style button', () => {
      const { getByTestId } = render(<Button title="Test" />);
      expect(getByTestId('android-button')).toBeTruthy();
    });
  });
});
```

---

## 8) Best Practices Checklist

```
┌─────────────────────────────────────────┐
│   CROSS-PLATFORM BEST PRACTICES        │
├─────────────────────────────────────────┤
│                                         │
│  CODE SHARING:                          │
│  □ Business logic 100% shared          │
│  □ State management shared             │
│  □ API layer shared                    │
│  □ Validation shared                   │
│  □ Platform-specific UI when needed    │
│                                         │
│  ARCHITECTURE:                          │
│  □ Clean Architecture layers           │
│  □ Dependency injection                │
│  □ Interface-based abstractions        │
│  □ Monorepo for code sharing           │
│                                         │
│  PERFORMANCE:                           │
│  □ Native modules for heavy ops        │
│  □ Platform-specific optimizations     │
│  □ Monitor binary size                 │
│  □ Profile on real devices             │
│                                         │
│  UX:                                    │
│  □ Platform-specific navigation        │
│  □ Native feel on each platform        │
│  □ Platform icons/styling              │
│  □ Respect platform conventions        │
│                                         │
│  TESTING:                               │
│  □ Shared unit tests                   │
│  □ Platform-specific E2E tests         │
│  □ Test on both platforms              │
│  □ CI/CD for both platforms            │
│                                         │
│  MAINTENANCE:                           │
│  □ Keep native dependencies updated    │
│  □ Monitor framework updates           │
│  □ Plan for native fallbacks           │
│  □ Document platform differences       │
│                                         │
└──────────────────────────────────────┘
```

---

## Best Practices Summary

### Strategy
- [ ] Choose right framework
- [ ] Maximize code sharing
- [ ] Abstract platform differences
- [ ] Native feel on each platform

### Architecture
- [ ] Clean Architecture
- [ ] Monorepo structure
- [ ] Shared packages
- [ ] Platform abstraction

### Performance
- [ ] Use native modules
- [ ] Profile both platforms
- [ ] Monitor bundle size
- [ ] Test on real devices

### UX
- [ ] Platform-specific navigation
- [ ] Adaptive components
- [ ] Platform icons
- [ ] Respect conventions

---

**References:**
- [React Native Architecture](https://reactnative.dev/architecture/overview)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf)
- [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform.html)
- [Nx Monorepo](https://nx.dev/)
