// lib/data/services/location_service_impl.dart

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/services/i_location_service.dart';

class LocationServiceImpl implements ILocationService {
  // Tọa độ mặc định: Trung tâm TP. Hồ Chí Minh (Quận 1 / Bến Thành)
  static const double defaultLat = 10.7769;
  static const double defaultLng = 106.6958;

  @override
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      if (!serviceEnabled) {
        debugPrint('[LocationService] Dịch vụ định vị chưa bật. Dùng tọa độ mặc định TP.HCM.');
        return (latitude: defaultLat, longitude: defaultLng);
      }

      var permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 2),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 3),
          onTimeout: () => LocationPermission.denied,
        );
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Quyền định vị bị từ chối. Dùng tọa độ mặc định.');
          return (latitude: defaultLat, longitude: defaultLng);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Quyền định vị bị từ chối vĩnh viễn. Dùng tọa độ mặc định.');
        return (latitude: defaultLat, longitude: defaultLng);
      }

      // Lấy vị trí với timeout 3 giây bằng Dart Future.timeout để không bị treo trên Web/Emulators
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('[LocationService] Quá thời gian chờ GPS (timeout). Dùng tọa độ mặc định TP.HCM.');
          throw Exception('Location Timeout');
        },
      );

      debugPrint('[LocationService] Lấy tọa độ GPS thành công: (${position.latitude}, ${position.longitude})');
      return (latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      debugPrint('[LocationService] Lỗi hoặc timeout khi lấy GPS: $e. Fallback về tọa độ mặc định TP.HCM.');
      return (latitude: defaultLat, longitude: defaultLng);
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }
}
