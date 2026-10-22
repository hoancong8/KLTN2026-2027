---
name: core-clean-developer
description: >-
  Comprehensive backend mobile engineering skill for KLTN2026-2027 Core layers: pure Dart Domain (Entities, Repositories, UseCases), Data infrastructure (DTOs with Defensive Parsing, Mappers, BaseRemoteDatasource, ABP Protocol), Centralized Riverpod DI, and Contextual Multi-Club Dynamic RBAC. Use whenever developing, extending, refactoring, fixing bugs, or testing logic ONLY within Domain or Data (not spanning UI), or when asked to 'phát triển core', 'thêm usecase', 'sửa dto', 'fix parser dto', 'thêm mapper', 'tạo entity', 'kết nối api abp', 'chuyển ngữ cảnh clb', 'sửa datasource'. Do NOT use for cross-layer Core+UI tasks (use feature-lifecycle instead) or UI-only tasks (use ui-flutter-developer instead).
---

# KLTN Core Clean Developer — Domain, Data & Multi-Club RBAC

## Goal (Single Responsibility)
Quy trình kỹ thuật toàn diện để phát triển mới, mở rộng, sửa lỗi, phòng thủ dữ liệu và kiểm thử mã nguồn trong tầng Lõi Backend Mobile ([`lib/domain/`](lib/domain), [`lib/data/`](lib/data), [`lib/app/provider.dart`](lib/app/provider.dart)) tuân thủ Pure Dart Domain, DTO Defensive Parsing, BaseRemoteDatasource và Multi-Club Dynamic RBAC.

---

## Ma Trận Phân Công Subagents Trong Phân Hệ Core

| Tác Vụ Cụ Thể | Subagent Đảm Nhiệm | Rào Chắn & Trách Nhiệm Bắt Buộc |
|---|---|---|
| **Tra cứu endpoint, DTO/Entity schema, quyền CLB** | [`system-spec-inspector`](.agents/agents/system-spec-inspector.md) | Tra cứu [`docs_api_clean_arch.md`](docs_api_clean_arch.md) và [`docs_api.md`](docs_api.md). |
| **Đánh giá kiến trúc thay đổi, abstractions, RBAC** | [`architecture-evaluator`](.agents/agents/architecture-evaluator.md) | Lập Blueprint nếu thay đổi base contracts hoặc luồng xác thực/ngữ cảnh. |
| **Viết mã Entity, Repo, UseCase, DTO, Datasource, Mapper** | [`feature-engineer`](.agents/agents/feature-engineer.md) | Pure Dart Domain, 100% defensive parsing trong DTO, BaseRemoteDatasource. |
| **Kiểm toán ranh giới pure Dart, defensive parsing, test** | [`code-integrity-auditor`](.agents/agents/code-integrity-auditor.md) | Quét verify_architecture.py, kiểm tra null safety và rò rỉ ranh giới. |

---

## Decision Tree: Phân Loại Tác Vụ trong Core

```text
Yêu cầu tác vụ liên quan đến tầng Lõi Core (Domain / Data / DI)
  │
  ├── 1. Thêm hành động nghiệp vụ mới (UseCase)?
  │      └── Định nghĩa UseCase trong lib/domain/usecases/<feature>/, kế thừa UseCase<Type> hoặc UseCaseWithParams<Type, Params> và đăng ký Provider tại lib/app/provider.dart.
  │
  ├── 2. Thêm hoặc cập nhật Entity nghiệp vụ?
  │      └── Tạo/sửa Pure Dart class trong lib/domain/entities/<feature>/ (bất biến @immutable, copyWith, operator ==).
  │
  ├── 3. Kết nối API Endpoint mới hoặc cập nhật Schema?
  │      ├── Định nghĩa DTO trong lib/data/dto/<feature>/ với 100% helper phòng thủ (_parseInt, _parseBool, _parseString, DateTime.tryParse).
  │      ├── Tạo/sửa Mapper trong lib/data/mapper/<feature>_mapper.dart (toEntity, toDto).
  │      ├── Tạo Remote Datasource kế thừa BaseRemoteDatasource trong lib/data/datasource/remote/.
  │      └── Triển khai Repository trong lib/data/repositories/<feature>_repository_impl.dart.
  │
  ├── 4. Sửa lỗi DTO bị crash TypeError (do backend trả sai kiểu hoặc null)?
  │      └── Thay thế toàn bộ ép kiểu thô (as int, as String, as bool) bằng các helper phòng thủ nội bộ DTO.
  │
  ├── 5. Thao tác liên quan đến phân quyền hoặc chuyển đổi ngữ cảnh CLB?
  │      ├── Chuyển đổi ngữ cảnh qua SwitchClubContextUseCase (/switch-context).
  │      └── Kiểm tra quyền thông qua activeContext.permissions hoặc ClubRolePermission. CẤM hardcode chuỗi role!
  │
  └── 6. Đăng ký phụ thuộc mới vào hệ thống?
         └── Khai báo Provider tập trung tại lib/app/provider.dart theo thứ tự Datasource → Repo → UseCase.
```

---

## Rào Chắn Bất Biến (Core Invariants)

1. **Domain Pure Dart:** Tuyệt đối cấm import `package:flutter/*`, `package:dio/*`, hoặc `package:.../data/dto/*` trong `lib/domain/`.
2. **DTO Defensive Parsing:** 100% DTO phải dùng `_parseInt`, `_parseDouble`, `_parseBool`, `_parseString`, `DateTime.tryParse`. Không bao giờ tin cậy backend trả về non-null.
3. **Datasource ABP Contract:** 100% Remote Datasource kế thừa `BaseRemoteDatasource`, dùng `handleResponse()` / `handleListResponse()`, bọc `try-catch` ném `handleError(e)`.
4. **Dynamic RBAC:** Không so sánh chuỗi tên role (`role == 'ADMIN'`). Kiểm tra qua quyền hạn `activeContext.permissions`.
