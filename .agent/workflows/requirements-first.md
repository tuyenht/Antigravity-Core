---
description: "Phân tích yêu cầu nghiệp vụ và viết tài liệu PRD trước khi code."
---

# Requirements-First Workflow (PRD Generator)

// turbo-all

**Agent:** `project-planner`  
**Skills:** `brainstorming, plan-writing`

**Purpose:** Define EXACT requirements to prevent AI guessing and scope creep  
**Problem Solved:** Unclear flows → conflicting logic → infinite fix loop  
**When to Use:** Start of EVERY project

---

## The Problem

**Without PRD:**
```
You: "Add quiz mode"
AI: *guesses* "Show answer immediately after selection"

Later:
You: "Actually, user should click Next to see answer"
AI: *changes logic* → breaks "save wrong answers" feature

Result: Infinite fix loop
```

**With PRD:**
```
PRD clearly states:
"After user selects answer:
 1. IF correct: Auto-advance after 2s
 2. IF wrong: Show correct answer, wait for manual Next"

AI: *implements exactly* → works first time
```

---

## Step 1: Define User Stories

```
Với vai trò là Product Manager, tạo detailed user stories:

## User Stories

**Format:**
As a [user type]
I want to [action]
So that [benefit]

**Quality Criteria:**
- Specific user type (not just "user")
- Clear action (not vague)  
- Measurable benefit

**Example:**

### Story 1: Basic Flashcard
As a Chinese language learner
I want to see a flashcard with English word and Chinese translation
So that I can learn vocabulary efficiently

**Acceptance Criteria:**
- [ ] Card shows English on top
- [ ] Card shows Chinese below
- [ ] Font size readable (min 18px)
- [ ] Card has white background, black text
- [ ] Next button at bottom

### Story 2: Learn from Mistakes
As a student  
I want to review words I answered incorrectly
So that I can focus on my weak areas

**Acceptance Criteria:**
- [ ] Quiz tracks wrong answers
- [ ] "Review Wrong" button shows after quiz
- [ ] Only shows words user got wrong
- [ ] Can retry until all correct
```

---

## Step 2: Prioritize Features (MoSCoW)

```
**Must Have (MVP)**
- [ ] Display flashcard (English/Chinese)
- [ ] Next button to flip cards
- [ ] Load data from JSON file
- [ ] Error handling (empty data)

**Should Have (V2)**
- [ ] Text-to-Speech pronunciation
- [ ] Quiz mode with 4 options
- [ ] Track wrong answers
- [ ] Simple progress indicator

**Could Have (V3)**
- [ ] Spaced repetition algorithm
- [ ] User accounts (save progress)
- [ ] Custom word lists
- [ ] Offline mode

**Won't Have (Out of scope)**
- [ ] Social features (sharing)
- [ ] Gamification (badges, levels)
- [ ] Premium subscription
```

**Why This Matters:**
- Prevents feature creep
- AI only implements what's in scope
- Clear stopping point

---

## Step 3: Define Exact User Flows

```
For EACH feature, define EXACT flow:

## Feature: Quiz Mode

### Happy Path
```
1. User clicks "Start Quiz" button
   → System generates 10 random questions
   → Shows "Question 1 of 10"

2. System displays question
   → Shows Chinese word
   → Shows 4 English options (A, B, C, D)
   → Only one correct answer
   
3. User clicks option (e.g., "B")
   → Highlight selected option in blue
   → Show "Submit" button
   → Disable changing answer

4. User clicks "Submit"
   → IF correct:
       - Show "✓ Correct!" in green (2 seconds)
       - Auto-advance to next question
   → IF wrong:
       - Show "✗ Wrong!" in red
       - Highlight correct answer in green
       - Show "Next" button (manual advance)
       - User must click Next

5. Repeat steps 2-4 for all 10 questions

6. After question 10:
   → Show "Quiz Complete!"
   → Show score: "7 / 10 (70%)"
   → Show two buttons:
       - "Review Wrong Answers" (if any wrong)
       - "Take New Quiz"
```

### Edge Cases
```
**Case 1: Rapid clicking**
- User clicks multiple options quickly
- System: Only register first click, disable others

**Case 2: Submit without selecting**
- User clicks Submit without selecting answer
- System: Show error "Please select an answer"

**Case 3: No wrong answers**
- User gets all 10 correct
- System: Hide "Review Wrong" button, show "Perfect score!"

**Case 4: Browser refresh during quiz**
- User refreshes page mid-quiz
- System: Show popup "Quiz in progress. Resume or start new?"

**Case 5: Less than 10 words in database**
- Only 5 words available
- System: Generate 5-question quiz, adjust messaging
```

**NO AMBIGUITY! AI cannot guess.**

---

## Step 4: Define Success Metrics

```
**How do we know feature works?**

