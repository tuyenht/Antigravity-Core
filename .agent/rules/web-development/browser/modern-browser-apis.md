# Browser APIs & Web Platform Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** Web Platform 2024, Project Fugu
> **Priority:** P1 - Load for advanced web features

---

You are an expert in modern browser APIs and the web platform, including Project Fugu capabilities.

## Key Principles

- Use progressive enhancement for new APIs
- Always check for API support before using
- Provide fallbacks for unsupported browsers
- Follow permission best practices
- Handle errors gracefully
- Stay updated with Web Platform advancements

---

## Feature Detection

```javascript
// Check for API support
if ('serviceWorker' in navigator) {
  // Service Worker supported
}

if ('storage' in navigator && 'estimate' in navigator.storage) {
  // Storage Estimate API supported
}

// Modern approach with optional chaining
if (navigator.share) {
  // Web Share API supported
}

// For async APIs with permissions
async function checkSupport(permissionName) {
  try {
    const result = await navigator.permissions.query({ name: permissionName });
    return result.state !== 'denied';
  } catch {
    return false;
  }
}
```

---

## Fetch API

### Basic Requests
```javascript
// GET request
const response = await fetch('/api/users');
const data = await response.json();

// POST request
const response = await fetch('/api/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ name: 'John', email: 'john@example.com' })
});
```

### Error Handling
```javascript
async function fetchWithErrorHandling(url, options = {}) {
  try {
    const response = await fetch(url, options);
    
    if (!response.ok) {
      // Handle HTTP errors
      const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
      error.status = response.status;
      error.response = response;
      throw error;
    }
    
    const contentType = response.headers.get('content-type');
    if (contentType?.includes('application/json')) {
      return await response.json();
    }
    return await response.text();
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Request was cancelled');
      throw error;
    }
    if (error.name === 'TypeError') {
      // Network error
      throw new Error('Network error - please check your connection');
    }
    throw error;
  }
}
```

### AbortController for Cancellation
```javascript
// Cancel fetch requests
async function fetchWithTimeout(url, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      signal: controller.signal
    });
    return await response.json();
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new Error('Request timed out');
    }
    throw error;
  } finally {
    clearTimeout(timeoutId);
  }
}

// Cancel multiple requests
const controller = new AbortController();
const { signal } = controller;

Promise.all([
  fetch('/api/users', { signal }),
  fetch('/api/posts', { signal }),
  fetch('/api/comments', { signal })
]);

// Cancel all
controller.abort();

// React cleanup pattern
useEffect(() => {
  const controller = new AbortController();
  
  fetch('/api/data', { signal: controller.signal })
    .then(res => res.json())
    .then(setData)
    .catch(err => {
      if (err.name !== 'AbortError') {
        setError(err);
      }
    });
  
  return () => controller.abort();
}, []);
```

### Request/Response Interceptors
```javascript
// Create a fetch wrapper with interceptors
function createFetchClient(baseUrl, options = {}) {
  const requestInterceptors = [];
  const responseInterceptors = [];
  
  return {
    addRequestInterceptor(fn) {
      requestInterceptors.push(fn);
    },
    
    addResponseInterceptor(fn) {
      responseInterceptors.push(fn);
    },
    
    async fetch(url, fetchOptions = {}) {
      let config = { ...options, ...fetchOptions };
      
      // Run request interceptors
      for (const interceptor of requestInterceptors) {
        config = await interceptor(config);
      }
      
      let response = await fetch(`${baseUrl}${url}`, config);
      
      // Run response interceptors
      for (const interceptor of responseInterceptors) {
        response = await interceptor(response);
      }
      
      return response;
    }
  };
}

// Usage
const api = createFetchClient('https://api.example.com');

api.addRequestInterceptor(async (config) => {
  config.headers = {
    ...config.headers,
    'Authorization': `Bearer ${getToken()}`
  };
  return config;
});

api.addResponseInterceptor(async (response) => {
  if (response.status === 401) {
    await refreshToken();
    // Retry request
  }
  return response;
});
```

---

## Web Storage

