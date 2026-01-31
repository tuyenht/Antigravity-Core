---
activation: always_on
---

# Technical Standards

**Universal** technical standards. Language-specific rules auto-detected.

---

## Step 0: Auto-Detect Project Language

```bash
# Detection Priority
if [ -f "package.json" ]; then
  LANG="JavaScript/TypeScript"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  LANG="Python"
elif [ -f "Cargo.toml" ]; then
  LANG="Rust"
elif [ -f "go.mod" ]; then
  LANG="Go"
elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
  LANG="Java"
elif [ -f "composer.json" ]; then
  LANG="PHP"
elif [ -f "Gemfile" ]; then
  LANG="Ruby"
else
  LANG="Unknown - Apply Universal Principles Only"
fi

# Framework Detection (in addition to language)
if [ -f "composer.json" ] && grep -q "laravel/framework" composer.json; then
  FRAMEWORK="Laravel"
fi

if [ -f "package.json" ] && grep -q "next" package.json; then
  FRAMEWORK="Next.js"
fi

if [ -f "composer.json" ] && grep -q "inertiajs/inertia-laravel" composer.json; then
  if [ -f "package.json" ] && grep -q "react" package.json; then
    FRAMEWORK="Laravel + Inertia.js + React"
  fi
fi
```

After detection, apply **Universal Principles** (below) + **Language-Specific Conventions** + **Framework-Specific Standards**.

---

## Framework-Specific Standards

### Laravel Projects
**Detection:** `composer.json` contains `laravel/framework`

**Apply:** `.agent/rules/standards/frameworks/laravel-conventions.md`

**Key Areas:**
- Eloquent ORM patterns (N+1 prevention, eager loading)
- RESTful routing conventions
- Form Request validation
- Security best practices (CSRF, SQL injection prevention)
- Performance optimization (caching, queuing)
- Testing with Pest

### Inertia.js + React + TypeScript
**Detection:** `composer.json` contains `inertiajs` + `package.json` contains `react`

**Apply:** `.agent/rules/standards/frameworks/inertia-react-conventions.md`

**Key Areas:**
- TypeScript-typed page components
- useForm hook patterns
- Navigation (Link component, router)
- Shared data and flash messages
- Modal dialogs with state preservation
- Performance optimization (partial reloads)

---

## Step 0B: Load Framework Standards

```bash
# After language detection, check for frameworks
if [ "$FRAMEWORK" = "Laravel" ]; then
  source .agent/rules/standards/frameworks/laravel-conventions.md
fi

if [ "$FRAMEWORK" = "Laravel + Inertia.js + React" ]; then
  source .agent/rules/standards/frameworks/laravel-conventions.md
  source .agent/rules/standards/frameworks/inertia-react-conventions.md
fi
```

---

## 1. Universal Naming Principles

Apply conventions based on detected language:

| Language | Variables | Functions | Classes | Constants |
|----------|-----------|-----------|---------|-----------|
| **JavaScript/TS** | camelCase | camelCase | PascalCase | SCREAMING_SNAKE_CASE |
| **Python** | snake_case | snake_case | PascalCase | SCREAMING_SNAKE_CASE |
| **Rust** | snake_case | snake_case | PascalCase | SCREAMING_SNAKE_CASE |
| **Go** | camelCase | PascalCase (exported) | PascalCase | PascalCase or camelCase |
| **Java** | camelCase | camelCase | PascalCase | SCREAMING_SNAKE_CASE |
| **PHP** | camelCase | camelCase | PascalCase | SCREAMING_SNAKE_CASE |
| **Ruby** | snake_case | snake_case | PascalCase | SCREAMING_SNAKE_CASE |

**Universal Rules (All Languages):**
- ✅ Use English for all names
- ✅ Boolean variables: prefix with `is`, `has`, `can`, `should`
- ✅ Avoid abbreviations (use `customerAddress` not `custAddr`)
- ❌ Never use single-letter names except loop counters (`i`, `j`, `k`)

---

## 2. Function & Logic Flow

**Universal Principles (Language-Agnostic):**

