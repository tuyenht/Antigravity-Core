# Mobile Performance Optimization Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Target:** 60fps (16ms/frame)  
> **Priority:** P0 - Load for performance issues

---

You are an expert in optimizing mobile application performance.

## Core Principles

- 60fps (16ms per frame) is the target
- Respect battery life and data usage
- Fast app launch time
- Smooth scrolling and animations

---

## 1) Performance Budgets

### Frame Budget
```
┌─────────────────────────────────────────┐
│            FRAME BUDGET                 │
├─────────────────────────────────────────┤
│                                         │
│  60 FPS = 16.67ms per frame            │
│                                         │
│  Frame breakdown:                       │
│  ┌───────────────────────────────────┐ │
│  │ JavaScript/Logic: ~10ms max       │ │
│  │ Layout/Measure:   ~2ms            │ │
│  │ Paint/Render:     ~2ms            │ │
│  │ Composite:        ~2ms            │ │
│  └───────────────────────────────────┘ │
│                                         │
│  WARNING THRESHOLDS:                    │
│  • Frame drop: >16.67ms               │
│  • Jank: >3 consecutive drops          │
│  • Freeze: >700ms                      │
│                                         │
│  120Hz DISPLAYS (iOS Pro, flagships):  │
│  Budget: 8.33ms per frame              │
│                                         │
└─────────────────────────────────────────┘
```

### Startup Time Budgets
```
┌─────────────────────────────────────────┐
│          STARTUP TIME TARGETS           │
├─────────────────────────────────────────┤
│                                         │
│  Cold Start (from kill):               │
│  ├── Excellent: <1.5s                  │
│  ├── Good:      <2.5s                  │
│  ├── Acceptable: <4s                   │
│  └── Poor:      >4s                    │
│                                         │
│  Warm Start (from background):         │
│  ├── Excellent: <500ms                 │
│  └── Acceptable: <1s                   │
│                                         │
│  Time to Interactive (TTI):            │
│  └── User can interact: <3s           │
│                                         │
└─────────────────────────────────────────┘
```

---

## 2) List Performance

### React Native Optimization
```tsx
// ==========================================
// OPTIMIZED FLATLIST
// ==========================================

import React, { memo, useCallback, useMemo } from 'react';
import { FlatList, View, StyleSheet } from 'react-native';

interface Product {
  id: string;
  name: string;
  price: number;
  image: string;
}

// ✅ Memoized list item - prevents unnecessary re-renders
const ProductItem = memo(function ProductItem({
  item,
  onPress,
}: {
  item: Product;
  onPress: (id: string) => void;
}) {
  // ✅ Stable callback reference
  const handlePress = useCallback(() => {
    onPress(item.id);
  }, [item.id, onPress]);

  return (
    <Pressable onPress={handlePress} style={styles.item}>
      <FastImage
        source={{ uri: item.image }}
        style={styles.image}
        resizeMode="cover"
      />
      <Text>{item.name}</Text>
      <Text>${item.price}</Text>
    </Pressable>
  );
});

export function ProductList({ products }: { products: Product[] }) {
  // ✅ Stable callbacks with useCallback
  const handlePress = useCallback((id: string) => {
    navigation.navigate('ProductDetail', { id });
  }, []);

  // ✅ Stable renderItem
  const renderItem = useCallback(({ item }: { item: Product }) => (
    <ProductItem item={item} onPress={handlePress} />
  ), [handlePress]);

  // ✅ Stable keyExtractor
  const keyExtractor = useCallback((item: Product) => item.id, []);

  // ✅ Fixed item height for getItemLayout
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
      getItemLayout={getItemLayout}  // ✅ Skip measurement
      
      // ✅ Performance optimizations
      removeClippedSubviews={true}   // Unmount off-screen items
      maxToRenderPerBatch={10}       // Render 10 items per batch
      windowSize={5}                  // 5 screens worth of items
      initialNumToRender={10}         // Initial visible items
      updateCellsBatchingPeriod={50}  // Batch updates
      
      // ✅ Prevent re-renders on scroll
      scrollEventThrottle={16}
      
      // ✅ Maintain scroll position
      maintainVisibleContentPosition={{
        minIndexForVisible: 0,
      }}
    />
  );
}

const ITEM_HEIGHT = 100;


// ==========================================
// FLASHLIST (Better alternative)
// ==========================================

import { FlashList } from '@shopify/flash-list';

export function OptimizedProductList({ products }: { products: Product[] }) {
  const renderItem = useCallback(({ item }: { item: Product }) => (
    <ProductItem item={item} onPress={handlePress} />
  ), []);

  return (
    <FlashList
      data={products}
      renderItem={renderItem}
      estimatedItemSize={ITEM_HEIGHT}  // Required!
      keyExtractor={(item) => item.id}
      
      // FlashList handles most optimizations automatically
      // Much better performance than FlatList for large lists
    />
  );
}


// ==========================================
// AVOID THESE ANTI-PATTERNS
// ==========================================

// ❌ BAD: Anonymous function in renderItem
<FlatList
  renderItem={({ item }) => <Item item={item} onPress={() => handlePress(item.id)} />}
/>

// ❌ BAD: Inline styles
<View style={{ padding: 16, margin: 8 }} />

// ❌ BAD: Object spread in item
<FlatList
  renderItem={({ item }) => <Item {...item} />}  // Creates new object each render
/>

// ❌ BAD: Non-primitive key
<FlatList
  keyExtractor={(item) => item}  // Object as key
/>
```

