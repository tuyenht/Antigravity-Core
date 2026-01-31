# WebAssembly (WASM) Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** WebAssembly 2.0, WASI, Component Model
> **Priority:** P2 - Load for performance-critical applications

---

You are an expert in WebAssembly development, integration, and optimization.

## Key Principles

- Use WebAssembly for CPU-intensive, performance-critical code
- Minimize JavaScript/WASM boundary crossings
- Optimize for both size and speed
- Use streaming compilation for faster loading
- Implement proper error handling and fallbacks
- Choose the right source language for your use case

---

## When to Use WebAssembly

### Good Use Cases
| Use Case | Why WASM |
|----------|----------|
| Image/Video processing | CPU-intensive pixel operations |
| Cryptography/Hashing | Performance-critical, constant-time |
| Game engines/Physics | Complex calculations, 60fps required |
| Audio processing | Real-time DSP |
| Compression | Algorithms benefit from low-level control |
| Scientific computing | Heavy math, SIMD opportunities |
| CAD/3D modeling | Complex geometry calculations |

### When NOT to Use
- Simple DOM manipulation (JavaScript is faster)
- IO-bound operations (network, storage)
- Small utility functions (overhead not worth it)
- When JavaScript is fast enough

---

## Loading WebAssembly

### Basic Loading
```javascript
// Simple instantiation
const response = await fetch('module.wasm');
const bytes = await response.arrayBuffer();
const { instance } = await WebAssembly.instantiate(bytes);

// Use exported functions
const result = instance.exports.add(1, 2);
```

### Streaming Compilation (Recommended)
```javascript
// Faster - compiles while downloading
const { instance } = await WebAssembly.instantiateStreaming(
  fetch('module.wasm'),
  importObject
);

// With proper error handling
async function loadWasm(url, imports = {}) {
  try {
    if (WebAssembly.instantiateStreaming) {
      return await WebAssembly.instantiateStreaming(
        fetch(url),
        imports
      );
    } else {
      // Fallback for older browsers
      const response = await fetch(url);
      const bytes = await response.arrayBuffer();
      return await WebAssembly.instantiate(bytes, imports);
    }
  } catch (error) {
    console.error('WASM loading failed:', error);
    throw error;
  }
}
```

### Caching Compiled Modules
```javascript
// Cache compiled module in IndexedDB
async function loadCachedWasm(url, imports = {}) {
  const cache = await caches.open('wasm-cache-v1');
  const cachedResponse = await cache.match(url);
  
  if (cachedResponse) {
    const module = await WebAssembly.compileStreaming(cachedResponse);
    return WebAssembly.instantiate(module, imports);
  }
  
  const response = await fetch(url);
  cache.put(url, response.clone());
  
  return WebAssembly.instantiateStreaming(response, imports);
}
```

### ES Module Integration
```javascript
// With bundler support (Vite, webpack)
import init, { greet, add } from './pkg/my_wasm.js';

async function main() {
  await init(); // Initialize WASM
  
  console.log(greet('World'));
  console.log(add(1, 2));
}

main();
```

---

## JavaScript Interop

### Import Object
```javascript
const importObject = {
  env: {
    // Memory (required for most modules)
    memory: new WebAssembly.Memory({ initial: 256, maximum: 512 }),
    
    // Table for function pointers
    table: new WebAssembly.Table({ initial: 0, element: 'anyfunc' }),
    
    // Import JS functions
    console_log: (ptr, len) => {
      const bytes = new Uint8Array(memory.buffer, ptr, len);
      const text = new TextDecoder().decode(bytes);
      console.log(text);
    },
    
    // Math functions
    sin: Math.sin,
    cos: Math.cos,
    
    // Performance
    performance_now: () => performance.now()
  },
  
  js: {
    // Custom namespace
    fetch_data: async (url) => { /* ... */ }
  }
};

const { instance } = await WebAssembly.instantiateStreaming(
  fetch('module.wasm'),
  importObject
);
```

### Memory Access
```javascript
// Create shared memory
const memory = new WebAssembly.Memory({ 
  initial: 256,    // 256 * 64KB = 16MB
  maximum: 512,    // 512 * 64KB = 32MB
  shared: false    // Set to true for threading
});

// Access memory as typed arrays
const buffer = memory.buffer;
const uint8 = new Uint8Array(buffer);
const int32 = new Int32Array(buffer);
const float64 = new Float64Array(buffer);

// Read string from WASM memory
function readString(ptr, len) {
  const bytes = new Uint8Array(memory.buffer, ptr, len);
  return new TextDecoder().decode(bytes);
}

// Write string to WASM memory
function writeString(str, ptr) {
  const bytes = new TextEncoder().encode(str);
  const view = new Uint8Array(memory.buffer, ptr, bytes.length);
  view.set(bytes);
  return bytes.length;
}

// Pass array to WASM
function passArray(arr, ptr) {
  const view = new Float64Array(memory.buffer, ptr, arr.length);
  view.set(arr);
}
```

