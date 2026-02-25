---
description: Thiết kế database trước khi code
---

# Schema-First Development Workflow

// turbo-all

**Agent:** `database-architect`  
**Skills:** `database-design, api-patterns`

**Purpose:** Prevent data model chaos by defining schema BEFORE writing ANY code  
**Problem Solved:** Data structure breaks mid-project  
**When to Use:** Start of EVERY new project or feature

---

## Quick Start

```bash
# Step 1: Define schema
/schema-first [project-name]

# Step 2: Validate schema
# Step 3: Generate TypeScript types
# Step 4: Create validation schemas
# Step 5: Build data access layer
```

---

## Step 1: Define Entities

Với vai trò là Data Modeling Expert, design complete schema:

### Identify Entities (Nouns)
```
What are the main "things" in your app?

Example (Vocabulary App):
- VocabularyWord
- Example (sentence)
- UserProgress
- QuizSession
- QuizQuestion
```

### Define Each Entity
```typescript
// For EACH entity, define:

interface VocabularyWord {
  // Primary Key
  id: string;
  
  // Core attributes
  english: string;
  chinese: string;
  pronunciation: string;
  
  // Metadata
  difficulty: 'easy' | 'medium' | 'hard';
  category: string;
  
  // Relationships
  examples: Example[];  // One-to-many
  
  // Timestamps
  createdAt: Date;
  updatedAt: Date;
}
```

**Questions to Answer:**
1. What identifies this entity uniquely? (id)
2. What are required vs optional fields?
3. What are the data types? (string, number, Date, enum)
4. What relationships exist? (one-to-one, one-to-many, many-to-many)
5. Should this be extensible? (additional properties)

---

## Step 2: Define Relationships

```typescript
// One-to-Many
VocabularyWord (1) ←→ (many) Example
VocabularyWord (1) ←→ (many) UserProgress

// Many-to-Many
User (many) ←→ (many) VocabularyWord
(through UserProgress)

// One-to-One
Quiz Session (1) → (1) User
```

**Relationship Rules:**
- Define foreign keys clearly
- Decide on cascade deletes
- Consider orphan data handling

---

## Step 3: Create Validation Schema

```typescript
import { z } from 'zod';

// Runtime validation using Zod
export const VocabularyWordSchema = z.object({
  id: z.string().uuid(),
  english: z.string().min(1).max(100),
  chinese: z.string().min(1).max(100),
  pronunciation: z.string().optional(),
  difficulty: z.enum(['easy', 'medium', 'hard']),
  category: z.string().min(1),
  examples: z.array(ExampleSchema),
  createdAt: z.date(),
  updatedAt: z.date()
});

// Type inference from schema
export type VocabularyWord = z.infer<typeof VocabularyWordSchema>;
```

**Why Validation Matters:**
- Catch bad data early
- Prevent runtime errors
- Document expectations
- Enable safe refactoring

---

## Step 4: Plan for Evolution

### Version Migration Strategy

```typescript
// Version 1.0.0
interface VocabularyWordV1 {
  id: string;
  english: string;
  chinese: string;
}

// Version 1.1.0 - Add pronunciation
interface VocabularyWordV1_1 {
  id: string;
  english: string;
  chinese: string;
  pronunciation?: string;  // Optional for backward compat
}

// Migration function
function migrateV1toV1_1(word: VocabularyWordV1): VocabularyWordV1_1 {
  return {
    ...word,
    pronunciation: word.pronunciation ?? ""  // Default value
  };
}
```

**Migration Checklist:**
- [ ] Add new fields as optional first
- [ ] Provide default values
- [ ] Write migration script
- [ ] Test with real data
- [ ] Update validation schema
- [ ] Update all consumers

---

## Step 5: Generate Initial Data

```json
// data/vocabulary.json (seed data)
{
  "version": "1.0.0",
  "words": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "english": "Hello",
      "chinese": "你好",
      "pronunciation": "nǐ hǎo",
      "difficulty": "easy",
      "category": "Daily Life",
      "examples": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440001",
          "sentence": "Hello, how are you?",
          "translation": "你好，你好吗？"
        }
      ],
      "createdAt": "2026-01-17T00:00:00Z",
      "updatedAt": "2026-01-17T00:00:00Z"
    }
  ]
}
```

---

## Step 6: Create Data Access Layer

```typescript
// vocabularyRepository.ts
export class VocabularyRepository {
  private words: VocabularyWord[] = [];
  
  async load(): Promise<void> {
    const response = await fetch('/data/vocabulary.json');
    const raw = await response.json();
    
    // Validate BEFORE using
    this.words = raw.words.map((word: unknown) => {
      const result = VocabularyWordSchema.safeParse(word);
      if (!result.success) {
        console.error('Invalid word:', word, result.error);
        throw new Error('Data validation failed');
      }
      return result.data;
    });
  }
  
  getAll(): VocabularyWord[] {
    return this.words;
  }
  
  getById(id: string): VocabularyWord | undefined {
    return this.words.find(w => w.id === id);
  }
  
  getByDifficulty(difficulty: Difficulty): VocabularyWord[] {
    return this.words.filter(w => w.difficulty === difficulty);
  }
}
```

---

## Checklist

Before writing ANY UI code:

- [ ] All entities defined with TypeScript interfaces
- [ ] Relationships mapped (ERD diagram)
- [ ] Validation schemas created (Zod)
- [ ] Migration plan documented
- [ ] Seed data created
- [ ] Data access layer implemented
- [ ] Data access tests written

**ONLY THEN proceed to UI development!**

---

## Benefits

✅ **No data model chaos** - Structure defined upfront  
✅ **Easy to add features** - Schema handles it  
✅ **Type safety** - TypeScript + Zod validation  
✅ **Safe refactoring** - Compiler catches breaks  
✅ **Clear migrations** - Planned evolution

---

## Anti-Patterns to Avoid

❌ **DON'T** define data structure in UI components  
❌ **DON'T** change schema mid-project without migration  
❌ **DON'T** use `any` types  
❌ **DON'T** skip validation  
❌ **DON'T** hardcode data in components

---

**Remember: Data drives everything. Get it right first!** 🎯

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Lỗi không xác định hoặc crash | Bật chế độ verbose, kiểm tra log hệ thống, cắt nhỏ phạm vi debug |
| Thiếu package/dependencies | Kiểm tra file lock, chạy lại npm/composer install |
| Xung đột context API | Reset session, tắt các plugin/extension không liên quan |
| Thời gian chạy quá lâu (timeout) | Cấu hình lại timeout, tối ưu hóa các queries nặng |
