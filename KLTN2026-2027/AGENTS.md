# AGENTS.md — KLTN2026-2027 Mobile App Universal Standards

Tài liệu định nghĩa các tiêu chuẩn phổ quát, nguyên tắc giao tiếp, phân định ranh giới tác vụ và ma trận phân công Subagents áp dụng xuyên suốt dự án KLTN2026-2027 Flutter Mobile Client trên mọi công cụ AI pair-programming.

---

## 1. Tech Stack & Target Environment
- **Platform:** Flutter 3.x (Dart 3.x).
- **Architecture:** Clean Architecture 3 Tầng (`Domain` -> `Data` -> `Presentation / UI`) + Centralized Riverpod DI.
- **State Management & DI:** `flutter_riverpod` 3.x (`StateNotifier`, `StateNotifierProvider`, `Provider`, `StateProvider`).
- **HTTP Client & Protocol:** `dio` 5.x + `pretty_dio_logger` + ABP Framework wrapper (`result`, `items`, `totalCount`, `error`).
- **Navigation:** `go_router` 14.x (Declarative routing, redirection guards).
- **Security & Storage:** `flutter_secure_storage` (AuthToken, RefreshToken), `shared_preferences`, `local_auth` (Biometrics).
- **Push Notification:** `firebase_core` 3.x + `firebase_messaging` 15.x.
- **Localization & Assets:** `flutter_localizations`, `intl` 0.20+, `.arb` files (`app_vi.arb`, `app_en.arb`), `context.l10n`.
- **Quality & Static Analysis:** `flutter_lints` 6.x (`flutter analyze`), `flutter_test`.

---

## 2. Quy Tắc Chung Toàn Bộ Dự Án (Universal Standards)
*Áp dụng bắt buộc trên toàn bộ workspace, mọi ngôn ngữ/tập tin, mọi lượt tương tác của agent.*

1. **Chuẩn Ngôn Ngữ & Tiếng Việt Có Dấu (Standard Accented Vietnamese):** Khi phản hồi hội thoại, viết UI strings, ghi chú tài liệu hoặc viết commit message bằng tiếng Việt, BẮT BUỘC sử dụng tiếng Việt có dấu đầy đủ, chuẩn chính tả ngữ pháp. Tuyệt đối không viết không dấu, viết tắt hoặc teencode. Các thuật ngữ kỹ thuật chuyên ngành giữ nguyên tiếng Anh (`Entity`, `UseCase`, `Repository`, `Datasource`, `StateNotifier`, `Provider`, `Defensive Parsing`, `ABP Protocol`).
2. **Chính Sách Zero Emoji (Zero Emoji Policy):** Nghiêm cấm sử dụng emoji trong mã nguồn Dart, commit message, nhật ký log, và phản hồi hội thoại. Sử dụng các ký hiệu ASCII chuẩn: `[OK]`, `[WARN]`, `[ERROR]`, `[INFO]`, hoặc markdown alerts (`> [!NOTE]`, `> [!IMPORTANT]`, `> [!WARNING]`).
3. **Định Dạng Đường Dẫn Tương Đối & Cấm Tuyệt Đối URI Cục Bộ (Repo-Relative Paths Only):** Trong toàn bộ mã nguồn, tài liệu repo, rules, skills, và subagents, TUYỆT ĐỐI CẤM hardcode URI ổ đĩa máy cục bộ (`file:///d:/...` hay `d:\...`). 100% tài liệu và liên kết phải sử dụng đường dẫn tương đối chuẩn repo (`lib/...`, `docs/...`, `.agents/...`). Dạng clickable `file:///` chỉ sử dụng khi trợ lý AI phản hồi trực tiếp trên khung chat nếu môi trường yêu cầu, không bao giờ được ghi vào tệp trong repo.
4. **Chính Sách Zero Additional Comments (Code Tự Tường Minh):** Tuyệt đối không viết comment giải thích rườm rà (`//`, `/* */`) khi chỉnh sửa hoặc viết code mới. Mã nguồn phải tự tường minh thông qua cấu trúc phân tầng rõ ràng, hàm nhỏ gọn và cách đặt tên biến/phương thức biểu cảm. Bảo toàn nguyên vẹn doc comments hiện có (`///`) không liên quan đến thay đổi.
5. **Triệt Tiêu Kế Thừa Cũ & Định Danh Duy Nhất (Zero Legacy & Single Canonical ID):** Không tạo các lớp tương thích ngược (deprecated shims, backwards-compatibility fallbacks, overload cũ). Không viết các nhánh fallback kiểm tra nhiều tên alias cho API keys, configuration key hay schema constants. Mỗi khái niệm chỉ có MỘT tên chuẩn duy nhất (Single Canonical Identifier).
6. **Thực Thi Trực Tiếp End-to-End (Direct End-to-End Execution):** Không chia nhỏ công việc thành các mốc thời gian nhân tạo, timeline nhiều ngày hoặc roadmap kéo dài. Thực thi và hoàn thành dứt điểm, trọn vẹn từ đầu đến cuối trong một phiên làm việc liên tục.
7. **Quy Trình Git Commit Chuẩn Hóa (Mandatory Commit Prompting & Conventional Commits):** Mọi commit phải tuân thủ nghiêm ngặt chuẩn Conventional Commits v1.0.0 (`<type>(<scope>): <tiêu đề tiếng Việt có dấu>`) theo [`conventional-commits.md`](.agents/rules/conventional-commits.md). Luôn hỏi xin xác nhận từ người dùng kèm thông điệp commit đề xuất và danh sách file thay đổi trước khi thực thi commit. Tuyệt đối không tự động commit ngầm.
8. **Ranh Giới Clean Architecture 3 Tầng Bất Biến (Dependency Rule):**
   - `lib/domain/`: Pure Dart 100%. Nghiêm cấm import Flutter UI (`package:flutter/*`), HTTP client (`package:dio/*`), hay Data models (`package:.../data/dto/*`).
   - `lib/data/`: Triển khai Repository interfaces, giao tiếp Dio, DTO phòng thủ, giải mã ABP wrapper, và chuyển đổi qua Mapper.
   - `lib/ui/`: Chỉ giao tiếp với ViewModels (`StateNotifier`), UseCases, và Entities. Cấm import Dio, Datasource, hoặc DTO.
