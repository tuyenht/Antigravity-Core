# Progressive Web App (PWA) Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** Web App Manifest, Service Worker API, Project Fugu
> **Priority:** P1 - Load for PWA projects

---

You are an expert in Progressive Web App development, utilizing modern PWA capabilities and Project Fugu APIs.

## Key Principles

- Implement offline-first strategy for reliability
- Use service workers for intelligent caching
- Make app installable with rich manifest
- Ensure fast loading and smooth experience
- Provide native app-like experience
- Leverage modern PWA capabilities (Project Fugu)

## Service Workers

### Registration
```javascript
// register-sw.js
if ('serviceWorker' in navigator) {
  window.addEventListener('load', async () => {
    try {
      const registration = await navigator.serviceWorker.register('/sw.js', {
        scope: '/'
      });
      
      // Handle updates
      registration.addEventListener('updatefound', () => {
        const newWorker = registration.installing;
        newWorker.addEventListener('statechange', () => {
          if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
            // New version available
            showUpdateNotification();
          }
        });
      });
    } catch (error) {
      console.error('SW registration failed:', error);
    }
  });
}
```

### Service Worker Lifecycle
```javascript
// sw.js
const CACHE_VERSION = 'v1.0.0';
const CACHE_NAME = `app-cache-${CACHE_VERSION}`;

// Install - cache critical resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll([
        '/',
        '/index.html',
        '/styles/main.css',
        '/scripts/app.js',
        '/offline.html'
      ]);
    })
  );
  // Activate immediately
  self.skipWaiting();
});

// Activate - cleanup old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      );
    })
  );
  // Take control immediately
  self.clients.claim();
});
```

### Workbox (Recommended)
```javascript
// sw.js with Workbox
import { precacheAndRoute } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { 
  CacheFirst, 
  NetworkFirst, 
  StaleWhileRevalidate 
} from 'workbox-strategies';
import { ExpirationPlugin } from 'workbox-expiration';
import { CacheableResponsePlugin } from 'workbox-cacheable-response';

// Precache static assets (from build manifest)
precacheAndRoute(self.__WB_MANIFEST);

// Static assets - Cache First
registerRoute(
  ({ request }) => request.destination === 'style' ||
                   request.destination === 'script' ||
                   request.destination === 'font',
  new CacheFirst({
    cacheName: 'static-assets',
    plugins: [
      new ExpirationPlugin({
        maxEntries: 60,
        maxAgeSeconds: 30 * 24 * 60 * 60 // 30 days
      })
    ]
  })
);

// Images - Cache First with size limit
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [
      new ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 30 * 24 * 60 * 60,
        purgeOnQuotaError: true
      })
    ]
  })
);

// API calls - Network First
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new NetworkFirst({
    cacheName: 'api-cache',
    networkTimeoutSeconds: 5,
    plugins: [
      new CacheableResponsePlugin({
        statuses: [0, 200]
      }),
      new ExpirationPlugin({
        maxEntries: 50,
        maxAgeSeconds: 5 * 60 // 5 minutes
      })
    ]
  })
);

// HTML pages - Stale While Revalidate
registerRoute(
  ({ request }) => request.mode === 'navigate',
  new StaleWhileRevalidate({
    cacheName: 'pages',
    plugins: [
      new CacheableResponsePlugin({
        statuses: [0, 200]
      })
    ]
  })
);
```

## Caching Strategies

| Strategy | Use Case | Behavior |
|----------|----------|----------|
| **Cache First** | Static assets, fonts, images | Check cache first, fallback to network |
| **Network First** | API calls, dynamic content | Try network first, fallback to cache |
| **Stale While Revalidate** | News, feeds, frequently updated | Return cache immediately, update in background |
| **Cache Only** | Offline fallback page | Only serve from cache |
| **Network Only** | Analytics, non-critical APIs | Only use network |

## Web App Manifest

