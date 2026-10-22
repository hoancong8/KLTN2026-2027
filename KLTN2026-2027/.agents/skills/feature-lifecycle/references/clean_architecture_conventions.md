# Clean Architecture Conventions Reference (KLTN2026-2027)

Tài liệu quy chuẩn các lớp và thư mục trong mô hình Clean Architecture 3 tầng của ứng dụng Flutter KLTN2026-2027.

---

## 1. Domain Layer (`lib/domain/`)

- **Bản chất:** Pure Dart, không có bất kỳ phụ thuộc nào vào SDK Flutter UI hoặc các package I/O (Dio, SharedPreferences).
- **Entities:** Khai báo bằng immutable class, kế thừa `Equatable` hoặc có constructor `const`.
- **Repositories:** Khai báo dạng `abstract class` chứa các phương thức trả về Future/Stream của Entity.
- **UseCases:** Mỗi use case chỉ thực hiện một hành vi nghiệp vụ đơn nhất. Triển khai interface `UseCase<Output>` hoặc `UseCaseWithParams<Output, Params>`.
- **Exceptions:** Kế thừa `AppException` để hỗ trợ đa ngôn ngữ thông qua `getDisplayMessage(IAppMessages)`.

---

## 2. Data Layer (`lib/data/`)

- **DTOs (`lib/data/dto/<feature>/`):**
  - Chịu trách nhiệm deserialize JSON từ API ABP Framework.
  - Phải có defensive parser helpers (`_parseInt`, `_parseBool`, `_parseString`, `DateTime.tryParse`).
- **Remote Datasource (`lib/data/datasource/remote/`):**
  - Gồm interface trong `abstract/` và class triển khai trong `implement/`.
  - Class implementation bắt buộc kế thừa `BaseRemoteDatasource` và dùng `handleResponse()` / `handleListResponse()`.
- **Mapper (`lib/data/mapper/`):**
  - Thực hiện chuyển đổi 2 chiều: `toEntity(dto)` và `toDto(entity)`.
- **Repositories (`lib/data/repositories/`):**
  - Triển khai interface từ `domain/repositories/`.
  - Gọi remote/local datasource, biến đổi DTO thành Entity qua Mapper, trả về cho Domain.

---

## 3. Presentation Layer (`lib/ui/`)

- **Screen (`lib/ui/screen/<feature>/`):**
  - Entrypoint kế thừa `ConsumerWidget`.
  - Gọi `ResponsiveLayout(mobile: ..., tablet: ...)`.
- **ViewModel & State (`<feature>_vm/`):**
  - State là immutable class có `copyWith`.
  - ViewModel kế thừa `StateNotifier<State>`.
  - ViewModel không nhận `BuildContext`, chỉ nhận UseCases.
- **Widgets (`widgets/`):**
  - Tách riêng `mobile` và `tablet`. Tablet tận dụng màn hình to để hiển thị chia đôi cột (Split View / Master-Detail).