| Principle | Description | Metric |
|-----------|-------------|--------|
| **Early Return** | Avoid deep nesting, return early | Max nesting: 3 levels |
| **Single Responsibility** | 1 function = 1 clear task | - |
| **Function Length** | Keep functions concise | Max 30-50 lines |
| **Parameter Count** | Minimize parameters | Max 3-4 parameters |
| **Cyclomatic Complexity** | Reduce branches | Cyclomatic < 10 |

**Pattern:**
```
✅ GOOD (Early Return Pattern)
function process(input):
    if not valid(input): return error
    if not authorized(input): return error
    return execute(input)

❌ BAD (Arrow/Pyramid of Doom)
function process(input):
    if valid(input):
        if authorized(input):
            return execute(input)
    return error
```

---

## 3. Type Safety

**Universal Rules:**
- ❌ **No Magic Numbers:** Use named constants
- ✅ **Strict Typing:** Declare types (TypeScript, Rust, Go) or type hints (Python)
- ✅ **Immutability:** Prefer immutable data structures

**Examples by Language:**

| Language | Magic Number | Named Constant |
|----------|--------------|----------------|
| **JavaScript/TS** | `if (status == 1)` | `if (status == OrderStatus.PENDING)` |
| **Python** | `if status == 1:` | `if status == OrderStatus.PENDING:` |
| **Rust** | `if status == 1` | `if status == OrderStatus::Pending` |
| **Go** | `if status == 1` | `if status == OrderStatusPending` |

---

## 4. Error Handling

**Universal Principles:**
- ❌ **Never swallow errors silently**
- ✅ **Log with context** (structured logging)
- ✅ **Fail fast** on critical errors
- ✅ **Use language idioms** (Exceptions vs Result types)

| Language | Error Pattern |
|----------|---------------|
| **JavaScript/TS** | `try/catch` + Promise rejection |
| **Python** | `try/except` + custom exceptions |
| **Rust** | `Result<T, E>` type (no exceptions) |
| **Go** | `if err != nil` pattern |
| **Java** | `try/catch` + checked exceptions |

---

## 5. Comments

**Universal Rules:**
- ✅ Comment the **WHY**, not the WHAT
- ✅ Use `TODO:`, `FIXME:`, `HACK:` markers
- ❌ Avoid redundant comments that repeat code

**Examples:**
```javascript
// ✅ Good - Explains WHY
// Using setTimeout to debounce rapid API calls and prevent rate limiting
setTimeout(fetchData, 300);

// ❌ Bad - States the obvious WHAT
// This code calls setTimeout with fetchData and 300
setTimeout(fetchData, 300);
```

---

## 6. Project Structure

**Universal Best Practices:**

| Principle | Description |
|-----------|-------------|
| **Separation of Concerns** | UI, Logic, Data in separate layers |
| **Consistent Naming** | Files/folders follow language conventions |
| **Single Entry Point** | Clear `main`, `index`, or `app` file |
| **Config Externalization** | Settings in config files, not code |
| **Test Co-location** | Tests near the code they test |

---

## Language-Specific Standards

After detecting language, reference additional guidelines if available:
- `standards/javascript-conventions.md`
- `standards/python-conventions.md`
- `standards/rust-conventions.md`
- etc.

**When standards file missing:** Fall back to universal principles above.

---

## Knowledge Expansion & Learning New Technologies

**Principle:** Agent MUST NOT have outdated knowledge. When encountering new technologies, automatically research and document best practices.

### Trigger Conditions

Create new **Sub-Standard** when **ANY** occurs:

| Trigger | Condition | Action Required |
|---------|-----------|-----------------|
| **New Language** | Language not in table above | Research official docs, create standard file |
| **New Framework** | Framework-specific request (e.g., SvelteKit, FastAPI) | Extract best practices, create sub-standard |
| **Missing Best Practice** | User mentions pattern not documented | Research, validate, document |
| **Technology Update** | Major version change (e.g., React 19, Python 3.13) | Update existing standard with new features |
| **Gap Identified** | Audit reveals missing coverage | Proactive research and documentation |

### Research Process

When new technology encountered:

