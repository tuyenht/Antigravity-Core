# React Native TypeScript Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **React Native:** 0.73+  
> **TypeScript:** 5.x  
> **Priority:** P0 - Load for React Native projects

---

You are an expert in React Native development with TypeScript.

## Core Principles

- Use TypeScript for all React Native code
- Type navigation params and routes strictly
- Use platform-specific types when needed
- Follow React Native best practices

---

## 1) Project Setup

### TypeScript Configuration
```json
// ==========================================
// tsconfig.json
// ==========================================

{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    
    // React Native specifics
    "target": "esnext",
    "module": "commonjs",
    "lib": ["es2022"],
    "allowJs": true,
    "jsx": "react-native",
    "noEmit": true,
    "isolatedModules": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    
    // Path aliases
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@screens/*": ["./src/screens/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@utils/*": ["./src/utils/*"],
      "@services/*": ["./src/services/*"],
      "@navigation/*": ["./src/navigation/*"],
      "@assets/*": ["./src/assets/*"]
    }
  },
  "include": ["src/**/*", "*.config.js"],
  "exclude": ["node_modules", "babel.config.js", "metro.config.js"]
}


// ==========================================
// babel.config.js (Path aliases)
// ==========================================

module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    [
      'module-resolver',
      {
        root: ['./'],
        alias: {
          '@': './src',
          '@components': './src/components',
          '@screens': './src/screens',
          '@hooks': './src/hooks',
          '@utils': './src/utils',
          '@services': './src/services',
          '@navigation': './src/navigation',
          '@assets': './src/assets',
        },
      },
    ],
  ],
};
```

### Project Structure
```
src/
├── components/           # Reusable components
│   ├── ui/              # Basic UI components
│   ├── forms/           # Form components
│   └── index.ts         # Exports
├── screens/             # Screen components
├── navigation/          # React Navigation
│   ├── types.ts         # Navigation types
│   ├── RootNavigator.tsx
│   └── stacks/
├── hooks/               # Custom hooks
├── services/            # API services
├── stores/              # State management
├── utils/               # Utilities
├── types/               # Global types
│   ├── index.ts
│   ├── api.ts
│   └── env.d.ts
├── constants/           # Constants
├── assets/              # Images, fonts
└── App.tsx
```

---

## 2) Component Typing

### Basic Components
```typescript
// ==========================================
// TYPED FUNCTIONAL COMPONENT
// ==========================================

import React from 'react';
import { View, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';

interface CardProps {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: () => void;
}

export function Card({ 
  title, 
  subtitle, 
  children, 
  style,
  onPress,
}: CardProps) {
  return (
    <View style={[styles.container, style]}>
      <Text style={styles.title}>{title}</Text>
      {subtitle && <Text style={styles.subtitle}>{subtitle}</Text>}
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 16,
    backgroundColor: '#fff',
    borderRadius: 8,
  } satisfies ViewStyle,
  title: {
    fontSize: 18,
    fontWeight: 'bold',
  } satisfies TextStyle,
  subtitle: {
    fontSize: 14,
    color: '#666',
  } satisfies TextStyle,
});


// ==========================================
// EXTENDING NATIVE COMPONENTS
// ==========================================

import { 
  Pressable, 
  PressableProps, 
  Text, 
  TextProps,
  ActivityIndicator,
} from 'react-native';

interface ButtonProps extends Omit<PressableProps, 'children'> {
  title: string;
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export function Button({
  title,
  variant = 'primary',
  size = 'md',
  loading = false,
  leftIcon,
  rightIcon,
  disabled,
  style,
  ...pressableProps
}: ButtonProps) {
  return (
    <Pressable
      style={({ pressed }) => [
        styles.button,
        styles[variant],
        styles[size],
        pressed && styles.pressed,
        disabled && styles.disabled,
        style,
      ]}
      disabled={disabled || loading}
      {...pressableProps}
    >
      {loading ? (
        <ActivityIndicator color="#fff" />
      ) : (
        <>
          {leftIcon}
          <Text style={[styles.text, styles[`${variant}Text`]]}>{title}</Text>
          {rightIcon}
        </>
      )}
    </Pressable>
  );
}


// ==========================================
// GENERIC LIST COMPONENT
// ==========================================

import { FlatList, FlatListProps, ListRenderItem } from 'react-native';

interface TypedListProps<T> extends Omit<FlatListProps<T>, 'data' | 'renderItem'> {
  data: T[];
  renderItem: ListRenderItem<T>;
  emptyComponent?: React.ReactElement;
  loadingComponent?: React.ReactElement;
  isLoading?: boolean;
}

export function TypedList<T extends { id: string | number }>({
  data,
  renderItem,
  emptyComponent,
  loadingComponent,
  isLoading,
  ...flatListProps
}: TypedListProps<T>) {
  if (isLoading && loadingComponent) {
    return loadingComponent;
  }
  
  return (
    <FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={(item) => String(item.id)}
      ListEmptyComponent={emptyComponent}
      {...flatListProps}
    />
  );
}

// Usage
<TypedList<User>
  data={users}
  renderItem={({ item }) => <UserCard user={item} />}
  emptyComponent={<Text>No users found</Text>}
/>
```

