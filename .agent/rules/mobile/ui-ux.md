# Mobile UI/UX Best Practices Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Platforms:** iOS 17+ | Android 14+  
> **Priority:** P0 - Load for mobile design/development

---

You are an expert in Mobile UI/UX design and implementation.

## Core Principles

- Design for touch (fingers are not cursors)
- Content first, chrome second
- Consistency within platform (iOS vs Android)
- Accessibility is not optional

---

## 1) Touch Interaction

### Touch Target Guidelines
```
┌─────────────────────────────────────────┐
│          MINIMUM TOUCH TARGETS          │
├─────────────────────────────────────────┤
│                                         │
│  iOS: 44pt × 44pt minimum               │
│  Android: 48dp × 48dp minimum           │
│                                         │
│  ┌──────────────┐                       │
│  │              │ ← Visual: 24×24       │
│  │   ┌────┐     │                       │
│  │   │icon│     │ ← Touch: 48×48        │
│  │   └──┘     │                       │
│  │              │                       │
│  └───────────┘                       │
│                                         │
│  Spacing between targets: min 8pt/dp    │
│                                         │
└──────────────────────────────────────┘
```

### React Native Implementation
```tsx
// ==========================================
// ACCESSIBLE TOUCH TARGETS
// ==========================================

import { Pressable, StyleSheet, View } from 'react-native';

interface TouchableProps {
  children: React.ReactNode;
  onPress: () => void;
  accessibilityLabel: string;
  accessibilityHint?: string;
  hitSlop?: number;
}

export function Touchable({
  children,
  onPress,
  accessibilityLabel,
  accessibilityHint,
  hitSlop = 8,
}: TouchableProps) {
  return (
    <Pressable
      onPress={onPress}
      accessibilityLabel={accessibilityLabel}
      accessibilityHint={accessibilityHint}
      accessibilityRole="button"
      hitSlop={hitSlop}  // Extends touch area
      style={({ pressed }) => [
        styles.touchable,
        pressed && styles.pressed,
      ]}
    >
      {children}
    </Pressable>
  );
}

// Icon button with proper touch target
export function IconButton({
  icon,
  onPress,
  accessibilityLabel,
  size = 24,
}: {
  icon: React.ReactNode;
  onPress: () => void;
  accessibilityLabel: string;
  size?: number;
}) {
  return (
    <Pressable
      onPress={onPress}
      accessibilityLabel={accessibilityLabel}
      accessibilityRole="button"
      style={styles.iconButton}  // 48x48 minimum
    >
      <View style={{ width: size, height: size }}>
        {icon}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  touchable: {
    minWidth: 48,
    minHeight: 48,
    justifyContent: 'center',
    alignItems: 'center',
  },
  pressed: {
    opacity: 0.7,
  },
  iconButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
```

### Thumb Zone Design
```
┌─────────────────────────────────────────┐
│            REACHABILITY ZONES           │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────┐               │
│  │  ░░░░░░░░░░░░░░░░░  │ ← Hard to     │
│  │  ░░░ STRETCH ░░░░░  │   reach       │
│  │  ░░░░░░░░░░░░░░░░░  │               │
│  ├─────────────────────┤               │
│  │  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │ ← OK reach   │
│  │  ▓▓▓ NATURAL ▓▓▓▓▓  │               │
│  │  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │               │
│  ├─────────────────────┤               │
│  │  ███████████████████ │ ← Easy       │
│  │  ████ PRIMARY ██████ │   reach      │
│  │  ███████████████████ │               │
│  └──────────────────┘               │
│            👍                           │
│                                         │
│  DESIGN IMPLICATIONS:                   │
│  • Primary actions at bottom           │
│  • Navigation tabs at bottom           │
│  • FAB in bottom-right corner          │
│  • Secondary actions can go higher     │
│                                         │
└──────────────────────────────────────┘
```

---

## 2) Navigation Patterns