```markdown
## Step 1: IDENTIFY GAP

**Technology:** [Name + Version]
**Category:** [Language | Framework | Tool | Pattern]
**Request Context:** [What user asked for]
**Current Coverage:** [None | Partial | Outdated]

**Gap Assessment:**
- [ ] No existing standard
- [ ] Partial coverage (needs expansion)
- [ ] Outdated (needs update)

---

## Step 2: RESEARCH OFFICIAL SOURCES

**Primary Sources (Priority Order):**
1. Official Documentation (highest priority)
2. Official GitHub Repository (CONTRIBUTING.md, docs/)
3. Official Style Guides
4. Framework/Language RFC or PEP/JSR/RFC documents
5. Community Best Practices (verified by maintainers)

**Research Checklist:**
- [ ] Naming conventions
- [ ] Project structure recommendations
- [ ] Error handling patterns
- [ ] Testing approaches
- [ ] Performance best practices
- [ ] Security considerations
- [ ] Common anti-patterns to avoid

**Sources Consulted:**
- [URL 1]: Official docs
- [URL 2]: Style guide
- [URL 3]: Best practices

---

## Step 3: EXTRACT BEST PRACTICES

**Key Learnings:**
1. [Practice 1]: [Description + Why]
2. [Practice 2]: [Description + Why]
3. [Practice 3]: [Description + Why]
...

**Anti-Patterns Identified:**
1. ❌ [Anti-pattern 1]: [Why to avoid]
2. ❌ [Anti-pattern 2]: [Why to avoid]

---

## Step 4: CREATE SUB-STANDARD FILE

**File Path:** `.agent/rules/standards/[technology]-conventions.md`

**Template Structure:**
```markdown
---
technology: [Name]
version: [Version or "latest"]
last_updated: [YYYY-MM-DD]
official_docs: [URL]
---

# [Technology] Standards

## Overview
[Brief description of technology and when to use it]

## Naming Conventions
[Language/framework-specific naming rules]

## Project Structure
[Recommended folder/file organization]

## Best Practices
1. [Practice 1]
2. [Practice 2]
...

## Common Patterns
[Idiomatic code patterns]

## Anti-Patterns to Avoid
1. ❌ [Anti-pattern 1]
2. ❌ [Anti-pattern 2]

## Testing
[Testing approach for this technology]

## Performance
[Performance considerations]

## Security
[Security best practices]

## Resources
- Official Docs: [URL]
- Style Guide: [URL]
- Best Practices: [URL]
```

---

## Step 5: PROPOSE TO USER

**Proposal Format:**
```markdown
## 📚 New Sub-Standard Proposed

**Technology:** [Name]
**Reason:** Encountered in user request, not currently covered

**Research Summary:**
- Consulted: [Official docs, style guides]
- Best practices extracted: [Count]
- Anti-patterns identified: [Count]

**Proposed File:**
`.agent/rules/standards/[technology]-conventions.md`

**Preview:**
[Show first 20 lines of proposed standard]

**Apply this standard?**
- [x] Yes, add to knowledge base
- [ ] No, skip
- [ ] Modify first (provide feedback)
```

**User can:**
- ✅ Approve immediately → File created
- ❌ Reject → Documented in BACKLOG
- 📝 Request modifications → Refine and re-propose
```

### Automatic Integration

After sub-standard created:

```bash
# Update detection logic in Step 0
# Add to language detection or framework detection

# Example: Adding Swift
if [ -f "Package.swift" ]; then
  LANG="Swift"
  SUB_STANDARD=".agent/rules/standards/swift-conventions.md"
fi

# Load sub-standard when detected
if [ -f "$SUB_STANDARD" ]; then
  echo "Loading $LANG conventions from $SUB_STANDARD"
fi
```

### Sub-Standards Library Structure