### Type Conversions
```javascript
// WASM only supports: i32, i64, f32, f64

// Booleans
const boolToWasm = (b) => b ? 1 : 0;
const wasmToBool = (i) => i !== 0;

// Strings (need pointers)
class WasmString {
  constructor(memory, allocFn, deallocFn) {
    this.memory = memory;
    this.alloc = allocFn;
    this.dealloc = deallocFn;
  }
  
  encode(str) {
    const bytes = new TextEncoder().encode(str);
    const ptr = this.alloc(bytes.length);
    new Uint8Array(this.memory.buffer, ptr, bytes.length).set(bytes);
    return { ptr, len: bytes.length };
  }
  
  decode(ptr, len) {
    return new TextDecoder().decode(
      new Uint8Array(this.memory.buffer, ptr, len)
    );
  }
  
  free(ptr, len) {
    this.dealloc(ptr, len);
  }
}
```

---

## Rust + WebAssembly

### Setup
```bash
# Install wasm-pack
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# Create new project
cargo new --lib my-wasm
cd my-wasm
```

### Cargo.toml
```toml
[package]
name = "my-wasm"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib", "rlib"]

[dependencies]
wasm-bindgen = "0.2"
js-sys = "0.3"
web-sys = { version = "0.3", features = ["console", "Document", "Element"] }
serde = { version = "1.0", features = ["derive"] }
serde-wasm-bindgen = "0.6"

# Optimize for size
[profile.release]
opt-level = 's'
lto = true
```

### Basic Rust WASM
```rust
use wasm_bindgen::prelude::*;

// Import JS functions
#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
    
    #[wasm_bindgen(js_namespace = console, js_name = log)]
    fn log_u32(n: u32);
}

// Export Rust functions
#[wasm_bindgen]
pub fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

#[wasm_bindgen]
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[wasm_bindgen]
pub fn fibonacci(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

// Struct export
#[wasm_bindgen]
pub struct Calculator {
    value: f64,
}

#[wasm_bindgen]
impl Calculator {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Calculator {
        Calculator { value: 0.0 }
    }
    
    pub fn add(&mut self, n: f64) {
        self.value += n;
    }
    
    pub fn subtract(&mut self, n: f64) {
        self.value -= n;
    }
    
    pub fn get_value(&self) -> f64 {
        self.value
    }
    
    pub fn reset(&mut self) {
        self.value = 0.0;
    }
}
```

### Rust with Web APIs
```rust
use wasm_bindgen::prelude::*;
use web_sys::{Document, Element, Window};

#[wasm_bindgen]
pub fn manipulate_dom() -> Result<(), JsValue> {
    let window: Window = web_sys::window().unwrap();
    let document: Document = window.document().unwrap();
    
    let element: Element = document.create_element("div")?;
    element.set_inner_html("Created from Rust!");
    element.set_attribute("class", "rust-element")?;
    
    document.body().unwrap().append_child(&element)?;
    
    Ok(())
}

#[wasm_bindgen]
pub async fn fetch_data(url: &str) -> Result<JsValue, JsValue> {
    use wasm_bindgen_futures::JsFuture;
    use web_sys::{Request, RequestInit, Response};
    
    let mut opts = RequestInit::new();
    opts.method("GET");
    
    let request = Request::new_with_str_and_init(url, &opts)?;
    
    let window = web_sys::window().unwrap();
    let response: Response = JsFuture::from(window.fetch_with_request(&request))
        .await?
        .dyn_into()?;
    
    let json = JsFuture::from(response.json()?).await?;
    Ok(json)
}
```

### Build and Use
```bash
# Build for web
wasm-pack build --target web

# Build for bundler (npm)
wasm-pack build --target bundler
```

```javascript
// Using the built package
import init, { greet, Calculator } from './pkg/my_wasm.js';

async function main() {
  await init();
  
  console.log(greet('Rust'));
  
  const calc = new Calculator();
  calc.add(10);
  calc.subtract(3);
  console.log(calc.get_value()); // 7
  calc.free(); // Important: free memory
}
```

