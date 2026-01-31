# 📋 COPY-PASTE PROMPT CREATION GUIDE

**Version:** 1.0  
**Purpose:** Guidelines để tạo prompts dễ copy-paste, không bị lỗi format  
**Created:** 2026-01-17

---

## 🚨 CRITICAL RULES (BẮT BUỘC)

### ❌ NEVER DO (Tuyệt đối KHÔNG làm):

1. **KHÔNG dùng nested code blocks**
   ```
   ❌ WRONG:
   ```
   Prompt content here:
   ```yaml
   some: yaml
   ```
   More content
   ```
   ```
   
   → Rendering lỗi, copy bị thiếu!

2. **KHÔNG dùng markdown numbered lists cho multi-line items**
   ```
   ❌ WRONG:
   1. Item 1 with description
      More details here
      Even more details
   2. Item 2
   ```
   
   → Copy chỉ được item 1, thiếu item 2-5!

3. **KHÔNG dùng indented content trong numbered lists**
   ```
   ❌ WRONG:
   1. Main point:
      - Sub point 1
      - Sub point 2
   2. Next point
   ```
   
   → Selection breaks, copy không đầy đủ!

---

## ✅ BEST PRACTICES (Luôn làm thế này):

### 1. Dùng Plain Text Separators

**Thay vì markdown syntax, dùng visual separators:**

```
✅ CORRECT:

═══════════════════════════════════════════════════════════
SECTION TITLE
═══════════════════════════════════════════════════════════

Content here...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUB-SECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

More content...
```

**Characters to use:**
- `═` (double line) - Major sections
- `━` (single line) - Sub-sections
- `─` (light line) - Minor separators

---

### 2. Manual Numbering Instead of Markdown Lists

**For numbered items with multiple lines:**

```
✅ CORRECT:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ITEM #1: Title
Description line 1
Description line 2
Details here

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ITEM #2: Title
Description line 1
Description line 2
Details here

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ITEM #3: Title
...
```

**Why this works:**
- Each item is a separate block
- Visual separation is clear
- Copy-paste gets EVERYTHING
- No markdown rendering issues

---

### 3. Clear Copy Boundaries

**Always mark where to copy from/to:**

```
✅ CORRECT:

### 🔥 COPY PROMPT BÊN DƯỚI (từ dòng --- đến dòng ---):

---

[ENTIRE PROMPT CONTENT HERE]
All instructions
All examples
All deliverables

---

### ✅ END OF PROMPT
```

**Key elements:**
- Clear start marker: `---`
- Clear end marker: `---`
- Instructions in Vietnamese: "COPY từ --- đến ---"
- Visual indicator: 🔥 or 📋

---

### 4. Code Examples Without Triple Backticks

**For code within prompts:**

```
✅ CORRECT:

TypeScript Example:
// ❌ WRONG
function bad() {
  return "no validation";
}

// ✅ CORRECT
function good(input: string) {
  if (!validate(input)) throw Error();
  return process(input);
}

End of example
```

**Why:**
- No nested backticks confusion
- Plain text, copies perfectly
- Still readable
- Highlighting done by viewer, not markdown

---

### 5. Structured Sections with Headers

```
✅ CORRECT:

NHIỆM VỤ:

Phân tích theo 4 tiêu chí:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. TIÊU CHÍ THỨ NHẤT

Description here...

Deliverable: What to produce

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2. TIÊU CHÍ THỨ HAI

Description here...

Deliverable: What to produce

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Benefits:**
- Easy to scan
- Clear hierarchy
- Perfect copy-paste
- Professional look

---

### 6. Examples and Templates

**Use visual markers for different content types:**

```
✅ CORRECT:

▼ TEMPLATE START ▼

template content here
all the details
everything needed

▲ TEMPLATE END ▲

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▼ EXAMPLE START ▼

example content here
showing how to use
the template above

▲ EXAMPLE END ▲
```

**Visual markers:**
- `▼` / `▲` - Template/Example blocks
- `【 】` - Important notes
- `├──` / `└──` - Tree structures
- `→` - Arrows for flow

---

## 📐 TEMPLATE STRUCTURE

### Standard Prompt Format:

```
═══════════════════════════════════════════════════════════