### Platform Comparison
```
┌─────────────────────────────────────────────────────────────┐
│                    NAVIGATION PATTERNS                       │
├─────────────────────────┬───────────────────────────────────┤
│         iOS             │            Android                │
├─────────────────────────┼───────────────────────────────────┤
│                         │                                   │
│  Tab Bar (Bottom)       │  Bottom Navigation                │
│  ┌─────────────────┐    │  ┌─────────────────┐              │
│  │                 │    │  │                 │              │
│  │     Content     │    │  │     Content     │              │
│  │                 │    │  │                 │              │
│  ├─────────────────┤    │  ├─────────────────┤              │
│  │ 🏠  🔍  👤  ⚙️  │    │  │ 🏠  🔍  👤  ⚙️  │              │
│  └──────────────┘    │  └──────────────┘              │
│                         │                                   │
│  Navigation Bar (Top)   │  App Bar / Top App Bar           │
│  ┌─────────────────┐    │  ┌─────────────────┐              │
│  │ ← Title    ⋯   │    │  │ ← Title     ⋮   │              │
│  └──────────────┘    │  └──────────────┘              │
│                         │                                   │
│  Back: Edge swipe       │  Back: System button/gesture     │
│  Dismiss: Swipe down    │  Dismiss: Back button            │
│                         │                                   │
│  Modal: Sheet/Fullscreen│  Modal: Dialog/Bottom Sheet     │
│                         │                                   │
└──────────────────────┴───────────────────────────────────┘
```

### Tab Navigation Best Practices
```tsx
// ==========================================
// BOTTOM TAB NAVIGATION
// ==========================================

// React Native (React Navigation)
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

const Tab = createBottomTabNavigator();

export function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: '#8E8E93',
        tabBarStyle: {
          paddingTop: 8,
          paddingBottom: Platform.OS === 'ios' ? 24 : 8,
          height: Platform.OS === 'ios' ? 84 : 64,
        },
        tabBarLabelStyle: {
          fontSize: 10,
          fontWeight: '500',
        },
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <HomeIcon color={color} size={size} />
          ),
          tabBarAccessibilityLabel: 'Home tab',
        }}
      />
      {/* Max 5 tabs for mobile */}
    </Tab.Navigator>
  );
}


// ==========================================
// NAVIGATION HIERARCHY
// ==========================================

/*
GOOD: Shallow hierarchy (2-3 levels)
┌─────────────────┐
│     Home        │ ← Level 1
│  ├── Products   │ ← Level 2
│  │   └── Detail │ ← Level 3
│  └── Settings   │
└──────────────┘

BAD: Deep hierarchy (5+ levels)
┌─────────────────┐
│     Home        │ ← Level 1
│  └── Category   │ ← Level 2
│      └── Sub    │ ← Level 3
│          └── Sub│ ← Level 4
│              └──│ ← Level 5 (TOO DEEP!)
└──────────────┘
*/
```

---

## 3) Visual Design Tokens

### Typography Scale
```typescript
// ==========================================
// MOBILE TYPOGRAPHY SCALE
// ==========================================

export const typography = {
  // iOS / Android equivalents
  largeTitle: {
    fontSize: 34,
    lineHeight: 41,
    fontWeight: '700',  // Bold
    letterSpacing: 0.37,
  },
  title1: {
    fontSize: 28,
    lineHeight: 34,
    fontWeight: '700',
  },
  title2: {
    fontSize: 22,
    lineHeight: 28,
    fontWeight: '700',
  },
  title3: {
    fontSize: 20,
    lineHeight: 25,
    fontWeight: '600',  // Semibold
  },
  headline: {
    fontSize: 17,
    lineHeight: 22,
    fontWeight: '600',
  },
  body: {
    fontSize: 17,       // Minimum for readability
    lineHeight: 22,
    fontWeight: '400',  // Regular
  },
  callout: {
    fontSize: 16,
    lineHeight: 21,
    fontWeight: '400',
  },
  subhead: {
    fontSize: 15,
    lineHeight: 20,
    fontWeight: '400',
  },
  footnote: {
    fontSize: 13,
    lineHeight: 18,
    fontWeight: '400',
  },
  caption1: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '400',
  },
  caption2: {
    fontSize: 11,       // Absolute minimum
    lineHeight: 13,
    fontWeight: '400',
  },
} as const;

// Dynamic type support
export function useScaledFontSize(baseSize: number): number {
  const { fontScale } = useWindowDimensions();
  return Math.round(baseSize * fontScale);
}
```