```json
{
  "name": "My Progressive Web App",
  "short_name": "MyPWA",
  "description": "A fast, reliable, and engaging web app",
  "start_url": "/?source=pwa",
  "scope": "/",
  "display": "standalone",
  "display_override": ["window-controls-overlay", "standalone"],
  "orientation": "any",
  "theme_color": "#1a73e8",
  "background_color": "#ffffff",
  "categories": ["productivity", "utilities"],
  
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/icons/icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ],
  
  "screenshots": [
    {
      "src": "/screenshots/desktop.png",
      "sizes": "1280x720",
      "type": "image/png",
      "form_factor": "wide",
      "label": "Desktop view"
    },
    {
      "src": "/screenshots/mobile.png",
      "sizes": "750x1334",
      "type": "image/png",
      "form_factor": "narrow",
      "label": "Mobile view"
    }
  ],
  
  "shortcuts": [
    {
      "name": "New Document",
      "short_name": "New",
      "description": "Create a new document",
      "url": "/new?source=shortcut",
      "icons": [{ "src": "/icons/new.png", "sizes": "192x192" }]
    },
    {
      "name": "Settings",
      "short_name": "Settings",
      "url": "/settings",
      "icons": [{ "src": "/icons/settings.png", "sizes": "192x192" }]
    }
  ],
  
  "share_target": {
    "action": "/share-receiver",
    "method": "POST",
    "enctype": "multipart/form-data",
    "params": {
      "title": "title",
      "text": "text",
      "url": "url",
      "files": [
        {
          "name": "media",
          "accept": ["image/*", "video/*"]
        }
      ]
    }
  },
  
  "file_handlers": [
    {
      "action": "/open-file",
      "accept": {
        "application/json": [".json"],
        "text/plain": [".txt", ".md"]
      }
    }
  ],
  
  "protocol_handlers": [
    {
      "protocol": "web+myapp",
      "url": "/protocol-handler?url=%s"
    }
  ],
  
  "related_applications": [],
  "prefer_related_applications": false
}
```

## Offline Experience

### Offline Fallback
```javascript
// In service worker
self.addEventListener('fetch', (event) => {
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(() => {
        return caches.match('/offline.html');
      })
    );
  }
});
```

### Offline Indicator
```javascript
// Network status detection
function updateOnlineStatus() {
  const indicator = document.getElementById('offline-indicator');
  if (navigator.onLine) {
    indicator.hidden = true;
    syncQueuedData();
  } else {
    indicator.hidden = false;
  }
}

window.addEventListener('online', updateOnlineStatus);
window.addEventListener('offline', updateOnlineStatus);
```

### Background Sync
```javascript
// Queue failed requests for retry
async function sendData(data) {
  try {
    await fetch('/api/data', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  } catch (error) {
    // Queue for background sync
    const registration = await navigator.serviceWorker.ready;
    await registration.sync.register('sync-data');
    await saveToIndexedDB(data);
  }
}

// In service worker
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-data') {
    event.waitUntil(syncData());
  }
});

async function syncData() {
  const data = await getFromIndexedDB();
  for (const item of data) {
    await fetch('/api/data', {
      method: 'POST',
      body: JSON.stringify(item)
    });
    await removeFromIndexedDB(item.id);
  }
}
```

### Periodic Background Sync
```javascript
// Request periodic sync permission
const registration = await navigator.serviceWorker.ready;

if ('periodicSync' in registration) {
  const status = await navigator.permissions.query({
    name: 'periodic-background-sync'
  });
  
  if (status.state === 'granted') {
    await registration.periodicSync.register('update-content', {
      minInterval: 24 * 60 * 60 * 1000 // 24 hours
    });
  }
}

// In service worker
self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'update-content') {
    event.waitUntil(updateContent());
  }
});
```

## Installability

### Install Prompt
```javascript
let deferredPrompt;

window.addEventListener('beforeinstallprompt', (event) => {
  // Prevent automatic prompt
  event.preventDefault();
  deferredPrompt = event;
  
  // Show custom install button
  showInstallButton();
});

async function handleInstallClick() {
  if (!deferredPrompt) return;
  
  // Show the prompt
  deferredPrompt.prompt();
  
  // Wait for user choice
  const { outcome } = await deferredPrompt.userChoice;
  
  if (outcome === 'accepted') {
    console.log('User accepted the install prompt');
  } else {
    console.log('User dismissed the install prompt');
  }
  
  deferredPrompt = null;
  hideInstallButton();
}

// Detect if app was installed
window.addEventListener('appinstalled', () => {
  console.log('PWA was installed');
  deferredPrompt = null;
});
```

### Display Mode Detection
```javascript
// Check if running as installed PWA
function isInstalledPWA() {
  return window.matchMedia('(display-mode: standalone)').matches ||
         window.matchMedia('(display-mode: window-controls-overlay)').matches ||
         navigator.standalone === true;
}

// React to display mode changes
window.matchMedia('(display-mode: standalone)').addEventListener('change', (e) => {
  if (e.matches) {
    console.log('Now running as installed PWA');
  }
});
```

## Push Notifications

