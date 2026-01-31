# Mobile Security Best Practices Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Standards:** OWASP MASVS 2.0 | MSTG  
> **Priority:** P0 - Load for security-critical apps

---

You are an expert in Mobile Application Security.

## Core Principles

- Trust no one (Zero Trust)
- Defense in depth
- Secure data at rest and in transit
- Minimize data collection

---

## 1) OWASP MASVS Compliance

### Security Levels
```
┌─────────────────────────────────────────┐
│         OWASP MASVS 2.0 LEVELS          │
├─────────────────────────────────────────┤
│                                         │
│  MASVS-L1: Standard Security           │
│  ├── Basic security requirements       │
│  ├── All apps should meet this         │
│  └── Protection against common attacks │
│                                         │
│  MASVS-L2: Defense-in-Depth            │
│  ├── Financial apps                    │
│  ├── Healthcare apps                   │
│  ├── Apps handling sensitive data      │
│  └── Advanced threat model             │
│                                         │
│  MASVS-R: Resilience (Hardening)       │
│  ├── Anti-tampering                    │
│  ├── Anti-reversing                    │
│  └── Root/jailbreak detection          │
│                                         │
│  CATEGORIES:                            │
│  • MASVS-STORAGE: Secure data storage  │
│  • MASVS-CRYPTO: Cryptography          │
│  • MASVS-AUTH: Authentication          │
│  • MASVS-NETWORK: Network security     │
│  • MASVS-PLATFORM: Platform security   │
│  • MASVS-CODE: Code quality            │
│  • MASVS-RESILIENCE: Anti-tampering    │
│                                         │
└─────────────────────────────────────────┘
```

---

## 2) Secure Storage

### React Native Implementation
```tsx
// ==========================================
// SECURE STORAGE - REACT NATIVE
// ==========================================

import * as Keychain from 'react-native-keychain';
import EncryptedStorage from 'react-native-encrypted-storage';

// ✅ Secure token storage using Keychain/Keystore
export class SecureTokenStorage {
  private static readonly SERVICE_NAME = 'com.myapp.auth';

  static async storeTokens(
    accessToken: string,
    refreshToken: string
  ): Promise<void> {
    try {
      // Store access token
      await Keychain.setGenericPassword(
        'accessToken',
        accessToken,
        {
          service: `${this.SERVICE_NAME}.access`,
          accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
          // Require biometric to access (optional)
          accessControl: Keychain.ACCESS_CONTROL.BIOMETRY_CURRENT_SET,
        }
      );

      // Store refresh token separately
      await Keychain.setGenericPassword(
        'refreshToken',
        refreshToken,
        {
          service: `${this.SERVICE_NAME}.refresh`,
          accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
        }
      );
    } catch (error) {
      console.error('Failed to store tokens securely');
      throw error;
    }
  }

  static async getAccessToken(): Promise<string | null> {
    try {
      const credentials = await Keychain.getGenericPassword({
        service: `${this.SERVICE_NAME}.access`,
      });
      return credentials ? credentials.password : null;
    } catch {
      return null;
    }
  }

  static async getRefreshToken(): Promise<string | null> {
    try {
      const credentials = await Keychain.getGenericPassword({
        service: `${this.SERVICE_NAME}.refresh`,
      });
      return credentials ? credentials.password : null;
    } catch {
      return null;
    }
  }

  static async clearTokens(): Promise<void> {
    await Keychain.resetGenericPassword({
      service: `${this.SERVICE_NAME}.access`,
    });
    await Keychain.resetGenericPassword({
      service: `${this.SERVICE_NAME}.refresh`,
    });
  }
}


// ==========================================
// ENCRYPTED LOCAL STORAGE
// ==========================================

// ✅ For larger data that needs encryption
export class SecureStorage {
  static async setItem(key: string, value: string): Promise<void> {
    await EncryptedStorage.setItem(key, value);
  }

  static async getItem(key: string): Promise<string | null> {
    return EncryptedStorage.getItem(key);
  }

  static async removeItem(key: string): Promise<void> {
    await EncryptedStorage.removeItem(key);
  }

  // Store structured data
  static async setObject<T>(key: string, value: T): Promise<void> {
    await EncryptedStorage.setItem(key, JSON.stringify(value));
  }

  static async getObject<T>(key: string): Promise<T | null> {
    const data = await EncryptedStorage.getItem(key);
    return data ? JSON.parse(data) : null;
  }
}


// ==========================================
// ❌ NEVER DO THIS
// ==========================================

// ❌ Plain AsyncStorage for sensitive data
import AsyncStorage from '@react-native-async-storage/async-storage';
await AsyncStorage.setItem('authToken', token);  // NOT SECURE!

// ❌ Hardcoded secrets
const API_KEY = 'sk-1234567890abcdef';  // EXPOSED IN BUNDLE!

// ❌ Console logging sensitive data
console.log('User password:', password);  // VISIBLE IN LOGS!
```

