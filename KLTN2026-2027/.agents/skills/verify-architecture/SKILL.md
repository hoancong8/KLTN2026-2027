---
name: verify-architecture
description: >-
  Verify Clean Architecture boundaries, layer purity (Domain, Data, UI), defensive DTO parsing, zero-emoji policy, and run flutter analyze & flutter test in KLTN2026-2027. Use before completing any feature, bug fix, or refactor to guarantee full architectural compliance.
---

# Flutter Architecture & Quality Verification

## Goal (Single Responsibility)
Execute comprehensive static analysis, architectural boundary validation, and automated test execution for the Flutter codebase to ensure zero violations.

---

## Black-Box Script Invocations

> [!IMPORTANT]
> **Use Scripts as Black Boxes:** Do NOT read or load the Python script source code into context. Run the CLI directly.

Execute the unified verification script from workspace root:

```powershell
python .agents/skills/verify-architecture/scripts/verify_architecture.py
```

The script performs 3 verification gates:
1. **Architectural Purity & Boundaries:** Scans `lib/` to confirm Domain has no Flutter UI/Dio/DTO, UI has no direct Datasource/Dio/DTO, Datasources extend `BaseRemoteDatasource`, and Zero Emoji policy is observed.
2. **Flutter Static Analysis:** Runs `flutter analyze` ensuring 0 warnings and 0 errors.
3. **Automated Tests:** Runs `flutter test` ensuring 100% test pass rate.

---

## References & Troubleshooting
- [Checklist Kiến Trúc](./references/architecture_checklist.md)
- [Hướng Dẫn Khắc Phục Lỗi](./examples/troubleshooting_fixes.md)
