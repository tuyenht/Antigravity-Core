---
description: "Chạy luồng làm việc nhóm từ requirement đến deploy (BA-SA-PM-DEV-QA-DO)."
---

# /full-pipeline — Enterprise Full Team Pipeline

// turbo-all

Chạy **BUILD pipeline (Phase 0→5)** với 2 STOP GATES bắt buộc, rồi **auto-chain sang SHIP pipeline** để deploy.

**Coordinator:** `orchestrator`

---

## Execution

1. Chạy **BUILD pipeline** (`pipelines/BUILD.md`) — Phase 0 đến Phase 5
2. Áp dụng **STOP GATE Overrides** (xem bảng dưới)
3. Khi BUILD Phase 5 hoàn tất → Auto-chain sang **SHIP pipeline** (`pipelines/SHIP.md`)

> Mọi Agent assignment, Skills loading, và Phase logic **tuân theo BUILD.md và SHIP.md**.
> File này CHỈ quy định phần **override** cho dự án enterprise.

---

## STOP GATE Overrides (khác BUILD thường)

| Sau Phase | Yêu cầu | BUILD thường |
|-----------|---------|--------------|
| Phase 1 DISCOVERY | ⛔ **BẮT BUỘC** user approve PRD/PLAN trước khi tiếp | Không có gate |
| Phase 2 PLANNING | ⛔ **BẮT BUỘC** user approve architecture + schema | Checkpoint nhẹ (user có thể skip) |

User nói "OK" / "tiếp" / "Xacnhan" → mở gate, tiếp tục Phase kế.
User yêu cầu thay đổi → quay lại Phase đó, chỉnh sửa, trình bày lại.

---

## Rollback & Escalation

| Tình huống | Hành động |
|-----------|---------|
| PRD bị reject (STOP GATE 1) | Quay lại Phase 1, thu thập thêm requirements |
| Architecture bị reject (STOP GATE 2) | Quay lại Phase 2, đề xuất phương án khác |
| QA fail nhưng fix được (Phase 4) | Quay lại Phase 3, fix rồi re-test |
| QA fail do design flaw | Quay lại Phase 2, re-architect |
| Deploy fail (SHIP) | Chạy `/backup` restore, `/debug` tìm lỗi |

---

## Completion Checklist

- [ ] PLAN.md approved (STOP GATE 1)
- [ ] Architecture approved (STOP GATE 2)
- [ ] All features implemented + tested (Phase 3-4)
- [ ] Security audit clean
- [ ] Production deployed + healthy (SHIP)
- [ ] Post-deploy monitoring 24h OK