### iOS Keychain (Swift)
```swift
// ==========================================
// KEYCHAIN SERVICE - iOS
// ==========================================

import Security

class KeychainService {
    enum KeychainError: Error {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }
    
    static func save(
        _ data: Data,
        service: String,
        account: String,
        accessControl: SecAccessControl? = nil
    ) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            // Only accessible when device unlocked
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        
        // Add biometric protection if specified
        if let accessControl = accessControl {
            query[kSecAttrAccessControl as String] = accessControl
        }
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    static func load(service: String, account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        return data
    }
    
    // With biometric protection
    static func createBiometricAccessControl() -> SecAccessControl? {
        return SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            nil
        )
    }
}

// Usage
let accessControl = KeychainService.createBiometricAccessControl()
try KeychainService.save(
    tokenData,
    service: "com.myapp.auth",
    account: "accessToken",
    accessControl: accessControl
)
```

### Android EncryptedSharedPreferences
```kotlin
// ==========================================
// ENCRYPTED STORAGE - ANDROID
// ==========================================

import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

class SecureStorage(context: Context) {
    
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()
    
    private val securePrefs = EncryptedSharedPreferences.create(
        context,
        "secure_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
    
    fun saveToken(key: String, token: String) {
        securePrefs.edit()
            .putString(key, token)
            .apply()
    }
    
    fun getToken(key: String): String? {
        return securePrefs.getString(key, null)
    }
    
    fun removeToken(key: String) {
        securePrefs.edit()
            .remove(key)
            .apply()
    }
    
    fun clearAll() {
        securePrefs.edit()
            .clear()
            .apply()
    }
}


// ==========================================
// ENCRYPTED ROOM DATABASE
// ==========================================

import net.zetetic.database.sqlcipher.SQLiteDatabase
import net.zetetic.database.sqlcipher.SupportFactory

class DatabaseProvider(context: Context) {
    
    private val passphrase: ByteArray
        get() = getOrCreateDatabaseKey()
    
    fun getDatabase(): AppDatabase {
        val factory = SupportFactory(passphrase)
        
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "app_database"
        )
            .openHelperFactory(factory)
            .build()
    }
    
    private fun getOrCreateDatabaseKey(): ByteArray {
        // Store key in Android Keystore
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)
        
        if (!keyStore.containsAlias("db_key")) {
            val keyGenerator = KeyGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_AES,
                "AndroidKeyStore"
            )
            keyGenerator.init(
                KeyGenParameterSpec.Builder(
                    "db_key",
                    KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
                )
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                    .build()
            )
            keyGenerator.generateKey()
        }
        
        return keyStore.getKey("db_key", null).encoded
    }
}
```

---

## 3) Network Security

