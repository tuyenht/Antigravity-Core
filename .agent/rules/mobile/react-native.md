# React Native Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **React Native:** 0.73+  
> **New Architecture:** Fabric + TurboModules  
> **Priority:** P0 - Load for React Native projects

---

You are an expert in React Native development for building high-quality cross-platform mobile applications.

## Core Principles

- Write platform-agnostic code where possible
- Optimize for performance (60fps)
- Follow platform design guidelines
- Use TypeScript for type safety

---

## 1) Project Structure

### Feature-Based Architecture
```
src/
├── app/                          # App entry and configuration
│   ├── App.tsx
│   ├── navigation/
│   │   ├── RootNavigator.tsx
│   │   ├── AuthNavigator.tsx
│   │   └── MainNavigator.tsx
│   └── providers/
│       ├── AppProviders.tsx
│       └── ThemeProvider.tsx
├── features/                     # Feature modules
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── SignupForm.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── screens/
│   │   │   ├── LoginScreen.tsx
│   │   │   └── SignupScreen.tsx
│   │   ├── services/
│   │   │   └── authService.ts
│   │   └── types/
│   │       └── auth.types.ts
│   ├── home/
│   │   ├── components/
│   │   ├── screens/
│   │   └── hooks/
│   └── profile/
├── shared/                       # Shared code
│   ├── components/
│   │   ├── ui/                   # Base components
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   └── Card.tsx
│   │   └── layout/
│   │       ├── Screen.tsx
│   │       └── Container.tsx
│   ├── hooks/
│   │   ├── useDebounce.ts
│   │   └── useKeyboard.ts
│   ├── services/
│   │   └── api.ts
│   ├── stores/
│   │   └── useAuthStore.ts
│   ├── theme/
│   │   ├── colors.ts
│   │   ├── typography.ts
│   │   └── spacing.ts
│   ├── utils/
│   │   ├── storage.ts
│   │   └── validation.ts
│   └── types/
│       └── navigation.types.ts
└── assets/
    ├── images/
    └── fonts/
```

---

## 2) Core Components

### Screen Component
```tsx
// ==========================================
// REUSABLE SCREEN WRAPPER
// ==========================================

import React, { ReactNode } from 'react';
import {
  View,
  StyleSheet,
  SafeAreaView,
  StatusBar,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  ViewStyle,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';

interface ScreenProps {
  children: ReactNode;
  scrollable?: boolean;
  safeArea?: boolean;
  keyboardAvoiding?: boolean;
  style?: ViewStyle;
  contentContainerStyle?: ViewStyle;
  statusBarStyle?: 'light-content' | 'dark-content';
}

export function Screen({
  children,
  scrollable = false,
  safeArea = true,
  keyboardAvoiding = true,
  style,
  contentContainerStyle,
  statusBarStyle,
}: ScreenProps) {
  const { colors, isDark } = useTheme();
  
  const Container = safeArea ? SafeAreaView : View;
  const ContentWrapper = scrollable ? ScrollView : View;
  
  const content = (
    <ContentWrapper
      style={[styles.content, !scrollable && styles.flex, style]}
      contentContainerStyle={scrollable ? [styles.scrollContent, contentContainerStyle] : undefined}
      keyboardShouldPersistTaps="handled"
      showsVerticalScrollIndicator={false}
    >
      {children}
    </ContentWrapper>
  );
  
  return (
    <Container style={[styles.container, { backgroundColor: colors.background }]}>
      <StatusBar
        barStyle={statusBarStyle ?? (isDark ? 'light-content' : 'dark-content')}
        backgroundColor={colors.background}
      />
      {keyboardAvoiding && Platform.OS === 'ios' ? (
        <KeyboardAvoidingView style={styles.flex} behavior="padding">
          {content}
        </KeyboardAvoidingView>
      ) : (
        content
      )}
    </Container>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  flex: {
    flex: 1,
  },
  content: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
  },
});
```