### Color System
```typescript
// ==========================================
// ACCESSIBLE COLOR PALETTE
// ==========================================

export const colors = {
  light: {
    // Semantic colors
    primary: '#007AFF',       // iOS Blue
    secondary: '#5856D6',     // Purple
    success: '#34C759',       // Green
    warning: '#FF9500',       // Orange
    error: '#FF3B30',         // Red
    
    // Text colors
    text: {
      primary: '#000000',     // Contrast: 21:1
      secondary: '#3C3C43',   // 60% opacity
      tertiary: '#3C3C4399',  // 30% opacity
      disabled: '#3C3C434D',  // 18% opacity
    },
    
    // Background colors
    background: {
      primary: '#FFFFFF',
      secondary: '#F2F2F7',
      tertiary: '#FFFFFF',
      grouped: '#F2F2F7',
    },
    
    // Border/Separator
    separator: '#3C3C4349',   // 29%
    border: '#C6C6C8',
  },
  
  dark: {
    primary: '#0A84FF',       // Brighter for dark
    secondary: '#5E5CE6',
    success: '#30D158',
    warning: '#FF9F0A',
    error: '#FF453A',
    
    text: {
      primary: '#FFFFFF',
      secondary: '#EBEBF599',
      tertiary: '#EBEBF54D',
      disabled: '#EBEBF530',
    },
    
    background: {
      primary: '#000000',
      secondary: '#1C1C1E',
      tertiary: '#2C2C2E',
      grouped: '#1C1C1E',
    },
    
    separator: '#54545899',
    border: '#38383A',
  },
};

// WCAG Contrast Requirements
/*
┌─────────────────────────────────────────┐
│         CONTRAST RATIOS (WCAG)          │
├─────────────────────────────────────────┤
│                                         │
│  Normal Text: 4.5:1 minimum (AA)        │
│  Large Text (18pt+): 3:1 minimum        │
│  UI Components: 3:1 minimum             │
│                                         │
│  AAA (enhanced):                        │
│  Normal Text: 7:1                       │
│  Large Text: 4.5:1                      │
│                                         │
└──────────────────────────────────────┘
*/
```

### Spacing System
```typescript
// ==========================================
// CONSISTENT SPACING
// ==========================================

export const spacing = {
  // Base unit: 4pt/dp
  xxs: 2,
  xs: 4,
  sm: 8,
  md: 12,
  base: 16,    // Standard padding
  lg: 20,
  xl: 24,
  xxl: 32,
  xxxl: 40,
  
  // Common patterns
  screenPadding: 16,
  cardPadding: 16,
  listItemPadding: 12,
  sectionSpacing: 24,
  
  // Safe areas (handled by platform)
  safeAreaTop: 'auto',
  safeAreaBottom: 'auto',
} as const;

// Usage in components
const styles = StyleSheet.create({
  container: {
    padding: spacing.base,
    gap: spacing.md,
  },
  card: {
    padding: spacing.cardPadding,
    marginBottom: spacing.base,
  },
});
```

---

## 4) State UI Components

### Loading States
```tsx
// ==========================================
// SKELETON LOADING (Preferred)
// ==========================================

import { View, StyleSheet } from 'react-native';
import Animated, {
  useAnimatedStyle,
  withRepeat,
  withTiming,
  useSharedValue,
} from 'react-native-reanimated';

export function Skeleton({
  width,
  height,
  borderRadius = 4,
}: {
  width: number | string;
  height: number;
  borderRadius?: number;
}) {
  const opacity = useSharedValue(0.3);
  
  React.useEffect(() => {
    opacity.value = withRepeat(
      withTiming(1, { duration: 1000 }),
      -1,  // Infinite
      true // Reverse
    );
  }, []);
  
  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
  }));
  
  return (
    <Animated.View
      style={[
        styles.skeleton,
        { width, height, borderRadius },
        animatedStyle,
      ]}
    />
  );
}

// Card skeleton example
export function ProductCardSkeleton() {
  return (
    <View style={styles.card}>
      <Skeleton width="100%" height={150} borderRadius={8} />
      <View style={styles.content}>
        <Skeleton width="80%" height={20} />
        <Skeleton width="60%" height={16} />
        <Skeleton width="40%" height={24} />
      </View>
    </View>
  );
}

// List skeleton
export function ProductListSkeleton() {
  return (
    <View style={styles.list}>
      {[...Array(5)].map((_, i) => (
        <ProductCardSkeleton key={i} />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  skeleton: {
    backgroundColor: '#E1E1E1',
  },
  card: {
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 16,
  },
  content: {
    padding: 12,
    gap: 8,
  },
  list: {
    padding: 16,
  },
});
```

