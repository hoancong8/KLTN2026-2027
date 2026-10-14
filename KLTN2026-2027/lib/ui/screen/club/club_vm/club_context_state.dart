// lib/ui/screen/club/club_vm/club_context_state.dart

import '../../../../domain/entities/club/active_club_context.dart';
import '../../../../domain/entities/club/my_club.dart';
import '../../../../domain/enums/club_role.dart';
import '../../../../domain/exceptions/app_exception.dart';

class ClubContextState {
  final List<MyClub> myClubs;
  final ActiveClubContext? activeContext;
  final bool isLoading;
  final bool isSwitching;
  final AppException? error;
  final String? successMessage;

  const ClubContextState({
    this.myClubs = const [],
    this.activeContext,
    this.isLoading = false,
    this.isSwitching = false,
    this.error,
    this.successMessage,
  });

  /// Vai trò của người dùng trong Câu lạc bộ đang chọn hoạt động
  ClubRole? get currentRole => activeContext?.role;

  /// Tên Câu lạc bộ đang hoạt động
  String? get currentClubName => activeContext?.clubName;

  /// ID Câu lạc bộ đang hoạt động
  String? get currentClubId => activeContext?.clubId;

  /// Kiểm tra có phải Host của CLB đang active không
  bool get isCurrentHost => activeContext?.role == ClubRole.host;

  /// Kiểm tra có phải Thủ quỹ của CLB đang active không
  bool get isCurrentTreasurer => activeContext?.role == ClubRole.treasurer;

  ClubContextState copyWith({
    List<MyClub>? myClubs,
    ActiveClubContext? activeContext,
    bool clearActiveContext = false,
    bool? isLoading,
    bool? isSwitching,
    AppException? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ClubContextState(
      myClubs: myClubs ?? this.myClubs,
      activeContext: clearActiveContext ? null : (activeContext ?? this.activeContext),
      isLoading: isLoading ?? this.isLoading,
      isSwitching: isSwitching ?? this.isSwitching,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