---

## 3) Navigation Typing

### Complete Navigation Setup
```typescript
// ==========================================
// src/navigation/types.ts
// ==========================================

import type { 
  NativeStackScreenProps,
  NativeStackNavigationProp,
} from '@react-navigation/native-stack';
import type { 
  BottomTabScreenProps,
  BottomTabNavigationProp,
} from '@react-navigation/bottom-tabs';
import type { 
  CompositeScreenProps,
  CompositeNavigationProp,
  NavigatorScreenParams,
} from '@react-navigation/native';

// ==========================================
// PARAM LISTS
// ==========================================

export type RootStackParamList = {
  // Auth screens
  Auth: NavigatorScreenParams<AuthStackParamList>;
  
  // Main app
  Main: NavigatorScreenParams<MainTabParamList>;
  
  // Modal screens
  Settings: undefined;
  Profile: { userId: string };
  ProductDetail: { productId: string; title: string };
};

export type AuthStackParamList = {
  Welcome: undefined;
  Login: { email?: string };
  Register: undefined;
  ForgotPassword: undefined;
  ResetPassword: { token: string };
};

export type MainTabParamList = {
  Home: NavigatorScreenParams<HomeStackParamList>;
  Search: undefined;
  Cart: undefined;
  Account: undefined;
};

export type HomeStackParamList = {
  HomeScreen: undefined;
  CategoryList: { categoryId: string };
  ProductList: { query?: string };
};


// ==========================================
// SCREEN PROPS TYPES
// ==========================================

// Root stack screens
export type RootStackScreenProps<T extends keyof RootStackParamList> =
  NativeStackScreenProps<RootStackParamList, T>;

// Auth stack screens
export type AuthStackScreenProps<T extends keyof AuthStackParamList> =
  CompositeScreenProps<
    NativeStackScreenProps<AuthStackParamList, T>,
    RootStackScreenProps<keyof RootStackParamList>
  >;

// Main tab screens
export type MainTabScreenProps<T extends keyof MainTabParamList> =
  CompositeScreenProps<
    BottomTabScreenProps<MainTabParamList, T>,
    RootStackScreenProps<keyof RootStackParamList>
  >;

// Home stack screens
export type HomeStackScreenProps<T extends keyof HomeStackParamList> =
  CompositeScreenProps<
    NativeStackScreenProps<HomeStackParamList, T>,
    MainTabScreenProps<keyof MainTabParamList>
  >;


// ==========================================
// NAVIGATION PROP TYPES
// ==========================================

export type RootNavigationProp = NativeStackNavigationProp<RootStackParamList>;

export type AuthNavigationProp = CompositeNavigationProp<
  NativeStackNavigationProp<AuthStackParamList>,
  RootNavigationProp
>;


// ==========================================
// DECLARE GLOBAL TYPES
// ==========================================

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}


// ==========================================
// src/screens/LoginScreen.tsx
// ==========================================

import { View, TextInput, Button } from 'react-native';
import type { AuthStackScreenProps } from '@navigation/types';

type Props = AuthStackScreenProps<'Login'>;

export function LoginScreen({ navigation, route }: Props) {
  // route.params.email is typed as string | undefined
  const initialEmail = route.params?.email ?? '';
  
  const handleLogin = () => {
    // Type-safe navigation
    navigation.navigate('Main', {
      screen: 'Home',
      params: {
        screen: 'HomeScreen',
      },
    });
  };
  
  const handleForgotPassword = () => {
    navigation.navigate('ForgotPassword');
  };
  
  return (
    <View>
      <TextInput defaultValue={initialEmail} />
      <Button title="Login" onPress={handleLogin} />
      <Button title="Forgot Password" onPress={handleForgotPassword} />
    </View>
  );
}


// ==========================================
// TYPED NAVIGATION HOOKS
// ==========================================

import { useNavigation, useRoute } from '@react-navigation/native';
import type { 
  RootStackParamList, 
  RootNavigationProp,
} from '@navigation/types';
import type { RouteProp } from '@react-navigation/native';

// Custom typed hooks
export function useAppNavigation() {
  return useNavigation<RootNavigationProp>();
}

export function useTypedRoute<T extends keyof RootStackParamList>() {
  return useRoute<RouteProp<RootStackParamList, T>>();
}

// Usage
function ProductScreen() {
  const navigation = useAppNavigation();
  const route = useTypedRoute<'ProductDetail'>();
  
  const { productId, title } = route.params;  // Typed!
  
  navigation.navigate('Cart');  // Type-safe!
}
```

