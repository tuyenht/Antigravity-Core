# Web Forms & Validation Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** HTML5 Forms, Constraint Validation API, ARIA 1.2
> **Priority:** P1 - Load for form-heavy applications

---

You are an expert in web forms, validation, and form UX best practices.

## Key Principles

- Use semantic HTML form elements
- Validate on both client and server (never trust client only)
- Provide immediate, inline feedback
- Ensure full accessibility with ARIA
- Keep forms simple and focused
- Use appropriate input types and modes

---

## Semantic Form Structure

### Basic Form
```html
<form id="registration" action="/api/register" method="POST" novalidate>
  <!-- novalidate: We'll handle validation with JS for better UX -->
  
  <fieldset>
    <legend>Personal Information</legend>
    
    <div class="field">
      <label for="fullName">
        Full Name
        <span class="required" aria-hidden="true">*</span>
      </label>
      <input 
        type="text" 
        id="fullName" 
        name="fullName"
        required
        autocomplete="name"
        aria-describedby="fullName-hint"
      >
      <span id="fullName-hint" class="hint">
        Enter your first and last name
      </span>
      <span id="fullName-error" class="error" role="alert" aria-live="polite"></span>
    </div>
    
    <div class="field">
      <label for="email">
        Email Address
        <span class="required" aria-hidden="true">*</span>
      </label>
      <input 
        type="email" 
        id="email" 
        name="email"
        required
        autocomplete="email"
        aria-describedby="email-error"
      >
      <span id="email-error" class="error" role="alert" aria-live="polite"></span>
    </div>
  </fieldset>
  
  <fieldset>
    <legend>Account Security</legend>
    
    <div class="field">
      <label for="password">
        Password
        <span class="required" aria-hidden="true">*</span>
      </label>
      <input 
        type="password" 
        id="password" 
        name="password"
        required
        minlength="12"
        autocomplete="new-password"
        aria-describedby="password-requirements password-error"
      >
      <ul id="password-requirements" class="hint">
        <li>At least 12 characters</li>
        <li>Mix of letters, numbers, and symbols</li>
      </ul>
      <div class="password-strength" aria-live="polite"></div>
      <span id="password-error" class="error" role="alert"></span>
    </div>
  </fieldset>
  
  <button type="submit">Create Account</button>
</form>
```

---

## Input Types & Attributes

### Specialized Input Types
```html
<!-- Email with validation -->
<input 
  type="email" 
  inputmode="email"
  autocomplete="email"
  required
>

<!-- Phone with numeric keyboard -->
<input 
  type="tel" 
  inputmode="tel"
  autocomplete="tel"
  pattern="[0-9]{10,}"
>

<!-- Number with constraints -->
<input 
  type="number" 
  inputmode="numeric"
  min="0" 
  max="100" 
  step="1"
>

<!-- Date with range -->
<input 
  type="date" 
  min="2024-01-01" 
  max="2024-12-31"
>

<!-- URL -->
<input 
  type="url" 
  inputmode="url"
  autocomplete="url"
  pattern="https://.*"
  placeholder="https://example.com"
>

<!-- Search -->
<input 
  type="search" 
  inputmode="search"
  autocomplete="off"
>

<!-- Credit card number -->
<input 
  type="text" 
  inputmode="numeric"
  autocomplete="cc-number"
  pattern="[0-9]{13,19}"
>
```

### inputmode Values
```html
<!-- Mobile keyboard optimization -->
<input inputmode="none">       <!-- No keyboard -->
<input inputmode="text">       <!-- Standard text -->
<input inputmode="tel">        <!-- Telephone -->
<input inputmode="url">        <!-- URL keyboard -->
<input inputmode="email">      <!-- Email keyboard -->
<input inputmode="numeric">    <!-- Numbers only -->
<input inputmode="decimal">    <!-- Numbers with decimal -->
<input inputmode="search">     <!-- Search optimized -->
```

### Autocomplete Values
```html
<!-- Personal -->
<input autocomplete="name">
<input autocomplete="given-name">
<input autocomplete="family-name">
<input autocomplete="email">
<input autocomplete="tel">
<input autocomplete="bday">

<!-- Address -->
<input autocomplete="street-address">
<input autocomplete="address-line1">
<input autocomplete="city">
<input autocomplete="postal-code">
<input autocomplete="country">

<!-- Payment -->
<input autocomplete="cc-name">
<input autocomplete="cc-number">
<input autocomplete="cc-exp">
<input autocomplete="cc-csc">

<!-- Passwords -->
<input autocomplete="current-password">
<input autocomplete="new-password">
<input autocomplete="one-time-code">
```

