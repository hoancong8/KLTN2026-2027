# GEMINI.md — Antigravity Agent Configuration (KLTN2026-2027)

> [!NOTE]
> Project-specific pair-programming persona, response formatting, and agentic execution workflow for the KLTN2026-2027 Flutter Mobile Client (Clean Architecture 3 Tầng / Riverpod / Dio / ABP Framework).

---

## 1. Persona & Response Standards

1. **Concise & Technically Rigorous:** Skip pleasantries and basic tutorials. Focus directly on code logic, architectural rationale, and concrete Flutter / Dart 3 / Riverpod solutions.
2. **Mandatory Clickable Links & Relative Repository Paths:** In chat responses, format clickable links with forward slashes for files and exact lines. In repository files (.md, .dart, scripts), NEVER hardcode local machine absolute drive paths (e.g., `d:/l7TeamVN/...`); always use repo-relative paths (`lib/...`, `docs/...`, `.agents/...`) to maintain 100% portability across all operating systems and machines.
3. **Language Consistency:** Match user language (Vietnamese for Vietnamese prompts, English for English prompts). Keep technical terms in English (`Entity`, `UseCase`, `Repository`, `Datasource`, `StateNotifier`, `Provider`, `Defensive Parsing`, `ABP Protocol`).
4. **Zero Emoji Policy:** Zero emoji icons in responses, commit messages, code, or logs. Use clean markdown and ASCII indicators (`[OK]`, `[WARN]`, `[ERROR]`, `[INFO]`, or GitHub markdown alerts `> [!NOTE]`, `> [!IMPORTANT]`).

---

## 2. Agentic Workflow: Plan → Execute → Verify → Prompt for Commit

1. **Plan Before Executing:** Consult the Single Source of Truth before modifying or adding features:
   - System Design & Requirements: `docs/01_TONG_QUAN_DE_TAI.md` -> `docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md`
   - Architecture Guidelines: `ARCHITECTURE_RULES.md`
   - API to Clean Architecture Mapping: `docs_api_clean_arch.md`
   - Raw API Documentation: `docs_api.md`
2. **Execute Defensively (5-Step Clean Architecture Workflow):**
   - **Step 1 (Domain):** Entity -> Repository Interface -> UseCase(s). Pure Dart, zero Flutter/Dio/DTO dependencies.
   - **Step 2 (Data):** DTO (with defensive parsing) -> Mapper -> Remote Datasource (inheriting `BaseRemoteDatasource`) -> Repository Implementation.
   - **Step 3 (App DI):** Register Endpoints in `app_config.dart` and wire up Providers in `lib/app/provider.dart`.
   - **Step 4 (UI / Presentation):** State (immutable `copyWith`) -> ViewModel (`StateNotifier<State>`) -> Screen (`ResponsiveLayout`) -> Mobile & Tablet Widgets. Check contextual RBAC via `ActiveClubContext`. Enforce Design Tokens (`context.colors.*` via `AppThemeColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTheme` from `package:kltn2026_2027/app/theme/theme.dart`). Strictly forbid hardcoded hex codes, raw `Colors.*`, static light colors on dynamic widgets, random font styles, or ad-hoc margins/paddings. Guarantee WCAG AA contrast on both Light and Dark themes.
   - **Step 5 (Localization & Resilience):** Add `.arb` keys synchronized across `app_vi.arb` & `app_en.arb`, bind `context.l10n`, strictly forbid hardcoded UI strings in `Text(...)`, and handle errors via `AppException`.
3. **Verify Immediately:**
   - Run architecture boundary and code health verification:
     ```powershell
     python .agents/skills/verify-architecture/scripts/verify_architecture.py
     ```
   - Run Flutter static analysis:
     ```powershell
     cd KLTN2026-2027; flutter analyze
     ```
   - Run unit and mapper tests:
     ```powershell
     cd KLTN2026-2027; flutter test
     ```
   Ensure zero analyzer warnings and 100% tests passing.
4. **Mandatory Commit Prompting:** ALWAYS ask the user if they want to commit after completing any code change, feature, or bugfix with an atomic Conventional Commits message (`<type>(<scope>): <tiêu đề tiếng Việt có dấu>`). Never commit silently.

---

## 3. Specialized Skills

- **Clean Feature Builder:** `.agents/skills/add-clean-feature` for scaffolding complete 5-layer Flutter feature slices (Domain -> Data -> DI -> UI -> Test).
- **Architecture & Quality Verification:** `.agents/skills/verify-architecture` for checking boundary purity, defensive parsing, `flutter analyze`, and `flutter test`.
- **Git Commits:** `.agents/skills/conventional-commits` for commit drafting, staging, and scope validation.
- **System Spec Alignment:** `.agents/skills/implement-system-spec` for tracing FR01-FR23, UC01-UC20, and API endpoints against `docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md` and `docs_api_clean_arch.md`.
