import '../../../../domain/entities/player_profile.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/exceptions/app_exception.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final AppException? error;
  final String? successMessage;
  final PlayerProfile? playerProfile;
  final UserProfile? userProfile;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.playerProfile,
    this.userProfile,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    AppException? error,
    String? successMessage,
    PlayerProfile? playerProfile,
    UserProfile? userProfile,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      playerProfile: playerProfile ?? this.playerProfile,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}
