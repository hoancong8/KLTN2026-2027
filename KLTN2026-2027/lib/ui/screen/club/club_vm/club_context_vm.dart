// lib/ui/screen/club/club_vm/club_context_vm.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../app/services/secure_storage_service.dart';
import '../../../../domain/enums/club_role.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/club/create_club_usecase.dart';
import '../../../../domain/usecases/club/get_my_clubs_usecase.dart';
import '../../../../domain/usecases/club/join_club_usecase.dart';
import '../../../../domain/usecases/club/remove_club_member_usecase.dart';
import '../../../../domain/usecases/club/switch_club_context_usecase.dart';
import 'club_context_state.dart';

final clubContextViewModelProvider =
    StateNotifierProvider<ClubContextViewModel, ClubContextState>((ref) {
  return ClubContextViewModel(
    ref: ref,
    getMyClubsUseCase: ref.watch(getMyClubsUseCaseProvider),
    createClubUseCase: ref.watch(createClubUseCaseProvider),
    joinClubUseCase: ref.watch(joinClubUseCaseProvider),
    removeClubMemberUseCase: ref.watch(removeClubMemberUseCaseProvider),
    switchClubContextUseCase: ref.watch(switchClubContextUseCaseProvider),
  );
});

class ClubContextViewModel extends StateNotifier<ClubContextState> {
  final Ref ref;
  final GetMyClubsUseCase getMyClubsUseCase;
  final CreateClubUseCase createClubUseCase;
  final JoinClubUseCase joinClubUseCase;
  final RemoveClubMemberUseCase removeClubMemberUseCase;
  final SwitchClubContextUseCase switchClubContextUseCase;

  ClubContextViewModel({
    required this.ref,
    required this.getMyClubsUseCase,
    required this.createClubUseCase,
    required this.joinClubUseCase,
    required this.removeClubMemberUseCase,
    required this.switchClubContextUseCase,
  }) : super(const ClubContextState()) {
    loadMyClubs();
  }

  /// Tải danh sách các câu lạc bộ người dùng tham gia kèm vai trò và quyền hạn (FR03)
  Future<void> loadMyClubs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final clubs = await getMyClubsUseCase.execute();
      state = state.copyWith(
        myClubs: clubs,
        isLoading: false,
      );

      // Nếu có ít nhất 1 CLB: ưu tiên khôi phục activeClubId đã lưu hoặc chọn CLB đầu tiên
      if (clubs.isNotEmpty) {
        final savedClubId = await SecureStorageService.instance.getActiveClubId();
        final targetClub = clubs.firstWhere(
          (c) => c.clubId == savedClubId,
          orElse: () => clubs.first,
        );
        await switchClub(targetClub.clubId);
      } else {
        await SecureStorageService.instance.saveActiveClubId('');
        ref.read(activeClubContextProvider.notifier).state = null;
        state = state.copyWith(clearActiveContext: true);
      }
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: e.toString()),
      );
    }
  }

  /// Chuyển đổi ngữ cảnh Câu lạc bộ đang hoạt động (FR04)
  /// Thiết lập Active Context và cập nhật Header X-Group-Id mà không thay đổi AccessToken toàn cục.
  Future<bool> switchClub(String clubId) async {
    if (state.isSwitching) return false;
    state = state.copyWith(isSwitching: true, clearError: true, clearSuccess: true);

    try {
      final activeContext = await switchClubContextUseCase.execute(clubId);

      // 1. Lưu activeClubId vào SecureStorage để Dio Interceptor tự động gắn Header X-Group-Id
      await SecureStorageService.instance.saveActiveClubId(clubId);

      // 2. Cập nhật provider ngữ cảnh toàn cục (Contextual RBAC)
      ref.read(activeClubContextProvider.notifier).state = activeContext;

      // 3. AccessToken toàn cục giữ nguyên suốt phiên làm việc (Clean Context-Based Auth)
      // Không ghi đè authTokenProvider hay Token trong SecureStorage.

      state = state.copyWith(
        activeContext: activeContext,
        isSwitching: false,
        successMessage: 'Đã chuyển sang nhóm ${activeContext.clubName} (${activeContext.role.displayName})',
      );
      debugPrint('[ClubContextVM] Switched context to ${activeContext.clubName} as ${activeContext.role.displayName} (X-Group-Id: $clubId)');
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSwitching: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSwitching: false,
        error: AppException(message: 'Lỗi chuyển nhóm: $e'),
      );
      return false;
    }
  }

  /// Tham gia một câu lạc bộ mới bằng mã code
  Future<bool> joinClub({
    required String clubCode,
    ClubRole role = ClubRole.member,
    String? nickname,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await joinClubUseCase.execute(JoinClubParams(
        clubCode: clubCode,
        role: role,
        nickname: nickname,
      ));

      await loadMyClubs();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tham gia câu lạc bộ thành công',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: 'Không thể tham gia: $e'),
      );
      return false;
    }
  }

  /// Tạo một câu lạc bộ mới (người tạo tự động trở thành Host)
  Future<String?> createClub({
    required String name,
    String? description,
    String? avatarUrl,
    String? fixedVenueName,
    String? fixedAddress,
    double? lat,
    double? lng,
    String? minSkillLevel,
    String? maxSkillLevel,
    List<dynamic>? schedules,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final newClubId = await createClubUseCase.execute(CreateClubParams(
        name: name,
        description: description,
        avatarUrl: avatarUrl,
        fixedVenueName: fixedVenueName,
        fixedAddress: fixedAddress,
        lat: lat,
        lng: lng,
        minSkillLevel: minSkillLevel,
        maxSkillLevel: maxSkillLevel,
        schedules: schedules,
      ));

      await loadMyClubs();
      if (newClubId.isNotEmpty) {
        await switchClub(newClubId);
      }
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tạo câu lạc bộ mới thành công! Bạn là Chủ nhóm (Host).',
      );
      return newClubId;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: 'Không thể tạo nhóm: $e'),
      );
      return null;
    }
  }

  /// Rời khỏi câu lạc bộ
  Future<bool> leaveClub(String clubId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final currentProfile = ref.read(currentUserProfileProvider);
      final userId = currentProfile?.id ?? '';
      await removeClubMemberUseCase.execute(RemoveClubMemberParams(
        clubId: clubId,
        userId: userId,
      ));

      // Nếu đang ở trong CLB bị rời -> clear activeContext
      if (state.currentClubId == clubId) {
        ref.read(activeClubContextProvider.notifier).state = null;
        state = state.copyWith(clearActiveContext: true);
      }

      await loadMyClubs();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Đã rời khỏi câu lạc bộ',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: 'Lỗi rời nhóm: $e'),
      );
      return false;
    }
  }
}