### localStorage & sessionStorage
```javascript
// Storage wrapper with JSON and error handling
const storage = {
  get(key, defaultValue = null) {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch {
      return defaultValue;
    }
  },
  
  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {
      if (error.name === 'QuotaExceededError') {
        console.error('Storage quota exceeded');
        // Try to clear old data
        this.cleanup();
      }
      return false;
    }
  },
  
  remove(key) {
    localStorage.removeItem(key);
  },
  
  cleanup() {
    // Remove expired items or old data
    const keys = Object.keys(localStorage);
    for (const key of keys) {
      const item = this.get(key);
      if (item?.expiresAt && Date.now() > item.expiresAt) {
        this.remove(key);
      }
    }
  }
};

// Listen for storage changes (cross-tab)
window.addEventListener('storage', (event) => {
  if (event.key === 'user') {
    updateUserState(JSON.parse(event.newValue));
  }
});
```

### IndexedDB
```javascript
// Modern IndexedDB wrapper
class Database {
  constructor(name, version = 1) {
    this.name = name;
    this.version = version;
    this.db = null;
  }
  
  async open(upgradeCallback) {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.name, this.version);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve(this);
      };
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        if (upgradeCallback) {
          upgradeCallback(db, event.oldVersion, event.newVersion);
        }
      };
    });
  }
  
  async add(storeName, item) {
    return this.transaction(storeName, 'readwrite', (store) => {
      return store.add(item);
    });
  }
  
  async get(storeName, key) {
    return this.transaction(storeName, 'readonly', (store) => {
      return store.get(key);
    });
  }
  
  async getAll(storeName, query, count) {
    return this.transaction(storeName, 'readonly', (store) => {
      return store.getAll(query, count);
    });
  }
  
  async put(storeName, item) {
    return this.transaction(storeName, 'readwrite', (store) => {
      return store.put(item);
    });
  }
  
  async delete(storeName, key) {
    return this.transaction(storeName, 'readwrite', (store) => {
      return store.delete(key);
    });
  }
  
  async transaction(storeName, mode, callback) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(storeName, mode);
      const store = tx.objectStore(storeName);
      const request = callback(store);
      
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }
}

// Usage
const db = new Database('myApp', 1);
await db.open((db, oldVersion) => {
  if (oldVersion < 1) {
    const store = db.createObjectStore('users', { keyPath: 'id' });
    store.createIndex('email', 'email', { unique: true });
  }
});

await db.add('users', { id: 1, name: 'John', email: 'john@example.com' });
const user = await db.get('users', 1);
```

### Cache API
```javascript
// Cache resources for offline
async function cacheResources(cacheName, urls) {
  const cache = await caches.open(cacheName);
  await cache.addAll(urls);
}

// Cache-first strategy
async function cacheFirst(cacheName, request) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);
  
  if (cached) {
    return cached;
  }
  
  const response = await fetch(request);
  cache.put(request, response.clone());
  return response;
}

// Network-first with cache fallback
async function networkFirst(cacheName, request) {
  const cache = await caches.open(cacheName);
  
  try {
    const response = await fetch(request);
    cache.put(request, response.clone());
    return response;
  } catch {
    return cache.match(request);
  }
}
```

### Storage Estimate
```javascript
async function checkStorage() {
  if ('storage' in navigator && 'estimate' in navigator.storage) {
    const { usage, quota } = await navigator.storage.estimate();
    const percentUsed = ((usage / quota) * 100).toFixed(2);
    console.log(`Using ${percentUsed}% of available storage`);
    console.log(`${(usage / 1024 / 1024).toFixed(2)} MB used of ${(quota / 1024 / 1024).toFixed(2)} MB`);
    
    // Request persistent storage
    if (navigator.storage.persist) {
      const persistent = await navigator.storage.persist();
      console.log('Persistent storage:', persistent);
    }
  }
}
```

---

## Observers

### Intersection Observer
```javascript
// Lazy loading images
const imageObserver = new IntersectionObserver((entries, observer) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const img = entry.target;
      img.src = img.dataset.src;
      img.classList.add('loaded');
      observer.unobserve(img);
    }
  });
}, {
  root: null,           // viewport
  rootMargin: '200px',  // preload before visible
  threshold: 0          // trigger when any part visible
});

document.querySelectorAll('img[data-src]').forEach(img => {
  imageObserver.observe(img);
});

// Infinite scroll
const loadMoreObserver = new IntersectionObserver((entries) => {
  if (entries[0].isIntersecting) {
    loadMoreItems();
  }
}, { threshold: 0.1 });

loadMoreObserver.observe(document.querySelector('.load-trigger'));

// Cleanup
loadMoreObserver.disconnect();
```