## PROMPT [NUMBER]: [TITLE]

**Mục tiêu:** [Goal]

**Thời gian:** [Estimate]

**Output:** [Expected deliverable]

═══════════════════════════════════════════════════════════

### 🔥 COPY PROMPT BÊN DƯỚI (từ dòng --- đến dòng ---):

---

Với vai trò là [ROLE], [action verb] [system/subject].

NHIỆM VỤ:

[High-level description]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. SECTION TITLE

[Content for this section]

Deliverable: [What to produce]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2. SECTION TITLE

[Content for this section]

Deliverable: [What to produce]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[More sections...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DELIVERABLES:

✅ Item 1
✅ Item 2
✅ Item 3

SUCCESS CRITERIA:
- Criterion 1
- Criterion 2
- Criterion 3

FORMAT: Create artifact [filename]

---

═══════════════════════════════════════════════════════════
```

---

## 🧪 TESTING CHECKLIST

Before finalizing prompt, verify:

- [ ] **Copy test**: Select from `---` to `---` → Paste → All content there?
- [ ] **No nested blocks**: Zero triple backticks inside prompts?
- [ ] **Manual numbering**: Multi-line items use separators instead of `1. 2. 3.`?
- [ ] **Clear boundaries**: Start/end markers visible?
- [ ] **Visual hierarchy**: Sections clearly separated?
- [ ] **No markdown lists**: For complex items with sub-items?
- [ ] **Mobile friendly**: Readable without horizontal scroll?

---

## 🎯 QUICK REFERENCE

**Character Set:**
```
Separators:
═══  Major section (double line)
━━━  Sub-section (single line)
───  Minor separator (light line)

Markers:
▼▲   Template/Example blocks
🔥   Copy here
✅   Success/Correct
❌   Error/Wrong
→    Arrow/Flow
【】  Important note brackets

Tree:
├──  Branch
└──  End branch
│    Vertical line
```

---

## 💡 REAL EXAMPLE

**BAD (lỗi format):**
```markdown
### Prompt

```
User task:

1. First item
   - Detail 1
   - Detail 2
   
2. Second item
```

Output: `file.md`
```

**GOOD (format đúng):**
```markdown
═══════════════════════════════════════════════════════════

### 🔥 COPY PROMPT BÊN DƯỚI:

---

Với vai trò là EXPERT, thực hiện task.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ITEM #1: First Item
Detail 1
Detail 2
More details

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ITEM #2: Second Item
Detail 1
Detail 2
More details

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FORMAT OUTPUT: Create artifact file.md

---

═══════════════════════════════════════════════════════════
```

---

## 📚 LESSONS LEARNED (From Supreme Prompts)

**Issue 1: Nested code blocks**
- Problem: Triple backticks inside triple backticks
- Solution: Remove outer backticks, use plain text

**Issue 2: Numbered list breaks**
- Problem: `1. Item\n   Details\n2. Item` only copies item 1
- Solution: Use separator blocks with manual numbering

**Issue 3: Indentation confusion**
- Problem: Indented sub-items break selection
- Solution: Flat structure with clear separators

**Issue 4: Copy incomplete**
- Problem: User couldn't copy all 5 items
- Solution: Each item as separate block with divider

---

## 🎯 SUMMARY

**Golden Rules:**
1. ✅ Use separators (`═══`, `━━━`) instead of markdown syntax
2. ✅ Manual numbering for multi-line items
3. ✅ Clear `---` boundaries for copy region
4. ✅ Plain text examples (no nested backticks)
5. ✅ Visual markers (`▼▲`, `🔥`) for clarity
6. ✅ Test copy-paste before delivery
7. ✅ Flat structure (avoid deep nesting)

**Always remember:** 
> **If it's meant to be copied, make it PLAIN TEXT with VISUAL SEPARATORS!**

---

**Created:** 2026-01-17  
**Last Updated:** 2026-01-17  
**Status:** PRODUCTION READY ✅

**Use this guide for ALL future copy-paste prompt creation!**