### Button Component
```tsx
// ==========================================
// VERSATILE BUTTON COMPONENT
// ==========================================

import React, { memo } from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
  TextStyle,
  Pressable,
} from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
} from 'react-native-reanimated';
import { useTheme } from '../theme/ThemeContext';

type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  disabled?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  fullWidth?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export const Button = memo(function Button({
  title,
  onPress,
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled = false,
  leftIcon,
  rightIcon,
  fullWidth = false,
  style,
  textStyle,
}: ButtonProps) {
  const { colors } = useTheme();
  const scale = useSharedValue(1);
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));
  
  const handlePressIn = () => {
    scale.value = withSpring(0.96, { damping: 15 });
  };
  
  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15 });
  };
  
  const getVariantStyles = (): { container: ViewStyle; text: TextStyle } => {
    switch (variant) {
      case 'primary':
        return {
          container: {
            backgroundColor: disabled ? colors.primaryDisabled : colors.primary,
          },
          text: { color: colors.white },
        };
      case 'secondary':
        return {
          container: {
            backgroundColor: disabled ? colors.secondaryDisabled : colors.secondary,
          },
          text: { color: colors.white },
        };
      case 'outline':
        return {
          container: {
            backgroundColor: 'transparent',
            borderWidth: 1,
            borderColor: disabled ? colors.border : colors.primary,
          },
          text: { color: disabled ? colors.textDisabled : colors.primary },
        };
      case 'ghost':
        return {
          container: { backgroundColor: 'transparent' },
          text: { color: disabled ? colors.textDisabled : colors.primary },
        };
    }
  };
  
  const getSizeStyles = (): { container: ViewStyle; text: TextStyle } => {
    switch (size) {
      case 'sm':
        return {
          container: { paddingVertical: 8, paddingHorizontal: 16 },
          text: { fontSize: 14 },
        };
      case 'md':
        return {
          container: { paddingVertical: 12, paddingHorizontal: 24 },
          text: { fontSize: 16 },
        };
      case 'lg':
        return {
          container: { paddingVertical: 16, paddingHorizontal: 32 },
          text: { fontSize: 18 },
        };
    }
  };
  
  const variantStyles = getVariantStyles();
  const sizeStyles = getSizeStyles();
  
  return (
    <AnimatedPressable
      style={[
        styles.container,
        variantStyles.container,
        sizeStyles.container,
        fullWidth && styles.fullWidth,
        animatedStyle,
        style,
      ]}
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      disabled={disabled || loading}
    >
      {loading ? (
        <ActivityIndicator color={variantStyles.text.color} />
      ) : (
        <>
          {leftIcon}
          <Text style={[styles.text, variantStyles.text, sizeStyles.text, textStyle]}>
            {title}
          </Text>
          {rightIcon}
        </>
      )}
    </AnimatedPressable>
  );
});

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    gap: 8,
  },
  fullWidth: {
    width: '100%',
  },
  text: {
    fontWeight: '600',
  },
});
```

