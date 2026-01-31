---
technology: React Native
version: 0.73+
last_updated: 2026-01-16
official_docs: https://reactnative.dev
---

# React Native - Best Practices & Conventions

**Version:** React Native 0.73+  
**Updated:** 2026-01-16  
**Source:** Official React Native docs + community best practices

---

## Overview

React Native enables building native mobile apps using React and JavaScript. Write once, deploy to iOS and Android with native performance.

---

## Project Structure

```
MyApp/
├── src/
│   ├── components/     # Reusable components
│   ├── screens/        # Screen components
│   ├── navigation/     # Navigation setup
│   ├── store/          # State management
│   ├── services/       # API services
│   ├── hooks/          # Custom hooks
│   ├── utils/          # Utilities
│   └── types/          # TypeScript types
├── ios/                # iOS native code
├── android/            # Android native code
└── app.json
```

---

## Navigation (React Navigation)

### Stack Navigation

```typescript
import { createNativeStackNavigator } from '@react-navigation/native-stack';

type RootStackParamList = {
  Home: undefined;
  Profile: { userId: string };
  Settings: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Profile" component={ProfileScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### Tab Navigation

```typescript
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

const Tab = createBottomTabNavigator();

export default function TabNavigator() {
  return (
    <Tab.Navigator>
      <Tab.Screen 
        name="Home" 
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Icon name="home" size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}
```

---

## State Management

### Zustand (Recommended - Simple)

```typescript
import create from 'zustand';

interface UserStore {
  user: User | null;
  setUser: (user: User) => void;
  logout: () => void;
}

export const useUserStore = create<UserStore>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
}));

// Usage
function ProfileScreen() {
  const user = useUserStore((state) => state.user);
  const logout = useUserStore((state) => state.logout);
  
  return <Text>{user?.name}</Text>;
}
```

### Redux Toolkit (Complex apps)

```typescript
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface UserState {
  user: User | null;
  loading: boolean;
}

const userSlice = createSlice({
  name: 'user',
  initialState: { user: null, loading: false } as UserState,
  reducers: {
    setUser: (state, action: PayloadAction<User>) => {
      state.user = action.payload;
    },
  },
});

export const { setUser } = userSlice.actions;
export default userSlice.reducer;
```

---

## Performance Optimization

### FlatList for Lists

```typescript
// ✅ Good - Use FlatList for large lists
<FlatList
  data={items}
  keyExtractor={(item) => item.id}
  renderItem={({ item }) => <ItemCard item={item} />}
  removeClippedSubviews={true}
  maxToRenderPerBatch={10}
  windowSize={5}
/>

// ❌ Bad - ScrollView for large lists
<ScrollView>
  {items.map(item => <ItemCard key={item.id} item={item} />)}
</ScrollView>
```

### Memoization

```typescript
import React, { memo, useMemo, useCallback } from 'react';

// ✅ Memo for expensive components
const ItemCard = memo(({ item }: { item: Item }) => {
  return <View>...</View>;
});

// ✅ useMemo for expensive calculations
function ListScreen({ items }: { items: Item[] }) {
  const sortedItems = useMemo(
    () => items.sort((a, b) => a.name.localeCompare(b.name)),
    [items]
  );
  
  const handlePress = useCallback((id: string) => {
    navigate('Detail', { id });
  }, [navigate]);
  
  return <FlatList data={sortedItems} />;
}
```

### Image Optimization

```typescript
// ✅ Use FastImage for better performance
import FastImage from 'react-native-fast-image';

<FastImage
  source={{ uri: imageUrl, priority: FastImage.priority.normal }}
  resizeMode={FastImage.resizeMode.cover}
  style={{ width: 200, height: 200 }}
/>

// ✅ Lazy load images
<Image 
  source={{ uri: imageUrl }}
  loadingIndicatorSource={require('./placeholder.png')}
/>
```

---

## Styling

### StyleSheet (Preferred)

```typescript
import { StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
});

// Usage
<View style={styles.container}>
  <Text style={styles.title}>Title</Text>
</View>
```

### Responsive Design

```typescript
import { Dimensions, Platform } from 'react-native';

