# Expo TypeScript Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Expo SDK:** 51+  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for Expo projects

---

You are an expert in Expo development with TypeScript.

## Core Principles

- Use Expo SDK with full TypeScript support
- Type Expo modules and APIs correctly
- Leverage Expo Router with TypeScript
- Use EAS Build and Update with proper types

---

## 1) Project Setup

### Create New Project
```bash
# Create Expo project with TypeScript
npx create-expo-app@latest my-app --template blank-typescript

# Or with Expo Router
npx create-expo-app@latest my-app --template tabs
```

### TypeScript Configuration
```json
// ==========================================
// tsconfig.json
// ==========================================

{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "paths": {
      "@/*": ["./*"],
      "@components/*": ["./components/*"],
      "@hooks/*": ["./hooks/*"],
      "@utils/*": ["./utils/*"],
      "@services/*": ["./services/*"],
      "@constants/*": ["./constants/*"],
      "@assets/*": ["./assets/*"]
    }
  },
  "include": [
    "**/*.ts",
    "**/*.tsx",
    ".expo/types/**/*.ts",
    "expo-env.d.ts"
  ]
}
```

### App Configuration with Types
```typescript
// ==========================================
// app.config.ts
// ==========================================

import { ExpoConfig, ConfigContext } from 'expo/config';

const defineConfig = ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'My App',
  slug: 'my-app',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  userInterfaceStyle: 'automatic',
  splash: {
    image: './assets/splash.png',
    resizeMode: 'contain',
    backgroundColor: '#ffffff',
  },
  assetBundlePatterns: ['**/*'],
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'com.company.myapp',
    infoPlist: {
      NSCameraUsageDescription: 'This app uses the camera for...',
      NSPhotoLibraryUsageDescription: 'This app accesses photos for...',
    },
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#ffffff',
    },
    package: 'com.company.myapp',
    permissions: [
      'android.permission.CAMERA',
      'android.permission.READ_EXTERNAL_STORAGE',
    ],
  },
  web: {
    favicon: './assets/favicon.png',
    bundler: 'metro',
  },
  plugins: [
    'expo-router',
    [
      'expo-camera',
      {
        cameraPermission: 'Allow $(PRODUCT_NAME) to access your camera.',
      },
    ],
    [
      'expo-location',
      {
        locationAlwaysAndWhenInUsePermission: 'Allow $(PRODUCT_NAME) to use your location.',
      },
    ],
  ],
  experiments: {
    typedRoutes: true,
  },
  extra: {
    apiUrl: process.env.EXPO_PUBLIC_API_URL,
    eas: {
      projectId: 'your-project-id',
    },
  },
});

export default defineConfig;
```

### Environment Variables
```typescript
// ==========================================
// env.d.ts
// ==========================================

declare global {
  namespace NodeJS {
    interface ProcessEnv {
      EXPO_PUBLIC_API_URL: string;
      EXPO_PUBLIC_SUPABASE_URL: string;
      EXPO_PUBLIC_SUPABASE_ANON_KEY: string;
    }
  }
}

export {};


// ==========================================
// constants/env.ts
// ==========================================

import { z } from 'zod';

const envSchema = z.object({
  EXPO_PUBLIC_API_URL: z.string().url(),
  EXPO_PUBLIC_SUPABASE_URL: z.string().url(),
  EXPO_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
});

export const env = envSchema.parse({
  EXPO_PUBLIC_API_URL: process.env.EXPO_PUBLIC_API_URL,
  EXPO_PUBLIC_SUPABASE_URL: process.env.EXPO_PUBLIC_SUPABASE_URL,
  EXPO_PUBLIC_SUPABASE_ANON_KEY: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY,
});
```

---

## 2) Expo Router (File-based Routing)