9. **Kỹ Thuật Phòng Thủ Dữ Liệu DTO & ABP Resilience:**
   - 100% DTO tại `lib/data/dto/` bắt buộc dùng parser phòng thủ (`_parseInt`, `_parseBool`, `_parseString`, safe `DateTime.tryParse`) trong `fromJson`.
   - 100% Remote Datasources kế thừa `BaseRemoteDatasource`, sử dụng `handleResponse()` / `handleListResponse()`, và bọc `try-catch` ném `handleError(e)`.
10. **Contextual Multi-Club Dynamic RBAC & Active Context:**
    - Hoạt động theo mô hình đa CLB (1 User $\rightarrow$ N Clubs $\rightarrow$ N Roles). Chuyển đổi ngữ cảnh qua `SwitchClubContextUseCase` (`/switch-context`), lưu `ActiveClubContext`.
    - Kiểm tra quyền động qua `activeContext.permissions` hoặc `ClubRolePermission`. Cấm hardcode tên role dạng chuỗi.
11. **Design Tokens, Adaptive Theming & L10n:**
    - Cấm hardcode mã màu hex (`Color(0xFF...)`) ngoài `app_colors.dart`.
    - Cấm dùng raw `Colors.*`. 100% màu sắc sử dụng qua token `context.colors.*` (`AppThemeColors`) hoặc token hằng số `AppColors.transparent`.
    - Mọi màn hình chính phải hỗ trợ `ResponsiveLayout(mobile: ..., tablet: ...)`.
    - 100% text giao diện đọc qua `context.l10n.*` đồng bộ cả hai tệp `lib/l10n/app_vi.arb` và `lib/l10n/app_en.arb`. Lỗi nghiệp vụ kế thừa `AppException` và resolve qua `state.error?.getDisplayMessage(context.l10n)`.
12. **Kiểm Tra Kiến Trúc & Chất Lượng Bắt Buộc (Mandatory Verification):**
    Trước khi kết thúc bất kỳ tác vụ nào, bắt buộc xác nhận:
    - `python .agents/skills/verify-architecture/scripts/verify_architecture.py` báo cáo 100% compliant.
    - `flutter analyze` báo cáo `No issues found!`.
    - `flutter test` đạt 100% tests passed.

---

## 3. Phân Định Ranh Giới Tác Vụ (Task Scope & Triggering)

Nhằm tối ưu hóa hiệu năng, ngữ cảnh và tránh nạp thừa các quy tắc kỹ thuật không liên quan, agent phân định rõ 2 nhóm tác vụ:

### 3.1. Tác Vụ Không Cần Code (Non-Coding Tasks)
- **Phạm vi:** Trả lời câu hỏi, tra cứu spec/docs, giải thích logic/kiến trúc hiện tại, kiểm tra trạng thái Git/nhật ký log, trao đổi ý tưởng, tư vấn giải pháp, hướng dẫn sử dụng.
- **Quy tắc xử lý:**
  - Trực tiếp phản hồi nhanh chóng, ngắn gọn, súc tích, tuân thủ phong cách giao tiếp và clickable links.
  - **TUYỆT ĐỐI KHÔNG** nạp các rule code chi tiết, **KHÔNG** kích hoạt subagents viết code, **KHÔNG** ép chu trình khi không có thay đổi mã nguồn.