### Flutter List Optimization
```dart
// ==========================================
// OPTIMIZED LISTVIEW
// ==========================================

class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // ✅ Only build visible items
      itemCount: products.length,
      
      // ✅ Fix item height for better performance
      itemExtent: 100,  // Fixed height
      
      // ✅ Enable caching of items
      cacheExtent: 500,  // Cache 500px above/below
      
      // ✅ Add repaint boundary for complex items
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductItem(
          key: ValueKey(product.id),  // ✅ Stable key
          product: product,
        );
      },
    );
  }
}

// ✅ Const constructor for static content
class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // ✅ Const widgets where possible
    return const SizedBox(
      height: 100,
      child: Row(
        children: [
          // ...
        ],
      ),
    );
  }
}
```

---

## 3) Image Optimization

### Efficient Image Loading
```tsx
// ==========================================
// REACT NATIVE IMAGE OPTIMIZATION
// ==========================================

import FastImage from 'react-native-fast-image';

// ✅ Use FastImage for better caching
export function OptimizedImage({
  uri,
  width,
  height,
  priority = 'normal',
}: {
  uri: string;
  width: number;
  height: number;
  priority?: 'low' | 'normal' | 'high';
}) {
  // ✅ Request appropriate size from CDN
  const optimizedUri = useMemo(() => {
    const pixelRatio = PixelRatio.get();
    const w = Math.round(width * pixelRatio);
    const h = Math.round(height * pixelRatio);
    
    // Use image CDN to resize
    return `${uri}?w=${w}&h=${h}&format=webp&q=80`;
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
// PROGRESSIVE IMAGE LOADING
// ==========================================

export function ProgressiveImage({
  thumbnailUri,
  fullUri,
  style,
}: {
  thumbnailUri: string;
  fullUri: string;
  style: any;
}) {
  const thumbnailOpacity = useSharedValue(1);
  const fullOpacity = useSharedValue(0);

  const handleFullLoad = () => {
    fullOpacity.value = withTiming(1, { duration: 300 });
    thumbnailOpacity.value = withTiming(0, { duration: 300 });
  };

  return (
    <View style={style}>
      {/* Low-res thumbnail (immediate) */}
      <Animated.View style={[StyleSheet.absoluteFill, { opacity: thumbnailOpacity }]}>
        <FastImage
          source={{ uri: thumbnailUri }}
          style={StyleSheet.absoluteFill}
          resizeMode="cover"
        />
        {/* Blur placeholder */}
        <BlurView style={StyleSheet.absoluteFill} blurAmount={10} />
      </Animated.View>
      
      {/* Full resolution (lazy) */}
      <Animated.View style={[StyleSheet.absoluteFill, { opacity: fullOpacity }]}>
        <FastImage
          source={{ uri: fullUri }}
          style={StyleSheet.absoluteFill}
          resizeMode="cover"
          onLoad={handleFullLoad}
        />
      </Animated.View>
    </View>
  );
}


// ==========================================
// IMAGE PRELOADING
// ==========================================

// Preload images before they're needed
export function preloadImages(uris: string[]) {
  FastImage.preload(
    uris.map(uri => ({
      uri,
      priority: FastImage.priority.normal,
    }))
  );
}

// Preload next screen's images
useEffect(() => {
  if (nextProduct) {
    preloadImages([nextProduct.imageUrl, ...nextProduct.gallery]);
  }
}, [nextProduct]);
```