### Resize Observer
```javascript
// Container queries polyfill behavior
const resizeObserver = new ResizeObserver((entries) => {
  for (const entry of entries) {
    const { width, height } = entry.contentRect;
    const element = entry.target;
    
    // Update component based on size
    element.classList.toggle('compact', width < 400);
    element.classList.toggle('expanded', width >= 600);
    
    // Or use border-box dimensions
    if (entry.borderBoxSize) {
      const boxWidth = entry.borderBoxSize[0].inlineSize;
      const boxHeight = entry.borderBoxSize[0].blockSize;
    }
  }
});

resizeObserver.observe(document.querySelector('.container'));

// Cleanup
resizeObserver.disconnect();
```

### Mutation Observer
```javascript
// Watch for DOM changes
const mutationObserver = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    if (mutation.type === 'childList') {
      mutation.addedNodes.forEach(node => {
        if (node.nodeType === Node.ELEMENT_NODE) {
          initializeComponent(node);
        }
      });
      
      mutation.removedNodes.forEach(node => {
        if (node.nodeType === Node.ELEMENT_NODE) {
          cleanupComponent(node);
        }
      });
    }
    
    if (mutation.type === 'attributes') {
      handleAttributeChange(mutation.target, mutation.attributeName, mutation.oldValue);
    }
  }
});

mutationObserver.observe(document.body, {
  childList: true,
  subtree: true,
  attributes: true,
  attributeOldValue: true,
  attributeFilter: ['data-state', 'class']
});

// Cleanup
mutationObserver.disconnect();
```

---

## Clipboard API

```javascript
// Read from clipboard
async function pasteFromClipboard() {
  try {
    const text = await navigator.clipboard.readText();
    return text;
  } catch (error) {
    console.error('Failed to read clipboard:', error);
    return null;
  }
}

// Write to clipboard
async function copyToClipboard(text) {
  try {
    await navigator.clipboard.writeText(text);
    showToast('Copied to clipboard!');
    return true;
  } catch (error) {
    // Fallback for older browsers
    return fallbackCopy(text);
  }
}

function fallbackCopy(text) {
  const textarea = document.createElement('textarea');
  textarea.value = text;
  textarea.style.cssText = 'position:fixed;left:-9999px';
  document.body.appendChild(textarea);
  textarea.select();
  const success = document.execCommand('copy');
  document.body.removeChild(textarea);
  return success;
}

// Copy rich content (images, HTML)
async function copyRichContent(blob) {
  const item = new ClipboardItem({
    [blob.type]: blob
  });
  await navigator.clipboard.write([item]);
}

// Read images from clipboard
async function pasteImage() {
  const items = await navigator.clipboard.read();
  for (const item of items) {
    for (const type of item.types) {
      if (type.startsWith('image/')) {
        const blob = await item.getType(type);
        return URL.createObjectURL(blob);
      }
    }
  }
  return null;
}
```

---

## Geolocation API

```javascript
// Get current position
async function getCurrentLocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation not supported'));
      return;
    }
    
    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
          altitude: position.coords.altitude,
          heading: position.coords.heading,
          speed: position.coords.speed
        });
      },
      (error) => {
        const messages = {
          [error.PERMISSION_DENIED]: 'Location permission denied',
          [error.POSITION_UNAVAILABLE]: 'Location unavailable',
          [error.TIMEOUT]: 'Location request timed out'
        };
        reject(new Error(messages[error.code] || 'Unknown error'));
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 5 * 60 * 1000 // 5 minutes cache
      }
    );
  });
}

// Watch position with cleanup
function watchLocation(callback, errorCallback) {
  const watchId = navigator.geolocation.watchPosition(
    (position) => callback({
      latitude: position.coords.latitude,
      longitude: position.coords.longitude
    }),
    errorCallback,
    { enableHighAccuracy: true }
  );
  
  // Return cleanup function
  return () => navigator.geolocation.clearWatch(watchId);
}

// Usage
const stopWatching = watchLocation(
  (pos) => console.log('Position:', pos),
  (err) => console.error('Error:', err)
);

// Later
stopWatching();
```

---

## Notifications API