---

## AssemblyScript

### Setup
```bash
npm init
npm install --save-dev assemblyscript
npx asinit .
```

### Basic AssemblyScript
```typescript
// assembly/index.ts

// Export functions
export function add(a: i32, b: i32): i32 {
  return a + b;
}

export function fibonacci(n: i32): i32 {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

// Class
export class Vector2 {
  x: f64;
  y: f64;
  
  constructor(x: f64, y: f64) {
    this.x = x;
    this.y = y;
  }
  
  add(other: Vector2): Vector2 {
    return new Vector2(this.x + other.x, this.y + other.y);
  }
  
  magnitude(): f64 {
    return Math.sqrt(this.x * this.x + this.y * this.y);
  }
}

// Array processing
export function sumArray(arr: Float64Array): f64 {
  let sum: f64 = 0;
  for (let i = 0; i < arr.length; i++) {
    sum += arr[i];
  }
  return sum;
}

// SIMD operations (if enabled)
export function addVectorsSIMD(a: Float32Array, b: Float32Array): Float32Array {
  const result = new Float32Array(a.length);
  for (let i = 0; i < a.length; i += 4) {
    const va = v128.load(a.dataStart + i * 4);
    const vb = v128.load(b.dataStart + i * 4);
    const vr = f32x4.add(va, vb);
    v128.store(result.dataStart + i * 4, vr);
  }
  return result;
}
```

### Build
```bash
npm run asbuild
```

### Use
```javascript
import { add, fibonacci, Vector2 } from './build/release.js';

console.log(add(1, 2));
console.log(fibonacci(10));

const v1 = new Vector2(3, 4);
console.log(v1.magnitude()); // 5
```

---

## WASM SIMD

### Check Support
```javascript
const simdSupported = WebAssembly.validate(new Uint8Array([
  0x00, 0x61, 0x73, 0x6d, // WASM magic
  0x01, 0x00, 0x00, 0x00, // Version
  0x01, 0x05, 0x01, 0x60, 0x00, 0x01, 0x7b, // Type section
  0x03, 0x02, 0x01, 0x00, // Function section
  0x0a, 0x0a, 0x01, 0x08, 0x00, 0xfd, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x0b // Code with SIMD
]));
```

### Rust SIMD
```rust
use std::arch::wasm32::*;

#[wasm_bindgen]
pub fn add_vectors_simd(a: &[f32], b: &[f32]) -> Vec<f32> {
    let mut result = Vec::with_capacity(a.len());
    
    for i in (0..a.len()).step_by(4) {
        unsafe {
            let va = v128_load(a.as_ptr().add(i) as *const v128);
            let vb = v128_load(b.as_ptr().add(i) as *const v128);
            let vr = f32x4_add(va, vb);
            
            let mut temp = [0f32; 4];
            v128_store(temp.as_mut_ptr() as *mut v128, vr);
            result.extend_from_slice(&temp);
        }
    }
    
    result
}
```

---

## WASM Threads

### Enable SharedArrayBuffer
```http
# Required headers
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

### Shared Memory
```javascript
// Create shared memory
const memory = new WebAssembly.Memory({
  initial: 256,
  maximum: 512,
  shared: true  // Enable sharing
});

// Share with workers
const worker = new Worker('worker.js');
worker.postMessage({ memory });
```

### Worker Setup
```javascript
// worker.js
self.onmessage = async (e) => {
  const { memory } = e.data;
  
  const { instance } = await WebAssembly.instantiateStreaming(
    fetch('parallel.wasm'),
    { env: { memory } }
  );
  
  // Run parallel computation
  instance.exports.compute_chunk(startIndex, endIndex);
  
  self.postMessage('done');
};
```

### Rust with Threads
```rust
// Cargo.toml
[dependencies]
wasm-bindgen = "0.2"
rayon = "1.5"
wasm-bindgen-rayon = "1.0"

// lib.rs
use rayon::prelude::*;
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn parallel_sum(data: &[f64]) -> f64 {
    data.par_iter().sum()
}

#[wasm_bindgen]
pub fn parallel_map(data: &[f64]) -> Vec<f64> {
    data.par_iter().map(|x| x * x).collect()
}
```

---

## WASI (WebAssembly System Interface)

```javascript
// Using WASI in browser with polyfill
import { WASI } from '@wasmer/wasi';
import { WasmFs } from '@aspect/wasm-fs';