### Error States
```tsx
// ==========================================
// ERROR STATE COMPONENT
// ==========================================

interface ErrorStateProps {
  title?: string;
  message: string;
  onRetry?: () => void;
  retryLabel?: string;
  icon?: React.ReactNode;
}

export function ErrorState({
  title = 'Something went wrong',
  message,
  onRetry,
  retryLabel = 'Try Again',
  icon,
}: ErrorStateProps) {
  return (
    <View style={styles.container}>
      {icon ?? (
        <View style={styles.iconContainer}>
          <AlertCircleIcon size={48} color="#FF3B30" />
        </View>
      )}
      
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.message}>{message}</Text>
      
      {onRetry && (
        <Pressable
          onPress={onRetry}
          style={styles.retryButton}
          accessibilityLabel={retryLabel}
          accessibilityRole="button"
        >
          <RefreshIcon size={20} color="#007AFF" />
          <Text style={styles.retryText}>{retryLabel}</Text>
        </Pressable>
      )}
    </View>
  );
}

// Network error variant
export function NetworkErrorState({ onRetry }: { onRetry?: () => void }) {
  return (
    <ErrorState
      title="No Internet Connection"
      message="Please check your connection and try again."
      onRetry={onRetry}
      icon={<WifiOffIcon size={48} color="#FF9500" />}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  iconContainer: {
    marginBottom: 16,
  },
  title: {
    fontSize: 20,
    fontWeight: '600',
    color: '#000',
    marginBottom: 8,
    textAlign: 'center',
  },
  message: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 24,
  },
  retryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
    backgroundColor: '#F2F2F7',
  },
  retryText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#007AFF',
  },
});
```

### Empty States
```tsx
// ==========================================
// EMPTY STATE COMPONENT
// ==========================================

interface EmptyStateProps {
  icon: React.ReactNode;
  title: string;
  message: string;
  action?: {
    label: string;
    onPress: () => void;
  };
}

export function EmptyState({
  icon,
  title,
  message,
  action,
}: EmptyStateProps) {
  return (
    <View style={styles.container}>
      <View style={styles.iconWrapper}>
        {icon}
      </View>
      
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.message}>{message}</Text>
      
      {action && (
        <Button
          title={action.label}
          onPress={action.onPress}
          variant="primary"
        />
      )}
    </View>
  );
}

// Specific empty states
export function NoResultsState({ query }: { query: string }) {
  return (
    <EmptyState
      icon={<SearchIcon size={48} color="#8E8E93" />}
      title="No Results"
      message={`We couldn't find anything for "${query}". Try a different search.`}
    />
  );
}

export function EmptyCartState({ onBrowse }: { onBrowse: () => void }) {
  return (
    <EmptyState
      icon={<ShoppingBagIcon size={48} color="#8E8E93" />}
      title="Your Cart is Empty"
      message="Add items to get started with your order."
      action={{
        label: 'Browse Products',
        onPress: onBrowse,
      }}
    />
  );
}

export function NoNotificationsState() {
  return (
    <EmptyState
      icon={<BellIcon size={48} color="#8E8E93" />}
      title="No Notifications"
      message="When you receive notifications, they'll appear here."
    />
  );
}
```

---

## 5) Accessibility

### Screen Reader Support
```tsx
// ==========================================
// ACCESSIBILITY IMPLEMENTATION
// ==========================================

// React Native
import { AccessibilityInfo, View, Text } from 'react-native';

// Accessible component
export function ProductCard({ product }: { product: Product }) {
  const priceFormatted = `$${product.price.toFixed(2)}`;
  
  return (
    <Pressable
      // Combined accessibility label
      accessibilityLabel={`${product.name}, ${priceFormatted}`}
      accessibilityHint="Double tap to view product details"
      accessibilityRole="button"
      // Group elements for screen reader
      accessible={true}
      onPress={() => navigateToProduct(product.id)}
    >
      <Image
        source={{ uri: product.imageUrl }}
        // Decorative images get null accessibilityLabel
        accessibilityElementsHidden={true}
        importantForAccessibility="no"
      />
      
      <View>
        <Text accessibilityRole="header">{product.name}</Text>
        <Text>{priceFormatted}</Text>
      </View>
    </Pressable>
  );
}

// Announce changes to screen reader
function SearchResults({ results, query }: Props) {
  useEffect(() => {
    const message = results.length === 0
      ? `No results found for ${query}`
      : `${results.length} results for ${query}`;
    
    AccessibilityInfo.announceForAccessibility(message);
  }, [results.length, query]);
  
  return <FlatList data={results} ... />;
}


// ==========================================
// DYNAMIC TYPE / FONT SCALING
// ==========================================