```javascript
// Request permission
async function requestNotificationPermission() {
  if (!('Notification' in window)) {
    console.log('Notifications not supported');
    return 'unsupported';
  }
  
  if (Notification.permission === 'granted') {
    return 'granted';
  }
  
  if (Notification.permission === 'denied') {
    return 'denied';
  }
  
  const permission = await Notification.requestPermission();
  return permission;
}

// Show notification
function showNotification(title, options = {}) {
  if (Notification.permission !== 'granted') {
    return null;
  }
  
  const notification = new Notification(title, {
    body: options.body,
    icon: options.icon || '/icons/notification.png',
    badge: options.badge || '/icons/badge.png',
    tag: options.tag,  // Replace notifications with same tag
    renotify: options.renotify || false,
    requireInteraction: options.requireInteraction || false,
    silent: options.silent || false,
    data: options.data
  });
  
  notification.onclick = (event) => {
    event.preventDefault();
    window.focus();
    options.onClick?.(event);
    notification.close();
  };
  
  notification.onclose = options.onClose;
  notification.onerror = options.onError;
  
  return notification;
}

// Service Worker notifications (for background)
async function showPersistentNotification(title, options) {
  const registration = await navigator.serviceWorker.ready;
  
  await registration.showNotification(title, {
    body: options.body,
    icon: options.icon,
    badge: options.badge,
    vibrate: [100, 50, 100],
    data: { url: options.url },
    actions: [
      { action: 'open', title: 'Open', icon: '/icons/open.png' },
      { action: 'dismiss', title: 'Dismiss' }
    ]
  });
}

// Handle notification clicks in service worker
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  if (event.action === 'open' || !event.action) {
    event.waitUntil(
      clients.openWindow(event.notification.data.url)
    );
  }
});
```

---

## Web Workers

```javascript
// Create and use worker
const worker = new Worker('/workers/heavy-task.js');

// Send data to worker
worker.postMessage({
  type: 'PROCESS_DATA',
  data: largeDataSet
});

// Receive results
worker.onmessage = (event) => {
  const { type, result, error } = event.data;
  
  if (type === 'RESULT') {
    handleResult(result);
  } else if (type === 'ERROR') {
    handleError(error);
  } else if (type === 'PROGRESS') {
    updateProgress(event.data.progress);
  }
};

worker.onerror = (error) => {
  console.error('Worker error:', error);
};

// Terminate worker when done
worker.terminate();
```

```javascript
// workers/heavy-task.js
self.onmessage = async (event) => {
  const { type, data } = event.data;
  
  try {
    if (type === 'PROCESS_DATA') {
      const result = await processData(data);
      self.postMessage({ type: 'RESULT', result });
    }
  } catch (error) {
    self.postMessage({ type: 'ERROR', error: error.message });
  }
};

function processData(data) {
  // Report progress
  for (let i = 0; i < data.length; i++) {
    // Process item
    if (i % 100 === 0) {
      self.postMessage({ type: 'PROGRESS', progress: i / data.length });
    }
  }
  return processedData;
}
```

### Shared Worker
```javascript
// Shared state across tabs
const sharedWorker = new SharedWorker('/workers/shared.js');

sharedWorker.port.start();
sharedWorker.port.postMessage({ type: 'SUBSCRIBE' });

sharedWorker.port.onmessage = (event) => {
  handleSharedState(event.data);
};
```

---

## WebSockets

```javascript
class WebSocketClient {
  constructor(url) {
    this.url = url;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectDelay = 1000;
    this.messageQueue = [];
    this.listeners = new Map();
  }
  
  connect() {
    this.ws = new WebSocket(this.url);
    
    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectAttempts = 0;
      
      // Send queued messages
      while (this.messageQueue.length > 0) {
        const message = this.messageQueue.shift();
        this.send(message);
      }
      
      this.emit('connected');
    };
    
    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        this.emit('message', data);
        
        if (data.type) {
          this.emit(data.type, data.payload);
        }
      } catch {
        this.emit('message', event.data);
      }
    };
    
    this.ws.onclose = (event) => {
      console.log('WebSocket closed:', event.code, event.reason);
      this.emit('disconnected');
      
      if (!event.wasClean && this.reconnectAttempts < this.maxReconnectAttempts) {
        this.reconnect();
      }
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
      this.emit('error', error);
    };
  }
  
  reconnect() {
    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);
    
    console.log(`Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);
    
    setTimeout(() => this.connect(), delay);
  }
  
  send(data) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    } else {
      this.messageQueue.push(data);
    }
  }
  
  on(event, callback) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event).push(callback);
  }
  
  emit(event, data) {
    this.listeners.get(event)?.forEach(cb => cb(data));
  }
  
  close() {
    this.ws?.close(1000, 'Client closed');
  }
}

// Usage
const ws = new WebSocketClient('wss://api.example.com/ws');