---

## CSS Validation Styles

### Basic Validation States
```css
/* Modern pseudo-classes (CSS 2024) */

/* Only show error states after user interaction */
input:user-invalid {
  border-color: var(--color-error);
  background-color: var(--color-error-bg);
}

input:user-valid {
  border-color: var(--color-success);
}

/* Fallback for browsers without :user-* support */
@supports not (selector(:user-invalid)) {
  input:invalid:not(:focus):not(:placeholder-shown) {
    border-color: var(--color-error);
  }
  
  input:valid:not(:placeholder-shown) {
    border-color: var(--color-success);
  }
}

/* Focus states */
input:focus {
  outline: 2px solid var(--color-focus);
  outline-offset: 2px;
}

input:focus:invalid {
  outline-color: var(--color-error);
}

/* Error message styling */
.error {
  color: var(--color-error);
  font-size: 0.875rem;
  margin-top: 0.25rem;
  display: none;
}

input:user-invalid ~ .error,
input[aria-invalid="true"] ~ .error {
  display: block;
}

/* Required indicator */
.required {
  color: var(--color-error);
  margin-left: 0.25rem;
}

/* Disabled state */
input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
```

### Visual Feedback
```css
:root {
  --color-error: #dc2626;
  --color-error-bg: #fef2f2;
  --color-success: #16a34a;
  --color-success-bg: #f0fdf4;
  --color-focus: #2563eb;
}

.field {
  position: relative;
  margin-bottom: 1.5rem;
}

.field label {
  display: block;
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.field input,
.field select,
.field textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 1rem;
  transition: border-color 0.15s, box-shadow 0.15s;
}

.field input:focus {
  border-color: var(--color-focus);
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

/* Icons for validation state */
.field.valid input {
  padding-right: 2.5rem;
  background-image: url("data:image/svg+xml,...");
  background-position: right 0.75rem center;
  background-repeat: no-repeat;
}

.field.invalid input {
  padding-right: 2.5rem;
  background-image: url("data:image/svg+xml,...");
  background-position: right 0.75rem center;
  background-repeat: no-repeat;
}
```

---

## Constraint Validation API

### Custom Validation
```javascript
const form = document.getElementById('registration');
const fields = form.querySelectorAll('input, select, textarea');

// Validate on blur
fields.forEach(field => {
  field.addEventListener('blur', () => validateField(field));
  field.addEventListener('input', () => clearError(field));
});

// Validate on submit
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  let isValid = true;
  
  fields.forEach(field => {
    if (!validateField(field)) {
      isValid = false;
    }
  });
  
  if (isValid) {
    await submitForm(form);
  } else {
    // Focus first invalid field
    form.querySelector(':invalid')?.focus();
  }
});

function validateField(field) {
  const errorEl = document.getElementById(`${field.id}-error`);
  
  // Check built-in validity
  if (!field.validity.valid) {
    const message = getErrorMessage(field);
    showError(field, errorEl, message);
    return false;
  }
  
  // Custom validation
  if (field.dataset.customValidation) {
    const customError = customValidators[field.dataset.customValidation]?.(field);
    if (customError) {
      showError(field, errorEl, customError);
      return false;
    }
  }
  
  clearError(field);
  return true;
}

function getErrorMessage(field) {
  const validity = field.validity;
  
  if (validity.valueMissing) {
    return `${field.labels[0]?.textContent || 'This field'} is required`;
  }
  if (validity.typeMismatch) {
    if (field.type === 'email') return 'Please enter a valid email address';
    if (field.type === 'url') return 'Please enter a valid URL';
    return 'Please enter a valid value';
  }
  if (validity.tooShort) {
    return `Must be at least ${field.minLength} characters`;
  }
  if (validity.tooLong) {
    return `Must be no more than ${field.maxLength} characters`;
  }
  if (validity.rangeUnderflow) {
    return `Must be at least ${field.min}`;
  }
  if (validity.rangeOverflow) {
    return `Must be at most ${field.max}`;
  }
  if (validity.patternMismatch) {
    return field.title || 'Please match the requested format';
  }
  
  return 'Please enter a valid value';
}

function showError(field, errorEl, message) {
  field.setAttribute('aria-invalid', 'true');
  field.classList.add('invalid');
  
  if (errorEl) {
    errorEl.textContent = message;
    field.setAttribute('aria-describedby', errorEl.id);
  }
}

function clearError(field) {
  const errorEl = document.getElementById(`${field.id}-error`);
  
  field.removeAttribute('aria-invalid');
  field.classList.remove('invalid');
  
  if (errorEl) {
    errorEl.textContent = '';
  }
}

// Custom validators
const customValidators = {
  passwordMatch(field) {
    const password = document.getElementById('password').value;
    if (field.value !== password) {
      return 'Passwords do not match';
    }
    return null;
  },
  
  async usernameAvailable(field) {
    const response = await fetch(`/api/check-username?q=${field.value}`);
    const { available } = await response.json();
    if (!available) {
      return 'This username is already taken';
    }
    return null;
  }
};
```