### Image Size Guidelines
```
┌─────────────────────────────────────────┐
│         IMAGE SIZE GUIDELINES           │
├─────────────────────────────────────────┤
│                                         │
│  FORMATS (in order of preference):      │
│  1. WebP - Best compression, wide support│
│  2. AVIF - Better than WebP, new       │
│  3. JPEG - Photos, no transparency      │
│  4. PNG  - Icons, transparency needed   │
│                                         │
│  RESOLUTION by use case:                │
│  ┌───────────────────────────────────┐ │
│  │ Thumbnails:  100x100 @3x          │ │
│  │ List items:  200x200 @3x          │ │
│  │ Cards:       400x300 @3x          │ │
│  │ Full screen: Device width @3x     │ │
│  └───────────────────────────────────┘ │
│                                         │
│  FILE SIZE TARGETS:                     │
│  • Thumbnails: <10KB                   │
│  • List items: <30KB                   │
│  • Full screen: <150KB                 │
│                                         │
│  QUALITY SETTINGS (WebP):              │
│  • Photos: 75-85%                      │
│  • Graphics: 85-95%                    │
│                                         │
└─────────────────────────────────────────┘
```

---

## 4) Memory Management

### Detecting Memory Leaks
```tsx
// ==========================================
// COMMON MEMORY LEAK PATTERNS
// ==========================================

// ❌ BAD: Listener not cleaned up
function BadComponent() {
  useEffect(() => {
    const subscription = eventEmitter.addListener('event', handler);
    // Missing cleanup!
  }, []);
}

// ✅ GOOD: Proper cleanup
function GoodComponent() {
  useEffect(() => {
    const subscription = eventEmitter.addListener('event', handler);
    
    return () => {
      subscription.remove();
    };
  }, []);
}


// ❌ BAD: Timer not cleared
function BadTimer() {
  useEffect(() => {
    setInterval(() => {
      doSomething();
    }, 1000);
    // Timer continues after unmount!
  }, []);
}

// ✅ GOOD: Timer cleared
function GoodTimer() {
  useEffect(() => {
    const timer = setInterval(() => {
      doSomething();
    }, 1000);
    
    return () => clearInterval(timer);
  }, []);
}


// ❌ BAD: Async state update after unmount
function BadAsync() {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    fetchData().then(result => {
      setData(result);  // May update unmounted component!
    });
  }, []);
}

// ✅ GOOD: Check if mounted
function GoodAsync() {
  const [data, setData] = useState(null);
  const isMounted = useRef(true);
  
  useEffect(() => {
    fetchData().then(result => {
      if (isMounted.current) {
        setData(result);
      }
    });
    
    return () => {
      isMounted.current = false;
    };
  }, []);
}

// ✅ BETTER: Use AbortController
function BetterAsync() {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    const controller = new AbortController();
    
    fetchData({ signal: controller.signal })
      .then(setData)
      .catch(e => {
        if (e.name !== 'AbortError') throw e;
      });
    
    return () => controller.abort();
  }, []);
}


// ==========================================
// LARGE OBJECT CLEANUP
// ==========================================

// Clear large data when leaving screen
function ProductGallery({ productId }: { productId: string }) {
  const [images, setImages] = useState<string[]>([]);
  
  useEffect(() => {
    loadImages(productId).then(setImages);
    
    return () => {
      // Clear images from memory
      setImages([]);
      
      // Clear image cache for this product
      FastImage.clearMemoryCache();
    };
  }, [productId]);
}


// ==========================================
// WEAK REFERENCES (Native)
// ==========================================

// Swift - Use weak self in closures
class ViewController: UIViewController {
    func loadData() {
        networkService.fetch { [weak self] result in
            guard let self = self else { return }
            self.updateUI(with: result)
        }
    }
}

// Kotlin - Use WeakReference
class MyViewModel : ViewModel() {
    private var weakRef: WeakReference<Callback>? = null
    
    fun setCallback(callback: Callback) {
        weakRef = WeakReference(callback)
    }
    
    fun onComplete() {
        weakRef?.get()?.onResult()
    }
}
```

