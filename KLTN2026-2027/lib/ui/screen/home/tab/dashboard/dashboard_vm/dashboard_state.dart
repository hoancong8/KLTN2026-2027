import 'package:flutter/material.dart';

class DashboardUserProfile {
  final String name;
  final String avatarUrl;
  final String memberTier;
  final String code;

  const DashboardUserProfile({
    required this.name,
    required this.avatarUrl,
    required this.memberTier,
    required this.code,
  });
}

class QuickActionItem {
  final String id;
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const QuickActionItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

class SportCategoryItem {
  final String id;
  final String name;
  final String iconEmoji;
  final bool isSelected;

  const SportCategoryItem({
    required this.id,
    required this.name,
    required this.iconEmoji,
    this.isSelected = false,
  });

  SportCategoryItem copyWith({bool? isSelected}) {
    return SportCategoryItem(
      id: id,
      name: name,
      iconEmoji: iconEmoji,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class PromoBannerItem {
  final String promoCode;
  final String title;
  final String subtitle;
  final String buttonText;

  const PromoBannerItem({
    required this.promoCode,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}

class VenueItem {
  final String id;
  final String name;
  final String categories;
  final String address;
  final double rating;
  final String distance;
  final String priceText;
  final String imageUrl;
  final bool isFavorite;

  const VenueItem({
    required this.id,
    required this.name,
    required this.categories,
    required this.address,
    required this.rating,
    required this.distance,
    required this.priceText,
    required this.imageUrl,
    this.isFavorite = false,
  });

  VenueItem copyWith({bool? isFavorite}) {
    return VenueItem(
      id: id,
      name: name,
      categories: categories,
      address: address,
      rating: rating,
      distance: distance,
      priceText: priceText,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class DashboardState {
  final bool isLoading;
  final bool isLoadingVenues;
  final String? error;
  final DashboardUserProfile userProfile;
  final List<QuickActionItem> quickActions;
  final List<SportCategoryItem> categories;
  final String? selectedSportTypeId;
  final PromoBannerItem promoBanner;
  final List<VenueItem> venues;

  const DashboardState({
    this.isLoading = false,
    this.isLoadingVenues = false,
    this.error,
    this.userProfile = const DashboardUserProfile(
      name: 'Nguyễn Văn An',
      avatarUrl: '',
      memberTier: 'MEMBER PRO',
      code: 'CB7',
    ),
    this.quickActions = const [],
    this.categories = const [],
    this.selectedSportTypeId,
    this.promoBanner = const PromoBannerItem(
      promoCode: 'SUMMER20',
      title: 'Đặt sân hôm nay - giảm đến 20%',
      subtitle: 'Áp dụng cho tất cả cơ sở Cầu lông & Pickleball',
      buttonText: 'ĐẶT NGAY',
    ),
    this.venues = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isLoadingVenues,
    String? error,
    DashboardUserProfile? userProfile,
    List<QuickActionItem>? quickActions,
    List<SportCategoryItem>? categories,
    String? selectedSportTypeId,
    PromoBannerItem? promoBanner,
    List<VenueItem>? venues,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingVenues: isLoadingVenues ?? this.isLoadingVenues,
      error: error,
      userProfile: userProfile ?? this.userProfile,
      quickActions: quickActions ?? this.quickActions,
      categories: categories ?? this.categories,
      selectedSportTypeId: selectedSportTypeId ?? this.selectedSportTypeId,
      promoBanner: promoBanner ?? this.promoBanner,
      venues: venues ?? this.venues,
    );
  }
}
