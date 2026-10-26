// lib/ui/screen/home/tab/dashboard/dashboard_vm/dashboard_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/entities/club/explore_club.dart';
import 'package:kltn2026_2027/domain/entities/club/my_club.dart';
import 'package:kltn2026_2027/domain/entities/player_profile.dart';
import 'package:kltn2026_2027/domain/entities/session/guest_recruitment.dart';
import 'package:kltn2026_2027/domain/entities/session/my_booking_item.dart';
import 'package:kltn2026_2027/domain/enums/session_enums.dart';
import 'package:kltn2026_2027/domain/services/i_location_service.dart';
import 'package:kltn2026_2027/domain/usecases/club/explore_clubs_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/club/get_my_clubs_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/session/get_my_bookings_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/session/session_usecases.dart';
import 'package:kltn2026_2027/domain/usecases/user/get_player_profile_usecase.dart';
import 'dashboard_state.dart';

final dashboardViewModelProvider =
    StateNotifierProvider.autoDispose<DashboardViewModel, DashboardState>((ref) {
  final getPlayerProfileUseCase = ref.watch(getPlayerProfileUseCaseProvider);
  final getMyBookingsUseCase = ref.watch(getMyBookingsUseCaseProvider);
  final exploreRecruitmentsUseCase = ref.watch(exploreRecruitmentsUseCaseProvider);
  final exploreClubsUseCase = ref.watch(exploreClubsUseCaseProvider);
  final getMyClubsUseCase = ref.watch(getMyClubsUseCaseProvider);
  final joinRecruitmentUseCase = ref.watch(joinRecruitmentUseCaseProvider);
  final locationService = ref.watch(locationServiceProvider);

  return DashboardViewModel(
    getPlayerProfileUseCase: getPlayerProfileUseCase,
    getMyBookingsUseCase: getMyBookingsUseCase,
    exploreRecruitmentsUseCase: exploreRecruitmentsUseCase,
    exploreClubsUseCase: exploreClubsUseCase,
    getMyClubsUseCase: getMyClubsUseCase,
    joinRecruitmentUseCase: joinRecruitmentUseCase,
    locationService: locationService,
  );
});

class DashboardViewModel extends StateNotifier<DashboardState> {
  final GetPlayerProfileUseCase _getPlayerProfileUseCase;
  final GetMyBookingsUseCase _getMyBookingsUseCase;
  final ExploreRecruitmentsUseCase _exploreRecruitmentsUseCase;
  final ExploreClubsUseCase _exploreClubsUseCase;
  final GetMyClubsUseCase _getMyClubsUseCase;
  final JoinRecruitmentUseCase _joinRecruitmentUseCase;
  final ILocationService _locationService;

