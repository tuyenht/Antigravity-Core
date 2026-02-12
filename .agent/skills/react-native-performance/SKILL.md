---
name: react-native-performance
description: Production-grade React Native and Expo performance optimization based on Vercel Best Practices. Use when building React Native components, optimizing list performance, implementing animations, or working with native modules.
version: 1.0
impact-driven: true
priority-order: CRITICAL → HIGH → MEDIUM → LOW
source: https://github.com/vercel-labs/agent-skills/tree/main/skills/react-native-skills
allowed-tools: Read, Write, Edit, Glob, Grep
---

# React Native Performance Optimization

> Production-grade performance rules for React Native and Expo applications, prioritized by real-world impact.

---

## 🎯 CORE PHILOSOPHY

```
IMPACT-DRIVEN OPTIMIZATION
│
├── CRITICAL  → Core rendering, list virtualization (prevents crashes + 2-10x improvement)
├── HIGH      → Animation, scroll, navigation (enables 60fps, native UX)
├── MEDIUM    → State management, UI patterns, design system (cleaner code, fewer re-renders)
└── LOW       → Monorepo, fonts, imports (architecture + DX improvements)
```

**Key libraries:** Reanimated 3, Gesture Handler, LegendList/FlashList, expo-image, zeego, expo-router

---

## 📊 PRIORITY DECISION TREE

```
REACT NATIVE PERFORMANCE ISSUE?
│
├── App crashes on render?
│   └── Section 1: Core Rendering (CRITICAL)
│       ├── 1.1 Falsy && conditional rendering
│       └── 1.2 Text in Text component
│
├── List scrolling is janky?
│   └── Section 2: List Performance (HIGH)
│       ├── 2.1-2.5 Memoization, callbacks, items
│       ├── 2.6 Use FlashList/LegendList
│       ├── 2.7 Compressed images
│       └── 2.8 Item types for recycling
│
├── Animations dropping frames?
│   └── Section 3: Animation (HIGH)
│       ├── 3.1 GPU properties only (transform, opacity)
│       ├── 3.2 useDerivedValue over useAnimatedReaction
│       └── 3.3 GestureDetector for press states
│
├── Scroll tracking causes re-renders?
│   └── Section 4: Scroll Performance (HIGH)
│       └── 4.1 useSharedValue, not useState
│
├── Navigation feels sluggish?
│   └── Section 5: Navigation (HIGH)
│       └── 5.1 Native stack/tabs, not JS navigators
│
├── State management issues?
│   └── Section 6-7: React State + Architecture (MEDIUM)
│       ├── 6.1 Minimize state, derive values
│       ├── 6.2 Fallback state pattern
│       ├── 6.3 Dispatch updaters
│       └── 7.1 State = ground truth
│
├── React Compiler compatibility?
│   └── Section 8: React Compiler (MEDIUM)
│       ├── 8.1 Destructure functions early
│       └── 8.2 .get()/.set() for shared values
│
├── UI not platform-native?
│   └── Section 9: User Interface (MEDIUM)
│       ├── 9.1-9.2 Measurement, styling
│       ├── 9.3-9.4 contentInset, safe areas
│       ├── 9.5-9.6 expo-image, Galeria
│       ├── 9.7-9.8 Native menus, modals
│       └── 9.9 Pressable over Touchable
│
└── Architecture/config issues?
    └── Sections 10-14 (LOW-MEDIUM)
        ├── 10.1 Compound components
        ├── 11.1-11.2 Monorepo patterns
        ├── 12.1 Design system imports
        ├── 13.1 Hoist Intl formatters
        └── 14.1 Native font loading
```

---

## 📚 COMPLETE RULES REFERENCE

> [!NOTE]
> For AI Agents: The complete, detailed rules with all code examples are in `AGENTS.md` in this same directory. Reference that file for specific examples and detailed implementations.

**Summary of Categories:**

1. **Core Rendering** (CRITICAL) — Prevents production crashes
2. **List Performance** (HIGH) — 2-10x scroll improvement
3. **Animation** (HIGH) — GPU-accelerated 60fps animations
4. **Scroll Performance** (HIGH) — No render thrashing during scroll
5. **Navigation** (HIGH) — Native platform navigation
6. **React State** (MEDIUM) — Fewer re-renders, no stale closures
7. **State Architecture** (MEDIUM) — Single source of truth
8. **React Compiler** (MEDIUM) — Compatibility patterns
9. **User Interface** (MEDIUM) — Native UI patterns
10. **Design System** (MEDIUM) — Component architecture
11. **Monorepo** (LOW) — Dependency management
12. **Third-Party Dependencies** (LOW) — Import abstraction
13. **JavaScript** (LOW) — Micro-optimizations
14. **Fonts** (LOW) — Native font loading

---

## 🔗 INTEGRATION WITH OTHER SKILLS

| Skill | Relationship |
|-------|-------------|
| `mobile-design` | General mobile principles (touch, platform, security). This skill adds **specific code patterns**. |
| `react-patterns` | Web React patterns. This skill covers **React Native specifics**. |
| `react-performance` | Web React performance. This skill is the **mobile counterpart**. |
| `state-management` | General state patterns. This skill covers **RN-specific state** (Reanimated, Zustand selectors). |

---

## 🏗️ HOW TO USE

### For Code Review
```
1. Read AGENTS.md for the relevant section
2. Check code against incorrect/correct examples
3. Report findings with impact level
```

### For Code Generation
```
1. Follow CRITICAL rules unconditionally
2. Apply HIGH rules for performance-sensitive features
3. Apply MEDIUM rules for quality
4. Consider LOW rules for polish
```

### Communication Template

```
**React Native Performance Issue**

Category: [CRITICAL/HIGH/MEDIUM/LOW]
Rule: [Section].[Number] [Rule Name]
Impact: [Expected improvement]

Current Code:
[bad example]

Suggested Fix:
[good example]

Rationale:
[Why this matters]
```
