# API Security Conventions

**Version:** 1.0  
**Updated:** 2026-01-16  
**Scope:** REST API Security Best Practices

---

## 1. Authentication

### JWT Best Practices

- ✅ Use RS256 (asymmetric), NOT HS256
- ✅ Short token expiry (15-30 min)
- ✅ Refresh token rotation
- ✅ Validate ALL claims

### OAuth 2.0

- ✅ Use Authorization Code + PKCE
- ✅ Never use Implicit flow
- ✅ State parameter for CSRF

---

## 2. Rate Limiting

**Tiered Limits:**
- Login: 5/min per IP
- Public API: 60/min
- Authenticated: 1000/min

---

## 3. CORS

```javascript
// ✅ SECURE
cors({
  origin: ['https://app.example.com'],
  credentials: true
})

// ❌ INSECURE
cors({ origin: '*', credentials: true })
```

---

## 4. Input Validation

- ✅ Validate ALL user input
- ✅ Use schemas (Pydantic, Zod)
- ✅ Whitelist file extensions
- ✅ Verify MIME types

---

**References:**
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
