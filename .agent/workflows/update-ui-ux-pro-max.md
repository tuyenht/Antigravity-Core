---
description: "Cập nhật và nâng cấp kho kỹ năng thiết kế UI/UX Pro Max lõi."
---

# Update UI-UX-Pro-Max Skill

Quy trình cập nhật skill UI-UX-Pro-Max từ https://github.com/nextlevelbuilder/ui-ux-pro-max-skill về project Antigravity-Core.

## Vấn đề đã biết

CLI tool `uipro-cli` tạo files vào `.shared/ui-ux-pro-max/` nhưng trong Antigravity-Core, chúng ta cần files nằm trong `.agent/skills/ui-ux-pro-max/`.

Workflow này đảm bảo:
- ✅ Cập nhật đầy đủ từ upstream
- ✅ Merge vào đúng vị trí `.agent/skills/`
- ✅ Không bị duplicate folders
- ✅ Giữ nguyên các customizations riêng (nếu có)

---

## Bước 1: Kiểm tra version hiện tại

```bash
# Xem các versions có sẵn
uipro versions
```

Output sẽ hiển thị danh sách versions với `[latest]` tag.

---

## Bước 2: Chạy CLI update

```bash
# // turbo

**Agent:** `orchestrator`  
**Skills:** `ui-ux-pro-max, frontend-design`
cd c:\Projects\Antigravity-Core

# Cài/cập nhật CLI nếu cần
npm install -g uipro-cli

# Tải version mới nhất
uipro init --ai antigravity
```

**Lưu ý:** CLI sẽ tạo files vào `.shared/` và `.agent/workflows/`.

---

## Bước 3: Merge files vào đúng vị trí

```powershell
# // turbo

**Agent:** `orchestrator`  
**Skills:** `ui-ux-pro-max, frontend-design`
# Merge data files (ghi đè files cũ với files mới)
Copy-Item -Path ".shared\ui-ux-pro-max\data\*" -Destination ".agent\skills\ui-ux-pro-max\data\" -Recurse -Force

# Merge script files
Copy-Item -Path ".shared\ui-ux-pro-max\scripts\*" -Destination ".agent\skills\ui-ux-pro-max\scripts\" -Recurse -Force
```

---

## Bước 4: Xóa thư mục .shared

```powershell
# // turbo

**Agent:** `orchestrator`  
**Skills:** `ui-ux-pro-max, frontend-design`
# Xóa thư mục .shared (không cần nữa)
Remove-Item -Path ".shared" -Recurse -Force
```

---

## Bước 5: Cập nhật paths trong workflow

Mở file `.agent/workflows/ui-ux-pro-max.md` và thay thế tất cả:
- `.shared/ui-ux-pro-max` → `.agent/skills/ui-ux-pro-max`

Hoặc chạy lệnh:

```powershell
# // turbo

**Agent:** `orchestrator`  
**Skills:** `ui-ux-pro-max, frontend-design`
(Get-Content ".agent\workflows\ui-ux-pro-max.md") -replace '\.shared/ui-ux-pro-max', '.agent/skills/ui-ux-pro-max' | Set-Content ".agent\workflows\ui-ux-pro-max.md"
```

---

## Bước 6: Verify và Commit

```bash
# // turbo

**Agent:** `orchestrator`  
**Skills:** `ui-ux-pro-max, frontend-design`
# Kiểm tra changes
git status

# Add và commit
git add .
git commit -m "⬆️ Update UI-UX-Pro-Max to vX.X.X"
git push
```

---

## One-liner Script (Nhanh gọn)

Copy và chạy toàn bộ script này:

```powershell
# Update UI-UX-Pro-Max - One-liner
uipro init --ai antigravity; `
Copy-Item -Path ".shared\ui-ux-pro-max\data\*" -Destination ".agent\skills\ui-ux-pro-max\data\" -Recurse -Force; `
Copy-Item -Path ".shared\ui-ux-pro-max\scripts\*" -Destination ".agent\skills\ui-ux-pro-max\scripts\" -Recurse -Force; `
Remove-Item -Path ".shared" -Recurse -Force; `
(Get-Content ".agent\workflows\ui-ux-pro-max.md") -replace '\.shared/ui-ux-pro-max', '.agent/skills/ui-ux-pro-max' | Set-Content ".agent\workflows\ui-ux-pro-max.md"; `
git add .; `
Write-Host "✅ UI-UX-Pro-Max updated! Run: git commit -m 'Update UI-UX-Pro-Max'"
```

---

## Troubleshooting

### Lỗi: "uipro is not recognized"
```bash
npm install -g uipro-cli
```

### Lỗi: ".shared folder not found"
CLI đã cập nhật và không tạo `.shared/` nữa. Kiểm tra trực tiếp `.agent/skills/ui-ux-pro-max/`.

### Lỗi: Permission denied
Chạy PowerShell với quyền Administrator.

---

## Files được cập nhật

| Vị trí | Mô tả |
|--------|-------|
| `.agent/skills/ui-ux-pro-max/SKILL.md` | Skill definition |
| `.agent/skills/ui-ux-pro-max/data/*.csv` | Design data (styles, colors, typography...) |
| `.agent/skills/ui-ux-pro-max/data/stacks/*.csv` | Stack-specific guidelines |
| `.agent/skills/ui-ux-pro-max/scripts/*.py` | Search & generator scripts |
| `.agent/workflows/ui-ux-pro-max.md` | Workflow definition |

---

**Version:** 1.0  
**Created:** 2026-01-31  
**Source:** https://github.com/nextlevelbuilder/ui-ux-pro-max-skill


---

##  Update Ui Ux Pro Max Checklist

- [ ] Prerequisites and environment verified
- [ ] All workflow steps executed sequentially
- [ ] Expected output validated against requirements
- [ ] No unresolved errors or warnings in tests/logs
- [ ] Related documentation updated if impact is systemic



