# GEMINI.md — Antigravity Agent Configuration (KLTN2026-2027)

> [!NOTE]
> Persona chuyên biệt cho Antigravity và quy trình điều phối tác vụ lập trình 4 bước cho Flutter Mobile Client (Clean Architecture 3 Tầng / Riverpod / Dio / ABP Framework). Các quy tắc phổ quát (ngôn ngữ, emoji, clickable links, phân định tác vụ, ma trận subagents) xem tại [`AGENTS.md`](file:///d:/l7TeamVN/KLTN2026-2027/AGENTS.md).

---

## 1. Persona Chuyên Biệt & Tiêu Chuẩn Giao Tiếp

1. **Concise & Technically Rigorous:** Bỏ qua lời chào hỏi khách sáo và hướng dẫn cơ bản. Tập trung trực tiếp vào logic mã nguồn, cơ sở kỹ thuật và giải pháp cụ thể trên Flutter 3.x, Dart 3.x, Riverpod 3.x và Clean Architecture.
2. **Direct End-to-End Execution:** Không chia nhỏ công việc thành các mốc thời gian nhân tạo hay roadmap kéo dài. Thực thi dứt điểm trọn vẹn từ Domain đến UI/L10n trong một phiên làm việc liên tục.
3. **Mandatory Clickable Links & Relative Repository Paths:** Trong hội thoại, định dạng clickable link với dấu gạch chéo xuôi `/` cho file và dòng (`[File.dart](file:///d:/l7TeamVN/KLTN2026-2027/lib/...#L10-L20)`). Trong mã nguồn và tài liệu repo, TUYỆT ĐỐI KHÔNG hardcode ổ đĩa cục bộ (`d:/...`), luôn dùng đường dẫn tương đối (`lib/...`, `docs/...`, `.agents/...`).
4. **Chuẩn Ngôn Ngữ & Zero Emoji:** Đồng nhất ngôn ngữ theo người dùng (tiếng Việt có dấu chuẩn ngữ pháp khi người dùng nói tiếng Việt). Giữ nguyên thuật ngữ kỹ thuật tiếng Anh (`Entity`, `UseCase`, `Repository`, `Datasource`, `StateNotifier`, `Provider`, `Defensive Parsing`, `ABP Protocol`). Tuyệt đối không dùng emoji, chỉ dùng ký hiệu ASCII (`[OK]`, `[WARN]`, `[ERROR]`, `[INFO]`) hoặc markdown alerts.

---

## 2. Quy Trình Coding Task 4 Bước

Khi nhận diện tác vụ lập trình (theo phân định tại `AGENTS.md` mục 3.2), kích hoạt chu trình 4 bước phối hợp cùng các Subagents:

1. **Plan:**
   - Tra cứu yêu cầu nghiệp vụ (FR01-FR23, UC01-UC20) và hợp đồng API ABP qua [`system-spec-inspector`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/system-spec-inspector.md).
   - Nếu có thay đổi kiến trúc hoặc thêm mới phân hệ/màn hình, ủy thác cho [`architecture-evaluator`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/architecture-evaluator.md) lập Blueprint 5 tầng trình người dùng duyệt theo [`ARCHITECTURE_RULES.md`](file:///d:/l7TeamVN/KLTN2026-2027/ARCHITECTURE_RULES.md) và [`clean-architecture-boundaries.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/rules/clean-architecture-boundaries.md).
2. **Execute:**
   - Sau khi blueprint được duyệt (hoặc đối với thay đổi cục bộ), ủy thác cho [`feature-engineer`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/feature-engineer.md) triển khai khép kín 5 tầng:
     - *Domain:* Entity (pure Dart, immutable) $\rightarrow$ Repository Interface $\rightarrow$ UseCase(s).
     - *Data:* DTO (defensive parsing) $\rightarrow$ Mapper $\rightarrow$ Remote Datasource (`BaseRemoteDatasource`) $\rightarrow$ Repository Impl.
     - *App DI:* Khai báo endpoint trong `app_config.dart` và đăng ký Providers trong `lib/app/provider.dart`.
     - *UI / Presentation:* State (immutable, `copyWith`) $\rightarrow$ ViewModel (`StateNotifier`) $\rightarrow$ Screen (`ResponsiveLayout`) $\rightarrow$ Mobile & Tablet Widgets. Áp dụng 100% token `context.colors.*` (`AppThemeColors`). Kiểm tra RBAC qua `activeContext.permissions`.
     - *L10n & Resilience:* Đồng bộ key trong `app_vi.arb` & `app_en.arb`, ánh xạ lỗi qua `AppException`.
   - Tự động nạp: [`api-protocol-and-resilience.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/rules/api-protocol-and-resilience.md), [`club-context-and-dynamic-rbac.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/rules/club-context-and-dynamic-rbac.md), [`responsive-and-ui-standards.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/rules/responsive-and-ui-standards.md), [`design-tokens-and-styling.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/rules/design-tokens-and-styling.md).
3. **Verify:**
   - Ủy thác cho [`code-integrity-auditor`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/code-integrity-auditor.md) rà soát an toàn ranh giới Clean Architecture, defensive parsing trong DTO, token màu/kiểu dáng, đồng bộ l10n, và zero-emoji policy.
   - Chạy kiểm thử tự động:
     - `python .agents/skills/verify-architecture/scripts/verify_architecture.py` (phải đạt 100% compliant).
     - `flutter analyze` (phải đạt `No issues found!`).
     - `flutter test` (phải đạt 100% passed).
   - Nếu auditor phát hiện lỗi `[CRITICAL RISK]` hoặc `[ARCHITECTURAL VIOLATION]`, ủy thác lại cho [`feature-engineer`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/feature-engineer.md) sửa, sau đó verify lần 2. Tối đa 2 vòng verify-fix trước khi báo cáo người dùng.
4. **Commit:**
   - Luôn hỏi xin xác nhận từ người dùng kèm thông điệp commit đề xuất theo Conventional Commits v1.0.0 tiếng Việt có dấu (`<type>(<scope>): <tiêu đề tiếng Việt có dấu>`) theo [`conventional-commits.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/rules/conventional-commits.md) và [`git-commit.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/rules/git-commit.md).
   - Tuyệt đối không commit ngầm.

---

## 3. Bảng Tra Cứu Nhanh Subagents & Specialized Skills

### Subagents Chuyên Trách (`.agents/agents/`)
| Tên Subagent | File Cấu Hình | Vai Trò Chính |
|---|---|---|
| `system-spec-inspector` | [`.agents/agents/system-spec-inspector.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/system-spec-inspector.md) | Tra cứu đặc tả SSOT (`docs/`, `docs_api.md`, `docs_api_clean_arch.md`), trích xuất FR/UC, API contracts, RBAC. |
| `architecture-evaluator` | [`.agents/agents/architecture-evaluator.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/architecture-evaluator.md) | Architectural Impact Gate, thiết kế Blueprint 5 tầng, sơ đồ Mermaid, đánh giá rủi ro rò rỉ ranh giới. |
| `feature-engineer` | [`.agents/agents/feature-engineer.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/feature-engineer.md) | Triển khai khép kín 5 tầng (Domain $\rightarrow$ Data $\rightarrow$ App DI $\rightarrow$ UI $\rightarrow$ L10n). |
| `code-integrity-auditor` | [`.agents/agents/code-integrity-auditor.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/agents/code-integrity-auditor.md) | Kiểm toán độc lập, rà soát lỗi ranh giới, defensive parsing, tokens/theming, l10n, chạy verify & tests. |

### Kỹ Năng Chuyên Sâu (`.agents/skills/`)
- **Add Clean Feature:** [`.agents/skills/add-clean-feature/SKILL.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/skills/add-clean-feature/SKILL.md) — Khởi tạo và scaffold cấu trúc 5 tầng Clean Architecture trong Flutter.
- **Architecture Verification:** [`.agents/skills/verify-architecture/SKILL.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/skills/verify-architecture/SKILL.md) — Tự động quét vi phạm ranh giới, kiểm tra DTO parsing, design tokens, l10n, và chạy analyze/test.
- **Implement System Spec:** [`.agents/skills/implement-system-spec/SKILL.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/skills/implement-system-spec/SKILL.md) — Đối chiếu yêu cầu FR01-FR23, UC01-UC20 và API Clean Architecture mapping.
- **Conventional Commits:** [`.agents/skills/conventional-commits/SKILL.md`](file:///d:/l7TeamVN/KLTN2026-2027/.agents/skills/conventional-commits/SKILL.md) — Soạn thảo, chuẩn hóa và kiểm tra commit message theo chuẩn v1.0.0 tiếng Việt có dấu.
