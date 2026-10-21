# AGENTS.md — KLTN2026-2027 Mobile App Universal Standards

Universal architectural standards, invariants, and safety guardrails across all AI pair-programming tools for the KLTN2026-2027 Flutter Mobile Client.

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

## 2. Core Architectural Invariants

1. **Clean Architecture Dependency Direction (Dependency Rule):**
   `Presentation (UI)` ──► `Domain (Business Core)` ◄── `Data (Infrastructure)`
   - `lib/domain/` is **Pure Dart**. Strictly FORBIDDEN from importing Flutter UI (`package:flutter/*`), HTTP libraries (`package:dio/*`), or Data layer models (`package:.../data/dto/*`).
   - `lib/data/` implements Domain repository interfaces, executes HTTP via Dio, unpacks ABP Framework responses, and maps DTOs to Entities.
   - `lib/ui/` only communicates with ViewModels (`StateNotifier`), UseCases, and Entities. Directly referencing `dio`, `datasource`, or `dto` in UI is strictly forbidden.

2. **Defensive Parsing in DTOs (Crash Prevention):**
   All DTO classes in `lib/data/dto/` MUST use defensive parser helpers (`_parseInt`, `_parseBool`, `_parseString`, safe `DateTime.tryParse`) in `fromJson`. Never assume the backend returns non-null or strictly typed primitive values.

3. **Remote Datasource Protocol & ABP Framework:**
   All Remote Datasource implementations in `lib/data/datasource/remote/implement/` MUST inherit `BaseRemoteDatasource`. Never unwrap `res.data['result']` manually. Always use `handleResponse()`, `handleListResponse()`, and wrap calls in `try-catch` throwing `handleError(e)` (mapped into `AppException`).

4. **Contextual Multi-Club Dynamic RBAC & Active Context:**
   The mobile client operates under a multi-club ecosystem (1 User -> N Clubs -> N Roles). Internal club operations must switch active context via `SwitchClubContextUseCase` (`/switch-context`), storing `ActiveClubContext`. UI permission checks must dynamically query `activeContext.permissions` or `ClubRolePermission` (e.g. `OPERATIONS.SESSION.CREATE`). Never hardcode role name strings.

5. **Mapper Pattern Isolation:**
   All data transformation between DTO and Entity MUST go through dedicated Mappers (`lib/data/mapper/`). DTOs must never cross into Domain entities or UI widgets.

6. **Centralized Riverpod Dependency Injection:**
   All dependencies (Dio, Datasources, Repositories, UseCases) must be registered and resolved centrally in `lib/app/provider.dart`. Use `Provider<T>` for singletons/factories, and `StateNotifierProvider<VM, State>` for screen view models.

7. **Responsive Layout Requirement:**
   Every major screen in `lib/ui/screen/` must support both Mobile and Tablet form factors using `ResponsiveLayout(mobile: ..., tablet: ...)`.

8. **Centralized Error Handling & Localization (i18n):**
   Never hardcode user-facing strings or error messages in Dart files. Business errors inherit `AppException` and resolve localized text via `state.error?.getDisplayMessage(context.l10n)`. Strings reside in `lib/l10n/app_vi.arb` and `lib/l10n/app_en.arb`.

9. **Zero Emoji Policy:**
   Never use emojis in source code, commit messages, logs, or chat responses. Use standard ASCII markers (`[OK]`, `[WARN]`, `[ERROR]`, `[INFO]`) or markdown alerts (`> [!NOTE]`, `> [!IMPORTANT]`).

10. **Mandatory Quality & Architecture Verification:**
    Before concluding any task, verify that:
    - `flutter analyze` returns `No issues found!`.
    - `flutter test` executes with 100% passing tests.
    - Architectural boundaries are verified via `.agents/skills/verify-architecture`.

11. **Mandatory Commit Prompting:**
    Always ask the user if they want to commit after completing any feature addition, bug fix, refactor, or code change with an atomic Conventional Commits message (`<type>(<scope>): <tiêu đề tiếng Việt có dấu>`). Never commit silently.

12. **Mandatory Design Tokens, Adaptive Theming & L10n Standards:**
    - Never hardcode arbitrary hex colors (`Color(0xFF...)`) outside `app_colors.dart`.
    - Never use raw Flutter `Colors.*` (`Colors.white`, `Colors.transparent`, `Colors.black`, `Colors.grey`, `Colors.blue`...). Always use token constants (`AppColors.transparent`, `AppColors.white`) or context-aware tokens (`context.colors.*`).
    - For all dynamic UI components (cards, text, inputs, backgrounds, borders), MUST consume theme-adaptive tokens via `context.colors.*` (`AppThemeColors`) to ensure 100% harmonious rendering in both Light and Dark modes without text disappearance or glare.
    - Strictly enforce Design Tokens from `lib/app/theme/theme.dart` (`AppThemeColors`, `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTheme`).
    - Never hardcode user-facing strings in UI `Text(...)` widgets. Always localize strings via `context.l10n.*` backed by synchronized `app_vi.arb` and `app_en.arb`.
    - Maintain strict UI/UX contrast standards (WCAG AA >= 4.5:1 for body text, >= 3:1 for large text and UI components).

---

## 3. Modular Rules Reference
Detailed Flutter mobile standards are modularized in `.agents/rules/`:
- **Clean Architecture Boundaries:** `.agents/rules/clean-architecture-boundaries.md` (Trigger: `lib/**, test/**`)
- **API Protocol & Resilience:** `.agents/rules/api-protocol-and-resilience.md` (Trigger: `lib/data/**, lib/app/**`)
- **Club Context & Dynamic RBAC:** `.agents/rules/club-context-and-dynamic-rbac.md` (Trigger: `lib/ui/screen/club/**, lib/domain/entities/club/**`)
- **Responsive & UI Standards:** `.agents/rules/responsive-and-ui-standards.md` (Trigger: `lib/ui/**`)
- **Design Tokens & Theming:** `.agents/rules/design-tokens-and-styling.md` (Trigger: `lib/ui/**, lib/widget/**, lib/app/theme/**`)
- **System Spec & API Alignment (SSOT):** `.agents/rules/system-spec-and-api-alignment.md` (Trigger: `model_decision`)
- **Conventional Commits:** `.agents/rules/conventional-commits.md` (Trigger: `model_decision`)
- **Git Commit Safety:** `.agents/rules/git-commit.md` (Trigger: `model_decision`)