### Certificate Pinning
```tsx
// ==========================================
// REACT NATIVE CERTIFICATE PINNING
// ==========================================

// Using react-native-ssl-pinning
import { fetch as pinnedFetch } from 'react-native-ssl-pinning';

export async function secureApiCall(
  url: string,
  options: RequestInit = {}
): Promise<Response> {
  return pinnedFetch(url, {
    ...options,
    // Pin certificates
    sslPinning: {
      certs: ['cert1', 'cert2'],  // Cert files in /assets
    },
    // Or pin public keys (more flexible)
    pkPinning: true,
    // Disable caching of sensitive responses
    disableAllSecurity: false,
  });
}


// ==========================================
// USING TRUSTKIT (iOS)
// ==========================================

// TrustKit.plist or initialization
let trustKitConfig: [String: Any] = [
    kTSKSwizzleNetworkDelegates: false,
    kTSKPinnedDomains: [
        "api.example.com": [
            kTSKEnforcePinning: true,
            kTSKIncludeSubdomains: true,
            kTSKPublicKeyHashes: [
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=",
            ],
            // Report pinning failures
            kTSKReportUris: ["https://report.example.com/pinning"]
        ]
    ]
]

TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
```

### Android Network Security Config
```xml
<!-- res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Production: Pin certificates -->
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2025-01-01">
            <!-- SHA-256 of Subject Public Key Info -->
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
            <!-- Backup pin -->
            <pin digest="SHA-256">BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=</pin>
        </pin-set>
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </domain-config>
    
    <!-- Block all cleartext (HTTP) -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </base-config>
</network-security-config>

<!-- AndroidManifest.xml -->
<application
    android:networkSecurityConfig="@xml/network_security_config">
```

### Secure API Client
```tsx
// ==========================================
// SECURE API CLIENT
// ==========================================

const API_CONFIG = {
  // Load from environment, not hardcoded
  baseURL: Config.API_BASE_URL,
  timeout: 30000,
};

class SecureApiClient {
  private accessToken: string | null = null;
  
  constructor() {
    this.initializeTokens();
  }
  
  private async initializeTokens() {
    this.accessToken = await SecureTokenStorage.getAccessToken();
  }
  
  async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    // Always use HTTPS
    const url = `${API_CONFIG.baseURL}${endpoint}`;
    
    if (!url.startsWith('https://')) {
      throw new Error('HTTPS required for all API calls');
    }
    
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };
    
    // Add auth token if available
    if (this.accessToken) {
      headers['Authorization'] = `Bearer ${this.accessToken}`;
    }
    
    const response = await fetch(url, {
      ...options,
      headers,
    });
    
    // Handle token refresh
    if (response.status === 401) {
      const refreshed = await this.refreshTokens();
      if (refreshed) {
        return this.request(endpoint, options);
      }
      throw new AuthError('Session expired');
    }
    
    if (!response.ok) {
      throw new ApiError(response.status, await response.text());
    }
    
    return response.json();
  }
  
  private async refreshTokens(): Promise<boolean> {
    const refreshToken = await SecureTokenStorage.getRefreshToken();
    if (!refreshToken) return false;
    
    try {
      const response = await fetch(`${API_CONFIG.baseURL}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });
      
      if (response.ok) {
        const { accessToken, refreshToken: newRefresh } = await response.json();
        await SecureTokenStorage.storeTokens(accessToken, newRefresh);
        this.accessToken = accessToken;
        return true;
      }
    } catch {
      // Refresh failed
    }
    
    await SecureTokenStorage.clearTokens();
    return false;
  }
}
```

---

## 4) Biometric Authentication

### React Native Biometrics
```tsx
// ==========================================
// BIOMETRIC AUTHENTICATION
// ==========================================

import ReactNativeBiometrics, { BiometryTypes } from 'react-native-biometrics';

const rnBiometrics = new ReactNativeBiometrics();

export class BiometricAuth {
  
  // Check if biometrics available
  static async isAvailable(): Promise<{
    available: boolean;
    biometryType: BiometryTypes | null;
  }> {
    const { available, biometryType } = await rnBiometrics.isSensorAvailable();
    return { available, biometryType };
  }
  
  // Prompt for biometric authentication
  static async authenticate(
    promptMessage: string = 'Confirm your identity'
  ): Promise<boolean> {
    try {
      const { success } = await rnBiometrics.simplePrompt({
        promptMessage,
        cancelButtonText: 'Cancel',
        fallbackPromptMessage: 'Use passcode',
      });
      return success;
    } catch {
      return false;
    }
  }
  
