# Custom Agent Creation Guide — Antigravity v5.0

> **Version:** 5.0.0 (Platinum Standard)  
> **Architecture:** Pipeline-Chained Agent Ecosystem

Tài liệu này hướng dẫn cách tạo và đăng ký một Custom Agent mới vào hệ thống Antigravity-Core v5.0.

---

## 1. Hệ tư tưởng v5.0 (Pipeline-Driven)

> [!WARNING]
> **QUAN TRỌNG:** Ở v5.0, Agent **KHÔNG THỂ tự do chạy workflow 7 bước** như v3.x/v4.x. 

- **Agent là ai?** Là một chuyên gia (*Specialist*) sở hữu Kiến thức sâu về một ngôn ngữ/framework.
- **Ai ra lệnh?** Intent Router sẽ phân loại yêu cầu → Khởi động Pipeline (BUILD, ENHANCE, FIX) → Pipeline sẽ gọi Agent vào giải quyết từng **PHASE** cụ thể.
- **Agent v5.0 siêu nhẹ:** File Agent chỉ chứa *Định danh*, *Capabilities*, *Ràng buộc kỹ thuật*, và *Behavior theo từng Phase*.

---

## 2. Quy trình 3 bước Khởi tạo Custom Agent

### Bước 1: Copy Template v5.0
Sử dụng template chuẩn để đảm bảo độ tương thích 100%.

```powershell
# Copy template vào thư mục agents
Copy-Item .agent\templates\agent-template-v5.md .agent\agents\ten-agent-moi.md
```

### Bước 2: Khai báo Identity, Constraints & Phase Rules
Mở file `ten-agent-moi.md` vừa copy và chỉnh sửa các `[Placeholders]`.

1. **Identity:** Khai báo chính xác mảng mà Agent giỏi nhất.
2. **Constraints:** Cố định phiên bản tech stack (Ví dụ: `Next.js 15+` thay vì `Next.js`).
3. **Pipeline Execution:** Quy định rõ thao tác của Agent khi Pipeline đưa yêu cầu "Lên thiết kế (Phase 2)" hoặc "Bắt đầu code (Phase 3)".

### Bước 3: Đăng ký Agent (Agent Registration Protocol)
> [!IMPORTANT]
> Đây là hành động bắt buộc. File Agent nằm trong `.agent/agents/` sẽ "chết" nếu không được khai báo.

Mở file `.agent/reference-catalog.md` và thêm Agent mới vào danh sách **§ 1. AGENT REGISTRY**:

```markdown
| Role | Recommended Agent | Trigger Keywords / Context |
|------|-------------------|----------------------------|
| Custom Backend | `ten-agent-moi` | .go, fiber, golang |
```

---

## 3. Checklist Nghiệm thu chuẩn Platinum
*Trước khi đưa Agent mới vào sử dụng, hãy tự kiểm duyệt:*

- [ ] Tên file tuân thủ **kebab-case** (VD: `sap-erp-specialist.md`).
- [ ] Không rác thừa (Zero-fluff). Không chứa các hướng dẫn quy trình tự biên tự diễn (Cấm định nghĩa workflow riêng cho Agent).
- [ ] Đã thêm mục Agent vào bảng Registry trong `reference-catalog.md`.
- [ ] Ràng buộc ranh giới file (`file_boundaries`) được thiết lập chặt chẽ để cắm Agent chôn chân vào đúng module (Ngăn đụng chạm code không liên quan).
- [ ] Test thực tế bằng cách gọi Pipeline thông thường (VD `/enhance`) với keyword liên quan để xem Intent Router có định tuyến đúng về Agent mới không.