### Input Component
```tsx
// ==========================================
// STYLED INPUT COMPONENT
// ==========================================

import React, { forwardRef, useState, memo } from 'react';
import {
  View,
  TextInput,
  Text,
  StyleSheet,
  TextInputProps,
  TouchableOpacity,
  ViewStyle,
} from 'react-native';
import Animated, {
  useAnimatedStyle,
  withTiming,
  useSharedValue,
  interpolateColor,
} from 'react-native-reanimated';
import { useTheme } from '../theme/ThemeContext';

interface InputProps extends Omit<TextInputProps, 'style'> {
  label?: string;
  error?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  containerStyle?: ViewStyle;
}

const AnimatedView = Animated.createAnimatedComponent(View);

export const Input = memo(
  forwardRef<TextInput, InputProps>(function Input(
    { label, error, leftIcon, rightIcon, containerStyle, ...props },
    ref
  ) {
    const { colors } = useTheme();
    const [isFocused, setIsFocused] = useState(false);
    const focusAnim = useSharedValue(0);
    
    const handleFocus = (e: any) => {
      setIsFocused(true);
      focusAnim.value = withTiming(1, { duration: 200 });
      props.onFocus?.(e);
    };
    
    const handleBlur = (e: any) => {
      setIsFocused(false);
      focusAnim.value = withTiming(0, { duration: 200 });
      props.onBlur?.(e);
    };
    
    const animatedBorderStyle = useAnimatedStyle(() => ({
      borderColor: interpolateColor(
        focusAnim.value,
        [0, 1],
        [error ? colors.error : colors.border, error ? colors.error : colors.primary]
      ),
    }));
    
    return (
      <View style={[styles.container, containerStyle]}>
        {label && (
          <Text style={[styles.label, { color: colors.textSecondary }]}>
            {label}
          </Text>
        )}
        <AnimatedView
          style={[
            styles.inputContainer,
            { backgroundColor: colors.inputBackground },
            animatedBorderStyle,
          ]}
        >
          {leftIcon && <View style={styles.iconLeft}>{leftIcon}</View>}
          <TextInput
            ref={ref}
            style={[
              styles.input,
              { color: colors.text },
              leftIcon && styles.inputWithLeftIcon,
              rightIcon && styles.inputWithRightIcon,
            ]}
            placeholderTextColor={colors.placeholder}
            onFocus={handleFocus}
            onBlur={handleBlur}
            {...props}
          />
          {rightIcon && <View style={styles.iconRight}>{rightIcon}</View>}
        </AnimatedView>
        {error && (
          <Text style={[styles.error, { color: colors.error }]}>{error}</Text>
        )}
      </View>
    );
  })
);

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 8,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderRadius: 12,
    minHeight: 48,
  },
  input: {
    flex: 1,
    fontSize: 16,
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  inputWithLeftIcon: {
    paddingLeft: 8,
  },
  inputWithRightIcon: {
    paddingRight: 8,
  },
  iconLeft: {
    paddingLeft: 12,
  },
  iconRight: {
    paddingRight: 12,
  },
  error: {
    fontSize: 12,
    marginTop: 4,
  },
});
```

---

## 3) Navigation

### Navigation Setup
```tsx
// ==========================================
// TYPE-SAFE NAVIGATION
// ==========================================

// types/navigation.types.ts
import { NavigatorScreenParams } from '@react-navigation/native';

export type RootStackParamList = {
  Auth: NavigatorScreenParams<AuthStackParamList>;
  Main: NavigatorScreenParams<MainTabParamList>;
  Modal: { title: string };
};

export type AuthStackParamList = {
  Login: undefined;
  Signup: undefined;
  ForgotPassword: { email?: string };
};

export type MainTabParamList = {
  Home: undefined;
  Search: undefined;
  Profile: undefined;
};

export type HomeStackParamList = {
  HomeScreen: undefined;
  Details: { id: string };
  Settings: undefined;
};

// Typed navigation hooks
declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}


// ==========================================
// ROOT NAVIGATOR
// ==========================================

// navigation/RootNavigator.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAuthStore } from '../stores/useAuthStore';
import { AuthNavigator } from './AuthNavigator';
import { MainNavigator } from './MainNavigator';
import { ModalScreen } from '../screens/ModalScreen';
import { RootStackParamList } from '../types/navigation.types';
import { linking } from './linking';
import { useTheme } from '../theme/ThemeContext';

const Stack = createNativeStackNavigator<RootStackParamList>();

export function RootNavigator() {
  const { isAuthenticated, isLoading } = useAuthStore();
  const { colors, isDark } = useTheme();
  
  if (isLoading) {
    return <SplashScreen />;
  }
  
  return (
    <NavigationContainer
      linking={linking}
      theme={{
        dark: isDark,
        colors: {
          primary: colors.primary,
          background: colors.background,
          card: colors.card,
          text: colors.text,
          border: colors.border,
          notification: colors.error,
        },
      }}
    >
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthenticated ? (
          <>
            <Stack.Screen name="Main" component={MainNavigator} />
            <Stack.Screen
              name="Modal"
              component={ModalScreen}
              options={{
                presentation: 'modal',
                animation: 'slide_from_bottom',
              }}
            />
          </>
        ) : (
          <Stack.Screen name="Auth" component={AuthNavigator} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}


// ==========================================
// TAB NAVIGATOR
// ==========================================

// navigation/MainNavigator.tsx
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Home, Search, User } from 'lucide-react-native';
import { HomeNavigator } from './HomeNavigator';
import { SearchScreen } from '../screens/SearchScreen';
import { ProfileScreen } from '../screens/ProfileScreen';
import { MainTabParamList } from '../types/navigation.types';
import { useTheme } from '../theme/ThemeContext';

const Tab = createBottomTabNavigator<MainTabParamList>();

export function MainNavigator() {
  const { colors } = useTheme();
  const insets = useSafeAreaInsets();
  
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.textSecondary,
        tabBarStyle: {
          backgroundColor: colors.card,
          borderTopColor: colors.border,
          paddingBottom: insets.bottom,
          height: 60 + insets.bottom,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '500',
        },
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeNavigator}
        options={{
          tabBarIcon: ({ color, size }) => <Home size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="Search"
        component={SearchScreen}
        options={{
          tabBarIcon: ({ color, size }) => <Search size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ color, size }) => <User size={size} color={color} />,
        }}
      />
    </Tab.Navigator>
  );
}


// ==========================================
// DEEP LINKING
// ==========================================

// navigation/linking.ts
import { LinkingOptions } from '@react-navigation/native';
import { RootStackParamList } from '../types/navigation.types';

export const linking: LinkingOptions<RootStackParamList> = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: {
    screens: {
      Auth: {
        screens: {
          Login: 'login',
          Signup: 'signup',
          ForgotPassword: 'forgot-password',
        },
      },
      Main: {
        screens: {
          Home: {
            screens: {
              HomeScreen: '',
              Details: 'details/:id',
            },
          },
          Profile: 'profile',
        },
      },
      Modal: 'modal',
    },
  },
};
```