```javascript
// Request permission
async function requestNotificationPermission() {
  const permission = await Notification.requestPermission();
  
  if (permission === 'granted') {
    await subscribeToPush();
  }
}

// Subscribe to push
async function subscribeToPush() {
  const registration = await navigator.serviceWorker.ready;
  
  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY)
  });
  
  // Send subscription to server
  await fetch('/api/push-subscription', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(subscription)
  });
}

// Handle push in service worker
self.addEventListener('push', (event) => {
  const data = event.data?.json() ?? {};
  
  const options = {
    body: data.body,
    icon: '/icons/icon-192.png',
    badge: '/icons/badge-72.png',
    vibrate: [100, 50, 100],
    data: { url: data.url },
    actions: [
      { action: 'open', title: 'Open' },
      { action: 'dismiss', title: 'Dismiss' }
    ]
  };
  
  event.waitUntil(
    self.registration.showNotification(data.title, options)
  );
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  if (event.action === 'open' || !event.action) {
    event.waitUntil(
      clients.openWindow(event.notification.data.url)
    );
  }
});
```

## Modern PWA APIs

### Badging API
```javascript
// Set app badge
if ('setAppBadge' in navigator) {
  navigator.setAppBadge(5); // Show badge with count
  navigator.clearAppBadge(); // Clear badge
}
```

### Web Share API
```javascript
// Share content
async function shareContent(data) {
  if (navigator.canShare?.(data)) {
    try {
      await navigator.share(data);
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error('Share failed:', error);
      }
    }
  } else {
    // Fallback to clipboard or custom UI
    await navigator.clipboard.writeText(data.url);
  }
}

// Usage
await shareContent({
  title: 'Check this out!',
  text: 'Amazing content',
  url: window.location.href
});

// Share files
await navigator.share({
  files: [imageFile],
  title: 'Photo'
});
```

### Screen Wake Lock
```javascript
// Prevent screen from sleeping
let wakeLock = null;

async function requestWakeLock() {
  if ('wakeLock' in navigator) {
    try {
      wakeLock = await navigator.wakeLock.request('screen');
      
      wakeLock.addEventListener('release', () => {
        console.log('Wake lock released');
      });
    } catch (error) {
      console.error('Wake lock request failed:', error);
    }
  }
}

function releaseWakeLock() {
  wakeLock?.release();
  wakeLock = null;
}

// Re-acquire on visibility change
document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible' && !wakeLock) {
    requestWakeLock();
  }
});
```

### Window Controls Overlay
```css
/* When using window-controls-overlay display mode */
.titlebar {
  position: fixed;
  left: env(titlebar-area-x, 0);
  top: env(titlebar-area-y, 0);
  width: env(titlebar-area-width, 100%);
  height: env(titlebar-area-height, 40px);
  -webkit-app-region: drag;
}

.titlebar button {
  -webkit-app-region: no-drag;
}
```

## Performance

### Resource Hints
```html
<!-- Preconnect to critical origins -->
<link rel="preconnect" href="https://api.example.com">
<link rel="dns-prefetch" href="https://analytics.example.com">

<!-- Preload critical resources -->
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin>
<link rel="modulepreload" href="/scripts/app.js">

<!-- Prefetch next page -->
<link rel="prefetch" href="/next-page.html">
```

### Navigation Preload
```javascript
// Enable in service worker
self.addEventListener('activate', (event) => {
  event.waitUntil(async function() {
    if (self.registration.navigationPreload) {
      await self.registration.navigationPreload.enable();
    }
  }());
});

// Use preloaded response
self.addEventListener('fetch', (event) => {
  if (event.request.mode === 'navigate') {
    event.respondWith(async function() {
      const preloadResponse = await event.preloadResponse;
      if (preloadResponse) {
        return preloadResponse;
      }
      return fetch(event.request);
    }());
  }
});
```

## Security

- Serve over HTTPS (required for service workers)
- Implement Content Security Policy headers
- Validate all user inputs
- Use secure authentication (WebAuthn preferred)
- Implement proper CORS for API calls
- Use SRI for external resources

## Testing

### Lighthouse Audit
- Target 100 PWA score
- Test on mobile devices
- Test offline functionality
- Test installation flow

### Checklist
- [ ] App works offline
- [ ] App is installable
- [ ] Uses HTTPS
- [ ] Fast on 3G networks
- [ ] All pages have unique URLs
- [ ] Content updates without refresh issues

---

**References:**
- [web.dev PWA](https://web.dev/progressive-web-apps/)
- [Workbox Documentation](https://developer.chrome.com/docs/workbox/)
- [Project Fugu APIs](https://fugu-tracker.web.app/)
- [PWA Builder](https://www.pwabuilder.com/)