### setCustomValidity
```javascript
// Custom validation message
const passwordField = document.getElementById('password');
const confirmField = document.getElementById('confirmPassword');

confirmField.addEventListener('input', () => {
  if (confirmField.value !== passwordField.value) {
    confirmField.setCustomValidity('Passwords do not match');
  } else {
    confirmField.setCustomValidity(''); // Clear error
  }
});
```

---

## Zod Schema Validation

### Define Schemas
```typescript
import { z } from 'zod';

// User registration schema
const RegistrationSchema = z.object({
  fullName: z.string()
    .min(2, 'Name must be at least 2 characters')
    .max(100, 'Name is too long'),
  
  email: z.string()
    .email('Invalid email address')
    .toLowerCase()
    .trim(),
  
  password: z.string()
    .min(12, 'Password must be at least 12 characters')
    .regex(/[A-Z]/, 'Must contain uppercase letter')
    .regex(/[a-z]/, 'Must contain lowercase letter')
    .regex(/[0-9]/, 'Must contain number'),
  
  confirmPassword: z.string(),
  
  age: z.number()
    .int('Age must be a whole number')
    .min(13, 'Must be at least 13 years old')
    .max(120, 'Invalid age')
    .optional(),
  
  website: z.string()
    .url('Invalid URL')
    .optional()
    .or(z.literal('')),
  
  acceptTerms: z.literal(true, {
    errorMap: () => ({ message: 'You must accept the terms' })
  })
}).refine(data => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword']
});

// Infer TypeScript type from schema
type RegistrationForm = z.infer<typeof RegistrationSchema>;
```

### Validate with Zod
```typescript
function validateForm(formData: unknown) {
  const result = RegistrationSchema.safeParse(formData);
  
  if (!result.success) {
    // Transform Zod errors to field errors
    const fieldErrors: Record<string, string> = {};
    
    result.error.issues.forEach(issue => {
      const path = issue.path.join('.');
      if (!fieldErrors[path]) {
        fieldErrors[path] = issue.message;
      }
    });
    
    return { success: false, errors: fieldErrors };
  }
  
  return { success: true, data: result.data };
}

// Usage
const formData = Object.fromEntries(new FormData(form));
const validation = validateForm(formData);

if (!validation.success) {
  Object.entries(validation.errors).forEach(([field, message]) => {
    showError(document.getElementById(field), message);
  });
}
```

---

## React Hook Form + Zod

### Setup
```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Min 8 characters')
});

type FormData = z.infer<typeof schema>;

function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting, isValid },
    setError,
    reset
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    mode: 'onBlur', // Validate on blur
    reValidateMode: 'onChange'
  });
  
  const onSubmit = async (data: FormData) => {
    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        body: JSON.stringify(data)
      });
      
      if (!response.ok) {
        const error = await response.json();
        setError('root.serverError', { message: error.message });
        return;
      }
      
      // Success
      reset();
    } catch (err) {
      setError('root.serverError', { 
        message: 'Network error. Please try again.' 
      });
    }
  };
  
  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      {errors.root?.serverError && (
        <div role="alert" className="error-banner">
          {errors.root.serverError.message}
        </div>
      )}
      
      <div className="field">
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          {...register('email')}
          aria-invalid={!!errors.email}
          aria-describedby="email-error"
        />
        {errors.email && (
          <span id="email-error" className="error" role="alert">
            {errors.email.message}
          </span>
        )}
      </div>
      
      <div className="field">
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          {...register('password')}
          aria-invalid={!!errors.password}
          aria-describedby="password-error"
        />
        {errors.password && (
          <span id="password-error" className="error" role="alert">
            {errors.password.message}
          </span>
        )}
      </div>
      
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Signing in...' : 'Sign In'}
      </button>
    </form>
  );
}
```