### Memory Profiling
```
┌─────────────────────────────────────────┐
│         MEMORY THRESHOLDS               │
├─────────────────────────────────────────┤
│                                         │
│  HEAP SIZE TARGETS:                     │
│  ├── Normal:   <150MB                  │
│  ├── Warning:  150-250MB               │
│  └── Critical: >250MB                  │
│                                         │
│  GROWTH PATTERNS TO WATCH:             │
│  • Steady increase = memory leak       │
│  • Spikes on navigation = large objects│
│  • Never decreasing = no cleanup       │
│                                         │
│  MONITORING TOOLS:                      │
│  • React Native: Flipper Memory tab    │
│  • iOS: Xcode Instruments              │
│  • Android: Android Studio Profiler    │
│  • Cross-platform: why-did-you-render  │
│                                         │
└─────────────────────────────────────────┘
```

---

## 5) Startup Optimization

### Lazy Loading
```tsx
// ==========================================
// LAZY LOAD SCREENS
// ==========================================

import { lazy, Suspense } from 'react';

// ✅ Lazy load non-critical screens
const SettingsScreen = lazy(() => import('./SettingsScreen'));
const ProfileScreen = lazy(() => import('./ProfileScreen'));
const AnalyticsScreen = lazy(() => import('./AnalyticsScreen'));

// Eager load critical screens
import HomeScreen from './HomeScreen';
import LoginScreen from './LoginScreen';

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        {/* Critical screens - eager loaded */}
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="Home" component={HomeScreen} />
        
        {/* Non-critical - lazy loaded */}
        <Stack.Screen name="Settings">
          {() => (
            <Suspense fallback={<LoadingScreen />}>
              <SettingsScreen />
            </Suspense>
          )}
        </Stack.Screen>
      </Stack.Navigator>
    </NavigationContainer>
  );
}


// ==========================================
// DEFER NON-CRITICAL INITIALIZATION
// ==========================================

export function App() {
  useEffect(() => {
    // ✅ Initialize critical services immediately
    initializeAuth();
    initializeNavigation();
    
    // ✅ Defer non-critical initialization
    InteractionManager.runAfterInteractions(() => {
      // After UI is rendered and interactive
      initializeAnalytics();
      initializePushNotifications();
      initializeRemoteConfig();
      preloadCommonData();
    });
    
    // ✅ Even more delayed for truly optional
    setTimeout(() => {
      initializeCrashReporting();
      syncOfflineData();
    }, 3000);
  }, []);
}


// ==========================================
// OPTIMIZE BUNDLE SIZE
// ==========================================

// ✅ Import only what you need
import { format } from 'date-fns';  // Not: import * as dateFns from 'date-fns'

// ✅ Use platform-specific code splitting
import { Platform } from 'react-native';

const Camera = Platform.select({
  ios: () => require('./Camera.ios').default,
  android: () => require('./Camera.android').default,
})();
```

### Android Baseline Profiles
```kotlin
// ==========================================
// BASELINE PROFILE GENERATION
// ==========================================

// BaselineProfileGenerator.kt
@ExperimentalBaselineProfilesApi
@RunWith(AndroidJUnit4::class)
class BaselineProfileGenerator {

    @get:Rule
    val rule = BaselineProfileRule()

    @Test
    fun generateBaselineProfile() {
        rule.collectBaselineProfile(
            packageName = "com.example.app",
        ) {
            // Cold start
            pressHome()
            startActivityAndWait()
            
            // Critical user journeys
            device.findObject(By.text("Products")).click()
            device.waitForIdle()
            
            device.findObject(By.text("Search")).click()
            device.waitForIdle()
            
            // Scroll lists
            val list = device.findObject(By.scrollable(true))
            list.scroll(Direction.DOWN, 2f)
        }
    }
}

// build.gradle.kts
android {
    buildTypes {
        release {
            // Enable baseline profiles
            baselineProfile.automaticGenerationDuringBuild = true
        }
    }
}
```