---

## 4) State Management

### Zustand Store
```tsx
// ==========================================
// AUTH STORE WITH ZUSTAND
// ==========================================

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { MMKV } from 'react-native-mmkv';

// MMKV storage adapter (faster than AsyncStorage)
const storage = new MMKV();

const mmkvStorage = {
  getItem: (name: string) => {
    const value = storage.getString(name);
    return value ?? null;
  },
  setItem: (name: string, value: string) => {
    storage.set(name, value);
  },
  removeItem: (name: string) => {
    storage.delete(name);
  },
};

interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  
  // Actions
  setUser: (user: User) => void;
  setToken: (token: string) => void;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  checkAuth: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: true,
      
      setUser: (user) => set({ user, isAuthenticated: true }),
      
      setToken: (token) => set({ token }),
      
      login: async (email, password) => {
        try {
          set({ isLoading: true });
          
          const response = await authService.login(email, password);
          
          set({
            user: response.user,
            token: response.token,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error) {
          set({ isLoading: false });
          throw error;
        }
      },
      
      logout: () => {
        set({
          user: null,
          token: null,
          isAuthenticated: false,
        });
      },
      
      checkAuth: async () => {
        const { token } = get();
        
        if (!token) {
          set({ isLoading: false });
          return;
        }
        
        try {
          const user = await authService.getProfile();
          set({ user, isAuthenticated: true, isLoading: false });
        } catch {
          set({ token: null, isLoading: false });
        }
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => mmkvStorage),
      partialize: (state) => ({
        token: state.token,
        user: state.user,
      }),
    }
  )
);


// ==========================================
// TANSTACK QUERY SETUP
// ==========================================

// providers/QueryProvider.tsx
import React from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { focusManager, onlineManager } from '@tanstack/react-query';
import NetInfo from '@react-native-community/netinfo';
import { AppState, AppStateStatus, Platform } from 'react-native';

// Listen to app state changes
focusManager.setEventListener((handleFocus) => {
  const subscription = AppState.addEventListener('change', (state: AppStateStatus) => {
    handleFocus(state === 'active');
  });
  
  return () => subscription.remove();
});

// Listen to online state
onlineManager.setEventListener((setOnline) => {
  return NetInfo.addEventListener((state) => {
    setOnline(!!state.isConnected);
  });
});

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 30, // 30 minutes
    },
    mutations: {
      retry: 1,
    },
  },
});

export function QueryProvider({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}


// ==========================================
// TYPED QUERY HOOKS
// ==========================================

// hooks/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productService } from '../services/productService';
import { Product } from '../types/product.types';

export function useProducts(category?: string) {
  return useQuery({
    queryKey: ['products', category],
    queryFn: () => productService.getProducts(category),
    staleTime: 1000 * 60 * 5,
  });
}

export function useProduct(id: string) {
  return useQuery({
    queryKey: ['products', id],
    queryFn: () => productService.getProduct(id),
    enabled: !!id,
  });
}

export function useCreateProduct() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: productService.createProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
```

