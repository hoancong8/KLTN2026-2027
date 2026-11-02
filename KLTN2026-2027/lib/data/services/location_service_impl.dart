import '../../domain/services/i_location_service.dart';

class LocationServiceImpl implements ILocationService {
  static const double defaultLat = 10.7769;
  static const double defaultLng = 106.6958;

  @override
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    return (latitude: defaultLat, longitude: defaultLng);
  }

  @override
  Future<bool> hasPermission() async {
    return false;
  }
}