  DashboardViewModel({
    required GetPlayerProfileUseCase getPlayerProfileUseCase,
    required GetMyBookingsUseCase getMyBookingsUseCase,
    required ExploreRecruitmentsUseCase exploreRecruitmentsUseCase,
    required ExploreClubsUseCase exploreClubsUseCase,
    required GetMyClubsUseCase getMyClubsUseCase,
    required JoinRecruitmentUseCase joinRecruitmentUseCase,
    required ILocationService locationService,
  })  : _getPlayerProfileUseCase = getPlayerProfileUseCase,
        _getMyBookingsUseCase = getMyBookingsUseCase,
        _exploreRecruitmentsUseCase = exploreRecruitmentsUseCase,
        _exploreClubsUseCase = exploreClubsUseCase,
        _getMyClubsUseCase = getMyClubsUseCase,
        _joinRecruitmentUseCase = joinRecruitmentUseCase,
        _locationService = locationService,
        super(const DashboardState()) {
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final loc = await _locationService.getCurrentLocation();

      final results = await Future.wait([
        _fetchProfile(),
        _fetchUpcomingBookings(),
        _fetchNearbyRecruitments(loc.latitude, loc.longitude),
        _fetchNearbyClubs(loc.latitude, loc.longitude),
        _fetchMyClubs(),
      ]);

      if (!mounted) return;
      final upcoming = results[1] as List<MyBookingItem>;
      final rawRecruitments = results[2] as List<GuestRecruitment>;
      final rawClubs = results[3] as List<ExploreClub>;
      final myClubs = results[4] as List<MyClub>;

      state = state.copyWith(
        isLoading: false,
        playerProfile: results[0] as PlayerProfile?,
        upcomingBookings: upcoming,
        nearbyRecruitments: _filterAvailableRecruitments(rawRecruitments, upcoming),
        nearbyClubs: _filterUnjoinedClubs(rawClubs, myClubs),
        myClubs: myClubs,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshData() async {
    if (!mounted) return;
    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final loc = await _locationService.getCurrentLocation();

      final results = await Future.wait([
        _fetchProfile(),
        _fetchUpcomingBookings(),
        _fetchNearbyRecruitments(loc.latitude, loc.longitude),
        _fetchNearbyClubs(loc.latitude, loc.longitude),
        _fetchMyClubs(),
      ]);

      if (!mounted) return;
      final upcoming = results[1] as List<MyBookingItem>;
      final rawRecruitments = results[2] as List<GuestRecruitment>;
      final rawClubs = results[3] as List<ExploreClub>;
      final myClubs = results[4] as List<MyClub>;

      state = state.copyWith(
        isRefreshing: false,
        playerProfile: results[0] as PlayerProfile?,
        upcomingBookings: upcoming,
        nearbyRecruitments: _filterAvailableRecruitments(rawRecruitments, upcoming),
        nearbyClubs: _filterUnjoinedClubs(rawClubs, myClubs),
        myClubs: myClubs,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  List<GuestRecruitment> _filterAvailableRecruitments(
    List<GuestRecruitment> recruitments,
    List<MyBookingItem> bookings,
  ) {
    final bookedSessionIds = bookings
        .where((b) => !b.isEnded && b.bookingStatus != BookingStatus.absent)
        .map((b) => b.sessionId)
        .toSet();
    return recruitments.where((r) => !bookedSessionIds.contains(r.sessionId)).toList();
  }

  List<ExploreClub> _filterUnjoinedClubs(
    List<ExploreClub> clubs,
    List<MyClub> myClubs,
  ) {
    final joinedClubIds = myClubs.map((c) => c.clubId).toSet();
    return clubs.where((c) => !joinedClubIds.contains(c.id)).toList();
  }

  Future<PlayerProfile?> _fetchProfile() async {
    try {
      return await _getPlayerProfileUseCase.execute();
    } catch (_) {
      return state.playerProfile;
    }
  }

  Future<List<MyBookingItem>> _fetchUpcomingBookings() async {
    try {
      final list = await _getMyBookingsUseCase.execute();
      final activeList = list.where((b) => b.isUpcomingOrOngoing).toList();
      activeList.sort((a, b) => a.startTime.compareTo(b.startTime));
      return activeList;
    } catch (_) {
      return state.upcomingBookings;
    }
  }

  Future<List<GuestRecruitment>> _fetchNearbyRecruitments(
    double lat,
    double lng,
  ) async {
    try {
      final list = await _exploreRecruitmentsUseCase.execute(
        latitude: lat,
        longitude: lng,
        radiusKm: 15.0,
      );
      final activeList = list.where((r) => r.isActive).toList();
      activeList.sort((a, b) => a.startTime.compareTo(b.startTime));
      return activeList;
    } catch (_) {
      return state.nearbyRecruitments;
    }
  }

  Future<List<ExploreClub>> _fetchNearbyClubs(
    double lat,
    double lng,
  ) async {
    try {
      return await _exploreClubsUseCase.execute(
        ExploreClubsParams(
          latitude: lat,
          longitude: lng,
          radiusKm: 15.0,
        ),
      );
    } catch (_) {
      return state.nearbyClubs;
    }
  }

  Future<List<MyClub>> _fetchMyClubs() async {
    try {
      return await _getMyClubsUseCase.execute();
    } catch (_) {
      return state.myClubs;
    }
  }

  Future<bool> joinRecruitment(String recruitmentId) async {
    if (!mounted) return false;
    state = state.copyWith(
      joiningRecruitmentId: recruitmentId,
      clearError: true,
    );

    try {
      await _joinRecruitmentUseCase.execute(recruitmentId);
      final loc = await _locationService.getCurrentLocation();
      final freshRecruitments = await _fetchNearbyRecruitments(loc.latitude, loc.longitude);
      final freshBookings = await _fetchUpcomingBookings();

      if (!mounted) return true;
      state = state.copyWith(
        clearJoiningId: true,
        nearbyRecruitments: freshRecruitments,
        upcomingBookings: freshBookings,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        clearJoiningId: true,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}