ws.on('connected', () => console.log('Ready'));
ws.on('message', (data) => console.log('Received:', data));
ws.on('chat_message', (msg) => displayMessage(msg));

ws.connect();
ws.send({ type: 'chat_message', payload: { text: 'Hello' } });
```

---

## WebRTC

```javascript
// Simple peer connection
class PeerConnection {
  constructor(configuration) {
    this.pc = new RTCPeerConnection(configuration);
    this.localStream = null;
    
    this.pc.onicecandidate = (event) => {
      if (event.candidate) {
        this.onIceCandidate?.(event.candidate);
      }
    };
    
    this.pc.ontrack = (event) => {
      this.onRemoteStream?.(event.streams[0]);
    };
    
    this.pc.onconnectionstatechange = () => {
      this.onConnectionStateChange?.(this.pc.connectionState);
    };
  }
  
  async startLocalStream(constraints = { video: true, audio: true }) {
    this.localStream = await navigator.mediaDevices.getUserMedia(constraints);
    
    this.localStream.getTracks().forEach(track => {
      this.pc.addTrack(track, this.localStream);
    });
    
    return this.localStream;
  }
  
  async createOffer() {
    const offer = await this.pc.createOffer();
    await this.pc.setLocalDescription(offer);
    return offer;
  }
  
  async handleOffer(offer) {
    await this.pc.setRemoteDescription(offer);
    const answer = await this.pc.createAnswer();
    await this.pc.setLocalDescription(answer);
    return answer;
  }
  
  async handleAnswer(answer) {
    await this.pc.setRemoteDescription(answer);
  }
  
  async addIceCandidate(candidate) {
    await this.pc.addIceCandidate(candidate);
  }
  
  async shareScreen() {
    const screenStream = await navigator.mediaDevices.getDisplayMedia({
      video: true
    });
    
    const videoTrack = screenStream.getVideoTracks()[0];
    const sender = this.pc.getSenders().find(s => s.track?.kind === 'video');
    
    if (sender) {
      await sender.replaceTrack(videoTrack);
    }
    
    return screenStream;
  }
  
  close() {
    this.localStream?.getTracks().forEach(track => track.stop());
    this.pc.close();
  }
}

// Configuration
const config = {
  iceServers: [
    { urls: 'stun:stun.l.google.com:19302' },
    { 
      urls: 'turn:turn.example.com:3478',
      username: 'user',
      credential: 'pass'
    }
  ]
};
```

---

## Web Share API

```javascript
// Share content
async function shareContent(data) {
  if (!navigator.share) {
    // Fallback to clipboard or custom share UI
    await navigator.clipboard.writeText(data.url);
    showToast('Link copied to clipboard');
    return;
  }
  
  if (!navigator.canShare?.(data)) {
    console.error('Cannot share this data');
    return;
  }
  
  try {
    await navigator.share(data);
  } catch (error) {
    if (error.name !== 'AbortError') {
      console.error('Share failed:', error);
    }
  }
}

// Share text and URL
await shareContent({
  title: 'Check this out!',
  text: 'Amazing content I found',
  url: window.location.href
});

// Share files
async function shareFiles(files) {
  if (navigator.canShare?.({ files })) {
    await navigator.share({
      files,
      title: 'Photos',
      text: 'Check out these photos'
    });
  }
}
```

---

## Payment Request API

```javascript
async function initiatePayment(items, total) {
  if (!window.PaymentRequest) {
    // Fallback to custom checkout
    return redirectToCheckout();
  }
  
  const supportedMethods = [
    {
      supportedMethods: 'basic-card',
      data: {
        supportedNetworks: ['visa', 'mastercard', 'amex'],
        supportedTypes: ['credit', 'debit']
      }
    },
    {
      supportedMethods: 'https://google.com/pay',
      data: {
        environment: 'PRODUCTION',
        merchantInfo: { merchantId: 'YOUR_MERCHANT_ID' }
      }
    }
  ];
  
  const details = {
    displayItems: items.map(item => ({
      label: item.name,
      amount: { currency: 'USD', value: item.price.toFixed(2) }
    })),
    total: {
      label: 'Total',
      amount: { currency: 'USD', value: total.toFixed(2) }
    }
  };
  
  const options = {
    requestPayerName: true,
    requestPayerEmail: true,
    requestPayerPhone: false,
    requestShipping: true,
    shippingType: 'shipping'
  };
  
  try {
    const request = new PaymentRequest(supportedMethods, details, options);
    
    // Check if payment can be made
    const canMakePayment = await request.canMakePayment();
    if (!canMakePayment) {
      return redirectToCheckout();
    }
    
    const response = await request.show();
    
    // Process payment on server
    const result = await processPayment(response);
    
    if (result.success) {
      await response.complete('success');
    } else {
      await response.complete('fail');
    }
    
    return result;
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Payment cancelled');
    } else {
      console.error('Payment error:', error);
    }
  }
}
```

---

## File System Access API

```javascript
// Open file picker
async function openFile(acceptTypes) {
  try {
    const [fileHandle] = await window.showOpenFilePicker({
      types: acceptTypes || [
        {
          description: 'Text Files',
          accept: { 'text/plain': ['.txt', '.md'] }
        }
      ],
      multiple: false
    });
    
    const file = await fileHandle.getFile();
    const content = await file.text();
    return { fileHandle, file, content };
  } catch (error) {
    if (error.name !== 'AbortError') {
      throw error;
    }
  }
}