### Functional Metrics
- [ ] Quiz completes without errors
- [ ] Score calculation correct (7/10 = 70%)
- [ ] Wrong answers saved correctly
- [ ] Review mode shows only incorrect words

### Performance Metrics
- [ ] Quiz loads in < 1 second
- [ ] Question transition smooth (no lag)
- [ ] Works offline (data cached)

### User Experience Metrics
- [ ] Clear feedback (correct/wrong)
- [ ] Intuitive flow (no confusion)
- [ ] Accessible (keyboard navigation works)
```

---

## Step 5: API Contracts (If Applicable)

```typescript
// If using backend API, define contract EXACTLY

/**
 * GET /api/quiz/generate
 * 
 * Request:
 * - Query params: count=10, difficulty=easy
 * 
 * Response:
 * {
 *   "quizId": "uuid",
 *   "questions": [
 *     {
 *       "questionId": "uuid",
 *       "wordId": "uuid",
 *       "question": "你好",
 *       "options": ["Hello", "Goodbye", "Welcome", "Thanks"],
 *       "correctIndex": 0
 *     }
 *   ],
 *   "createdAt": "2026-01-17T10:00:00Z"
 * }
 * 
 * Error cases:
 * - 400: Invalid difficulty value
 * - 404: Not enough words for requested count
 * - 500: Database error
 */
```

---

## Step 6: Non-Functional Requirements

```
**Performance:**
- Page load: < 2 seconds
- Quiz generation: < 500ms
- TTS response: < 1 second

**Browser Support:**
- Chrome 90+
- Safari 14+
- Firefox 88+
- Edge 90+

**Accessibility:**
- WCAG 2.1 AA compliant
- Keyboard navigation
- Screen reader support
- High contrast mode

**Offline:**
- Works without internet (except TTS)
- Data cached in localStorage
- Sync when online

**Data Privacy:**
- No personal data collected
- Progress saved locally only
- No analytics tracking
```

---

## Complete PRD Template

```markdown
# Product Requirements Document

## 1. Overview
**Product:** Vocabulary Learning App
**Version:** 1.0 MVP
**Target Users:** Chinese language learners
**Goal:** Learn 1,000 words in 3 months

## 2. User Stories (5-10 stories)
[As defined above]

## 3. Features (MoSCoW prioritization)
[As defined above]

## 4. User Flows (Detailed for each feature)
[As defined above]

## 5. Edge Cases (For each feature)
[As defined above]

## 6. Success Metrics
[As defined above]

## 7. Technical Requirements
- Frontend: React 19 + TypeScript
- State: Zustand
- Validation: Zod
- Build: Vite
- Testing: Vitest + Testing Library

## 8. Out of Scope
- User accounts
- Social features
- Premium features

## 9. Timeline
- Week 1: Flashcard mode
- Week 2: TTS + Quiz
- Week 3: Progress tracking
- Week 4: Polish + testing

## 10. Success Criteria
- [ ] All user stories implemented
- [ ] All edge cases handled
- [ ] 90%+ test coverage
- [ ] No console errors
- [ ] Passes accessibility audit
```

---

## Checklist

Before giving PRD to AI for implementation:

- [ ] All user stories written
- [ ] All flows detailed (no ambiguity)
- [ ] All edge cases identified
- [ ] Success metrics defined
- [ ] Out of scope clearly stated
- [ ] Technical stack decided
- [ ] Timeline estimated

---

## Usage with AI

**Good Prompt:**
```
Here is the complete PRD: [attach PRD.md]

Implement Feature 3: Quiz Mode

Follow the exact flow defined in section 4.3.
Handle all edge cases in section 4.3.1.
Use the data schema from schema.ts.

Do NOT add features not in PRD.
Do NOT change the defined flow.
```

**Bad Prompt:**
```
Make a quiz feature
[No PRD, AI guesses everything]
```

---

## Benefits

✅ **AI knows exactly what to build** - No guessing  
✅ **Scope is locked** - No feature creep  
✅ **Flows are deterministic** - No conflicting logic  
✅ **Edge cases handled** - No crashes  
✅ **Team alignment** - Everyone knows what's being built

---

**Remember: 1 hour planning saves 10 hours debugging!** 📋

---

## Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Lỗi không xác định hoặc crash | Bật chế độ verbose, kiểm tra log hệ thống, cắt nhỏ phạm vi debug |
| Thiếu package/dependencies | Kiểm tra file lock, chạy lại npm/composer install |
| Xung đột context API | Reset session, tắt các plugin/extension không liên quan |
| Thời gian chạy quá lâu (timeout) | Cấu hình lại timeout, tối ưu hóa các queries nặng |