### 3.2. Tác Vụ Lập Trình & Thay Đổi Mã Nguồn (Coding Tasks)
- **Phạm vi:** Phát triển tính năng mới, cập nhật logic hiện có, sửa lỗi (bug fixes), tái cấu trúc (refactor), scaffolding màn hình, tạo widget/tokens.
- **Quy tắc xử lý:**
  - Kích hoạt chu trình phát triển 4 bước chuẩn hóa với sự tham gia của các Subagents chuyên trách.
  - Các quy chuẩn kỹ thuật chuyên sâu được tự động nạp theo đúng ngữ cảnh thực thi:
    - *Kiến trúc hệ thống & Impact Gate:* [`system-architecture.md`](.agents/rules/system-architecture.md).
    - *Tầng lõi Core (Domain, Data, API ABP, RBAC):* [`core-architecture.md`](.agents/rules/core-architecture.md).
    - *Tầng giao diện (Presentation, Responsive, L10n):* [`ui-architecture.md`](.agents/rules/ui-architecture.md).
    - *Design Tokens & Styling:* [`design-tokens-and-styling.md`](.agents/rules/design-tokens-and-styling.md).
    - *Đối chiếu đặc tả hệ thống SSOT:* [`system-spec-reference.md`](.agents/rules/system-spec-reference.md).
    - *Quy chuẩn commit Git:* [`conventional-commits.md`](.agents/rules/conventional-commits.md).

---

## 4. Ma Trận Phân Công Subagents Chuyên Trách
*Chỉ áp dụng và ủy thác khi có tác vụ kỹ thuật cụ thể tương ứng:*

| Subagent Chuyên Trách | Trách Nhiệm Cốt Lõi | Ngữ Cảnh Ủy Thác |
|---|---|---|
| [`system-spec-inspector`](.agents/agents/system-spec-inspector.md) | Chuyên gia tra cứu đọc tài liệu đặc tả SSOT (`docs/`, `docs_api.md`, `docs_api_clean_arch.md`, `ARCHITECTURE_RULES.md`), trích xuất yêu cầu FR01-FR23, UC01-UC20, hợp đồng API và RBAC. | Khi cần xác minh yêu cầu, tra cứu schema endpoint, DTO/Entity mapping, hoặc quyền câu lạc bộ. |
| [`architecture-evaluator`](.agents/agents/architecture-evaluator.md) | Đánh giá tác động kiến trúc Clean Architecture (Architectural Impact Gate), thiết kế Blueprint 5 tầng, sơ đồ Mermaid, đánh giá rủi ro rò rỉ ranh giới và trình người dùng duyệt. | Khi có tính năng mới, thay đổi luồng điều phối, tái cấu trúc, hoặc bổ sung tích hợp nền tảng. |
| [`feature-engineer`](.agents/agents/feature-engineer.md) | Kỹ sư Clean Architecture Full-Stack trực tiếp viết mã triển khai tính năng khép kín 5 tầng (Domain $\rightarrow$ Data $\rightarrow$ App DI $\rightarrow$ UI $\rightarrow$ L10n). | Sau khi blueprint được duyệt (hoặc thay đổi cục bộ), cần viết mã mới hoặc sửa đổi code Dart/ARB. |
| [`code-integrity-auditor`](.agents/agents/code-integrity-auditor.md) | Kiểm toán mã nguồn độc lập, rà soát rò rỉ ranh giới, defensive parsing DTO, design tokens/adaptive theming, hardcoded text, chạy verify_architecture.py, flutter analyze và test. | Sau khi viết hoặc sửa code Dart / ARB, trước khi nghiệm thu và commit (tối đa 2 vòng verify-fix). |

---

## 5. Danh Mục Quy Tắc Chuyên Sâu (Modular Rules Reference)
- **System Architecture & Impact Gate:** [`.agents/rules/system-architecture.md`](.agents/rules/system-architecture.md) (Trigger: `lib/**, test/**`)
- **Core Architecture (Domain, Data & RBAC):** [`.agents/rules/core-architecture.md`](.agents/rules/core-architecture.md) (Trigger: `lib/domain/**, lib/data/**, lib/app/provider.dart`)
- **UI Architecture & Presentation:** [`.agents/rules/ui-architecture.md`](.agents/rules/ui-architecture.md) (Trigger: `lib/ui/**, lib/widget/**`)
- **Design Tokens & Theming:** [`.agents/rules/design-tokens-and-styling.md`](.agents/rules/design-tokens-and-styling.md) (Trigger: `lib/ui/**, lib/widget/**, lib/app/theme/**`)
- **System Spec Reference (SSOT):** [`.agents/rules/system-spec-reference.md`](.agents/rules/system-spec-reference.md) (Trigger: `model_decision`)
- **Conventional Commits & Safety:** [`.agents/rules/conventional-commits.md`](.agents/rules/conventional-commits.md) (Trigger: `model_decision`)