---

## 5) Animations

### Reanimated Patterns
```tsx
// ==========================================
// REANIMATED 3 ANIMATIONS
// ==========================================

import React from 'react';
import { View, StyleSheet } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  withSequence,
  withDelay,
  withRepeat,
  Easing,
  interpolate,
  Extrapolation,
  runOnJS,
} from 'react-native-reanimated';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';

// Animated Card with scale
export function AnimatedCard({ children }: { children: React.ReactNode }) {
  const scale = useSharedValue(1);
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));
  
  const gesture = Gesture.Tap()
    .onBegin(() => {
      scale.value = withSpring(0.95);
    })
    .onFinalize(() => {
      scale.value = withSpring(1);
    });
  
  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.card, animatedStyle]}>
        {children}
      </Animated.View>
    </GestureDetector>
  );
}


// Fade-in animation on mount
export function FadeIn({ 
  children, 
  delay = 0,
  duration = 300,
}: { 
  children: React.ReactNode;
  delay?: number;
  duration?: number;
}) {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(20);
  
  React.useEffect(() => {
    opacity.value = withDelay(delay, withTiming(1, { duration }));
    translateY.value = withDelay(delay, withTiming(0, { duration }));
  }, []);
  
  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));
  
  return <Animated.View style={animatedStyle}>{children}</Animated.View>;
}


// Staggered list animation
export function StaggeredList<T>({ 
  data, 
  renderItem,
  staggerDelay = 50,
}: { 
  data: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  staggerDelay?: number;
}) {
  return (
    <>
      {data.map((item, index) => (
        <FadeIn key={index} delay={index * staggerDelay}>
          {renderItem(item, index)}
        </FadeIn>
      ))}
    </>
  );
}


// ==========================================
// GESTURE ANIMATIONS
// ==========================================

// Swipeable Card
export function SwipeableCard({ 
  onSwipeLeft, 
  onSwipeRight,
  children,
}: {
  onSwipeLeft?: () => void;
  onSwipeRight?: () => void;
  children: React.ReactNode;
}) {
  const translateX = useSharedValue(0);
  const SWIPE_THRESHOLD = 100;
  
  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX;
    })
    .onEnd((event) => {
      if (event.translationX > SWIPE_THRESHOLD) {
        translateX.value = withTiming(500, {}, () => {
          if (onSwipeRight) runOnJS(onSwipeRight)();
        });
      } else if (event.translationX < -SWIPE_THRESHOLD) {
        translateX.value = withTiming(-500, {}, () => {
          if (onSwipeLeft) runOnJS(onSwipeLeft)();
        });
      } else {
        translateX.value = withSpring(0);
      }
    });
  
  const animatedStyle = useAnimatedStyle(() => {
    const rotate = interpolate(
      translateX.value,
      [-200, 0, 200],
      [-15, 0, 15],
      Extrapolation.CLAMP
    );
    
    return {
      transform: [
        { translateX: translateX.value },
        { rotate: `${rotate}deg` },
      ],
    };
  });
  
  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={animatedStyle}>
        {children}
      </Animated.View>
    </GestureDetector>
  );
}


// Bottom Sheet
export function BottomSheet({ 
  isOpen, 
  onClose, 
  children,
  snapPoints = [300, 500],
}: {
  isOpen: boolean;
  onClose: () => void;
  children: React.ReactNode;
  snapPoints?: number[];
}) {
  const translateY = useSharedValue(snapPoints[snapPoints.length - 1]);
  const currentSnap = useSharedValue(0);
  
  React.useEffect(() => {
    translateY.value = withSpring(isOpen ? 0 : snapPoints[snapPoints.length - 1], {
      damping: 20,
      stiffness: 150,
    });
  }, [isOpen]);
  
  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateY.value = Math.max(0, event.translationY);
    })
    .onEnd((event) => {
      if (event.translationY > 100) {
        translateY.value = withSpring(snapPoints[snapPoints.length - 1]);
        runOnJS(onClose)();
      } else {
        translateY.value = withSpring(0);
      }
    });
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }],
  }));
  
  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.bottomSheet, animatedStyle]}>
        <View style={styles.handle} />
        {children}
      </Animated.View>
    </GestureDetector>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  bottomSheet: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 16,
    paddingTop: 8,
  },
  handle: {
    width: 40,
    height: 4,
    backgroundColor: '#e0e0e0',
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 16,
  },
});
```