const wasmFs = new WasmFs();
const wasi = new WASI({
  args: ['program', 'arg1'],
  env: { 'VAR': 'value' },
  bindings: {
    ...wasmFs.bindings
  }
});

const response = await fetch('program.wasm');
const bytes = await response.arrayBuffer();
const module = await WebAssembly.compile(bytes);

const instance = await WebAssembly.instantiate(module, {
  wasi_snapshot_preview1: wasi.wasiImport
});

wasi.start(instance);
```

---

## Performance Optimization

### Minimize Boundary Crossings
```javascript
// ❌ Bad - many boundary crossings
for (let i = 0; i < 1000000; i++) {
  wasmInstance.exports.process_item(data[i]);
}

// ✅ Good - pass entire array
const ptr = wasmInstance.exports.alloc(data.length * 8);
new Float64Array(memory.buffer, ptr, data.length).set(data);
wasmInstance.exports.process_all(ptr, data.length);
wasmInstance.exports.dealloc(ptr, data.length * 8);
```

### Batch Operations
```rust
#[wasm_bindgen]
pub fn process_batch(data: &[f64]) -> Vec<f64> {
    data.iter().map(|x| x.sqrt() * 2.0).collect()
}
```

### Memory Pre-allocation
```rust
// Pre-allocate buffers
static mut BUFFER: [f64; 1024] = [0.0; 1024];

#[wasm_bindgen]
pub fn get_buffer_ptr() -> *const f64 {
    unsafe { BUFFER.as_ptr() }
}

#[wasm_bindgen]
pub fn process_buffer(len: usize) {
    unsafe {
        for i in 0..len.min(1024) {
            BUFFER[i] = BUFFER[i].sqrt();
        }
    }
}
```

### Size Optimization (Rust)
```toml
# Cargo.toml
[profile.release]
opt-level = 'z'     # Optimize for size
lto = true          # Link-time optimization
codegen-units = 1   # Better optimization
panic = 'abort'     # Smaller panic handling

[dependencies]
wee_alloc = "0.4"   # Smaller allocator
```

```rust
// Use smaller allocator
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;
```

```bash
# Post-build optimization
wasm-opt -Oz -o optimized.wasm original.wasm
```

---

## Feature Detection & Fallbacks

```javascript
async function loadBestImplementation() {
  // Check WASM support
  if (typeof WebAssembly === 'undefined') {
    console.log('WASM not supported, using JS fallback');
    return import('./js-fallback.js');
  }
  
  // Check SIMD support
  const simdSupported = await checkSIMDSupport();
  
  if (simdSupported) {
    return loadWasm('./optimized-simd.wasm');
  } else {
    return loadWasm('./optimized.wasm');
  }
}

async function checkSIMDSupport() {
  try {
    return WebAssembly.validate(SIMD_TEST_BYTES);
  } catch {
    return false;
  }
}
```

---

## Debugging

### Source Maps
```bash
# Rust: Build with debug info
RUSTFLAGS="-C debuginfo=2" wasm-pack build --debug

# Enable DWARF in browser DevTools
```

### Console Logging from WASM
```rust
use web_sys::console;

#[wasm_bindgen]
pub fn debug_function(value: i32) {
    console::log_1(&format!("Value: {}", value).into());
}
```

### Performance Profiling
```javascript
// Measure WASM performance
console.time('wasm-compute');
const result = wasmInstance.exports.heavy_computation(data);
console.timeEnd('wasm-compute');

// Use Performance API
performance.mark('wasm-start');
wasmInstance.exports.process(data);
performance.mark('wasm-end');
performance.measure('wasm', 'wasm-start', 'wasm-end');
```

---

## Best Practices Checklist

- [ ] Use streaming compilation for faster loading
- [ ] Cache compiled modules
- [ ] Minimize JS/WASM boundary crossings
- [ ] Use SIMD when available
- [ ] Optimize for size in production
- [ ] Implement proper error handling
- [ ] Provide JavaScript fallbacks
- [ ] Profile before and after optimization
- [ ] Test across browsers
- [ ] Document WASM/JS interface

---

**References:**
- [WebAssembly.org](https://webassembly.org/)
- [Rust and WebAssembly](https://rustwasm.github.io/docs/book/)
- [AssemblyScript](https://www.assemblyscript.org/)
- [wasm-bindgen Guide](https://rustwasm.github.io/docs/wasm-bindgen/)
- [MDN WebAssembly](https://developer.mozilla.org/en-US/docs/WebAssembly)
