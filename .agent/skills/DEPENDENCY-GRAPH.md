# Skill Dependency & Consolidation Graph

> **Version:** 5.1.0 | **Skills:** 60 | **Last Updated:** 2026-03-12
> **Purpose:** Visual map of skill relationships, consolidations, and dependency chains.

---

## Consolidation Map

These "mastery" skills consolidate multiple original skills into single sources of truth.
Original skills remain available but contain deprecation notices pointing to their mastery version.

```mermaid
graph TB
    subgraph "Architecture Mastery"
        AM["architecture-mastery"]
        AM --> A1["architecture ⚠️"]
        AM --> A2["api-patterns"]
        AM --> A3["microservices-communication"]
        AM --> A4["graphql-patterns"]
    end

    subgraph "Testing Mastery"
        TM["testing-mastery"]
        TM --> T1["testing-patterns ⚠️"]
        TM --> T2["tdd-workflow ⚠️"]
        TM --> T3["contract-testing ⚠️"]
        TM --> T4["webapp-testing"]
    end

    style A1 fill:#ff9800,stroke:#e65100
    style T1 fill:#ff9800,stroke:#e65100
    style T2 fill:#ff9800,stroke:#e65100
    style T3 fill:#ff9800,stroke:#e65100
    style AM fill:#4caf50,stroke:#1b5e20,color:#fff
    style TM fill:#4caf50,stroke:#1b5e20,color:#fff
```

> ⚠️ = Deprecated (has deprecation notice, use mastery version instead)

---

## Skill Categories

```mermaid
graph LR
    subgraph "🏗️ Architecture & Design"
        architecture-mastery
        architecture
        api-patterns
        graphql-patterns
        microservices-communication
        mcp-builder
    end

    subgraph "🧪 Testing & Quality"
        testing-mastery
        testing-patterns
        tdd-workflow
        contract-testing
        webapp-testing
        code-review-checklist
        lint-and-validate
    end

    subgraph "⚡ Performance"
        performance-profiling
        react-performance
        react-native-performance
        laravel-performance
        inertia-performance
    end

    subgraph "🎨 Frontend"
        frontend-design
        react-patterns
        tailwind-patterns
        vue-expert
        state-management
        nextjs-best-practices
        ui-ux-pro-max
        velzon-admin
    end

    subgraph "📱 Mobile"
        mobile-design
        react-native-performance
        game-development
    end

    subgraph "🔧 Backend"
        nodejs-best-practices
        nestjs-expert
        python-patterns
        prisma-expert
        database-design
        nosql-patterns
        vector-databases
    end

    subgraph "☁️ Infrastructure"
        docker-expert
        kubernetes-patterns
        terraform-iac
        cloudflare
        deployment-procedures
        server-management
        monitoring-observability
    end

    subgraph "🔒 Security"
        vulnerability-scanner
        red-team-tactics
    end

    subgraph "🛠️ Workflow & Planning"
        brainstorming
        plan-writing
        app-builder
        behavioral-modes
        parallel-agents
        clean-code
        systematic-debugging
    end

    subgraph "📦 Tooling"
        typescript-expert
        ai-sdk-expert
        bash-linux
        powershell-windows
    end

    subgraph "🌐 External Knowledge"
        context-hub-bridge
    end

    subgraph "🌍 Growth"
        seo-fundamentals
        geo-fundamentals
        i18n-localization
        documentation-templates
    end
```

---

## Cross-Skill Dependencies

When a skill is loaded, these related skills should also be considered:

| Skill | Depends On | Enhances |
|-------|-----------|----------|
| `react-performance` | `react-patterns` | `nextjs-best-practices` |
| `react-native-performance` | `mobile-design` | `game-development` |
| `laravel-performance` | `database-design` | `inertia-performance` |
| `inertia-performance` | `laravel-performance`, `react-patterns` | — |
| `velzon-admin` | `react-patterns`, `state-management` | `frontend-design` |
| `nextjs-best-practices` | `react-patterns`, `typescript-expert` | `seo-fundamentals` |
| `webapp-testing` | `testing-patterns` | `performance-profiling` |
| `vulnerability-scanner` | `red-team-tactics` | — |
| `kubernetes-patterns` | `docker-expert` | `terraform-iac` |
| `prisma-expert` | `database-design`, `typescript-expert` | `nestjs-expert` |
| `cloudflare` | `deployment-procedures` | `server-management` |
| `ai-sdk-expert` | `typescript-expert`, `react-patterns` | — |
| `architecture-mastery` | `api-patterns`, `database-design` | `app-builder` |
| `testing-mastery` | `testing-patterns`, `tdd-workflow` | `webapp-testing` |
| `app-builder` | `brainstorming`, `plan-writing`, `architecture-mastery` | — |
| `context-hub-bridge` | `mcp-builder` | All backend/frontend skills |

---

## Skill Loading Priority

```
1. MANDATORY (always loaded)
   └── clean-code

2. TASK-TRIGGERED
   ├── brainstorming ← complex/unclear requests
   ├── plan-writing ← multi-file tasks
   ├── systematic-debugging ← bug fixes
   └── behavioral-modes ← mode switching

3. TECH-TRIGGERED (by file extension / project type)
   ├── react-patterns ← .tsx
   ├── vue-expert ← .vue
   ├── python-patterns ← .py
   ├── prisma-expert ← schema.prisma
   └── typescript-expert ← .ts

4. MASTERY (loaded instead of originals)
   ├── architecture-mastery ← replaces architecture
   └── testing-mastery ← replaces testing-patterns + tdd + contract

5. EXTERNAL-KNOWLEDGE-TRIGGERED
   └── context-hub-bridge ← agent needs third-party API docs
```

---

## Deprecation Status

| Skill | Status | Replacement |
|-------|--------|-------------|
| `architecture` | ⚠️ Deprecated | `architecture-mastery` |
| `testing-patterns` | ⚠️ Deprecated | `testing-mastery` |
| `tdd-workflow` | ⚠️ Deprecated | `testing-mastery` |
| `contract-testing` | ⚠️ Deprecated | `testing-mastery` |
| All other 56 skills | ✅ Active | — |

---

**Maintainer:** Antigravity Core System