---

## 6) Performance Optimization

### Optimized FlatList
```tsx
// ==========================================
// OPTIMIZED FLATLIST
// ==========================================

import React, { memo, useCallback, useMemo } from 'react';
import { FlatList, View, Text, StyleSheet, ListRenderItem } from 'react-native';
import { FlashList } from '@shopify/flash-list';

interface Product {
  id: string;
  name: string;
  price: number;
  image: string;
}

// Memoized list item
const ProductItem = memo(function ProductItem({
  item,
  onPress,
}: {
  item: Product;
  onPress: (id: string) => void;
}) {
  const handlePress = useCallback(() => {
    onPress(item.id);
  }, [item.id, onPress]);
  
  return (
    <TouchableOpacity style={styles.item} onPress={handlePress}>
      <Image source={{ uri: item.image }} style={styles.image} />
      <Text style={styles.name}>{item.name}</Text>
      <Text style={styles.price}>${item.price}</Text>
    </TouchableOpacity>
  );
});

export function ProductList({ products }: { products: Product[] }) {
  // Stable callback reference
  const handlePress = useCallback((id: string) => {
    navigation.navigate('ProductDetail', { id });
  }, []);
  
  // Stable renderItem reference
  const renderItem: ListRenderItem<Product> = useCallback(({ item }) => (
    <ProductItem item={item} onPress={handlePress} />
  ), [handlePress]);
  
  // Stable keyExtractor
  const keyExtractor = useCallback((item: Product) => item.id, []);
  
  // Memoized item layout (if fixed height)
  const getItemLayout = useCallback(
    (_: any, index: number) => ({
      length: ITEM_HEIGHT,
      offset: ITEM_HEIGHT * index,
      index,
    }),
    []
  );
  
  return (
    <FlatList
      data={products}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      getItemLayout={getItemLayout}
      // Performance optimizations
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      windowSize={5}
      initialNumToRender={10}
      updateCellsBatchingPeriod={50}
      // Empty state
      ListEmptyComponent={<EmptyState />}
      // Header/Footer
      ListHeaderComponent={<ListHeader />}
      // Separators
      ItemSeparatorComponent={() => <View style={styles.separator} />}
    />
  );
}


// ==========================================
// FLASHLIST (Better performance)
// ==========================================

export function ProductFlashList({ products }: { products: Product[] }) {
  const handlePress = useCallback((id: string) => {
    navigation.navigate('ProductDetail', { id });
  }, []);
  
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => <ProductItem item={item} onPress={handlePress} />}
      estimatedItemSize={100}  // Required!
      keyExtractor={(item) => item.id}
    />
  );
}

const ITEM_HEIGHT = 80;
```

### Image Optimization
```tsx
// ==========================================
// OPTIMIZED IMAGE LOADING
// ==========================================

import FastImage from 'react-native-fast-image';

interface OptimizedImageProps {
  uri: string;
  width: number;
  height: number;
  priority?: 'low' | 'normal' | 'high';
}

export function OptimizedImage({ uri, width, height, priority = 'normal' }: OptimizedImageProps) {
  // Generate optimized URL (if using image CDN)
  const optimizedUri = useMemo(() => {
    return `${uri}?w=${width * 2}&h=${height * 2}&format=webp&q=80`;
  }, [uri, width, height]);
  
  return (
    <FastImage
      style={{ width, height }}
      source={{
        uri: optimizedUri,
        priority: FastImage.priority[priority],
        cache: FastImage.cacheControl.immutable,
      }}
      resizeMode={FastImage.resizeMode.cover}
    />
  );
}


// ==========================================
// LAZY IMAGE WITH PLACEHOLDER
// ==========================================

export function LazyImage({ uri, style }: { uri: string; style: any }) {
  const [loaded, setLoaded] = useState(false);
  const opacity = useSharedValue(0);
  
  const handleLoad = () => {
    setLoaded(true);
    opacity.value = withTiming(1, { duration: 300 });
  };
  
  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
  }));
  
  return (
    <View style={style}>
      {!loaded && <PlaceholderShimmer style={StyleSheet.absoluteFill} />}
      <Animated.View style={[StyleSheet.absoluteFill, animatedStyle]}>
        <FastImage
          source={{ uri }}
          style={StyleSheet.absoluteFill}
          onLoad={handleLoad}
        />
      </Animated.View>
    </View>
  );
}
```