### Typed Routes
```typescript
// ==========================================
// app/_layout.tsx
// ==========================================

import { Stack } from 'expo-router';
import { useColorScheme } from 'react-native';
import { ThemeProvider, DarkTheme, DefaultTheme } from '@react-navigation/native';

export default function RootLayout() {
  const colorScheme = useColorScheme();
  
  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="(auth)" options={{ headerShown: false }} />
        <Stack.Screen 
          name="modal" 
          options={{ 
            presentation: 'modal',
            headerTitle: 'Modal',
          }} 
        />
        <Stack.Screen 
          name="product/[id]" 
          options={{ 
            headerTitle: 'Product Details',
          }} 
        />
      </Stack>
    </ThemeProvider>
  );
}


// ==========================================
// app/(tabs)/_layout.tsx
// ==========================================

import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { ComponentProps } from 'react';

type IconName = ComponentProps<typeof Ionicons>['name'];

interface TabConfig {
  name: string;
  title: string;
  icon: IconName;
  iconFocused: IconName;
}

const tabs: TabConfig[] = [
  { name: 'index', title: 'Home', icon: 'home-outline', iconFocused: 'home' },
  { name: 'search', title: 'Search', icon: 'search-outline', iconFocused: 'search' },
  { name: 'cart', title: 'Cart', icon: 'cart-outline', iconFocused: 'cart' },
  { name: 'profile', title: 'Profile', icon: 'person-outline', iconFocused: 'person' },
];

export default function TabLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#007AFF' }}>
      {tabs.map((tab) => (
        <Tabs.Screen
          key={tab.name}
          name={tab.name}
          options={{
            title: tab.title,
            tabBarIcon: ({ color, focused }) => (
              <Ionicons 
                name={focused ? tab.iconFocused : tab.icon} 
                size={24} 
                color={color} 
              />
            ),
          }}
        />
      ))}
    </Tabs>
  );
}


// ==========================================
// TYPED ROUTE PARAMETERS
// ==========================================

// app/product/[id].tsx
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import { View, Text, Button } from 'react-native';

// Define param types
interface ProductParams {
  id: string;
  title?: string;
}

export default function ProductScreen() {
  // Typed params
  const { id, title } = useLocalSearchParams<ProductParams>();
  const router = useRouter();
  
  return (
    <View>
      <Stack.Screen 
        options={{ 
          headerTitle: title ?? 'Product',
        }} 
      />
      <Text>Product ID: {id}</Text>
      <Button 
        title="Go Back" 
        onPress={() => router.back()} 
      />
    </View>
  );
}


// ==========================================
// TYPED NAVIGATION WITH LINK
// ==========================================

import { Link, Href } from 'expo-router';
import { Pressable, Text } from 'react-native';

// Type-safe navigation
function NavigationExample() {
  return (
    <View>
      {/* Type-safe links */}
      <Link href="/" asChild>
        <Pressable>
          <Text>Home</Text>
        </Pressable>
      </Link>
      
      <Link 
        href={{
          pathname: '/product/[id]',
          params: { id: '123', title: 'iPhone' },
        }} 
        asChild
      >
        <Pressable>
          <Text>View Product</Text>
        </Pressable>
      </Link>
      
      {/* With typed routes enabled */}
      <Link href="/search" asChild>
        <Pressable>
          <Text>Search</Text>
        </Pressable>
      </Link>
    </View>
  );
}


// ==========================================
// NAVIGATION HOOK
// ==========================================

import { useRouter, useSegments, usePathname } from 'expo-router';

export function useAppNavigation() {
  const router = useRouter();
  const segments = useSegments();
  const pathname = usePathname();
  
  const navigateToProduct = (id: string, title?: string) => {
    router.push({
      pathname: '/product/[id]',
      params: { id, title },
    });
  };
  
  const navigateToCart = () => {
    router.push('/(tabs)/cart');
  };
  
  const goBack = () => {
    if (router.canGoBack()) {
      router.back();
    } else {
      router.replace('/');
    }
  };
  
  return {
    router,
    segments,
    pathname,
    navigateToProduct,
    navigateToCart,
    goBack,
  };
}
```

---

## 3) Expo Modules Typing