```plaintext
.agent/rules/standards/
├── README.md                      # Index of all sub-standards
├── javascript-conventions.md      # Core JS/TS
├── python-conventions.md          # Core Python
├── rust-conventions.md            # Core Rust
├── go-conventions.md              # Core Go
├── java-conventions.md            # Core Java
│
├── frameworks/
│   ├── react-conventions.md       # React-specific
│   ├── nextjs-conventions.md      # Next.js patterns
│   ├── fastapi-conventions.md     # FastAPI best practices
│   ├── django-conventions.md      # Django patterns
│   ├── express-conventions.md     # Express.js
│   └── nestjs-conventions.md      # Nest.js
│
├── mobile/
│   ├── react-native-conventions.md
│   ├── flutter-conventions.md
│   └── swiftui-conventions.md
│
├── data/
│   ├── pandas-conventions.md
│   ├── numpy-conventions.md
│   └── sql-conventions.md
│
└── tools/
    ├── docker-conventions.md
    ├── kubernetes-conventions.md
    └── terraform-conventions.md
```

### Continuous Learning Metrics

Track knowledge expansion:

```markdown
## Knowledge Base Growth

| Date | Technology | Sub-Standard Created | Source | Status |
|------|------------|---------------------|--------|--------|
| 2026-01-16 | Swift | swift-conventions.md | Apple Docs | ✅ Active |
| 2026-01-17 | FastAPI | frameworks/fastapi-conventions.md | Official Docs | ✅ Active |
| ... | ... | ... | ... | ... |

**Statistics:**
- Total Sub-Standards: [Count]
- Languages Covered: [Count]
- Frameworks Covered: [Count]
- Last Updated: [Date]
- Coverage Gaps: [List if any]
```

### Maintenance & Updates

**Keep standards fresh:**

```bash
# Check for outdated standards (manual or in periodic audit)
for file in standards/**/*.md; do
  LAST_UPDATED=$(grep "last_updated:" $file)
  AGE_DAYS=$(($(date +%s) - $(date -d "$LAST_UPDATED" +%s)) / 86400)
  
  if [ $AGE_DAYS -gt 180 ]; then
    echo "⚠️ $file is $AGE_DAYS days old - Consider updating"
  fi
done
```

**Update triggers:**
- Major version release
- Official docs significant update
- Audit reveals outdated practice
- User reports incorrect standard

### Example: Learning FastAPI

**Scenario:** User asks "Build a FastAPI endpoint for CRUD operations"

**Process:**
```markdown
1. DETECT: FastAPI mentioned, not in current standards
2. RESEARCH:
   - Official docs: https://fastapi.tiangolo.com
   - Key findings:
     * Pydantic for validation
     * Async/await by default
     * Auto-generated OpenAPI docs
     * Type hints required

3. EXTRACT:
   Best Practices:
   - Use Pydantic BaseModel for request/response
   - Async functions for I/O operations
   - Dependency injection for shared logic
   - HTTPException for errors

   Anti-Patterns:
   - ❌ Sync functions for DB calls
   - ❌ Dict for request validation (use Pydantic)
   - ❌ Manual OpenAPI docs

4. CREATE FILE:
   `.agent/rules/standards/frameworks/fastapi-conventions.md`

5. PROPOSE:
   "📚 I learned FastAPI best practices from official docs.
   Create fastapi-conventions.md sub-standard? [Preview attached]"

6. INTEGRATE:
   Update detection: if grep -q "fastapi" requirements.txt
   → Load fastapi-conventions.md
```

### Quality Checklist for Sub-Standards

Before proposing new sub-standard:

- [ ] Researched from **official** sources (not blogs/Stack Overflow)
- [ ] Verified best practices are **current** (not outdated)
- [ ] Extracted at least **5 best practices**
- [ ] Identified at least **3 anti-patterns**
- [ ] Included **examples** for clarity
- [ ] Listed **official resources** for reference
- [ ] Structured using **standard template**
- [ ] Validated practices are **framework-specific** (not generic)

---

## Fallback Strategy

If official docs unavailable or unclear:

1. **Check framework GitHub:** CONTRIBUTING.md, docs/, examples/
2. **Official blog/newsletter:** Framework announcements
3. **Verified community guides:** Maintained by core team
4. **Defer to universal principles:** Use sections 1-6 above

**NEVER use:**
- ❌ Random blog posts
- ❌ Outdated tutorials (> 2 years old)
- ❌ Unverified StackOverflow answers
- ❌ Personal opinions without source

---

**Commitment:** This agent will **NEVER** provide outdated or incorrect technical advice. When in doubt, research official sources before responding.
