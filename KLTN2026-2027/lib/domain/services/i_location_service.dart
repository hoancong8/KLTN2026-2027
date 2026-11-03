// lib/domain/services/i_location_service.dart

class LocationSearchResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const LocationSearchResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

abstract class ILocationService {
  /// Lấy vị trí GPS hiện tại của thiết bị (latitude, longitude).
  Future<({double latitude, double longitude})> getCurrentLocation();

  /// Kiểm tra xem thiết bị đã bật dịch vụ định vị và đã cấp quyền hay chưa.
  Future<bool> hasPermission();

  /// Giải mã ngược tọa độ thành tên sân và địa chỉ
  Future<({String? venueName, String address})> reverseGeocode(double latitude, double longitude);

  /// Tìm kiếm địa điểm theo từ khóa
  Future<List<LocationSearchResult>> searchLocations(
    String query, {
    double? latitude,
    double? longitude,
  });
}
