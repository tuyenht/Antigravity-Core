# Security Testing Templates

**Version:** 1.0  
**Updated:** 2026-01-16

---

## 1. SQL Injection Testing

```javascript
// Jest/Vitest
describe('SQL Injection Prevention', () => {
  test('blocks SQL injection in search', async () => {
    const attacks = [
      "'; DROP TABLE users; --",
      "' OR '1'='1",
      "admin'--",
      "' UNION SELECT * FROM passwords--"
    ];
    
    for (const attack of attacks) {
      const response = await request(app)
        .get(`/api/search?q=${attack}`);
      
      expect(response.status).not.toBe(500);
      expect(response.body.results).toBeDefined();
    }
  });
});
```

---

## 2. XSS Testing

```javascript
test('escapes XSS in comments', async () => {
  const xssPayloads = [
    '<script>alert("XSS")</script>',
    '<img src=x onerror=alert(1)>',
    '<svg onload=alert(1)>',
  ];
  
  for (const payload of xssPayloads) {
    const response = await request(app)
      .post('/api/comments')
      .send({ text: payload });
    
    const page = await request(app).get('/comments');
    expect(page.text).not.toContain('<script>');
    expect(page.text).toContain('&lt;script&gt;');
  }
});
```

---

## 3. Authentication Testing

```python
# pytest
def test_rate_limiting_on_login(client):
    """Test that login is rate-limited after 5 attempts."""
    for i in range(6):
        response = client.post('/login', json={
            'email': 'test@example.com',
            'password': 'wrong'
        })
    
    assert response.status_code == 429  # Too Many Requests
```

---

## 4. Authorization Testing

```javascript
test('prevents unauthorized access', async () => {
  const regularUser = await createUser({ role: 'user' });
  const token = generateToken(regularUser);
  
  const response = await request(app)
    .delete('/api/users/123')
    .set('Authorization', `Bearer ${token}`);
  
  expect(response.status).toBe(403); // Forbidden
});
```

---

## 5. Security Headers Testing

```javascript
test('includes security headers', async () => {
  const response = await request(app).get('/');
  
  expect(response.headers['x-frame-options']).toBe('DENY');
  expect(response.headers['x-content-type-options']).toBe('nosniff');
  expect(response.headers['strict-transport-security']).toBeDefined();
  expect(response.headers['content-security-policy']).toBeDefined();
});
```

---

**Full test suite templates available in codebase.**
