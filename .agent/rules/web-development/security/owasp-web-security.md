# Web Security Best Practices Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** OWASP Top 10 2021, CSP Level 3, WebAuthn
> **Priority:** P0 - Critical for all web projects

---

You are an expert in web security and secure coding practices, following OWASP guidelines and modern security standards.

## Key Principles

- Follow OWASP Top 10 2021 guidelines
- Implement defense in depth
- Validate and sanitize all user inputs
- Use HTTPS everywhere
- Follow principle of least privilege
- Keep dependencies updated
- Monitor and log security events

---

## OWASP Top 10 (2021)

### A01: Broken Access Control

```javascript
// Server-side authorization check - ALWAYS verify on server
async function getDocument(req, res) {
  const document = await Document.findById(req.params.id);
  
  // Verify ownership or permission
  if (!document) {
    return res.status(404).json({ error: 'Not found' });
  }
  
  if (document.ownerId !== req.user.id && !req.user.isAdmin) {
    // Log security event
    logger.warn('Unauthorized access attempt', {
      userId: req.user.id,
      documentId: req.params.id,
      ip: req.ip
    });
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  return res.json(document);
}

// Role-based middleware
function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}

app.delete('/users/:id', requireRole('admin'), deleteUser);
app.put('/posts/:id', requireRole('admin', 'editor'), updatePost);
```

### A02: Cryptographic Failures

```javascript
import { randomBytes, scrypt, timingSafeEqual } from 'crypto';
import bcrypt from 'bcrypt';

// Hash passwords with bcrypt (cost factor 12+)
async function hashPassword(password) {
  const saltRounds = 12; // Increase over time as hardware improves
  return bcrypt.hash(password, saltRounds);
}

async function verifyPassword(password, hash) {
  return bcrypt.compare(password, hash);
}

// Generate secure random tokens
function generateSecureToken(bytes = 32) {
  return randomBytes(bytes).toString('hex');
}

// Encrypt sensitive data at rest
import { createCipheriv, createDecipheriv } from 'crypto';

function encrypt(plaintext, key) {
  const iv = randomBytes(16);
  const cipher = createCipheriv('aes-256-gcm', key, iv);
  
  let encrypted = cipher.update(plaintext, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const authTag = cipher.getAuthTag();
  
  return {
    iv: iv.toString('hex'),
    encrypted,
    authTag: authTag.toString('hex')
  };
}
```

### A03: Injection

#### SQL Injection Prevention
```javascript
// ❌ VULNERABLE - Never do this!
const query = `SELECT * FROM users WHERE id = ${userInput}`;

// ✅ SAFE - Parameterized queries
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);

// ✅ SAFE - Using ORM (Prisma example)
const user = await prisma.user.findUnique({
  where: { id: userId }
});

// ✅ SAFE - TypeORM with query builder
const user = await userRepository
  .createQueryBuilder('user')
  .where('user.id = :id', { id: userId })
  .getOne();
```

#### XSS Prevention
```javascript
// ❌ VULNERABLE - DOM-based XSS
element.innerHTML = userInput;

// ✅ SAFE - Use textContent for plain text
element.textContent = userInput;

// ✅ SAFE - Sanitize if HTML is needed
import DOMPurify from 'dompurify';

const cleanHTML = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
  ALLOWED_ATTR: ['href', 'title'],
  ALLOW_DATA_ATTR: false
});
element.innerHTML = cleanHTML;

// ✅ React auto-escapes by default
return <div>{userInput}</div>;

// ⚠️ Dangerous - use with DOMPurify only
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />
```

#### Command Injection Prevention
```javascript
// ❌ VULNERABLE
exec(`ls ${userInput}`);

// ✅ SAFE - Use execFile with arguments array
import { execFile } from 'child_process';

execFile('ls', ['-la', sanitizedPath], (error, stdout) => {
  // Handle output
});

// ✅ SAFE - Validate against allowlist
const allowedCommands = ['list', 'status', 'version'];
if (!allowedCommands.includes(command)) {
  throw new Error('Invalid command');
}
```

### A04: Insecure Design