// Support larger accessibility sizes
export function ScalableText({ 
  style, 
  children,
  maxFontScale = 2,  // Limit max scaling
}: Props) {
  return (
    <Text
      style={style}
      maxFontSizeMultiplier={maxFontScale}
      // Or disable entirely (not recommended)
      // allowFontScaling={false}
    >
      {children}
    </Text>
  );
}

// Use in layouts that can break with large text
export function FixedHeightRow({ label, value }: Props) {
  return (
    <View style={styles.row}>
      <Text 
        style={styles.label}
        maxFontSizeMultiplier={1.5}  // Limit to 150%
        numberOfLines={1}
      >
        {label}
      </Text>
      <Text 
        style={styles.value}
        maxFontSizeMultiplier={1.5}
        numberOfLines={1}
      >
        {value}
      </Text>
    </View>
  );
}
```

### Accessibility Checklist
```
┌─────────────────────────────────────────┐
│       ACCESSIBILITY CHECKLIST           │
├─────────────────────────────────────────┤
│                                         │
│  TOUCH:                                 │
│  ✓ Min 44pt/48dp touch targets         │
│  ✓ Adequate spacing (8pt min)          │
│  ✓ Hit slop for small icons           │
│                                         │
│  VISUAL:                                │
│  ✓ Color contrast 4.5:1 (text)         │
│  ✓ Color contrast 3:1 (UI)             │
│  ✓ Not color-only information          │
│  ✓ Focus indicators visible            │
│                                         │
│  SCREEN READERS:                        │
│  ✓ All interactive elements labeled    │
│  ✓ Images have alt text               │
│  ✓ Decorative images hidden           │
│  ✓ Logical reading order              │
│  ✓ Dynamic changes announced          │
│                                         │
│  TEXT:                                  │
│  ✓ Support Dynamic Type                │
│  ✓ Min 11pt font size                  │
│  ✓ Readable line height (1.3x)         │
│                                         │
│  MOTION:                                │
│  ✓ Respect reduce motion setting       │
│  ✓ No auto-playing animations          │
│  ✓ Pause/stop controls available       │
│                                         │
└──────────────────────────────────────┘
```

---

## 6) Micro-Interactions

### Animation Patterns
```tsx
// ==========================================
// HAPTIC FEEDBACK
// ==========================================

import * as Haptics from 'expo-haptics';
// Or: import { trigger } from 'react-native-haptic-feedback';

// Use haptics for:
// - Button taps (light)
// - Toggle changes (medium)
// - Destructive actions (heavy)
// - Success/error (notification)

export function HapticButton({ onPress, hapticType = 'light', ...props }) {
  const handlePress = () => {
    switch (hapticType) {
      case 'light':
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        break;
      case 'medium':
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
        break;
      case 'success':
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
        break;
      case 'error':
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
        break;
    }
    onPress();
  };
  
  return <Button {...props} onPress={handlePress} />;
}


// ==========================================
// ANIMATED INTERACTIONS
// ==========================================

import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withSequence,
  withTiming,
} from 'react-native-reanimated';

// Like button with animation
export function LikeButton({ isLiked, onToggle }: Props) {
  const scale = useSharedValue(1);
  
  const handlePress = () => {
    // Bounce animation
    scale.value = withSequence(
      withSpring(1.3, { damping: 2 }),
      withSpring(1, { damping: 4 })
    );
    
    // Haptic feedback
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    
    onToggle();
  };
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));
  
  return (
    <Pressable onPress={handlePress}>
      <Animated.View style={animatedStyle}>
        <HeartIcon
          size={24}
          fill={isLiked ? '#FF3B30' : 'none'}
          color={isLiked ? '#FF3B30' : '#8E8E93'}
        />
      </Animated.View>
    </Pressable>
  );
}

// Pull to refresh indicator
export function PullToRefresh({ onRefresh, children }: Props) {
  const translateY = useSharedValue(0);
  const isRefreshing = useSharedValue(false);
  
  // Custom pull to refresh with smooth animation
  const gesture = Gesture.Pan()
    .onUpdate((e) => {
      if (e.translationY > 0 && !isRefreshing.value) {
        translateY.value = Math.min(e.translationY * 0.5, 80);
      }
    })
    .onEnd(() => {
      if (translateY.value > 60) {
        isRefreshing.value = true;
        runOnJS(onRefresh)();
      }
      translateY.value = withSpring(0);
    });
  
  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={animatedStyle}>
        {children}
      </Animated.View>
    </GestureDetector>
  );
}