---

## 6) Network Optimization

### Efficient Data Fetching
```tsx
// ==========================================
// OPTIMIZED API CLIENT
// ==========================================

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // ✅ Cache data
      staleTime: 1000 * 60 * 5,      // 5 minutes fresh
      gcTime: 1000 * 60 * 30,         // 30 minutes in cache
      
      // ✅ Retry with backoff
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      
      // ✅ Refetch strategies
      refetchOnWindowFocus: false,    // Mobile doesn't have window focus
      refetchOnReconnect: true,       // Refetch when back online
      
      // ✅ Network mode
      networkMode: 'offlineFirst',    // Use cache when offline
    },
  },
});


// ==========================================
// PREFETCHING
// ==========================================

// Prefetch next screen's data
function ProductList() {
  const queryClient = useQueryClient();
  
  const handleProductHover = (productId: string) => {
    // Prefetch product details
    queryClient.prefetchQuery({
      queryKey: ['product', productId],
      queryFn: () => fetchProduct(productId),
      staleTime: 1000 * 60 * 5,
    });
  };
  
  return (
    <FlatList
      data={products}
      renderItem={({ item }) => (
        <ProductCard
          product={item}
          onPressIn={() => handleProductHover(item.id)}
        />
      )}
    />
  );
}


// ==========================================
// PAGINATION WITH INFINITE SCROLL
// ==========================================

function InfiniteProductList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['products'],
    queryFn: ({ pageParam = 1 }) => fetchProducts(pageParam),
    getNextPageParam: (lastPage) => lastPage.nextPage,
    staleTime: 1000 * 60 * 5,
  });

  const products = useMemo(() => 
    data?.pages.flatMap(page => page.items) ?? [],
    [data]
  );

  const handleEndReached = useCallback(() => {
    if (hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  }, [hasNextPage, isFetchingNextPage, fetchNextPage]);

  return (
    <FlashList
      data={products}
      renderItem={renderItem}
      estimatedItemSize={100}
      onEndReached={handleEndReached}
      onEndReachedThreshold={0.5}  // Load more at 50% from bottom
      ListFooterComponent={
        isFetchingNextPage ? <ActivityIndicator /> : null
      }
    />
  );
}


// ==========================================
// REQUEST BATCHING
// ==========================================

import DataLoader from 'dataloader';

// Batch multiple product requests into one
const productLoader = new DataLoader(async (ids: string[]) => {
  const products = await api.getProducts({ ids });
  
  // Return in same order as requested
  const productMap = new Map(products.map(p => [p.id, p]));
  return ids.map(id => productMap.get(id) ?? null);
});

// Usage - these will be batched
await Promise.all([
  productLoader.load('product-1'),
  productLoader.load('product-2'),
  productLoader.load('product-3'),
]);
// Result: Single API call with all 3 IDs
```

---

## 7) Animation Performance

### 60fps Animations
```tsx
// ==========================================
// UI THREAD ANIMATIONS (Reanimated)
// ==========================================

import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  runOnUI,
} from 'react-native-reanimated';

// ✅ Animate on UI thread - no bridge crossing
function SmoothCard() {
  const scale = useSharedValue(1);
  
  // Runs on UI thread
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));
  
  const handlePressIn = () => {
    // UI thread animation
    scale.value = withSpring(0.95, { damping: 15 });
  };
  
  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15 });
  };
  
  return (
    <Pressable onPressIn={handlePressIn} onPressOut={handlePressOut}>
      <Animated.View style={[styles.card, animatedStyle]}>
        <Text>Smooth 60fps animation</Text>
      </Animated.View>
    </Pressable>
  );
}


// ==========================================
// GESTURE-DRIVEN ANIMATIONS
// ==========================================

import { Gesture, GestureDetector } from 'react-native-gesture-handler';

function SwipeableCard() {
  const translateX = useSharedValue(0);
  
  const gesture = Gesture.Pan()
    .onUpdate((e) => {
      // ✅ UI thread - no JS involvement
      translateX.value = e.translationX;
    })
    .onEnd((e) => {
      if (Math.abs(e.translationX) > THRESHOLD) {
        translateX.value = withSpring(
          Math.sign(e.translationX) * SCREEN_WIDTH
        );
      } else {
        translateX.value = withSpring(0);
      }
    });
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
  }));
  
  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={animatedStyle}>
        {/* Content */}
      </Animated.View>
    </GestureDetector>
  );
}


// ==========================================
// AVOID JS THREAD ANIMATIONS
// ==========================================

// ❌ BAD: Animated.timing on JS thread
Animated.timing(animatedValue, {
  toValue: 1,
  duration: 300,
  useNativeDriver: false,  // JS thread!
}).start();

// ✅ GOOD: Native driver
Animated.timing(animatedValue, {
  toValue: 1,
  duration: 300,
  useNativeDriver: true,  // UI thread
}).start();

// ✅ BETTER: Reanimated
scale.value = withTiming(1, { duration: 300 });
```

