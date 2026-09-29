import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/usecases/venue/get_venue_recommendations_usecase.dart';
import 'dashboard_state.dart';

final dashboardViewModelProvider =
    StateNotifierProvider.autoDispose<DashboardViewModel, DashboardState>((
      ref,
    ) {
      final getVenueRecommendationsUseCase =
          ref.watch(getVenueRecommendationsUseCaseProvider);
      return DashboardViewModel(
        getVenueRecommendationsUseCase: getVenueRecommendationsUseCase,
      );
    });

class DashboardViewModel extends StateNotifier<DashboardState> {
  final GetVenueRecommendationsUseCase _getVenueRecommendationsUseCase;

  DashboardViewModel({
    required GetVenueRecommendationsUseCase getVenueRecommendationsUseCase,
  })  : _getVenueRecommendationsUseCase = getVenueRecommendationsUseCase,
        super(const DashboardState()) {
    _initMockData();
    fetchRecommendedVenues();
  }

  void _initMockData() {
    state = state.copyWith(
      quickActions: const [
        QuickActionItem(
          id: 'booking',
          title: 'Đặt sân',
          icon: Icons.calendar_today_outlined,
          bgColor: Color(0xFFE8F8F2),
          iconColor: Color(0xFF10B981),
        ),
        QuickActionItem(
          id: 'matchmaking',
          title: 'Ghép trận',
          icon: Icons.people_outline,
          bgColor: Color(0xFFE6F7F5),
          iconColor: Color(0xFF14B8A6),
        ),
        QuickActionItem(
          id: 'schedule',
          title: 'Lịch của tôi',
          icon: Icons.emoji_events_outlined,
          bgColor: Color(0xFFEBF3FE),
          iconColor: Color(0xFF3B82F6),
        ),
        QuickActionItem(
          id: 'favorite',
          title: 'Yêu thích',
          icon: Icons.favorite_border,
          bgColor: Color(0xFFFDE8EC),
          iconColor: Color(0xFFEC4899),
        ),
      ],
      categories: const [
        SportCategoryItem(id: 'badminton', name: 'Cầu lông', iconEmoji: '🏸', isSelected: true),
        SportCategoryItem(id: 'pickleball', name: 'Pickleball', iconEmoji: '🏓'),
        SportCategoryItem(id: 'tennis', name: 'Tennis', iconEmoji: '🎾'),
        SportCategoryItem(id: 'football', name: 'Bóng đá', iconEmoji: '⚽'),
        SportCategoryItem(id: 'basketball', name: 'Bóng rổ', iconEmoji: '🏀'),
      ],
      venues: const [
        VenueItem(
          id: 'v1',
          name: 'ABC Sport Center',
          categories: 'BADMINTON • PICKLEBALL • TENNIS',
          address: '123 Nguyễn Thị Minh Khai, Q.3, TP. Hồ Chí Minh',
          rating: 4.9,
          distance: '1.2 km',
          priceText: 'Từ 80k/h →',
          imageUrl: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=400',
          isFavorite: false,
        ),
        VenueItem(
          id: 'v2',
          name: 'Smash Badminton Club',
          categories: 'BADMINTON',
          address: '45 Lê Văn Sỹ, Q. Phú Nhuận, TP. Hồ Chí Minh',
          rating: 4.8,
          distance: '2.5 km',
          priceText: 'Từ 70k/h →',
          imageUrl: 'https://images.unsplash.com/photo-1521537634581-0dced2efa2a3?w=400',
          isFavorite: true,
        ),
      ],
    );
  }

  bool _isGuid(String? val) {
    if (val == null) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(val);
  }

  Future<void> fetchRecommendedVenues({
    String? sportTypeId,
    double? latitude,
    double? longitude,
  }) async {
    if (!mounted) return;
    state = state.copyWith(isLoadingVenues: true);
    try {
      final effectiveSportTypeId = _isGuid(sportTypeId) ? sportTypeId : null;

      final result = await _getVenueRecommendationsUseCase.execute(
        latitude: latitude,
        longitude: longitude,
        sportTypeId: effectiveSportTypeId,
        pageNumber: 1,
        pageSize: 20,
      );

      final venueItems = result.items.map((entity) {
        final sportNames = entity.sportTypes.isNotEmpty
            ? entity.sportTypes.map((s) => s.name.toUpperCase()).join(' • ')
            : 'THỂ THAO';

        final distanceStr = entity.distanceKm != null
            ? '${entity.distanceKm!.toStringAsFixed(1)} km'
            : '';

        final priceStr = entity.minPricePerHour != null
            ? 'Từ ${(entity.minPricePerHour! / 1000).toInt()}k/h →'
            : 'Xem chi tiết →';

        return VenueItem(
          id: entity.idVenue,
          name: entity.nameVenue,
          categories: sportNames,
          address: entity.address,
          rating: entity.averageRating,
          distance: distanceStr,
          priceText: priceStr,
          imageUrl: entity.primaryImageUrl ?? '',
          isFavorite: entity.isFavourite,
        );
      }).toList();

      if (!mounted) return;
      state = state.copyWith(
        isLoadingVenues: false,
        venues: venueItems.isNotEmpty ? venueItems : state.venues,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingVenues: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await fetchRecommendedVenues(sportTypeId: state.selectedSportTypeId);
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleFavorite(String venueId) {
    final updatedVenues = state.venues.map((v) {
      if (v.id == venueId) {
        return v.copyWith(isFavorite: !v.isFavorite);
      }
      return v;
    }).toList();
    state = state.copyWith(venues: updatedVenues);
  }

  void selectCategory(String categoryId) {
    final updatedCategories = state.categories.map((c) {
      return c.copyWith(isSelected: c.id == categoryId);
    }).toList();
    final newSelectedSportTypeId = categoryId == state.selectedSportTypeId ? null : categoryId;
    state = state.copyWith(
      categories: updatedCategories,
      selectedSportTypeId: newSelectedSportTypeId,
    );
    fetchRecommendedVenues(sportTypeId: newSelectedSportTypeId);
  }
}
