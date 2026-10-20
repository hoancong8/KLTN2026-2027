import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/club/club_detail.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/club/get_club_detail_usecase.dart';
import '../../../../domain/usecases/club/join_request_usecases.dart';
import '../../../../domain/usecases/club/switch_club_context_usecase.dart';
import '../../../../domain/usecases/club/update_club_info_usecase.dart';
import '../../../../domain/usecases/club/update_club_schedules_usecase.dart';
import '../../club/club_vm/club_context_vm.dart';
import 'club_detail_state.dart';

final clubDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<ClubDetailViewModel, ClubDetailState, String>((ref, clubId) {
  return ClubDetailViewModel(
    ref: ref,
    clubId: clubId,
    getClubDetailUseCase: ref.watch(getClubDetailUseCaseProvider),
    createJoinRequestUseCase: ref.watch(createJoinRequestUseCaseProvider),
    switchClubContextUseCase: ref.watch(switchClubContextUseCaseProvider),
    updateClubInfoUseCase: ref.watch(updateClubInfoUseCaseProvider),
    updateClubSchedulesUseCase: ref.watch(updateClubSchedulesUseCaseProvider),
  );
});

class ClubDetailViewModel extends StateNotifier<ClubDetailState> {
  final Ref ref;
  final String clubId;
  final GetClubDetailUseCase getClubDetailUseCase;
  final CreateJoinRequestUseCase createJoinRequestUseCase;
  final SwitchClubContextUseCase switchClubContextUseCase;
  final UpdateClubInfoUseCase updateClubInfoUseCase;
  final UpdateClubSchedulesUseCase updateClubSchedulesUseCase;

  ClubDetailViewModel({
    required this.ref,
    required this.clubId,
    required this.getClubDetailUseCase,
    required this.createJoinRequestUseCase,
    required this.switchClubContextUseCase,
    required this.updateClubInfoUseCase,
    required this.updateClubSchedulesUseCase,
  }) : super(const ClubDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final club = await getClubDetailUseCase.execute(clubId);
      state = state.copyWith(isLoading: false, club: club);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: e.toString()),
      );
    }
  }

  Future<bool> sendJoinRequest(String? introduction) async {
    state = state.copyWith(isSubmitting: true, error: null, successMessage: null);
    try {
      await createJoinRequestUseCase.execute(clubId, introduction: introduction);
      await loadDetail();
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Đã gửi yêu cầu gia nhập CLB thành công! Chờ duyệt nhé!',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: AppException(message: e.toString()),
      );
      return false;
    }
  }

  Future<bool> switchContext() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final success = await ref.read(clubContextViewModelProvider.notifier).switchClub(clubId);
      state = state.copyWith(isSubmitting: false);
      return success;
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: AppException(message: e.toString()),
      );
      return false;
    }
  }

  Future<bool> updateInfo({
    required String groupName,
    String? description,
    String? avatarUrl,
    String? fixedVenueName,
    String? fixedAddress,
    double? lat,
    double? lng,
    SkillLevel? minSkillLevel,
    SkillLevel? maxSkillLevel,
    required bool isRecruiting,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, successMessage: null);
    try {
      await updateClubInfoUseCase.execute(UpdateClubInfoParams(
        clubId: clubId,
        groupName: groupName,
        description: description,
        avatarUrl: avatarUrl,
        fixedVenueName: fixedVenueName,
        fixedAddress: fixedAddress,
        lat: lat,
        lng: lng,
        minSkillLevel: minSkillLevel,
        maxSkillLevel: maxSkillLevel,
        isRecruiting: isRecruiting,
      ));
      await loadDetail();
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Cập nhật thông tin CLB thành công!',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: AppException(message: e.toString()),
      );
      return false;
    }
  }

  Future<bool> updateSchedules(List<ClubScheduleInput> schedules) async {
    state = state.copyWith(isSubmitting: true, error: null, successMessage: null);
    try {
      await updateClubSchedulesUseCase.execute(clubId, schedules);
      await loadDetail();
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Cập nhật lịch tuần CLB thành công!',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: AppException(message: e.toString()),
      );
      return false;
    }
  }
}
