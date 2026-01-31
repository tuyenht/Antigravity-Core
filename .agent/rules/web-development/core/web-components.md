# Web Components & Custom Elements Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Standards:** Custom Elements v1, Shadow DOM v1, HTML Templates
> **Priority:** P2 - Load for component library projects

---

You are an expert in Web Components, Custom Elements, and the component model of the web platform.

## Key Principles

- Use Web Components for truly reusable UI
- Implement proper encapsulation with Shadow DOM
- Follow web standards and conventions
- Use progressive enhancement
- Ensure accessibility with ElementInternals
- Support SSR with Declarative Shadow DOM

---

## Custom Elements Basics

### Defining a Custom Element
```javascript
class MyButton extends HTMLElement {
  // Observed attributes for attributeChangedCallback
  static observedAttributes = ['disabled', 'variant'];
  
  constructor() {
    super();
    // Attach Shadow DOM
    this.attachShadow({ mode: 'open' });
    
    // Initialize state
    this._disabled = false;
  }
  
  // Called when element is added to DOM
  connectedCallback() {
    this.render();
    this.setupEventListeners();
  }
  
  // Called when element is removed from DOM
  disconnectedCallback() {
    this.cleanup();
  }
  
  // Called when observed attribute changes
  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue === newValue) return;
    
    switch (name) {
      case 'disabled':
        this._disabled = newValue !== null;
        this.render();
        break;
      case 'variant':
        this.render();
        break;
    }
  }
  
  // Called when element is moved to new document
  adoptedCallback() {
    // Handle document change if needed
  }
  
  // Getters and setters for properties
  get disabled() {
    return this._disabled;
  }
  
  set disabled(value) {
    this._disabled = Boolean(value);
    // Reflect to attribute
    if (this._disabled) {
      this.setAttribute('disabled', '');
    } else {
      this.removeAttribute('disabled');
    }
  }
  
  render() {
    const variant = this.getAttribute('variant') || 'primary';
    
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: inline-block;
        }
        
        button {
          padding: 0.5rem 1rem;
          border: none;
          border-radius: 4px;
          cursor: pointer;
          font-family: inherit;
          font-size: inherit;
        }
        
        button:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        
        .primary {
          background: var(--button-primary-bg, #0066cc);
          color: var(--button-primary-color, white);
        }
        
        .secondary {
          background: var(--button-secondary-bg, #e0e0e0);
          color: var(--button-secondary-color, #333);
        }
      </style>
      
      <button class="${variant}" ?disabled="${this._disabled}">
        <slot></slot>
      </button>
    `;
  }
  
  setupEventListeners() {
    this.shadowRoot.querySelector('button').addEventListener('click', (e) => {
      if (this._disabled) {
        e.preventDefault();
        e.stopPropagation();
        return;
      }
      
      // Dispatch custom event
      this.dispatchEvent(new CustomEvent('button-click', {
        bubbles: true,
        composed: true,  // Crosses shadow boundary
        detail: { timestamp: Date.now() }
      }));
    });
  }
  
  cleanup() {
    // Remove event listeners, cancel timers, etc.
  }
}

// Register the custom element
customElements.define('my-button', MyButton);
```

### Usage
```html
<my-button variant="primary">Click Me</my-button>
<my-button variant="secondary" disabled>Disabled</my-button>

<script>
  document.querySelector('my-button').addEventListener('button-click', (e) => {
    console.log('Button clicked:', e.detail);
  });
</script>
```

---

## Shadow DOM

### Open vs Closed Shadow Root
```javascript
// Open - shadowRoot is accessible
this.attachShadow({ mode: 'open' });
element.shadowRoot; // Returns ShadowRoot

// Closed - shadowRoot is inaccessible
this.attachShadow({ mode: 'closed' });
element.shadowRoot; // Returns null

// Recommendation: Use 'open' for most cases
// 'closed' doesn't provide true security
```

### Declarative Shadow DOM (SSR-Friendly)
```html
<!-- Server-rendered component with Shadow DOM -->
<my-card>
  <template shadowrootmode="open">
    <style>
      :host {
        display: block;
        border: 1px solid #ddd;
        border-radius: 8px;
        padding: 1rem;
      }
      
      .title {
        font-weight: bold;
        margin-bottom: 0.5rem;
      }
    </style>
    
    <div class="title">
      <slot name="title"></slot>
    </div>
    <div class="content">
      <slot></slot>
    </div>
  </template>
  
  <span slot="title">Card Title</span>
  <p>Card content goes here.</p>