- Implement threat modeling early
- Define security requirements in design phase
- Use secure design patterns
- Perform security architecture reviews
- Implement security user stories

### A05: Security Misconfiguration

```javascript
// Express security configuration
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

const app = express();

// Remove X-Powered-By header
app.disable('x-powered-by');

// Apply security headers
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  standardHeaders: true,
  legacyHeaders: false
});
app.use(limiter);

// Stricter rate limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts'
});
app.use('/api/auth', authLimiter);

// Environment configuration
if (process.env.NODE_ENV === 'production') {
  // Enforce HTTPS
  app.use((req, res, next) => {
    if (req.header('x-forwarded-proto') !== 'https') {
      res.redirect(`https://${req.header('host')}${req.url}`);
    } else {
      next();
    }
  });
}

// Don't expose stack traces in production
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    error: process.env.NODE_ENV === 'production' 
      ? 'Internal server error' 
      : err.message
  });
});
```

### A06: Vulnerable and Outdated Components

```bash
# Regular security audits
npm audit
npm audit fix

# Use lockfiles for reproducible builds
npm ci

# Automated vulnerability scanning
npx snyk test

# Check for outdated packages
npm outdated

# Update dependencies safely
npx npm-check-updates
```

```json
// package.json - Enable automated updates
{
  "scripts": {
    "security:audit": "npm audit --audit-level=moderate",
    "security:check": "snyk test"
  }
}
```

### A07: Identification and Authentication Failures

```javascript
// Secure session configuration
import session from 'express-session';
import RedisStore from 'connect-redis';

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET,
  name: 'sessionId', // Don't use default name
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true,           // HTTPS only
    httpOnly: true,         // No JavaScript access
    sameSite: 'strict',     // CSRF protection
    maxAge: 1000 * 60 * 60, // 1 hour
    domain: '.example.com'
  }
}));

// Regenerate session on privilege change
async function login(user, req) {
  return new Promise((resolve, reject) => {
    req.session.regenerate((err) => {
      if (err) return reject(err);
      req.session.userId = user.id;
      req.session.role = user.role;
      resolve();
    });
  });
}

// Account lockout
const loginAttempts = new Map();
const MAX_ATTEMPTS = 5;
const LOCKOUT_TIME = 15 * 60 * 1000; // 15 minutes

async function handleLogin(email, password, ip) {
  const key = `${email}:${ip}`;
  const attempts = loginAttempts.get(key) || { count: 0, lockedUntil: 0 };
  
  if (Date.now() < attempts.lockedUntil) {
    throw new Error('Account temporarily locked');
  }
  
  const user = await User.findByEmail(email);
  const valid = user && await verifyPassword(password, user.passwordHash);
  
  if (!valid) {
    attempts.count++;
    if (attempts.count >= MAX_ATTEMPTS) {
      attempts.lockedUntil = Date.now() + LOCKOUT_TIME;
    }
    loginAttempts.set(key, attempts);
    throw new Error('Invalid credentials');
  }
  
  loginAttempts.delete(key);
  return user;
}
```

### A08: Software and Data Integrity Failures

```html
<!-- Subresource Integrity for external scripts -->
<script 
  src="https://cdn.example.com/library.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9Gq..."
  crossorigin="anonymous">
</script>

<link 
  rel="stylesheet"
  href="https://cdn.example.com/styles.css"
  integrity="sha384-..."
  crossorigin="anonymous">
```

```javascript
// Verify webhook signatures
import crypto from 'crypto';

function verifyWebhookSignature(payload, signature, secret) {
  const expectedSig = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
  
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSig)
  );
}
```

### A09: Security Logging and Monitoring Failures

```javascript
// Structured security logging
import winston from 'winston';

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'security.log' })
  ]
});

function logSecurityEvent(event) {
  securityLogger.info({
    timestamp: new Date().toISOString(),
    type: event.type,
    userId: event.userId,
    ip: event.ip,
    userAgent: event.userAgent,
    action: event.action,
    result: event.result,
    metadata: event.metadata
  });
}

// Log security-relevant events
logSecurityEvent({
  type: 'authentication',
  action: 'login_failed',
  result: 'failure',
  ip: req.ip,
  metadata: { email: req.body.email, attempts: 3 }
});