  // Create keys for secure operations
  static async createKeys(): Promise<string | null> {
    try {
      const { publicKey } = await rnBiometrics.createKeys();
      return publicKey;
    } catch {
      return null;
    }
  }
  
  // Sign data with biometric-protected key
  static async signWithBiometrics(
    payload: string,
    promptMessage: string
  ): Promise<string | null> {
    try {
      const { success, signature } = await rnBiometrics.createSignature({
        promptMessage,
        payload,
        cancelButtonText: 'Cancel',
      });
      
      return success ? signature : null;
    } catch {
      return null;
    }
  }
}


// ==========================================
// USAGE IN LOGIN FLOW
// ==========================================

function LoginScreen() {
  const [biometricAvailable, setBiometricAvailable] = useState(false);
  
  useEffect(() => {
    BiometricAuth.isAvailable().then(({ available }) => {
      setBiometricAvailable(available);
    });
  }, []);
  
  const handleBiometricLogin = async () => {
    const authenticated = await BiometricAuth.authenticate(
      'Sign in with biometrics'
    );
    
    if (authenticated) {
      // Get stored credentials
      const token = await SecureTokenStorage.getAccessToken();
      if (token) {
        // User is authenticated
        navigation.replace('Home');
      }
    }
  };
  
  return (
    <View>
      {/* Regular login form */}
      
      {biometricAvailable && (
        <TouchableOpacity onPress={handleBiometricLogin}>
          <Text>Sign in with Face ID / Fingerprint</Text>
        </TouchableOpacity>
      )}
    </View>
  );
}
```

### iOS Face ID / Touch ID
```swift
// ==========================================
// LOCAL AUTHENTICATION - iOS
// ==========================================

import LocalAuthentication

class BiometricAuthService {
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    static func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        default:
            return .none
        }
    }
    
    static func authenticate(
        reason: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(.failure(error ?? BiometricError.notAvailable))
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(true))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(BiometricError.unknown))
                }
            }
        }
    }
}

// Info.plist required key
// NSFaceIDUsageDescription: "We use Face ID to securely sign you in"
```

---

## 5) Root/Jailbreak Detection

### Detection Implementation
```tsx
// ==========================================
// ROOT/JAILBREAK DETECTION
// ==========================================

import JailMonkey from 'jail-monkey';

export class SecurityChecker {
  
  // Check for compromised device
  static isDeviceCompromised(): boolean {
    return JailMonkey.isJailBroken();
  }
  
  // Check for debugging
  static isBeingDebugged(): boolean {
    return JailMonkey.isDebuggedMode();
  }
  
  // Check if running on emulator
  static isEmulator(): boolean {
    return !JailMonkey.isOnRealDevice();
  }
  
  // Comprehensive security check
  static performSecurityCheck(): {
    passed: boolean;
    issues: string[];
  } {
    const issues: string[] = [];
    
    if (this.isDeviceCompromised()) {
      issues.push('Device is rooted/jailbroken');
    }
    
    if (this.isBeingDebugged()) {
      issues.push('App is being debugged');
    }
    
    if (__DEV__) {
      // Allow emulator in development
    } else if (this.isEmulator()) {
      issues.push('App is running on emulator');
    }
    
    return {
      passed: issues.length === 0,
      issues,
    };
  }
}


// ==========================================
// USAGE AT APP STARTUP
// ==========================================

function App() {
  const [securityPassed, setSecurityPassed] = useState<boolean | null>(null);
  
  useEffect(() => {
    // Don't check in development
    if (__DEV__) {
      setSecurityPassed(true);
      return;
    }
    
    const { passed, issues } = SecurityChecker.performSecurityCheck();
    
    if (!passed) {
      // Log security issues (without sensitive data)
      analytics.logEvent('security_check_failed', { issues });
    }
    
    setSecurityPassed(passed);
  }, []);
  
  if (securityPassed === null) {
    return <SplashScreen />;
  }
  
  if (!securityPassed) {
    return (
      <SecurityWarningScreen
        message="This app cannot run on a rooted/jailbroken device."
      />
    );
  }
  
  return <MainApp />;
}
```

### Android Root Detection (Native)
```kotlin
// ==========================================
// ROOT DETECTION - ANDROID
// ==========================================