</my-card>
```

### Hydrating Declarative Shadow DOM
```javascript
class MyCard extends HTMLElement {
  constructor() {
    super();
    
    // Check for existing declarative shadow root
    if (!this.shadowRoot) {
      this.attachShadow({ mode: 'open' });
      this.render();
    }
    
    // Hydrate - add interactivity
    this.hydrate();
  }
  
  hydrate() {
    // Add event listeners to existing DOM
    this.shadowRoot.querySelector('.title')?.addEventListener('click', () => {
      // Handle click
    });
  }
}
```

---

## Slots & Content Projection

### Named Slots
```javascript
class MyDialog extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    this.shadowRoot.innerHTML = `
      <style>
        .dialog {
          border: 1px solid #ccc;
          border-radius: 8px;
          max-width: 500px;
        }
        
        .header {
          padding: 1rem;
          border-bottom: 1px solid #eee;
          font-weight: bold;
        }
        
        .body {
          padding: 1rem;
        }
        
        .footer {
          padding: 1rem;
          border-top: 1px solid #eee;
          display: flex;
          justify-content: flex-end;
          gap: 0.5rem;
        }
        
        /* Style slotted content */
        ::slotted(h2) {
          margin: 0;
          font-size: 1.25rem;
        }
        
        ::slotted([slot="footer"] button) {
          padding: 0.5rem 1rem;
        }
      </style>
      
      <div class="dialog">
        <div class="header">
          <slot name="header">Default Header</slot>
        </div>
        <div class="body">
          <slot>Default content</slot>
        </div>
        <div class="footer">
          <slot name="footer"></slot>
        </div>
      </div>
    `;
  }
}

customElements.define('my-dialog', MyDialog);
```

```html
<my-dialog>
  <h2 slot="header">Confirm Action</h2>
  <p>Are you sure you want to proceed?</p>
  <div slot="footer">
    <button>Cancel</button>
    <button>Confirm</button>
  </div>
</my-dialog>
```

### Slot Change Events
```javascript
connectedCallback() {
  const slot = this.shadowRoot.querySelector('slot');
  
  slot.addEventListener('slotchange', () => {
    const assignedNodes = slot.assignedNodes({ flatten: true });
    const assignedElements = slot.assignedElements({ flatten: true });
    
    console.log('Slot content changed:', assignedElements);
  });
}
```

---

## Styling

### Host Styling
```css
/* Basic host styling */
:host {
  display: block;
  contain: content;
  font-family: system-ui, sans-serif;
}

/* Host with attribute */
:host([hidden]) {
  display: none;
}

:host([variant="primary"]) {
  --bg-color: blue;
}

/* Host with class */
:host(.large) {
  font-size: 1.5rem;
}

/* Host in context */
:host-context(.dark-theme) {
  --bg-color: #333;
  --text-color: white;
}

:host-context([dir="rtl"]) {
  direction: rtl;
}
```

### CSS Custom Properties (Theming)
```javascript
class ThemableCard extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          /* Define defaults, allow override from outside */
          --card-bg: var(--theme-card-bg, white);
          --card-border: var(--theme-card-border, #e0e0e0);
          --card-shadow: var(--theme-card-shadow, 0 2px 4px rgba(0,0,0,0.1));
          --card-radius: var(--theme-card-radius, 8px);
          --card-padding: var(--theme-card-padding, 1rem);
          
          display: block;
          background: var(--card-bg);
          border: 1px solid var(--card-border);
          border-radius: var(--card-radius);
          box-shadow: var(--card-shadow);
          padding: var(--card-padding);
        }
      </style>
      <slot></slot>
    `;
  }
}
```

```css
/* Theme from outside */
:root {
  --theme-card-bg: #f5f5f5;
  --theme-card-radius: 16px;
}

.dark-theme {
  --theme-card-bg: #1a1a1a;
  --theme-card-border: #333;
}
```

### CSS Shadow Parts
```javascript
class MyTabs extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    this.shadowRoot.innerHTML = `
      <style>
        .tab-list {
          display: flex;
          border-bottom: 1px solid #ddd;
        }
        
        .tab {
          padding: 0.5rem 1rem;
          cursor: pointer;
          border: none;
          background: transparent;
        }
        
        .tab[aria-selected="true"] {
          border-bottom: 2px solid var(--tab-active-color, blue);
        }
        
        .panel {
          padding: 1rem;
        }
      </style>
      
      <div class="tab-list" part="tab-list">
        <button class="tab" part="tab" aria-selected="true">Tab 1</button>
        <button class="tab" part="tab">Tab 2</button>
      </div>
      <div class="panel" part="panel">
        <slot></slot>
      </div>
    `;
  }
}
```