const { width, height } = Dimensions.get('window');

const styles = StyleSheet.create({
  container: {
    width: width * 0.9,
    padding: Platform.select({ ios: 16, android: 12 }),
  },
});
```

---

## Native Modules Integration

### Platform-Specific Code

```typescript
import { Platform } from 'react-native';

// ✅ Platform.select
const styles = StyleSheet.create({
  container: {
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
      },
      android: {
        elevation: 4,
      },
    }),
  },
});

// ✅ Platform.OS
if (Platform.OS === 'ios') {
  // iOS-specific code
}
```

### Linking Native Libraries

```typescript
import { NativeModules } from 'react-native';

const { CalendarModule } = NativeModules;

// Call native method
CalendarModule.createEvent('Party', '123 Main St');
```

---

## API Integration

### Axios with Interceptors

```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.example.com',
});

api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      logout();
    }
    return Promise.reject(error);
  }
);
```

### TanStack Query (React Query)

```typescript
import { useQuery } from '@tanstack/react-query';

function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => api.get(`/users/${userId}`),
  });
  
  if (isLoading) return <ActivityIndicator />;
  if (error) return <Text>Error loading user</Text>;
  
  return <Text>{data.name}</Text>;
}
```

---

## Testing

### Jest + React Native Testing Library

```typescript
import { render, fireEvent } from '@testing-library/react-native';

describe('LoginScreen', () => {
  it('submits form with credentials', () => {
    const onSubmit = jest.fn();
    const { getByPlaceholderText, getByText } = render(
      <LoginScreen onSubmit={onSubmit} />
    );
    
    fireEvent.changeText(
      getByPlaceholderText('Email'),
      'test@example.com'
    );
    fireEvent.press(getByText('Login'));
    
    expect(onSubmit).toHaveBeenCalled();
  });
});
```

### Detox (E2E Testing)

```javascript
describe('Login flow', () => {
  it('should login successfully', async () => {
    await element(by.id('email-input')).typeText('user@example.com');
    await element(by.id('password-input')).typeText('password');
    await element(by.id('login-button')).tap();
    
    await expect(element(by.id('home-screen'))).toBeVisible();
  });
});
```

---

## Internationalization (i18n)

```typescript
import i18n from 'i18next';
import { initReactI18next, useTranslation } from 'react-i18next';

i18n.use(initReactI18next).init({
  resources: {
    en: { translation: { welcome: 'Welcome' } },
    vi: { translation: { welcome: 'Chào mừng' } },
  },
  lng: 'en',
  fallbackLng: 'en',
});

function WelcomeScreen() {
  const { t } = useTranslation();
  return <Text>{t('welcome')}</Text>;
}
```

---

## Push Notifications

```typescript
import messaging from '@react-native-firebase/messaging';

async function requestPermission() {
  const authStatus = await messaging().requestPermission();
  const enabled =
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL;
  
  if (enabled) {
    const token = await messaging().getToken();
    // Send token to server
  }
}

messaging().onMessage(async (remoteMessage) => {
  // Handle foreground notification
});
```

---

## Anti-Patterns to Avoid

❌ **ScrollView for long lists** → Use FlatList  
❌ **Inline styles** → Use StyleSheet  
❌ **Not memoizing** → Use memo, useMemo  
❌ **Large images** → Optimize and lazy load  
❌ **No error boundaries** → Catch errors  
❌ **Blocking main thread** → Use background tasks  
❌ **No TypeScript** → Type safety critical

---

## Best Practices

✅ **FlatList** for lists  
✅ **Memoization** (React.memo, useMemo)  
✅ **Image optimization** (resize, WebP)  
✅ **Code splitting** where possible  
✅ **Secure storage** for sensitive data  
✅ **TypeScript** for type safety  
✅ **Hermes engine** for performance  
✅ **Flipper** for profiling  
✅ **Native driver** for animations  
✅ **InteractionManager** for heavy work  
✅ **Batch native calls** for efficiency

---

**References:**
- [React Native Docs](https://reactnative.dev/)
- [React Navigation](https://reactnavigation.org/)
- [Expo](https://docs.expo.dev/)