logSecurityEvent({
  type: 'authorization',
  action: 'access_denied',
  userId: req.user.id,
  ip: req.ip,
  metadata: { resource: '/admin', method: 'GET' }
});
```

### A10: Server-Side Request Forgery (SSRF)

```javascript
// Validate and whitelist URLs
const ALLOWED_HOSTS = ['api.trusted.com', 'cdn.trusted.com'];
const BLOCKED_IP_RANGES = [
  /^127\./,           // Localhost
  /^10\./,            // Private
  /^172\.(1[6-9]|2\d|3[01])\./,  // Private
  /^192\.168\./,      // Private
  /^0\./,             // Reserved
  /^169\.254\./       // Link-local
];

async function validateUrl(urlString) {
  const url = new URL(urlString);
  
  // Check protocol
  if (!['http:', 'https:'].includes(url.protocol)) {
    throw new Error('Invalid protocol');
  }
  
  // Check host whitelist
  if (!ALLOWED_HOSTS.includes(url.hostname)) {
    throw new Error('Host not allowed');
  }
  
  // Resolve DNS and check for internal IPs
  const addresses = await dns.promises.resolve(url.hostname);
  for (const addr of addresses) {
    for (const range of BLOCKED_IP_RANGES) {
      if (range.test(addr)) {
        throw new Error('Internal IP not allowed');
      }
    }
  }
  
  return url.href;
}
```

---

## Security Headers

### Complete Security Headers Configuration

```javascript
// Express with Helmet
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        (req, res) => `'nonce-${res.locals.nonce}'`
      ],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      fontSrc: ["'self'"],
      connectSrc: ["'self'", "https://api.example.com"],
      mediaSrc: ["'self'"],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
      upgradeInsecureRequests: []
    }
  },
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: { policy: 'same-origin' },
  crossOriginResourcePolicy: { policy: 'same-origin' },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
}));

// Generate nonce for inline scripts
app.use((req, res, next) => {
  res.locals.nonce = crypto.randomBytes(16).toString('base64');
  next();
});
```

### Headers Reference

```http
# Content Security Policy
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' 'nonce-abc123';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self';
  connect-src 'self' https://api.example.com;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
  upgrade-insecure-requests;

# Cross-Origin Isolation
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Resource-Policy: same-origin

# HSTS - Force HTTPS
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

# Prevent MIME sniffing
X-Content-Type-Options: nosniff

# Clickjacking protection
X-Frame-Options: DENY

# Referrer Policy
Referrer-Policy: strict-origin-when-cross-origin

# Permissions Policy
Permissions-Policy: geolocation=(), camera=(), microphone=(), payment=()
```

---

## CSRF Protection

### Token-Based CSRF
```javascript
import csrf from 'csurf';

const csrfProtection = csrf({ 
  cookie: {
    httpOnly: true,
    secure: true,
    sameSite: 'strict'
  }
});

app.use(csrfProtection);

// Send token to client
app.get('/form', (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() });
});
```

```html
<!-- Include in forms -->
<form method="POST" action="/submit">
  <input type="hidden" name="_csrf" value="{{csrfToken}}">
  <!-- form fields -->
  <button type="submit">Submit</button>
</form>
```

### SPA CSRF Protection
```javascript
// Send token via header for API requests
fetch('/api/action', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrfToken
  },
  credentials: 'include',
  body: JSON.stringify(data)
});
```

### SameSite Cookies (Primary Defense)
```javascript
res.cookie('session', sessionId, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',  // Best protection
  // sameSite: 'lax',  // Allows top-level navigation
  maxAge: 3600000
});
```

---

## Authentication Best Practices

### Password Requirements (NIST Guidelines)
```javascript
import zxcvbn from 'zxcvbn';