import com.scottyab.rootbeer.RootBeer

class SecurityService(private val context: Context) {
    
    private val rootBeer = RootBeer(context)
    
    fun isDeviceRooted(): Boolean {
        return rootBeer.isRooted
    }
    
    fun isRunningOnEmulator(): Boolean {
        return (Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || "google_sdk" == Build.PRODUCT)
    }
    
    fun isDebuggerAttached(): Boolean {
        return Debug.isDebuggerConnected()
    }
    
    fun performSecurityCheck(): SecurityCheckResult {
        val issues = mutableListOf<String>()
        
        if (isDeviceRooted()) {
            issues.add("ROOTED_DEVICE")
        }
        
        if (!BuildConfig.DEBUG && isRunningOnEmulator()) {
            issues.add("EMULATOR_DETECTED")
        }
        
        if (!BuildConfig.DEBUG && isDebuggerAttached()) {
            issues.add("DEBUGGER_ATTACHED")
        }
        
        return SecurityCheckResult(
            passed = issues.isEmpty(),
            issues = issues
        )
    }
}
```

---

## 6) Code Protection

### Android ProGuard/R8
```proguard
# proguard-rules.pro

# Keep application class
-keep class com.myapp.** { *; }

# Obfuscate aggressively
-repackageclasses ''
-allowaccessmodification
-optimizations !code/simplification/arithmetic

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Keep Retrofit
-keepattributes Signature
-keepattributes *Annotation*

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Encrypt strings (using DexGuard/DexProtector)
# -encryptstrings class com.myapp.security.** { *; }
```

### iOS Build Settings
```swift
// Build Settings for Release

/*
 * Compiler Optimizations:
 * - Swift Optimization Level: -O (Optimize for Speed)
 * - Enable Bitcode: YES
 * - Strip Debug Symbols: YES
 * - Debug Information Format: DWARF
 *
 * Security Settings:
 * - Enable Hardened Runtime: YES
 * - Code Signing Identity: Distribution certificate
 */

// Remove debug code
#if !DEBUG
    // Production-only code
#endif

// Disable debug logging in production
func debugLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}
```

---

## 7) Sensitive Screen Protection

### Prevent Screenshots/Recording
```tsx
// ==========================================
// SCREEN PROTECTION
// ==========================================

import { usePreventScreenCapture, addScreenshotListener } from 'expo-screen-capture';
// Or: react-native-screenshot-prevent

function SensitiveScreen() {
  // Prevent screenshots and screen recording
  usePreventScreenCapture();
  
  useEffect(() => {
    // Detect screenshot attempts
    const subscription = addScreenshotListener(() => {
      Alert.alert(
        'Screenshot Detected',
        'Screenshots are not allowed on this screen for security reasons.'
      );
      // Log for security monitoring
      analytics.logEvent('screenshot_attempt', {
        screen: 'SensitiveScreen',
      });
    });
    
    return () => subscription.remove();
  }, []);
  
  return (
    <View>
      {/* Sensitive content */}
    </View>
  );
}


// ==========================================
// iOS - Blur on App Switch
// ==========================================

// AppDelegate.swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var blurView: UIVisualEffectView?
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Add blur when app goes to background
        let blurEffect = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView?.frame = application.keyWindow?.bounds ?? .zero
        application.keyWindow?.addSubview(blurView!)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Remove blur when app becomes active
        blurView?.removeFromSuperview()
        blurView = nil
    }
}


// ==========================================
// REACT NATIVE - Hide Content on Background
// ==========================================

import { AppState, View } from 'react-native';