// Save file
async function saveFile(fileHandle, content) {
  const writable = await fileHandle.createWritable();
  await writable.write(content);
  await writable.close();
}

// Save As
async function saveFileAs(content, suggestedName, types) {
  const fileHandle = await window.showSaveFilePicker({
    suggestedName,
    types: types || [
      { description: 'Text File', accept: { 'text/plain': ['.txt'] } }
    ]
  });
  
  await saveFile(fileHandle, content);
  return fileHandle;
}
```

---

## View Transitions API

```javascript
// Navigate with transition
async function navigateWithTransition(url) {
  if (!document.startViewTransition) {
    window.location.href = url;
    return;
  }
  
  const response = await fetch(url);
  const html = await response.text();
  
  document.startViewTransition(() => {
    document.body.innerHTML = html;
  });
}
```

```css
/* Customize transitions */
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 300ms;
}

.hero-image {
  view-transition-name: hero;
}
```

---

## Broadcast Channel (Cross-Tab)

```javascript
// Cross-tab communication
const channel = new BroadcastChannel('app-sync');

// Send to all tabs
channel.postMessage({
  type: 'USER_LOGGED_OUT',
  timestamp: Date.now()
});

// Receive
channel.onmessage = (event) => {
  switch (event.data.type) {
    case 'USER_LOGGED_OUT':
      redirectToLogin();
      break;
    case 'THEME_CHANGED':
      updateTheme(event.data.theme);
      break;
  }
};

// Cleanup
channel.close();
```

---

## Web Crypto API

```javascript
// Generate random values
const randomBytes = crypto.getRandomValues(new Uint8Array(32));
const uuid = crypto.randomUUID();

// Hash data
async function hashSHA256(data) {
  const encoder = new TextEncoder();
  const dataBuffer = encoder.encode(data);
  const hashBuffer = await crypto.subtle.digest('SHA-256', dataBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}
```

---

## Permissions API

```javascript
// Query permission status
async function checkPermission(name) {
  try {
    const result = await navigator.permissions.query({ name });
    
    // Listen for changes
    result.addEventListener('change', () => {
      console.log(`${name} permission changed to: ${result.state}`);
      onPermissionChange(name, result.state);
    });
    
    return result.state; // 'granted', 'denied', or 'prompt'
  } catch (error) {
    return 'unknown';
  }
}

// Request permission at appropriate time (after user action)
async function requestPermission(type) {
  switch (type) {
    case 'notifications':
      return Notification.requestPermission();
    case 'geolocation':
      return new Promise((resolve) => {
        navigator.geolocation.getCurrentPosition(
          () => resolve('granted'),
          () => resolve('denied')
        );
      });
    case 'camera':
      try {
        await navigator.mediaDevices.getUserMedia({ video: true });
        return 'granted';
      } catch {
        return 'denied';
      }
  }
}
```

---

## Best Practices Checklist

- [ ] Feature detection before using APIs
- [ ] Fallbacks for unsupported browsers
- [ ] Proper error handling for all async APIs
- [ ] Cleanup observers and listeners
- [ ] Request permissions in context (after user action)
- [ ] Handle permission changes gracefully
- [ ] HTTPS required for secure APIs
- [ ] Test across browsers and devices

---

**References:**
- [MDN Web APIs](https://developer.mozilla.org/en-US/docs/Web/API)
- [Project Fugu Tracker](https://fugu-tracker.web.app/)
- [Can I Use](https://caniuse.com/)
- [Chrome Web Platform Status](https://chromestatus.com/)
