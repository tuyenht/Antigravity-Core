# Accessibility Standards (A11y)

**Version:** 1.0  
**Updated:** 2026-01-16  
**Compliance:** WCAG 2.1 AA

---

## Overview

These standards ensure our applications are accessible to all users, including those with disabilities. We target WCAG 2.1 Level AA compliance as the minimum standard.

---

## 1. Semantic HTML

**Always use semantic HTML elements:**

```html
<!-- ✅ GOOD - Semantic -->
<header>
  <nav>
    <ul>
      <li><a href="/">Home</a></li>
    </ul>
  </nav>
</header>

<main>
  <article>
    <h1>Article Title</h1>
    <p>Content...</p>
  </article>
</main>

<footer>
  <p>&copy; 2026 Company</p>
</footer>

<!-- ❌ BAD - Non-semantic -->
<div class="header">
  <div class="nav">...</div>
</div>
```

---

## 2. ARIA Attributes

**Use ARIA when semantic HTML isn't enough:**

```html
<!-- ✅ Button with ARIA -->
<button 
  aria-label="Close dialog" 
  aria-pressed="false"
  onclick={closeDialog}
>
  <span aria-hidden="true">×</span>
</button>

<!-- ✅ Custom dropdown -->
<div role="combobox" aria-expanded="false" aria-haspopup="listbox">
  <input type="text" aria-autocomplete="list" />
  <ul role="listbox">
    <li role="option">Option 1</li>
  </ul>
</div>

<!-- ✅ Loading state -->
<div role="status" aria-live="polite" aria-busy="true">
  Loading...
</div>
```

---

## 3. Keyboard Navigation

**All interactive elements must be keyboard accessible:**

```javascript
// ✅ Keyboard support
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick();
    }
  }}
>
  Click me
</div>

// ✅ Focus management
const dialogRef = useRef();

function openDialog() {
  setIsOpen(true);
  // Focus first element
  setTimeout(() => dialogRef.current?.focus(), 0);
}

// ✅ Skip links
<a href="#main-content" className="skip-link">
  Skip to main content
</a>
```

---

## 4. Color Contrast

**WCAG AA Requirements:**
- Normal text: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum
- UI components: 3:1 minimum

```css
/* ✅ GOOD - High contrast */
.button {
  background: #1a73e8; /* Blue */
  color: #ffffff;      /* White - 4.5:1 ratio */
}

/* ❌ BAD - Low contrast */
.button-bad {
  background: #cccccc; /* Light gray */
  color: #ffffff;      /* White - 1.3:1 ratio ❌ */
}

/* ✅ Never rely on color alone */
.error {
  color: #d32f2f;
  border-left: 4px solid #d32f2f; /* Visual indicator */
}
.error::before {
  content: "⚠ ";  /* Icon indicator */
}
```

---

## 5. Form Accessibility

```html
<!-- ✅ Proper labels -->
<label for="email">Email Address</label>
<input 
  type="email" 
  id="email" 
  name="email"
  required
  aria-required="true"
  aria-invalid="false"
  aria-describedby="email-error"
/>
<span id="email-error" role="alert">
  <!-- Error message appears here -->
</span>

<!-- ✅ Fieldset for radio groups -->
<fieldset>
  <legend>Choose your plan</legend>
  <input type="radio" id="basic" name="plan" value="basic" />
  <label for="basic">Basic</label>
  
  <input type="radio" id="pro" name="plan" value="pro" />
  <label for="pro">Pro</label>
</fieldset>
```

---

## 6. Images & Media

```html
<!-- ✅ Descriptive alt text -->
<img 
  src="chart.png" 
  alt="Bar chart showing 40% increase in sales for Q4 2025"
/>

<!-- ✅ Decorative images -->
<img src="decoration.png" alt="" />  <!-- Empty alt for decorative -->

<!-- ✅ Video accessibility -->
<video controls>
  <source src="video.mp4" type="video/mp4" />
  <track kind="captions" src="captions.vtt" srclang="en" label="English" />
  <track kind="descriptions" src="descriptions.vtt" srclang="en" />
</video>
```

---

## 7. Screen Reader Support

```jsx
// ✅ Announce dynamic content
<div role="status" aria-live="polite">
  {successMessage}
</div>

// ✅ Hide decorative elements
<span aria-hidden="true" className="icon">★</span>

// ✅ Accessible modals
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-desc"
>
  <h2 id="dialog-title">Confirm Action</h2>
  <p id="dialog-desc">Are you sure you want to delete this item?</p>
</div>
```

---

## 8. Mobile Accessibility

```css
/* ✅ Touch target size (min 44x44px) */
.button {
  min-width: 44px;
  min-height: 44px;
  padding: 12px 24px;
}

/* ✅ Adequate spacing */
.button + .button {
  margin-left: 8px;  /* Min 8px spacing */
}

/* ✅ Zoom support */
html {
  /* Don't disable zoom */
  /* ❌ user-scalable=no */
}
```

---

## 9. Testing Checklist

**Before deployment:**

- [ ] All images have alt text
- [ ] Color contrast meets AA (4.5:1)
- [ ] All interactive elements keyboard accessible
- [ ] Forms have proper labels
- [ ] ARIA used correctly (not overused)
- [ ] Focus indicators visible
- [ ] Skip links present
- [ ] Heading hierarchy logical (h1→h2→h3)
- [ ] Tables have proper headers
- [ ] Error messages descriptive

**Tools:**
- axe DevTools (browser extension)
- WAVE (web accessibility evaluation tool)
- Lighthouse accessibility audit
- Screen readers: NVDA (Windows), JAWS, VoiceOver (Mac/iOS)

---

## 10. Framework-Specific Patterns

### React
```jsx
// ✅ Focus management with refs
const firstInput = useRef();

useEffect(() => {
  firstInput.current?.focus();
}, []);

// ✅ Announce route changes
import { useLocation } from 'react-router-dom';

function RouteAnnouncer() {
  const location = useLocation();
  const [message, setMessage] = useState('');
  
  useEffect(() => {
    setMessage(`Navigated to ${location.pathname}`);
  }, [location]);
  
  return <div role="status" aria-live="polite" aria-atomic="true">{message}</div>;
}
```

### Vue
```vue
<!-- ✅ v-focus directive -->
<input v-focus />

<script>
export default {
  directives: {
    focus: {
      mounted(el) {
        el.focus();
      }
    }
  }
}
</script>
```

---

**References:**
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
- [A11y Project](https://www.a11yproject.com/)