```css
/* Style parts from outside */
my-tabs::part(tab-list) {
  gap: 0.5rem;
}

my-tabs::part(tab) {
  font-weight: 500;
}

my-tabs::part(tab):hover {
  background: #f0f0f0;
}
```

### Constructable Stylesheets
```javascript
// Create shared stylesheet
const sharedStyles = new CSSStyleSheet();
sharedStyles.replaceSync(`
  :host {
    display: block;
  }
  
  .button {
    padding: 0.5rem 1rem;
    border-radius: 4px;
  }
`);

class MyComponent extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    // Adopt shared stylesheet
    this.shadowRoot.adoptedStyleSheets = [sharedStyles];
    
    this.shadowRoot.innerHTML = `
      <button class="button"><slot></slot></button>
    `;
  }
}

// Share styles across multiple components
class AnotherComponent extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.adoptedStyleSheets = [sharedStyles];
  }
}
```

---

## Form-Associated Custom Elements

```javascript
class MyInput extends HTMLElement {
  // Mark as form-associated
  static formAssociated = true;
  
  static observedAttributes = ['value', 'required', 'disabled'];
  
  constructor() {
    super();
    
    // Get ElementInternals for form integration
    this._internals = this.attachInternals();
    
    this.attachShadow({ mode: 'open' });
    this._value = '';
  }
  
  connectedCallback() {
    this.render();
    this.setupValidation();
  }
  
  render() {
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: inline-block;
        }
        
        input {
          padding: 0.5rem;
          border: 1px solid #ccc;
          border-radius: 4px;
          font: inherit;
          width: 100%;
          box-sizing: border-box;
        }
        
        input:focus {
          outline: 2px solid var(--focus-color, #0066cc);
          outline-offset: 2px;
        }
        
        :host([invalid]) input {
          border-color: red;
        }
      </style>
      
      <input 
        type="text" 
        .value="${this._value}"
        ?required="${this.hasAttribute('required')}"
        ?disabled="${this.hasAttribute('disabled')}"
      >
    `;
    
    this.shadowRoot.querySelector('input').addEventListener('input', (e) => {
      this._value = e.target.value;
      this._internals.setFormValue(this._value);
      this.validate();
    });
  }
  
  setupValidation() {
    this.validate();
  }
  
  validate() {
    const input = this.shadowRoot.querySelector('input');
    
    if (this.hasAttribute('required') && !this._value) {
      this._internals.setValidity(
        { valueMissing: true },
        'This field is required',
        input
      );
      this.setAttribute('invalid', '');
    } else {
      this._internals.setValidity({});
      this.removeAttribute('invalid');
    }
  }
  
  // Form lifecycle callbacks
  formAssociatedCallback(form) {
    console.log('Associated with form:', form);
  }
  
  formDisabledCallback(disabled) {
    this.shadowRoot.querySelector('input').disabled = disabled;
  }
  
  formResetCallback() {
    this._value = '';
    this.shadowRoot.querySelector('input').value = '';
    this._internals.setFormValue('');
  }
  
  formStateRestoreCallback(state, mode) {
    this._value = state;
    this.shadowRoot.querySelector('input').value = state;
  }
  
  // Properties
  get value() {
    return this._value;
  }
  
  set value(val) {
    this._value = val;
    this._internals.setFormValue(val);
    if (this.shadowRoot.querySelector('input')) {
      this.shadowRoot.querySelector('input').value = val;
    }
  }
  
  get form() {
    return this._internals.form;
  }
  
  get validity() {
    return this._internals.validity;
  }
  
  get validationMessage() {
    return this._internals.validationMessage;
  }
  
  checkValidity() {
    return this._internals.checkValidity();
  }
  
  reportValidity() {
    return this._internals.reportValidity();
  }
}

customElements.define('my-input', MyInput);
```

```html
<form id="myForm">
  <my-input name="username" required></my-input>
  <button type="submit">Submit</button>
</form>

<script>
  document.getElementById('myForm').addEventListener('submit', (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    console.log('Username:', formData.get('username'));
  });
</script>
```

---

## ElementInternals for Accessibility

```javascript
class MyToggle extends HTMLElement {
  static formAssociated = true;
  
  constructor() {
    super();
    this._internals = this.attachInternals();
    this._checked = false;
    
    this.attachShadow({ mode: 'open' });
    
    // Set ARIA role
    this._internals.role = 'switch';
    this._internals.ariaChecked = 'false';
  }
  