### Field Arrays
```typescript
import { useFieldArray } from 'react-hook-form';

function DynamicForm() {
  const { control, register } = useForm({
    defaultValues: {
      emails: [{ value: '' }]
    }
  });
  
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'emails'
  });
  
  return (
    <form>
      {fields.map((field, index) => (
        <div key={field.id}>
          <input {...register(`emails.${index}.value`)} />
          <button type="button" onClick={() => remove(index)}>
            Remove
          </button>
        </div>
      ))}
      <button type="button" onClick={() => append({ value: '' })}>
        Add Email
      </button>
    </form>
  );
}
```

---

## FormData API

### Reading Form Data
```javascript
const form = document.getElementById('myForm');

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const formData = new FormData(form);
  
  // Get single value
  const email = formData.get('email');
  
  // Get multiple values (checkboxes)
  const interests = formData.getAll('interests');
  
  // Convert to object
  const data = Object.fromEntries(formData);
  
  // Convert to JSON
  const json = JSON.stringify(data);
  
  // Send as FormData (for file uploads)
  await fetch('/api/submit', {
    method: 'POST',
    body: formData  // Content-Type set automatically
  });
  
  // Or send as JSON
  await fetch('/api/submit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: json
  });
});
```

### Modifying FormData
```javascript
const formData = new FormData();

// Add fields
formData.set('name', 'John');
formData.append('tags', 'javascript');
formData.append('tags', 'react');

// Add file
const fileInput = document.querySelector('input[type="file"]');
formData.append('avatar', fileInput.files[0]);

// Delete field
formData.delete('name');

// Check if field exists
formData.has('tags'); // true

// Iterate
for (const [key, value] of formData) {
  console.log(key, value);
}
```

---

## File Uploads

### Drag and Drop Upload
```html
<div 
  class="dropzone" 
  id="dropzone"
  role="button"
  tabindex="0"
  aria-label="Upload area, drag and drop files here"
>
  <input 
    type="file" 
    id="fileInput"
    multiple
    accept="image/*,.pdf"
    class="sr-only"
  >
  <p>Drag files here or click to upload</p>
</div>
<div id="preview" class="preview"></div>
```

```javascript
const dropzone = document.getElementById('dropzone');
const fileInput = document.getElementById('fileInput');
const preview = document.getElementById('preview');

// Click to upload
dropzone.addEventListener('click', () => fileInput.click());
dropzone.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' || e.key === ' ') {
    fileInput.click();
  }
});

// Drag and drop
dropzone.addEventListener('dragover', (e) => {
  e.preventDefault();
  dropzone.classList.add('dragover');
});

dropzone.addEventListener('dragleave', () => {
  dropzone.classList.remove('dragover');
});

dropzone.addEventListener('drop', (e) => {
  e.preventDefault();
  dropzone.classList.remove('dragover');
  handleFiles(e.dataTransfer.files);
});

// File input change
fileInput.addEventListener('change', () => {
  handleFiles(fileInput.files);
});

function handleFiles(files) {
  Array.from(files).forEach(file => {
    // Validate
    if (!validateFile(file)) return;
    
    // Preview
    if (file.type.startsWith('image/')) {
      previewImage(file);
    }
    
    // Upload
    uploadFile(file);
  });
}

function validateFile(file) {
  const maxSize = 5 * 1024 * 1024; // 5MB
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
  
  if (file.size > maxSize) {
    alert('File too large. Maximum size is 5MB.');
    return false;
  }
  
  if (!allowedTypes.includes(file.type)) {
    alert('File type not allowed.');
    return false;
  }
  
  return true;
}

async function uploadFile(file) {
  const formData = new FormData();
  formData.append('file', file);
  
  try {
    const response = await fetch('/api/upload', {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) throw new Error('Upload failed');
    
    const result = await response.json();
    console.log('Uploaded:', result.url);
  } catch (error) {
    console.error('Upload error:', error);
  }
}
```

---

## Multi-Step Forms

### Progress Indicator
```html
<form id="wizard">
  <nav aria-label="Form progress">
    <ol class="steps">
      <li class="step active" aria-current="step">
        <span class="step-number">1</span>
        <span class="step-label">Personal Info</span>
      </li>
      <li class="step">
        <span class="step-number">2</span>
        <span class="step-label">Address</span>
      </li>
      <li class="step">
        <span class="step-number">3</span>
        <span class="step-label">Review</span>
      </li>
    </ol>
  </nav>
  
  <div class="step-content" data-step="1">
    <!-- Step 1 fields -->
  </div>
  
  <div class="step-content" data-step="2" hidden>
    <!-- Step 2 fields -->
  </div>
  
  <div class="step-content" data-step="3" hidden>
    <!-- Step 3 fields -->
  </div>
  
  <div class="actions">
    <button type="button" id="prevBtn" disabled>Previous</button>
    <button type="button" id="nextBtn">Next</button>
    <button type="submit" id="submitBtn" hidden>Submit</button>
  </div>
</form>
```

