# Ví Dụ Mẫu Một Lát Cắt Tính Năng Clean Architecture (Feature Slice Sample)

Ví dụ chi tiết về tính năng **Club Member (Thành viên nhóm)** đầy đủ qua 5 tầng:

---

## 1. Tầng Domain
- **Entity:** `lib/domain/entities/club/club_member.dart`
- **Repo Interface:** `lib/domain/repositories/club_member_repository.dart`
- **UseCase:** `lib/domain/usecases/club/get_club_members_usecase.dart`

```dart
// lib/domain/usecases/club/get_club_members_usecase.dart
import '../../app/usecase.dart';
import '../../entities/club/club_member.dart';
import '../../repositories/club_member_repository.dart';

class GetClubMembersUseCase implements UseCaseWithParams<List<ClubMember>, String> {
  final ClubMemberRepository repository;
  GetClubMembersUseCase(this.repository);

  @override
  Future<List<ClubMember>> execute(String clubId) {
    return repository.getClubMembers(clubId);
  }
}
```

---

## 2. Tầng Data
- **DTO:** `lib/data/dto/club/club_member_response_dto.dart` (có defensive parsing)
- **Mapper:** `lib/data/mapper/club_member_mapper.dart`
- **Datasource:** `lib/data/datasource/remote/implement/club_member_remote_datasource_impl.dart`
- **Repo Impl:** `lib/data/repositories/club_member_repository_impl.dart`

```dart
// lib/data/repositories/club_member_repository_impl.dart
import '../../domain/entities/club/club_member.dart';
import '../../domain/repositories/club_member_repository.dart';
import '../datasource/remote/abstract/club_member_remote_datasource.dart';
import '../mapper/club_member_mapper.dart';

class ClubMemberRepositoryImpl implements ClubMemberRepository {
  final ClubMemberRemoteDatasource remote;
  ClubMemberRepositoryImpl(this.remote);

  @override
  Future<List<ClubMember>> getClubMembers(String clubId) async {
    final dtos = await remote.getMembers(clubId);
    return dtos.map(ClubMemberMapper.toEntity).toList();
  }
}
```

---

## 3. Tầng App DI (`lib/app/provider.dart`)

```dart
final clubMemberRemoteDatasourceProvider = Provider<ClubMemberRemoteDatasource>((ref) {
  return ClubMemberRemoteDatasourceImpl(ref.watch(dioProvider));
});

final clubMemberRepositoryProvider = Provider<ClubMemberRepository>((ref) {
  return ClubMemberRepositoryImpl(ref.watch(clubMemberRemoteDatasourceProvider));
});

final getClubMembersUseCaseProvider = Provider<GetClubMembersUseCase>((ref) {
  return GetClubMembersUseCase(ref.watch(clubMemberRepositoryProvider));
});
```

---

## 4. Tầng UI Presentation
- **State:** `lib/ui/screen/club_members/club_members_vm/club_members_state.dart`
- **ViewModel:** `lib/ui/screen/club_members/club_members_vm/club_members_vm.dart`
- **Screen:** `lib/ui/screen/club_members/club_members_screen.dart` (Dùng `ResponsiveLayout`)
- **Widgets:** `widgets/club_members_mobile.dart` & `widgets/club_members_tablet.dart`