### Camera
```typescript
// ==========================================
// hooks/useCamera.ts
// ==========================================

import { useState, useRef } from 'react';
import { 
  CameraView, 
  CameraType, 
  useCameraPermissions,
  CameraCapturedPicture,
} from 'expo-camera';

interface UseCameraReturn {
  cameraRef: React.RefObject<CameraView>;
  facing: CameraType;
  permission: ReturnType<typeof useCameraPermissions>[0];
  requestPermission: ReturnType<typeof useCameraPermissions>[1];
  toggleFacing: () => void;
  takePicture: () => Promise<CameraCapturedPicture | undefined>;
}

export function useCamera(): UseCameraReturn {
  const cameraRef = useRef<CameraView>(null);
  const [facing, setFacing] = useState<CameraType>('back');
  const [permission, requestPermission] = useCameraPermissions();
  
  const toggleFacing = () => {
    setFacing(current => (current === 'back' ? 'front' : 'back'));
  };
  
  const takePicture = async (): Promise<CameraCapturedPicture | undefined> => {
    if (cameraRef.current) {
      return await cameraRef.current.takePictureAsync({
        quality: 0.8,
        base64: false,
        exif: true,
      });
    }
  };
  
  return {
    cameraRef,
    facing,
    permission,
    requestPermission,
    toggleFacing,
    takePicture,
  };
}


// ==========================================
// components/CameraScreen.tsx
// ==========================================

import { View, Button, StyleSheet } from 'react-native';
import { CameraView } from 'expo-camera';
import { useCamera } from '@hooks/useCamera';

export function CameraScreen() {
  const { 
    cameraRef, 
    facing, 
    permission, 
    requestPermission,
    toggleFacing,
    takePicture,
  } = useCamera();
  
  if (!permission) {
    return <View />;
  }
  
  if (!permission.granted) {
    return (
      <View style={styles.container}>
        <Button title="Grant Permission" onPress={requestPermission} />
      </View>
    );
  }
  
  const handleCapture = async () => {
    const photo = await takePicture();
    if (photo) {
      console.log('Photo URI:', photo.uri);
    }
  };
  
  return (
    <View style={styles.container}>
      <CameraView 
        ref={cameraRef}
        style={styles.camera} 
        facing={facing}
      >
        <View style={styles.buttonContainer}>
          <Button title="Flip" onPress={toggleFacing} />
          <Button title="Capture" onPress={handleCapture} />
        </View>
      </CameraView>
    </View>
  );
}
```

### Location
```typescript
// ==========================================
// hooks/useLocation.ts
// ==========================================

import { useState, useEffect } from 'react';
import * as Location from 'expo-location';

interface LocationState {
  location: Location.LocationObject | null;
  address: Location.LocationGeocodedAddress | null;
  error: string | null;
  isLoading: boolean;
}

interface UseLocationReturn extends LocationState {
  requestPermission: () => Promise<boolean>;
  getCurrentLocation: () => Promise<void>;
  watchLocation: () => Location.LocationSubscription | undefined;
}

export function useLocation(): UseLocationReturn {
  const [state, setState] = useState<LocationState>({
    location: null,
    address: null,
    error: null,
    isLoading: false,
  });
  
  const requestPermission = async (): Promise<boolean> => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    return status === 'granted';
  };
  
  const getCurrentLocation = async () => {
    setState(prev => ({ ...prev, isLoading: true, error: null }));
    
    try {
      const hasPermission = await requestPermission();
      if (!hasPermission) {
        throw new Error('Location permission denied');
      }
      
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });
      
      const [address] = await Location.reverseGeocodeAsync({
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
      });
      
      setState({
        location,
        address: address ?? null,
        error: null,
        isLoading: false,
      });
    } catch (error) {
      setState(prev => ({
        ...prev,
        error: error instanceof Error ? error.message : 'Unknown error',
        isLoading: false,
      }));
    }
  };
  
  const watchLocation = () => {
    return Location.watchPositionAsync(
      {
        accuracy: Location.Accuracy.High,
        distanceInterval: 10,
      },
      (location) => {
        setState(prev => ({ ...prev, location }));
      }
    );
  };
  
  return {
    ...state,
    requestPermission,
    getCurrentLocation,
    watchLocation,
  };
}
```