  connectedCallback() {
    this.render();
    
    // Make focusable
    if (!this.hasAttribute('tabindex')) {
      this.setAttribute('tabindex', '0');
    }
    
    this.addEventListener('click', () => this.toggle());
    this.addEventListener('keydown', (e) => {
      if (e.key === ' ' || e.key === 'Enter') {
        e.preventDefault();
        this.toggle();
      }
    });
  }
  
  toggle() {
    this._checked = !this._checked;
    this._internals.ariaChecked = String(this._checked);
    this._internals.setFormValue(this._checked ? 'on' : null);
    this.render();
    
    this.dispatchEvent(new CustomEvent('change', {
      bubbles: true,
      detail: { checked: this._checked }
    }));
  }
  
  render() {
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: inline-flex;
          align-items: center;
          gap: 0.5rem;
          cursor: pointer;
        }
        
        :host(:focus-visible) {
          outline: 2px solid var(--focus-color, #0066cc);
          outline-offset: 2px;
        }
        
        .track {
          width: 44px;
          height: 24px;
          background: ${this._checked ? 'var(--toggle-on, #0066cc)' : 'var(--toggle-off, #ccc)'};
          border-radius: 12px;
          position: relative;
          transition: background 0.2s;
        }
        
        .thumb {
          width: 20px;
          height: 20px;
          background: white;
          border-radius: 50%;
          position: absolute;
          top: 2px;
          left: ${this._checked ? '22px' : '2px'};
          transition: left 0.2s;
          box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        }
      </style>
      
      <div class="track">
        <div class="thumb"></div>
      </div>
      <slot></slot>
    `;
  }
  
  get checked() {
    return this._checked;
  }
  
  set checked(value) {
    this._checked = Boolean(value);
    this._internals.ariaChecked = String(this._checked);
    this.render();
  }
}

customElements.define('my-toggle', MyToggle);
```

---

## Lit (Modern Web Component Library)

### Basic Lit Component
```javascript
import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';

@customElement('my-counter')
class MyCounter extends LitElement {
  static styles = css`
    :host {
      display: block;
      font-family: system-ui;
    }
    
    .counter {
      display: flex;
      align-items: center;
      gap: 1rem;
    }
    
    button {
      padding: 0.5rem 1rem;
      font-size: 1.25rem;
      cursor: pointer;
    }
    
    .count {
      font-size: 2rem;
      font-weight: bold;
      min-width: 3rem;
      text-align: center;
    }
  `;
  
  @property({ type: Number })
  count = 0;
  
  @property({ type: Number })
  step = 1;
  
  @state()
  private _isAnimating = false;
  
  render() {
    return html`
      <div class="counter">
        <button @click=${this._decrement} ?disabled=${this.count <= 0}>
          -
        </button>
        <span class="count">${this.count}</span>
        <button @click=${this._increment}>
          +
        </button>
      </div>
    `;
  }
  
  private _increment() {
    this.count += this.step;
    this._notifyChange();
  }
  
  private _decrement() {
    this.count = Math.max(0, this.count - this.step);
    this._notifyChange();
  }
  
  private _notifyChange() {
    this.dispatchEvent(new CustomEvent('count-changed', {
      detail: { count: this.count },
      bubbles: true,
      composed: true
    }));
  }
}
```

### Lit with Slots
```javascript
import { LitElement, html, css } from 'lit';

class MyCard extends LitElement {
  static styles = css`
    :host {
      display: block;
      border: 1px solid var(--card-border, #e0e0e0);
      border-radius: var(--card-radius, 8px);
      overflow: hidden;
    }
    
    .header {
      padding: 1rem;
      background: var(--card-header-bg, #f5f5f5);
      font-weight: bold;
    }
    
    .content {
      padding: 1rem;
    }
    
    .footer {
      padding: 1rem;
      background: var(--card-footer-bg, #fafafa);
      border-top: 1px solid var(--card-border, #e0e0e0);
    }
    
    ::slotted([slot="header"]) {
      margin: 0;
    }
  `;
  
  render() {
    return html`
      <div class="header">
        <slot name="header"></slot>
      </div>
      <div class="content">
        <slot></slot>
      </div>
      <div class="footer">
        <slot name="footer"></slot>
      </div>
    `;
  }
}

customElements.define('my-card', MyCard);
```

### Lit Reactive Controllers
```javascript
import { LitElement } from 'lit';
import { Task } from '@lit/task';

class MyUserProfile extends LitElement {
  @property()
  userId = '';
  
  private _userTask = new Task(this, {
    task: async ([userId]) => {
      const response = await fetch(`/api/users/${userId}`);
      if (!response.ok) throw new Error('Failed to fetch user');
      return response.json();
    },
    args: () => [this.userId]
  });
  
  render() {
    return this._userTask.render({
      pending: () => html`<p>Loading...</p>`,
      complete: (user) => html`
        <div class="profile">
          <img src=${user.avatar} alt=${user.name}>
          <h2>${user.name}</h2>
          <p>${user.email}</p>
        </div>
      `,
      error: (e) => html`<p>Error: ${e.message}</p>`
    });
  }
}
```

---

## Templates & Efficient Rendering

### HTML Template Element
```javascript
// Cache template reference
const cardTemplate = document.createElement('template');
cardTemplate.innerHTML = `
  <style>
    .card { border: 1px solid #ddd; padding: 1rem; }
  </style>
  <div class="card">
    <slot></slot>
  </div>
`;

class FastCard extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    // Clone template (faster than innerHTML)
    this.shadowRoot.appendChild(
      cardTemplate.content.cloneNode(true)
    );
  }
}
```

---

## Events

### Custom Events with Composed
```javascript
class MyComponent extends HTMLElement {
  notifyChange(data) {
    // composed: true - crosses shadow DOM boundaries
    this.dispatchEvent(new CustomEvent('my-change', {
      bubbles: true,
      composed: true,
      cancelable: true,
      detail: data
    }));
  }
  
  notifyInternalEvent() {
    // composed: false - stays within shadow DOM
    this.shadowRoot.dispatchEvent(new CustomEvent('internal-event', {
      bubbles: true,
      composed: false
    }));
  }
}
```

### Event Retargeting
```javascript
// Events are retargeted when crossing shadow boundaries
document.addEventListener('click', (e) => {
  console.log('Target:', e.target);           // my-component
  console.log('Composed path:', e.composedPath()); // Full path including shadow
});
```

---

## Performance Best Practices

### Lazy Registration
```javascript
// Don't define immediately, wait until needed
async function loadMyComponent() {
  if (!customElements.get('my-component')) {
    const { MyComponent } = await import('./my-component.js');
    customElements.define('my-component', MyComponent);
  }
}

// Or use whenDefined
customElements.whenDefined('my-component').then(() => {
  console.log('my-component is ready');
});
```

### Efficient Updates
```javascript
class EfficientComponent extends HTMLElement {
  #pendingUpdate = false;
  
  requestUpdate() {
    if (this.#pendingUpdate) return;
    
    this.#pendingUpdate = true;
    requestAnimationFrame(() => {
      this.render();
      this.#pendingUpdate = false;
    });
  }
}
```

### CSS Containment
```css
:host {
  contain: content; /* or layout, paint, strict */
}
```

---

## Testing

```javascript
// Using Web Test Runner or similar
import { fixture, html, expect } from '@open-wc/testing';

describe('MyButton', () => {
  it('renders with default variant', async () => {
    const el = await fixture(html`<my-button>Click</my-button>`);
    
    const button = el.shadowRoot.querySelector('button');
    expect(button).to.exist;
    expect(button.classList.contains('primary')).to.be.true;
  });
  
  it('reflects disabled attribute', async () => {
    const el = await fixture(html`<my-button disabled>Click</my-button>`);
    
    expect(el.disabled).to.be.true;
    
    const button = el.shadowRoot.querySelector('button');
    expect(button.disabled).to.be.true;
  });
  
  it('dispatches click event', async () => {
    const el = await fixture(html`<my-button>Click</my-button>`);
    
    let clicked = false;
    el.addEventListener('button-click', () => { clicked = true; });
    
    el.shadowRoot.querySelector('button').click();
    
    expect(clicked).to.be.true;
  });
});
```

---

## Best Practices Checklist

- [ ] Use kebab-case naming (my-component)
- [ ] Extend HTMLElement (not other elements)
- [ ] Use Shadow DOM for encapsulation
- [ ] Implement all lifecycle callbacks as needed
- [ ] Reflect properties to attributes appropriately
- [ ] Use CSS custom properties for theming
- [ ] Support Declarative Shadow DOM for SSR
- [ ] Use ElementInternals for form integration
- [ ] Ensure keyboard accessibility
- [ ] Test with screen readers
- [ ] Document public API
- [ ] Publish to npm for reusability

---

**References:**
- [MDN Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components)
- [Lit Documentation](https://lit.dev/)
- [Open Web Components](https://open-wc.org/)
- [Custom Elements Manifest](https://custom-elements-manifest.open-wc.org/)