function validatePassword(password) {
  const errors = [];
  
  // Minimum length (NIST recommends 8, but 12+ is better)
  if (password.length < 12) {
    errors.push('Password must be at least 12 characters');
  }
  
  // Maximum length (allow long passphrases)
  if (password.length > 128) {
    errors.push('Password must be at most 128 characters');
  }
  
  // Check password strength
  const strength = zxcvbn(password);
  if (strength.score < 3) {
    errors.push('Password is too weak: ' + strength.feedback.warning);
  }
  
  // Check against breached passwords
  const isBreached = await checkHaveIBeenPwned(password);
  if (isBreached) {
    errors.push('This password has been found in data breaches');
  }
  
  return { valid: errors.length === 0, errors };
}

// Check Have I Been Pwned API
async function checkHaveIBeenPwned(password) {
  const hash = crypto.createHash('sha1').update(password).digest('hex').toUpperCase();
  const prefix = hash.slice(0, 5);
  const suffix = hash.slice(5);
  
  const response = await fetch(`https://api.pwnedpasswords.com/range/${prefix}`);
  const data = await response.text();
  
  return data.includes(suffix);
}
```

### WebAuthn / Passkeys (Passwordless)
```javascript
import { 
  generateRegistrationOptions,
  verifyRegistrationResponse,
  generateAuthenticationOptions,
  verifyAuthenticationResponse
} from '@simplewebauthn/server';

// Registration
async function startRegistration(user) {
  const options = await generateRegistrationOptions({
    rpName: 'My App',
    rpID: 'example.com',
    userID: user.id,
    userName: user.email,
    authenticatorSelection: {
      authenticatorAttachment: 'platform',
      userVerification: 'preferred',
      residentKey: 'preferred'
    }
  });
  
  // Store challenge in session
  req.session.challenge = options.challenge;
  
  return options;
}

// Frontend registration
const credential = await navigator.credentials.create({
  publicKey: registrationOptions
});

// Verify registration response
async function finishRegistration(user, response) {
  const verification = await verifyRegistrationResponse({
    response,
    expectedChallenge: req.session.challenge,
    expectedOrigin: 'https://example.com',
    expectedRPID: 'example.com'
  });
  
  if (verification.verified) {
    // Store credential
    await saveCredential(user.id, verification.registrationInfo);
  }
  
  return verification.verified;
}
```

### JWT Best Practices
```javascript
import jwt from 'jsonwebtoken';

// Short-lived access tokens
function generateAccessToken(user) {
  return jwt.sign(
    { 
      userId: user.id, 
      role: user.role,
      type: 'access'
    },
    process.env.JWT_ACCESS_SECRET,
    { 
      expiresIn: '15m',
      algorithm: 'RS256',  // Use asymmetric algorithm
      issuer: 'https://example.com',
      audience: 'https://api.example.com'
    }
  );
}

// Longer-lived refresh tokens
function generateRefreshToken(user) {
  return jwt.sign(
    { 
      userId: user.id,
      tokenVersion: user.tokenVersion,  // For revocation
      type: 'refresh'
    },
    process.env.JWT_REFRESH_SECRET,
    { 
      expiresIn: '7d',
      algorithm: 'RS256'
    }
  );
}

// Verify token
function verifyAccessToken(token) {
  try {
    return jwt.verify(token, process.env.JWT_ACCESS_PUBLIC_KEY, {
      algorithms: ['RS256'],
      issuer: 'https://example.com',
      audience: 'https://api.example.com'
    });
  } catch (error) {
    return null;
  }
}

// Revoke all tokens for a user
async function revokeAllTokens(userId) {
  await User.increment('tokenVersion', { where: { id: userId } });
}
```

---

## Input Validation

### Schema Validation with Zod
```javascript
import { z } from 'zod';

// Define strict schemas
const UserRegistrationSchema = z.object({
  email: z.string()
    .email('Invalid email format')
    .max(254, 'Email too long')
    .transform(e => e.toLowerCase().trim()),
  
  password: z.string()
    .min(12, 'Password must be at least 12 characters')
    .max(128, 'Password too long'),
  
  username: z.string()
    .min(3, 'Username too short')
    .max(30, 'Username too long')
    .regex(/^[a-zA-Z0-9_]+$/, 'Invalid characters in username'),
  
  age: z.number()
    .int('Age must be an integer')
    .min(13, 'Must be at least 13 years old')
    .max(150, 'Invalid age')
    .optional(),
    
  website: z.string()
    .url('Invalid URL')
    .optional()
    .or(z.literal(''))
});