---

## 4) State Management

### Redux Toolkit
```typescript
// ==========================================
// src/stores/slices/authSlice.ts
// ==========================================

import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { authService } from '@services/auth';

interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  status: 'idle' | 'loading' | 'authenticated' | 'error';
  error: string | null;
}

const initialState: AuthState = {
  user: null,
  token: null,
  status: 'idle',
  error: null,
};

export const login = createAsyncThunk<
  { user: User; token: string },
  { email: string; password: string },
  { rejectValue: string }
>('auth/login', async (credentials, { rejectWithValue }) => {
  try {
    const response = await authService.login(credentials);
    return response.data;
  } catch (error) {
    return rejectWithValue('Invalid credentials');
  }
});

export const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    logout: (state) => {
      state.user = null;
      state.token = null;
      state.status = 'idle';
    },
    updateUser: (state, action: PayloadAction<Partial<User>>) => {
      if (state.user) {
        state.user = { ...state.user, ...action.payload };
      }
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(login.pending, (state) => {
        state.status = 'loading';
        state.error = null;
      })
      .addCase(login.fulfilled, (state, action) => {
        state.status = 'authenticated';
        state.user = action.payload.user;
        state.token = action.payload.token;
      })
      .addCase(login.rejected, (state, action) => {
        state.status = 'error';
        state.error = action.payload ?? 'Unknown error';
      });
  },
});

export const { logout, updateUser } = authSlice.actions;


// ==========================================
// src/stores/index.ts
// ==========================================

import { configureStore } from '@reduxjs/toolkit';
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import { authSlice } from './slices/authSlice';
import { cartSlice } from './slices/cartSlice';

export const store = configureStore({
  reducer: {
    auth: authSlice.reducer,
    cart: cartSlice.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: false,
    }),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// Typed hooks
export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

### Zustand (Simpler Alternative)
```typescript
// ==========================================
// src/stores/useAuthStore.ts
// ==========================================

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface User {
  id: string;
  email: string;
  name: string;
}

interface AuthStore {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  
  // Actions
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  updateUser: (updates: Partial<User>) => void;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isLoading: false,
      
      login: async (email, password) => {
        set({ isLoading: true });
        try {
          const response = await fetch('/api/auth/login', {
            method: 'POST',
            body: JSON.stringify({ email, password }),
          });
          const { user, token } = await response.json();
          set({ user, token, isLoading: false });
        } catch (error) {
          set({ isLoading: false });
          throw error;
        }
      },
      
      logout: () => {
        set({ user: null, token: null });
      },
      
      updateUser: (updates) => {
        const { user } = get();
        if (user) {
          set({ user: { ...user, ...updates } });
        }
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({ 
        user: state.user, 
        token: state.token,
      }),
    }
  )
);
```

---

## 5) Platform-Specific Code

### Platform Typing
```typescript
// ==========================================
// PLATFORM.SELECT
// ==========================================

import { Platform, StyleSheet, ViewStyle } from 'react-native';

const styles = StyleSheet.create({
  shadow: Platform.select<ViewStyle>({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.25,
      shadowRadius: 3.84,
    },
    android: {
      elevation: 5,
    },
    default: {},
  }),
});


// ==========================================
// PLATFORM-SPECIFIC FILES
// ==========================================

// components/StatusBar/index.tsx
export { StatusBar } from './StatusBar';

// components/StatusBar/StatusBar.ios.tsx
import { StatusBar as RNStatusBar } from 'react-native';

interface StatusBarProps {
  backgroundColor?: string;
  barStyle?: 'light-content' | 'dark-content';
}

export function StatusBar({ backgroundColor, barStyle = 'dark-content' }: StatusBarProps) {
  return <RNStatusBar barStyle={barStyle} backgroundColor={backgroundColor} />;
}

// components/StatusBar/StatusBar.android.tsx
import { StatusBar as RNStatusBar, View, StyleSheet } from 'react-native';

interface StatusBarProps {
  backgroundColor?: string;
  barStyle?: 'light-content' | 'dark-content';
}

