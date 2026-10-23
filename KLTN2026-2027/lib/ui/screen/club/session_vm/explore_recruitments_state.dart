// lib/ui/screen/club/session_vm/explore_recruitments_state.dart

import '../../../../domain/entities/session/guest_recruitment.dart';

class ExploreRecruitmentsState {
  final bool isLoading;
  final bool isJoining;
  final List<GuestRecruitment> recruitments;
  final double radiusKm;
  final String? selectedSkillLevel;
  final String searchTerm;
  final double? latitude;
  final double? longitude;
  final bool isLocating;
  final String? errorMessage;
  final String? successMessage;

  const ExploreRecruitmentsState({
    this.isLoading = false,
    this.isJoining = false,
    this.recruitments = const [],
    this.radiusKm = 10.0,
    this.selectedSkillLevel,
    this.searchTerm = '',
    this.latitude,
    this.longitude,
    this.isLocating = false,
    this.errorMessage,
    this.successMessage,
  });

  List<GuestRecruitment> get filteredRecruitments {
    if (searchTerm.trim().isEmpty) return recruitments;
    final q = searchTerm.trim().toLowerCase();
    return recruitments.where((r) {
      return r.clubName.toLowerCase().contains(q) ||
          r.courtLocation.toLowerCase().contains(q);
    }).toList();
  }

  ExploreRecruitmentsState copyWith({
    bool? isLoading,
    bool? isJoining,
    List<GuestRecruitment>? recruitments,
    double? radiusKm,
    String? selectedSkillLevel,
    bool clearSkillLevel = false,
    String? searchTerm,
    double? latitude,
    double? longitude,
    bool? isLocating,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ExploreRecruitmentsState(
      isLoading: isLoading ?? this.isLoading,
      isJoining: isJoining ?? this.isJoining,
      recruitments: recruitments ?? this.recruitments,
      radiusKm: radiusKm ?? this.radiusKm,
      selectedSkillLevel: clearSkillLevel ? null : (selectedSkillLevel ?? this.selectedSkillLevel),
      searchTerm: searchTerm ?? this.searchTerm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocating: isLocating ?? this.isLocating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
