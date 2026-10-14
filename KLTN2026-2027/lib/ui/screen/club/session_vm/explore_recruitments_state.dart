// lib/ui/screen/club/session_vm/explore_recruitments_state.dart

import '../../../../domain/entities/session/guest_recruitment.dart';

class ExploreRecruitmentsState {
  final bool isLoading;
  final bool isJoining;
  final List<GuestRecruitment> recruitments;
  final double radiusKm;
  final String? selectedSkillLevel;
  final String? errorMessage;
  final String? successMessage;

  const ExploreRecruitmentsState({
    this.isLoading = false,
    this.isJoining = false,
    this.recruitments = const [],
    this.radiusKm = 10.0,
    this.selectedSkillLevel,
    this.errorMessage,
    this.successMessage,
  });

  ExploreRecruitmentsState copyWith({
    bool? isLoading,
    bool? isJoining,
    List<GuestRecruitment>? recruitments,
    double? radiusKm,
    String? selectedSkillLevel,
    String? errorMessage,
    String? successMessage,
  }) {
    return ExploreRecruitmentsState(
      isLoading: isLoading ?? this.isLoading,
      isJoining: isJoining ?? this.isJoining,
      recruitments: recruitments ?? this.recruitments,
      radiusKm: radiusKm ?? this.radiusKm,
      selectedSkillLevel: selectedSkillLevel ?? this.selectedSkillLevel,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
