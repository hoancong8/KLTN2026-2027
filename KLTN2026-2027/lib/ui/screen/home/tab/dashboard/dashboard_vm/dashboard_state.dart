// lib/ui/screen/home/tab/dashboard/dashboard_vm/dashboard_state.dart

import 'package:flutter/foundation.dart';
import 'package:kltn2026_2027/domain/entities/club/explore_club.dart';
import 'package:kltn2026_2027/domain/entities/club/my_club.dart';
import 'package:kltn2026_2027/domain/entities/player_profile.dart';
import 'package:kltn2026_2027/domain/entities/session/guest_recruitment.dart';
import 'package:kltn2026_2027/domain/entities/session/my_booking_item.dart';

@immutable
class DashboardState {
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final PlayerProfile? playerProfile;
  final List<MyBookingItem> upcomingBookings;
  final List<GuestRecruitment> nearbyRecruitments;
  final List<ExploreClub> nearbyClubs;
  final List<MyClub> myClubs;
  final String? joiningRecruitmentId;

  const DashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.playerProfile,
    this.upcomingBookings = const [],
    this.nearbyRecruitments = const [],
    this.nearbyClubs = const [],
    this.myClubs = const [],
    this.joiningRecruitmentId,
  });

  bool get hasUpcomingBooking => upcomingBookings.isNotEmpty;
  MyBookingItem? get nextBooking =>
      upcomingBookings.isNotEmpty ? upcomingBookings.first : null;

  int get activeClubCount => myClubs.length;
  int get upcomingSessionCount => upcomingBookings.length;
  double get reputationScore => playerProfile?.reputationScore ?? 5.0;

  DashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    PlayerProfile? playerProfile,
    List<MyBookingItem>? upcomingBookings,
    List<GuestRecruitment>? nearbyRecruitments,
    List<ExploreClub>? nearbyClubs,
    List<MyClub>? myClubs,
    String? joiningRecruitmentId,
    bool clearJoiningId = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      playerProfile: playerProfile ?? this.playerProfile,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      nearbyRecruitments: nearbyRecruitments ?? this.nearbyRecruitments,
      nearbyClubs: nearbyClubs ?? this.nearbyClubs,
      myClubs: myClubs ?? this.myClubs,
      joiningRecruitmentId: clearJoiningId
          ? null
          : (joiningRecruitmentId ?? this.joiningRecruitmentId),
    );
  }
}