function SecureWrapper({ children }: { children: React.ReactNode }) {
  const [isBackground, setIsBackground] = useState(false);
  const appState = useRef(AppState.currentState);
  
  useEffect(() => {
    const subscription = AppState.addEventListener('change', nextAppState => {
      if (nextAppState === 'active') {
        setIsBackground(false);
      } else if (nextAppState === 'inactive' || nextAppState === 'background') {
        setIsBackground(true);
      }
      appState.current = nextAppState;
    });
    
    return () => subscription.remove();
  }, []);
  
  if (isBackground) {
    return (
      <View style={styles.blurOverlay}>
        <Text>App is in background</Text>
      </View>
    );
  }
  
  return <>{children}</>;
}
```

---

## 8) Security Checklist

### Pre-Release Security Audit
```
┌─────────────────────────────────────────┐
│       SECURITY AUDIT CHECKLIST          │
├─────────────────────────────────────────┤
│                                         │
│  DATA STORAGE (MASVS-STORAGE):          │
│  □ Sensitive data in Keychain/Keystore │
│  □ No plaintext credentials            │
│  □ Database encrypted (SQLCipher)      │
│  □ Clipboard cleared after paste       │
│  □ Screenshot protection enabled       │
│  □ Keyboard cache disabled for PII     │
│                                         │
│  NETWORK (MASVS-NETWORK):               │
│  □ HTTPS only (no HTTP)                │
│  □ Certificate pinning configured      │
│  □ No hardcoded API keys              │
│  □ TLS 1.3 preferred                   │
│  □ Certificate validation enabled      │
│                                         │
│  AUTHENTICATION (MASVS-AUTH):           │
│  □ Biometric authentication works      │
│  □ Session timeout implemented         │
│  □ Secure token storage                │
│  □ Token refresh mechanism             │
│  □ Logout clears all tokens            │
│                                         │
│  CODE QUALITY (MASVS-CODE):             │
│  □ ProGuard/R8 enabled (Android)       │
│  □ Debug code removed                  │
│  □ Logging disabled in production      │
│  □ Third-party libs updated            │
│  □ No deprecated APIs                  │
│                                         │
│  RESILIENCE (MASVS-RESILIENCE):         │
│  □ Root/jailbreak detection           │
│  □ Tampering detection                 │
│  □ Emulator detection (production)     │
│  □ Debugger detection                  │
│  □ Integrity verification              │
│                                         │
│  PLATFORM (MASVS-PLATFORM):             │
│  □ Permissions minimized              │
│  □ Deep links validated                │
│  □ WebView hardened                    │
│  □ IPC secured                        │
│                                         │
└─────────────────────────────────────────┘
```

### Security Testing Tools
```
┌─────────────────────────────────────────┐
│         SECURITY TESTING TOOLS          │
├─────────────────────────────────────────┤
│                                         │
│  STATIC ANALYSIS (SAST):                │
│  • MobSF (Mobile Security Framework)   │
│  • Semgrep                            │
│  • SonarQube                          │
│                                         │
│  DYNAMIC ANALYSIS (DAST):               │
│  • Frida                              │
│  • Objection                          │
│  • Drozer (Android)                   │
│                                         │
│  PENETRATION TESTING:                   │
│  • Burp Suite                         │
│  • OWASP ZAP                          │
│  • Charles Proxy                      │
│                                         │
│  AUTOMATED SCANNING:                    │
│  • AppSweep                           │
│  • NowSecure                          │
│  • ImmuniWeb                          │
│                                         │
└─────────────────────────────────────────┘
```

---

## Best Practices Summary

### Storage
- [ ] Keychain/Keystore for secrets
- [ ] Encrypted databases
- [ ] No plaintext credentials
- [ ] Secure cache handling

### Network
- [ ] HTTPS everywhere
- [ ] Certificate pinning
- [ ] No hardcoded keys
- [ ] Token refresh logic

### Authentication
- [ ] Biometric support
- [ ] Session management
- [ ] Secure deep links
- [ ] MFA when possible

### Code
- [ ] Obfuscation enabled
- [ ] Debug code removed
- [ ] Logs disabled
- [ ] Dependencies updated

---

**References:**
- [OWASP MASVS](https://mas.owasp.org/MASVS/)
- [OWASP MSTG](https://mas.owasp.org/MASTG/)
- [Apple Security Guide](https://developer.apple.com/documentation/security)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