export function StatusBar({ backgroundColor = '#fff', barStyle = 'dark-content' }: StatusBarProps) {
  return (
    <View style={[styles.statusBar, { backgroundColor }]}>
      <RNStatusBar
        translucent
        backgroundColor="transparent"
        barStyle={barStyle}
      />
    </View>
  );
}


// ==========================================
// PLATFORM-SPECIFIC TYPES
// ==========================================

import { Platform } from 'react-native';

type IOSPermission = 'camera' | 'photos' | 'microphone' | 'location';
type AndroidPermission = 
  | 'android.permission.CAMERA'
  | 'android.permission.READ_EXTERNAL_STORAGE'
  | 'android.permission.RECORD_AUDIO'
  | 'android.permission.ACCESS_FINE_LOCATION';

type Permission = typeof Platform.OS extends 'ios' 
  ? IOSPermission 
  : AndroidPermission;

// Cross-platform permission mapping
const permissionMap = {
  camera: Platform.select({
    ios: 'camera' as const,
    android: 'android.permission.CAMERA' as const,
  }),
  photos: Platform.select({
    ios: 'photos' as const,
    android: 'android.permission.READ_EXTERNAL_STORAGE' as const,
  }),
} as const;
```

---

## 6) API Integration

### Typed API Service
```typescript
// ==========================================
// src/services/api.ts
// ==========================================

import axios, { AxiosInstance, AxiosRequestConfig, AxiosError } from 'axios';
import { useAuthStore } from '@stores/useAuthStore';

// Response types
interface ApiResponse<T> {
  data: T;
  message?: string;
}

interface ApiError {
  code: string;
  message: string;
  details?: Record<string, string[]>;
}

interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    perPage: number;
    totalPages: number;
  };
}

// Create typed API client
class ApiClient {
  private client: AxiosInstance;
  
  constructor(baseURL: string) {
    this.client = axios.create({
      baseURL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    // Request interceptor
    this.client.interceptors.request.use((config) => {
      const token = useAuthStore.getState().token;
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });
    
    // Response interceptor
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError<ApiError>) => {
        if (error.response?.status === 401) {
          useAuthStore.getState().logout();
        }
        throw error;
      }
    );
  }
  
  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.get<ApiResponse<T>>(url, config);
    return response.data.data;
  }
  
  async post<T, D = unknown>(url: string, data?: D, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.post<ApiResponse<T>>(url, data, config);
    return response.data.data;
  }
  
  async put<T, D = unknown>(url: string, data?: D, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.put<ApiResponse<T>>(url, data, config);
    return response.data.data;
  }
  
  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.delete<ApiResponse<T>>(url, config);
    return response.data.data;
  }
  
  async getPaginated<T>(
    url: string, 
    config?: AxiosRequestConfig
  ): Promise<PaginatedResponse<T>> {
    const response = await this.client.get<PaginatedResponse<T>>(url, config);
    return response.data;
  }
}

export const api = new ApiClient('https://api.example.com');


// ==========================================
// src/services/products.ts
// ==========================================

import { api } from './api';

interface Product {
  id: string;
  name: string;
  price: number;
  image: string;
  description: string;
  category: string;
}

interface CreateProductInput {
  name: string;
  price: number;
  description: string;
  categoryId: string;
}

export const productsService = {
  getAll: (params?: { category?: string; search?: string }) =>
    api.getPaginated<Product>('/products', { params }),
    
  getById: (id: string) =>
    api.get<Product>(`/products/${id}`),
    
  create: (data: CreateProductInput) =>
    api.post<Product>('/products', data),
    
  update: (id: string, data: Partial<CreateProductInput>) =>
    api.put<Product>(`/products/${id}`, data),
    
  delete: (id: string) =>
    api.delete<void>(`/products/${id}`),
};


// ==========================================
// REACT QUERY INTEGRATION
// ==========================================

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsService } from '@services/products';

export function useProducts(category?: string) {
  return useQuery({
    queryKey: ['products', { category }],
    queryFn: () => productsService.getAll({ category }),
  });
}

export function useProduct(id: string) {
  return useQuery({
    queryKey: ['products', id],
    queryFn: () => productsService.getById(id),
    enabled: !!id,
  });
}

export function useCreateProduct() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: productsService.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
```

---

## 7) Animations

### Typed Animations
```typescript
// ==========================================
// ANIMATED VALUES
// ==========================================

import { Animated, Easing } from 'react-native';
import { useRef, useEffect } from 'react';

