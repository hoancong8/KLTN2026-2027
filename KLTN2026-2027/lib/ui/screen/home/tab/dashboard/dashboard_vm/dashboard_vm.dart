// lib/ui/screen/home/tab/dashboard/dashboard_vm/dashboard_vm.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/consts/app_log.dart';
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
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  final getPlayerProfileUseCase = ref.watch(getPlayerProfileUseCaseProvider);
  final getMyBookingsUseCase = ref.watch(getMyBookingsUseCaseProvider);
  final exploreRecruitmentsUseCase = ref.watch(exploreRecruitmentsUseCaseProvider);
  final exploreClubsUseCase = ref.watch(exploreClubsUseCaseProvider);
  final getMyClubsUseCase = ref.watch(getMyClubsUseCaseProvider);
  final joinRecruitmentUseCase = ref.watch(joinRecruitmentUseCaseProvider);
  final locationService = ref.watch(locationServiceProvider);

  return DashboardViewModel(
    ref: ref,
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
  final Ref ref;
  final GetPlayerProfileUseCase _getPlayerProfileUseCase;
  final GetMyBookingsUseCase _getMyBookingsUseCase;
  final ExploreRecruitmentsUseCase _exploreRecruitmentsUseCase;
  final ExploreClubsUseCase _exploreClubsUseCase;
  final GetMyClubsUseCase _getMyClubsUseCase;
  final JoinRecruitmentUseCase _joinRecruitmentUseCase;
  final ILocationService _locationService;
  Future<void>? _runningLoadData;

  DashboardViewModel({
    required this.ref,
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
        super(const DashboardState());

  Future<void> loadData() {
    if (_runningLoadData != null) return _runningLoadData!;
    final future = _executeLoadData();
    _runningLoadData = future.whenComplete(() {
      _runningLoadData = null;
    });
    return _runningLoadData!;
  }

  Future<void> _executeLoadData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final nonLocationResults = await Future.wait([
        _fetchProfile(),
        _fetchUpcomingBookings(),
        _fetchMyClubs(),
      ]);

      if (!mounted) return;
      var profile = nonLocationResults[0] as PlayerProfile?;
      final upcoming = nonLocationResults[1] as List<MyBookingItem>;
      final myClubs = nonLocationResults[2] as List<MyClub>;

      if (profile == null) {
        final user = ref.read(currentUserProfileProvider);
        if (user != null) {
          profile = PlayerProfile(
            id: user.id,
            fullName: user.userName,
            userName: user.userName,
            email: user.email,
            phoneNumber: user.phoneNumber,
            gender: 0,
            avatarUrl: null,
            skillLevel: SkillLevel.nb,
            skillLevelName: 'Newbie',
            isOpenForGuest: false,
            reputationScore: 5.0,
          );
        }
      }

      state = state.copyWith(
        playerProfile: profile,
        upcomingBookings: upcoming,
        myClubs: myClubs,
      );

      final loc = await _locationService.getCurrentLocation();
      if (!mounted) return;

      final nearbyResults = await Future.wait([
        _fetchNearbyRecruitments(loc.latitude, loc.longitude),
        _fetchNearbyClubs(loc.latitude, loc.longitude),
      ]);

      if (!mounted) return;
      final rawRecruitments = nearbyResults[0] as List<GuestRecruitment>;
      final rawClubs = nearbyResults[1] as List<ExploreClub>;

      state = state.copyWith(
        isLoading: false,
        nearbyRecruitments: rawRecruitments,
        nearbyClubs: _filterUnjoinedClubs(rawClubs, myClubs),
      );
    } catch (e) {
      AppLog.info('[Dashboard] loadData error: $e');
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
      final nonLocationResults = await Future.wait([
        _fetchProfile(),
        _fetchUpcomingBookings(),
        _fetchMyClubs(),
      ]);

      if (!mounted) return;
      final profile = nonLocationResults[0] as PlayerProfile?;
      final upcoming = nonLocationResults[1] as List<MyBookingItem>;
      final myClubs = nonLocationResults[2] as List<MyClub>;

      state = state.copyWith(
        playerProfile: profile,
        upcomingBookings: upcoming,
        myClubs: myClubs,
      );

      final loc = await _locationService.getCurrentLocation();
      if (!mounted) return;

      final nearbyResults = await Future.wait([
        _fetchNearbyRecruitments(loc.latitude, loc.longitude),
        _fetchNearbyClubs(loc.latitude, loc.longitude),
      ]);

      if (!mounted) return;
      final rawRecruitments = nearbyResults[0] as List<GuestRecruitment>;
      final rawClubs = nearbyResults[1] as List<ExploreClub>;

      state = state.copyWith(
        isRefreshing: false,
        nearbyRecruitments: rawRecruitments,
        nearbyClubs: _filterUnjoinedClubs(rawClubs, myClubs),
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  List<ExploreClub> _filterUnjoinedClubs(
    List<ExploreClub> clubs,
    List<MyClub> myClubs,
  ) {
    final joinedIds = myClubs.map((c) => c.clubId.trim().toLowerCase()).where((s) => s.isNotEmpty).toSet();
    final joinedCodes = myClubs.map((c) => c.clubCode.trim().toUpperCase()).where((s) => s.isNotEmpty).toSet();
    final joinedNames = myClubs.map((c) => c.clubName.trim().toLowerCase()).where((s) => s.isNotEmpty).toSet();

    return clubs.where((c) {
      final id = c.id.trim().toLowerCase();
      final code = c.code.trim().toUpperCase();
      final name = c.groupName.trim().toLowerCase();

      if (id.isNotEmpty && joinedIds.contains(id)) return false;
      if (code.isNotEmpty && joinedCodes.contains(code)) return false;
      if (name.isNotEmpty && joinedNames.contains(name)) return false;
      return true;
    }).toList();
  }

  Future<PlayerProfile?> _fetchProfile() async {
    try {
      return await _getPlayerProfileUseCase.execute();
    } catch (e) {
      AppLog.info('[Dashboard] FetchProfile error: $e');
      return state.playerProfile;
    }
  }

  Future<List<MyBookingItem>> _fetchUpcomingBookings() async {
    try {
      final list = await _getMyBookingsUseCase.execute();
      final activeList = list.where((b) => b.isUpcomingOrOngoing).toList();
      activeList.sort((a, b) => a.startTime.compareTo(b.startTime));
      return activeList;
    } catch (e) {
      AppLog.info('[Dashboard] FetchUpcomingBookings error: $e');
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
    } catch (e) {
      AppLog.info('[Dashboard] FetchNearbyRecruitments error: $e');
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
    } catch (e) {
      AppLog.info('[Dashboard] FetchNearbyClubs error: $e');
      return state.nearbyClubs;
    }
  }

  Future<List<MyClub>> _fetchMyClubs() async {
    try {
      return await _getMyClubsUseCase.execute();
    } catch (e) {
      AppLog.info('[Dashboard] FetchMyClubs error: $e');
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