```javascript
class FormWizard {
  constructor(form) {
    this.form = form;
    this.currentStep = 1;
    this.totalSteps = form.querySelectorAll('.step-content').length;
    
    this.bindEvents();
    this.loadSavedProgress();
  }
  
  bindEvents() {
    document.getElementById('nextBtn').addEventListener('click', () => this.next());
    document.getElementById('prevBtn').addEventListener('click', () => this.prev());
    
    // Auto-save on input
    this.form.addEventListener('input', () => this.saveProgress());
  }
  
  async next() {
    if (!this.validateCurrentStep()) return;
    
    if (this.currentStep < this.totalSteps) {
      this.currentStep++;
      this.updateUI();
    }
  }
  
  prev() {
    if (this.currentStep > 1) {
      this.currentStep--;
      this.updateUI();
    }
  }
  
  validateCurrentStep() {
    const currentContent = this.form.querySelector(`[data-step="${this.currentStep}"]`);
    const fields = currentContent.querySelectorAll('input, select, textarea');
    
    let isValid = true;
    fields.forEach(field => {
      if (!field.checkValidity()) {
        isValid = false;
        field.reportValidity();
      }
    });
    
    return isValid;
  }
  
  updateUI() {
    // Update steps
    this.form.querySelectorAll('.step').forEach((step, i) => {
      step.classList.toggle('active', i + 1 === this.currentStep);
      step.classList.toggle('completed', i + 1 < this.currentStep);
      step.removeAttribute('aria-current');
      if (i + 1 === this.currentStep) {
        step.setAttribute('aria-current', 'step');
      }
    });
    
    // Update content
    this.form.querySelectorAll('.step-content').forEach((content, i) => {
      content.hidden = i + 1 !== this.currentStep;
    });
    
    // Update buttons
    document.getElementById('prevBtn').disabled = this.currentStep === 1;
    document.getElementById('nextBtn').hidden = this.currentStep === this.totalSteps;
    document.getElementById('submitBtn').hidden = this.currentStep !== this.totalSteps;
  }
  
  saveProgress() {
    const data = Object.fromEntries(new FormData(this.form));
    data._currentStep = this.currentStep;
    localStorage.setItem('formProgress', JSON.stringify(data));
  }
  
  loadSavedProgress() {
    const saved = localStorage.getItem('formProgress');
    if (!saved) return;
    
    const data = JSON.parse(saved);
    
    Object.entries(data).forEach(([key, value]) => {
      const field = this.form.elements[key];
      if (field) field.value = value;
    });
    
    if (data._currentStep) {
      this.currentStep = data._currentStep;
      this.updateUI();
    }
  }
}

new FormWizard(document.getElementById('wizard'));
```

---

## Password Strength Indicator

```javascript
import zxcvbn from 'zxcvbn';

function PasswordStrength(inputId, feedbackId) {
  const input = document.getElementById(inputId);
  const feedback = document.getElementById(feedbackId);
  
  input.addEventListener('input', () => {
    const result = zxcvbn(input.value);
    
    const labels = ['Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'];
    const colors = ['#dc2626', '#f97316', '#eab308', '#22c55e', '#16a34a'];
    
    feedback.innerHTML = `
      <div class="strength-bar" style="width: ${(result.score + 1) * 20}%; background: ${colors[result.score]}"></div>
      <span class="strength-label" style="color: ${colors[result.score]}">${labels[result.score]}</span>
      ${result.feedback.warning ? `<p class="warning">${result.feedback.warning}</p>` : ''}
    `;
  });
}

PasswordStrength('password', 'password-strength');
```

---

## Accessibility Checklist

- [ ] Every input has an associated `<label>`
- [ ] Required fields marked with `aria-required="true"`
- [ ] Error messages use `role="alert"` and `aria-live="polite"`
- [ ] Invalid fields have `aria-invalid="true"`
- [ ] `aria-describedby` links to hints and errors
- [ ] Fieldsets group related inputs with legends
- [ ] Focus moves to first error on submission
- [ ] Form can be completed with keyboard only
- [ ] Error messages are specific and actionable
- [ ] Color is not the only error indicator

---

**References:**
- [MDN HTML Forms](https://developer.mozilla.org/en-US/docs/Learn/Forms)
- [React Hook Form](https://react-hook-form.com/)
- [Zod Documentation](https://zod.dev/)
- [WCAG Forms Tutorial](https://www.w3.org/WAI/tutorials/forms/)