### Image Picker
```typescript
// ==========================================
// hooks/useImagePicker.ts
// ==========================================

import * as ImagePicker from 'expo-image-picker';

interface UseImagePickerOptions {
  allowsEditing?: boolean;
  aspect?: [number, number];
  quality?: number;
}

interface UseImagePickerReturn {
  pickImage: () => Promise<string | null>;
  takePhoto: () => Promise<string | null>;
  pickMultiple: () => Promise<string[]>;
}

export function useImagePicker(
  options: UseImagePickerOptions = {}
): UseImagePickerReturn {
  const { 
    allowsEditing = true, 
    aspect = [1, 1], 
    quality = 0.8,
  } = options;
  
  const pickImage = async (): Promise<string | null> => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing,
      aspect,
      quality,
    });
    
    if (!result.canceled && result.assets[0]) {
      return result.assets[0].uri;
    }
    return null;
  };
  
  const takePhoto = async (): Promise<string | null> => {
    const { status } = await ImagePicker.requestCameraPermissionsAsync();
    
    if (status !== 'granted') {
      throw new Error('Camera permission denied');
    }
    
    const result = await ImagePicker.launchCameraAsync({
      allowsEditing,
      aspect,
      quality,
    });
    
    if (!result.canceled && result.assets[0]) {
      return result.assets[0].uri;
    }
    return null;
  };
  
  const pickMultiple = async (): Promise<string[]> => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsMultipleSelection: true,
      quality,
    });
    
    if (!result.canceled) {
      return result.assets.map(asset => asset.uri);
    }
    return [];
  };
  
  return { pickImage, takePhoto, pickMultiple };
}
```

---

## 4) Push Notifications

### Notifications Setup
```typescript
// ==========================================
// services/notifications.ts
// ==========================================

import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import Constants from 'expo-constants';
import { Platform } from 'react-native';

// Types
export interface PushNotificationData {
  type: 'order' | 'message' | 'promo';
  id: string;
  [key: string]: unknown;
}

export interface NotificationContent {
  title: string;
  body: string;
  data?: PushNotificationData;
}

// Configure notifications
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export async function registerForPushNotifications(): Promise<string | null> {
  if (!Device.isDevice) {
    console.warn('Push notifications require a physical device');
    return null;
  }
  
  // Check existing permissions
  const { status: existingStatus } = await Notifications.getPermissionsAsync();
  let finalStatus = existingStatus;
  
  // Request permissions if needed
  if (existingStatus !== 'granted') {
    const { status } = await Notifications.requestPermissionsAsync();
    finalStatus = status;
  }
  
  if (finalStatus !== 'granted') {
    console.warn('Push notification permission denied');
    return null;
  }
  
  // Get push token
  const projectId = Constants.expoConfig?.extra?.eas?.projectId;
  
  const { data: token } = await Notifications.getExpoPushTokenAsync({
    projectId,
  });
  
  // Configure Android channel
  if (Platform.OS === 'android') {
    await Notifications.setNotificationChannelAsync('default', {
      name: 'Default',
      importance: Notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: '#FF231F7C',
    });
  }
  
  return token;
}

export async function scheduleLocalNotification(
  content: NotificationContent,
  trigger?: Notifications.NotificationTriggerInput
): Promise<string> {
  return await Notifications.scheduleNotificationAsync({
    content: {
      title: content.title,
      body: content.body,
      data: content.data as Record<string, unknown>,
    },
    trigger: trigger ?? null,
  });
}


// ==========================================
// hooks/useNotifications.ts
// ==========================================

import { useEffect, useRef, useState } from 'react';
import * as Notifications from 'expo-notifications';
import { 
  registerForPushNotifications, 
  PushNotificationData,
} from '@services/notifications';
import { useRouter } from 'expo-router';

export function useNotifications() {
  const [expoPushToken, setExpoPushToken] = useState<string | null>(null);
  const [notification, setNotification] = useState<Notifications.Notification | null>(null);
  const notificationListener = useRef<Notifications.Subscription>();
  const responseListener = useRef<Notifications.Subscription>();
  const router = useRouter();
  
  useEffect(() => {
    // Register for push notifications
    registerForPushNotifications().then(token => {
      setExpoPushToken(token);
    });
    
    // Listen for incoming notifications
    notificationListener.current = Notifications.addNotificationReceivedListener(
      notification => {
        setNotification(notification);
      }
    );
    
    // Listen for notification interactions
    responseListener.current = Notifications.addNotificationResponseReceivedListener(
      response => {
        const data = response.notification.request.content.data as PushNotificationData;
        
        // Handle navigation based on notification type
        switch (data.type) {
          case 'order':
            router.push(`/orders/${data.id}`);
            break;
          case 'message':
            router.push(`/messages/${data.id}`);
            break;
          case 'promo':
            router.push(`/promotions/${data.id}`);
            break;
        }
      }
    );
    
    return () => {
      notificationListener.current?.remove();
      responseListener.current?.remove();
    };
  }, [router]);
  
  return { expoPushToken, notification };
}
```

---

## 5) Authentication