// ==========================================
// RESPECT REDUCED MOTION
// ==========================================

import { AccessibilityInfo } from 'react-native';

export function useReducedMotion() {
  const [isReducedMotion, setIsReducedMotion] = useState(false);
  
  useEffect(() => {
    AccessibilityInfo.isReduceMotionEnabled().then(setIsReducedMotion);
    
    const subscription = AccessibilityInfo.addEventListener(
      'reduceMotionChanged',
      setIsReducedMotion
    );
    
    return () => subscription.remove();
  }, []);
  
  return isReducedMotion;
}

// Usage
function AnimatedComponent() {
  const reduceMotion = useReducedMotion();
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { 
        scale: reduceMotion 
          ? 1  // No animation
          : withSpring(scale.value) 
      },
    ],
  }));
  
  return <Animated.View style={animatedStyle}>...</Animated.View>;
}
```

---

## 7) Forms & Input

### Mobile Form Patterns
```tsx
// ==========================================
// OPTIMIZED FORM INPUT
// ==========================================

interface FormInputProps {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  error?: string;
  // Keyboard types for mobile
  keyboardType?: 'default' | 'email-address' | 'numeric' | 'phone-pad' | 'decimal-pad';
  autoComplete?: 'email' | 'password' | 'name' | 'tel' | 'postal-code' | 'cc-number';
  textContentType?: 'emailAddress' | 'password' | 'newPassword' | 'name' | 'telephoneNumber';
  returnKeyType?: 'done' | 'next' | 'go' | 'search';
  onSubmitEditing?: () => void;
}

export function FormInput({
  label,
  value,
  onChangeText,
  error,
  keyboardType = 'default',
  autoComplete,
  textContentType,
  returnKeyType = 'next',
  onSubmitEditing,
}: FormInputProps) {
  return (
    <View style={styles.container}>
      <Text style={styles.label}>{label}</Text>
      <TextInput
        value={value}
        onChangeText={onChangeText}
        style={[styles.input, error && styles.inputError]}
        // Mobile optimizations
        keyboardType={keyboardType}
        autoComplete={autoComplete}             // Android autofill
        textContentType={textContentType}       // iOS autofill
        returnKeyType={returnKeyType}
        onSubmitEditing={onSubmitEditing}
        blurOnSubmit={returnKeyType === 'done'}
        // Accessibility
        accessibilityLabel={label}
        accessibilityHint={error}
      />
      {error && (
        <Text style={styles.error} accessibilityRole="alert">
          {error}
        </Text>
      )}
    </View>
  );
}

// Common input configurations
export const inputConfigs = {
  email: {
    keyboardType: 'email-address',
    autoComplete: 'email',
    textContentType: 'emailAddress',
    autoCapitalize: 'none',
    autoCorrect: false,
  },
  password: {
    secureTextEntry: true,
    autoComplete: 'password',
    textContentType: 'password',
  },
  newPassword: {
    secureTextEntry: true,
    autoComplete: 'password-new',
    textContentType: 'newPassword',
  },
  phone: {
    keyboardType: 'phone-pad',
    autoComplete: 'tel',
    textContentType: 'telephoneNumber',
  },
  creditCard: {
    keyboardType: 'numeric',
    autoComplete: 'cc-number',
    textContentType: 'creditCardNumber',
  },
} as const;
```

---

## Best Practices Checklist

### Touch & Interaction
- [ ] 44pt/48dp minimum targets
- [ ] Adequate spacing (8pt+)
- [ ] Haptic feedback on actions
- [ ] Reduce motion support

### Visual Design
- [ ] 4.5:1 contrast ratio
- [ ] Dark mode support
- [ ] Consistent spacing
- [ ] Clear visual hierarchy

### Navigation
- [ ] 3 levels max depth
- [ ] Back gestures work
- [ ] Tab bar for main nav
- [ ] Clear current location

### States
- [ ] Skeleton loading
- [ ] Helpful error messages
- [ ] Actionable empty states
- [ ] Offline handling

### Accessibility
- [ ] Screen reader labels
- [ ] Dynamic Type support
- [ ] Focus management
- [ ] Semantic roles

---

**References:**
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Material Design](https://m3.material.io/)
- [WCAG Mobile Accessibility](https://www.w3.org/WAI/standards-guidelines/mobile/)