---

## 7) Testing

### Component Testing
```tsx
// ==========================================
// COMPONENT TESTS
// ==========================================

import React from 'react';
import { render, fireEvent, screen, waitFor } from '@testing-library/react-native';
import { Button } from '../Button';
import { LoginScreen } from '../LoginScreen';

describe('Button', () => {
  it('renders correctly with title', () => {
    render(<Button title="Press me" onPress={() => {}} />);
    
    expect(screen.getByText('Press me')).toBeTruthy();
  });
  
  it('calls onPress when pressed', () => {
    const onPress = jest.fn();
    render(<Button title="Press me" onPress={onPress} />);
    
    fireEvent.press(screen.getByText('Press me'));
    
    expect(onPress).toHaveBeenCalledTimes(1);
  });
  
  it('shows loading indicator when loading', () => {
    render(<Button title="Press me" onPress={() => {}} loading />);
    
    expect(screen.queryByText('Press me')).toBeNull();
    expect(screen.getByTestId('activity-indicator')).toBeTruthy();
  });
  
  it('is disabled when disabled prop is true', () => {
    const onPress = jest.fn();
    render(<Button title="Press me" onPress={onPress} disabled />);
    
    fireEvent.press(screen.getByText('Press me'));
    
    expect(onPress).not.toHaveBeenCalled();
  });
});


// ==========================================
// SCREEN TESTS WITH MOCKS
// ==========================================

import { NavigationContainer } from '@react-navigation/native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });
  
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <NavigationContainer>
        {children}
      </NavigationContainer>
    </QueryClientProvider>
  );
};

describe('LoginScreen', () => {
  it('shows validation errors for empty fields', async () => {
    render(<LoginScreen />, { wrapper: createWrapper() });
    
    fireEvent.press(screen.getByText('Login'));
    
    await waitFor(() => {
      expect(screen.getByText('Email is required')).toBeTruthy();
      expect(screen.getByText('Password is required')).toBeTruthy();
    });
  });
  
  it('submits form with valid credentials', async () => {
    const mockLogin = jest.fn().mockResolvedValue({ user: {}, token: 'token' });
    
    render(<LoginScreen />, { wrapper: createWrapper() });
    
    fireEvent.changeText(screen.getByPlaceholderText('Email'), 'test@example.com');
    fireEvent.changeText(screen.getByPlaceholderText('Password'), 'password123');
    fireEvent.press(screen.getByText('Login'));
    
    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'password123');
    });
  });
});
```

---

## Best Practices Checklist

### Performance
- [ ] Use FlatList/FlashList for lists
- [ ] Memoize components and callbacks
- [ ] Enable Hermes engine
- [ ] Optimize images (WebP, sizing)
- [ ] Avoid inline styles in render

### Architecture
- [ ] Feature-based structure
- [ ] Type-safe navigation
- [ ] Proper state management
- [ ] Error boundaries

### UX
- [ ] Support dark mode
- [ ] Handle loading states
- [ ] Implement pull-to-refresh
- [ ] Support offline mode

### Quality
- [ ] TypeScript strict mode
- [ ] Unit tests for components
- [ ] E2E tests for flows
- [ ] Handle permissions gracefully

---

**References:**
- [React Native Documentation](https://reactnative.dev/docs/)
- [React Navigation](https://reactnavigation.org/docs/)
- [Reanimated](https://docs.swmansion.com/react-native-reanimated/)