### Auth Context
```typescript
// ==========================================
// contexts/AuthContext.tsx
// ==========================================

import { 
  createContext, 
  useContext, 
  useEffect, 
  useState, 
  useCallback,
  ReactNode,
} from 'react';
import * as SecureStore from 'expo-secure-store';
import { useRouter, useSegments } from 'expo-router';

interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
}

interface AuthContextType extends AuthState {
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, name: string) => Promise<void>;
  signOut: () => Promise<void>;
  updateUser: (updates: Partial<User>) => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

const TOKEN_KEY = 'auth_token';
const USER_KEY = 'auth_user';

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user: null,
    token: null,
    isLoading: true,
    isAuthenticated: false,
  });
  
  const router = useRouter();
  const segments = useSegments();
  
  // Load stored auth on mount
  useEffect(() => {
    loadStoredAuth();
  }, []);
  
  // Protect routes
  useEffect(() => {
    if (state.isLoading) return;
    
    const inAuthGroup = segments[0] === '(auth)';
    
    if (!state.isAuthenticated && !inAuthGroup) {
      router.replace('/(auth)/login');
    } else if (state.isAuthenticated && inAuthGroup) {
      router.replace('/(tabs)');
    }
  }, [state.isAuthenticated, state.isLoading, segments]);
  
  const loadStoredAuth = async () => {
    try {
      const [token, userJson] = await Promise.all([
        SecureStore.getItemAsync(TOKEN_KEY),
        SecureStore.getItemAsync(USER_KEY),
      ]);
      
      if (token && userJson) {
        const user = JSON.parse(userJson) as User;
        setState({
          user,
          token,
          isLoading: false,
          isAuthenticated: true,
        });
      } else {
        setState(prev => ({ ...prev, isLoading: false }));
      }
    } catch {
      setState(prev => ({ ...prev, isLoading: false }));
    }
  };
  
  const signIn = useCallback(async (email: string, password: string) => {
    setState(prev => ({ ...prev, isLoading: true }));
    
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      
      if (!response.ok) {
        throw new Error('Invalid credentials');
      }
      
      const { user, token } = await response.json();
      
      await Promise.all([
        SecureStore.setItemAsync(TOKEN_KEY, token),
        SecureStore.setItemAsync(USER_KEY, JSON.stringify(user)),
      ]);
      
      setState({
        user,
        token,
        isLoading: false,
        isAuthenticated: true,
      });
    } catch (error) {
      setState(prev => ({ ...prev, isLoading: false }));
      throw error;
    }
  }, []);
  
  const signUp = useCallback(async (email: string, password: string, name: string) => {
    setState(prev => ({ ...prev, isLoading: true }));
    
    try {
      const response = await fetch('/api/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, name }),
      });
      
      if (!response.ok) {
        throw new Error('Registration failed');
      }
      
      const { user, token } = await response.json();
      
      await Promise.all([
        SecureStore.setItemAsync(TOKEN_KEY, token),
        SecureStore.setItemAsync(USER_KEY, JSON.stringify(user)),
      ]);
      
      setState({
        user,
        token,
        isLoading: false,
        isAuthenticated: true,
      });
    } catch (error) {
      setState(prev => ({ ...prev, isLoading: false }));
      throw error;
    }
  }, []);
  
  const signOut = useCallback(async () => {
    await Promise.all([
      SecureStore.deleteItemAsync(TOKEN_KEY),
      SecureStore.deleteItemAsync(USER_KEY),
    ]);
    
    setState({
      user: null,
      token: null,
      isLoading: false,
      isAuthenticated: false,
    });
  }, []);
  
  const updateUser = useCallback((updates: Partial<User>) => {
    setState(prev => {
      if (!prev.user) return prev;
      const updatedUser = { ...prev.user, ...updates };
      SecureStore.setItemAsync(USER_KEY, JSON.stringify(updatedUser));
      return { ...prev, user: updatedUser };
    });
  }, []);
  
  return (
    <AuthContext.Provider 
      value={{ ...state, signIn, signUp, signOut, updateUser }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

---

## 6) EAS Configuration

### EAS Build Configuration
```json
// ==========================================
// eas.json
// ==========================================