export function useFadeIn(duration: number = 300) {
  const opacity = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(20)).current;
  
  useEffect(() => {
    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 1,
        duration,
        useNativeDriver: true,
      }),
      Animated.timing(translateY, {
        toValue: 0,
        duration,
        easing: Easing.out(Easing.ease),
        useNativeDriver: true,
      }),
    ]).start();
  }, [opacity, translateY, duration]);
  
  return {
    opacity,
    transform: [{ translateY }],
  };
}


// ==========================================
// REANIMATED 3
// ==========================================

import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
  Extrapolate,
} from 'react-native-reanimated';

interface AnimatedCardProps {
  children: React.ReactNode;
  delay?: number;
}

export function AnimatedCard({ children, delay = 0 }: AnimatedCardProps) {
  const progress = useSharedValue(0);
  
  useEffect(() => {
    progress.value = withDelay(
      delay,
      withSpring(1, { damping: 12, stiffness: 100 })
    );
  }, [delay, progress]);
  
  const animatedStyle = useAnimatedStyle(() => ({
    opacity: progress.value,
    transform: [
      {
        translateY: interpolate(
          progress.value,
          [0, 1],
          [50, 0],
          Extrapolate.CLAMP
        ),
      },
      {
        scale: interpolate(
          progress.value,
          [0, 1],
          [0.9, 1],
          Extrapolate.CLAMP
        ),
      },
    ],
  }));
  
  return (
    <Animated.View style={animatedStyle}>
      {children}
    </Animated.View>
  );
}
```

---

## 8) Testing

### Jest + Testing Library
```typescript
// ==========================================
// jest.config.js
// ==========================================

module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|@react-navigation)/)',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};


// ==========================================
// __tests__/components/Button.test.tsx
// ==========================================

import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';
import { Button } from '@components/Button';

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button title="Click me" onPress={() => {}} />);
    
    expect(screen.getByText('Click me')).toBeTruthy();
  });
  
  it('calls onPress when pressed', () => {
    const onPress = jest.fn();
    render(<Button title="Click me" onPress={onPress} />);
    
    fireEvent.press(screen.getByText('Click me'));
    
    expect(onPress).toHaveBeenCalledTimes(1);
  });
  
  it('shows loading indicator when loading', () => {
    render(<Button title="Submit" onPress={() => {}} loading />);
    
    expect(screen.getByTestId('loading-indicator')).toBeTruthy();
    expect(screen.queryByText('Submit')).toBeNull();
  });
  
  it('is disabled when disabled prop is true', () => {
    const onPress = jest.fn();
    render(<Button title="Click me" onPress={onPress} disabled />);
    
    fireEvent.press(screen.getByText('Click me'));
    
    expect(onPress).not.toHaveBeenCalled();
  });
});


// ==========================================
// __tests__/screens/LoginScreen.test.tsx
// ==========================================

import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import { NavigationContainer } from '@react-navigation/native';
import { LoginScreen } from '@screens/LoginScreen';

// Mock navigation
const mockNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({
    navigate: mockNavigate,
  }),
  useRoute: () => ({
    params: {},
  }),
}));

const renderWithNavigation = (component: React.ReactElement) => {
  return render(
    <NavigationContainer>
      {component}
    </NavigationContainer>
  );
};

describe('LoginScreen', () => {
  beforeEach(() => {
    mockNavigate.mockClear();
  });
  
  it('navigates to Home on successful login', async () => {
    const { getByPlaceholderText, getByText } = renderWithNavigation(
      <LoginScreen />
    );
    
    fireEvent.changeText(getByPlaceholderText('Email'), 'test@example.com');
    fireEvent.changeText(getByPlaceholderText('Password'), 'password123');
    fireEvent.press(getByText('Login'));
    
    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('Main', expect.any(Object));
    });
  });
});
```

---

## Best Practices Checklist

### Project
- [ ] TypeScript strict mode
- [ ] Path aliases configured
- [ ] ESLint + Prettier

### Components
- [ ] Props interfaces defined
- [ ] StyleSheet typed
- [ ] Generic components

### Navigation
- [ ] RootParamList defined
- [ ] Screen props typed
- [ ] Navigation hooks typed

### State
- [ ] Typed Redux/Zustand
- [ ] Typed React Query
- [ ] Typed async storage

### Platform
- [ ] Platform.select typed
- [ ] Platform-specific files
- [ ] Native modules typed

---

**References:**
- [React Native TypeScript](https://reactnative.dev/docs/typescript)
- [React Navigation TypeScript](https://reactnavigation.org/docs/typescript/)
- [Testing Library RN](https://testing-library.com/docs/react-native-testing-library/intro/)