// Validate in route handler
app.post('/register', async (req, res) => {
  const result = UserRegistrationSchema.safeParse(req.body);
  
  if (!result.success) {
    return res.status(400).json({
      errors: result.error.issues.map(i => ({
        field: i.path.join('.'),
        message: i.message
      }))
    });
  }
  
  // result.data is typed and validated
  await createUser(result.data);
});
```

### File Upload Security
```javascript
import multer from 'multer';
import { fileTypeFromBuffer } from 'file-type';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
    files: 5
  },
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    
    if (!allowedMimes.includes(file.mimetype)) {
      return cb(new Error('Invalid file type'), false);
    }
    
    cb(null, true);
  }
});

// Additional validation on content
async function validateFileContent(buffer, expectedType) {
  const type = await fileTypeFromBuffer(buffer);
  
  if (!type || !expectedType.includes(type.mime)) {
    throw new Error('File content does not match expected type');
  }
  
  return type;
}

app.post('/upload', upload.single('file'), async (req, res) => {
  // Validate actual file content
  const type = await validateFileContent(
    req.file.buffer, 
    ['image/jpeg', 'image/png', 'image/webp']
  );
  
  // Generate random filename
  const filename = `${crypto.randomUUID()}.${type.ext}`;
  
  // Store file securely
  await storeFile(filename, req.file.buffer);
});
```

---

## CORS Configuration

```javascript
import cors from 'cors';

const corsOptions = {
  origin: (origin, callback) => {
    const allowedOrigins = [
      'https://app.example.com',
      'https://admin.example.com'
    ];
    
    // Allow requests with no origin (mobile apps, Postman)
    // In production, you may want to be stricter
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token'],
  exposedHeaders: ['X-RateLimit-Limit', 'X-RateLimit-Remaining'],
  maxAge: 86400 // 24 hours
};

app.use(cors(corsOptions));

// Handle preflight
app.options('*', cors(corsOptions));
```

---

## API Security

```javascript
// Rate limiting with sliding window
import { RateLimiterRedis } from 'rate-limiter-flexible';

const rateLimiter = new RateLimiterRedis({
  storeClient: redisClient,
  keyPrefix: 'ratelimit',
  points: 100,           // Requests
  duration: 60,          // Per 60 seconds
  blockDuration: 60 * 5  // Block for 5 minutes if exceeded
});

async function rateLimitMiddleware(req, res, next) {
  try {
    const key = req.user?.id || req.ip;
    await rateLimiter.consume(key);
    next();
  } catch (error) {
    res.status(429).json({ error: 'Too many requests' });
  }
}

// API versioning
app.use('/api/v1', v1Router);
app.use('/api/v2', v2Router);

// Request validation middleware
function validateRequest(schema) {
  return (req, res, next) => {
    const result = schema.safeParse({
      body: req.body,
      query: req.query,
      params: req.params
    });
    
    if (!result.success) {
      return res.status(400).json({ errors: result.error.issues });
    }
    
    req.validated = result.data;
    next();
  };
}
```

---

## Security Testing Checklist

### Pre-Deployment
- [ ] OWASP Top 10 vulnerabilities checked
- [ ] All user inputs validated and sanitized
- [ ] Authentication and session management secure
- [ ] Authorization checks on all endpoints
- [ ] Security headers configured
- [ ] HTTPS enforced with HSTS
- [ ] CSRF protection implemented
- [ ] Rate limiting configured
- [ ] Dependencies audited for vulnerabilities
- [ ] Sensitive data encrypted at rest
- [ ] Logs do not contain sensitive data
- [ ] Error messages are generic for users

### Ongoing
- [ ] Dependency vulnerabilities monitored
- [ ] Security logging and alerting active
- [ ] Regular penetration testing
- [ ] Security incident response plan in place

---

**References:**
- [OWASP Top 10](https://owasp.org/Top10/)
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/)
- [Mozilla Security Guidelines](https://infosec.mozilla.org/guidelines/web_security)
- [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [WebAuthn Guide](https://webauthn.guide/)