{
  "cli": {
    "version": ">= 7.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      },
      "env": {
        "EXPO_PUBLIC_API_URL": "https://dev-api.example.com"
      }
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": false
      },
      "android": {
        "buildType": "apk"
      },
      "env": {
        "EXPO_PUBLIC_API_URL": "https://staging-api.example.com"
      }
    },
    "production": {
      "autoIncrement": true,
      "env": {
        "EXPO_PUBLIC_API_URL": "https://api.example.com"
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your@email.com",
        "ascAppId": "1234567890",
        "appleTeamId": "XXXXXXXXXX"
      },
      "android": {
        "serviceAccountKeyPath": "./google-service-account.json",
        "track": "internal"
      }
    }
  }
}
```

### EAS Update
```typescript
// ==========================================
// hooks/useUpdates.ts
// ==========================================

import { useEffect, useState } from 'react';
import * as Updates from 'expo-updates';

interface UpdateState {
  isUpdateAvailable: boolean;
  isUpdatePending: boolean;
  isChecking: boolean;
  isDownloading: boolean;
}

export function useUpdates() {
  const [state, setState] = useState<UpdateState>({
    isUpdateAvailable: false,
    isUpdatePending: false,
    isChecking: false,
    isDownloading: false,
  });
  
  const checkForUpdate = async () => {
    if (!Updates.isEnabled) {
      return;
    }
    
    setState(prev => ({ ...prev, isChecking: true }));
    
    try {
      const update = await Updates.checkForUpdateAsync();
      setState(prev => ({ 
        ...prev, 
        isUpdateAvailable: update.isAvailable,
        isChecking: false,
      }));
    } catch {
      setState(prev => ({ ...prev, isChecking: false }));
    }
  };
  
  const downloadUpdate = async () => {
    if (!state.isUpdateAvailable) {
      return;
    }
    
    setState(prev => ({ ...prev, isDownloading: true }));
    
    try {
      await Updates.fetchUpdateAsync();
      setState(prev => ({ 
        ...prev, 
        isUpdatePending: true,
        isDownloading: false,
      }));
    } catch {
      setState(prev => ({ ...prev, isDownloading: false }));
    }
  };
  
  const applyUpdate = async () => {
    if (state.isUpdatePending) {
      await Updates.reloadAsync();
    }
  };
  
  useEffect(() => {
    checkForUpdate();
  }, []);
  
  return {
    ...state,
    checkForUpdate,
    downloadUpdate,
    applyUpdate,
  };
}
```

---

## 7) Testing

### Jest Configuration
```javascript
// ==========================================
// jest.config.js
// ==========================================

module.exports = {
  preset: 'jest-expo',
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg)',
  ],
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
};


// ==========================================
// __tests__/screens/HomeScreen.test.tsx
// ==========================================

import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';
import HomeScreen from '@/app/(tabs)/index';

// Mock expo-router
jest.mock('expo-router', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
  Link: ({ children }: { children: React.ReactNode }) => children,
}));

describe('HomeScreen', () => {
  it('renders correctly', () => {
    render(<HomeScreen />);
    
    expect(screen.getByText('Welcome')).toBeTruthy();
  });
  
  it('navigates to product on press', () => {
    const mockPush = jest.fn();
    jest.mocked(require('expo-router').useRouter).mockReturnValue({
      push: mockPush,
    });
    
    render(<HomeScreen />);
    
    fireEvent.press(screen.getByTestId('product-card'));
    
    expect(mockPush).toHaveBeenCalledWith('/product/1');
  });
});
```

---

## Best Practices Checklist

### Project
- [ ] TypeScript strict mode
- [ ] app.config.ts typed
- [ ] Environment variables typed

### Routing
- [ ] Expo Router with typed routes
- [ ] useLocalSearchParams typed
- [ ] Link/router.push typed

### Modules
- [ ] Camera permissions typed
- [ ] Location with typed hooks
- [ ] Notifications typed

### Auth
- [ ] SecureStore with typed keys
- [ ] Auth context typed
- [ ] Route protection

### Build
- [ ] EAS profiles configured
- [ ] Updates hook implemented
- [ ] Environment per profile

---

**References:**
- [Expo TypeScript](https://docs.expo.dev/guides/typescript/)
- [Expo Router](https://docs.expo.dev/router/introduction/)
- [EAS Build](https://docs.expo.dev/build/introduction/)
- [Expo Notifications](https://docs.expo.dev/push-notifications/overview/)