---

## 8) Profiling & Debugging

### React Native Performance
```tsx
// ==========================================
// PERFORMANCE MONITORING
// ==========================================

// Enable performance monitor
import { PerformanceObserver } from 'perf_hooks';

// Custom performance marks
performance.mark('screen_load_start');
// ... component renders
performance.mark('screen_load_end');
performance.measure('Screen Load', 'screen_load_start', 'screen_load_end');


// ==========================================
// WHY DID YOU RENDER
// ==========================================

// wdyr.js
import React from 'react';

if (__DEV__) {
  const whyDidYouRender = require('@welldone-software/why-did-you-render');
  whyDidYouRender(React, {
    trackAllPureComponents: true,
    trackHooks: true,
    logOnDifferentValues: true,
  });
}

// Track specific component
ProductList.whyDidYouRender = true;


// ==========================================
// FLIPPER PERFORMANCE PLUGIN
// ==========================================

// Setup in index.js
if (__DEV__) {
  require('react-native-flipper-performance-plugin').setupDefaultFlipperReporter();
}
```

### Performance Checklist
```
┌─────────────────────────────────────────┐
│       PERFORMANCE CHECKLIST             │
├─────────────────────────────────────────┤
│                                         │
│  RENDERING:                             │
│  □ FlatList with all optimizations      │
│  □ Memoized components (React.memo)     │
│  □ Stable callbacks (useCallback)       │
│  □ No inline styles in render           │
│  □ Keys on list items                   │
│                                         │
│  IMAGES:                                │
│  □ Using FastImage or equivalent        │
│  □ Proper sizing for device             │
│  □ WebP format                          │
│  □ Lazy loading for off-screen          │
│  □ Caching configured                   │
│                                         │
│  MEMORY:                                │
│  □ Cleanup in useEffect                 │
│  □ No async state after unmount         │
│  □ Cleared subscriptions                │
│  □ Released large objects               │
│                                         │
│  STARTUP:                               │
│  □ Lazy loaded non-critical screens     │
│  □ Deferred initialization              │
│  □ Splash screen while loading          │
│  □ Baseline profiles (Android)          │
│                                         │
│  NETWORK:                               │
│  □ Caching with React Query             │
│  □ Prefetching likely data              │
│  □ Pagination for long lists            │
│  □ Request batching                     │
│                                         │
│  ANIMATIONS:                            │
│  □ Using Reanimated 3                   │
│  □ UI thread animations                 │
│  □ useNativeDriver: true               │
│                                         │
└─────────────────────────────────────────┘
```

---

## Best Practices Summary

### Measure First
- [ ] Profile before optimizing
- [ ] Test on low-end devices
- [ ] Use Flipper/DevTools
- [ ] Track metrics over time

### Rendering
- [ ] FlashList over FlatList
- [ ] Memoize components
- [ ] Stable references
- [ ] getItemLayout for fixed heights

### Assets
- [ ] WebP images
- [ ] Proper sizing
- [ ] Lazy loading
- [ ] CDN optimization

### Memory
- [ ] Clean up effects
- [ ] Abort pending requests
- [ ] Release resources
- [ ] Monitor heap size

---

**References:**
- [React Native Performance](https://reactnative.dev/docs/performance)
- [FlashList by Shopify](https://shopify.github.io/flash-list/)
- [Android Performance](https://developer.android.com/topic/performance)
- [iOS Performance](https://developer.apple.com/documentation/xcode/improving-your-app-s-performance)
