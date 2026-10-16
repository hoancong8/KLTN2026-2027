// lib/domain/services/i_location_service.dart

abstract class ILocationService {
  /// Lấy vị trí GPS hiện tại của thiết bị (latitude, longitude).
  /// Nếu người dùng chưa cấp quyền, từ chối quyền hoặc dịch vụ định vị bị tắt,
  /// hàm sẽ fallback về tọa độ mặc định (TP.HCM: 10.7769, 106.6958).
  Future<({double latitude, double longitude})> getCurrentLocation();

  /// Kiểm tra xem thiết bị đã bật dịch vụ định vị và đã cấp quyền hay chưa.
  Future<bool> hasPermission();
}
