import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/services/i_location_service.dart';

class LocationServiceImpl implements ILocationService {
  static const double defaultLat = 10.7725;
  static const double defaultLng = 106.6698;

  final Dio _dio;

  LocationServiceImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  @override
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        return (latitude: position.latitude, longitude: position.longitude);
      }
    } catch (_) {
      // Fallback
    }
    return (latitude: defaultLat, longitude: defaultLng);
  }

  @override
  Future<bool> hasPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<({String? venueName, String address})> reverseGeocode(double latitude, double longitude) async {
    try {
      // 1. Primary: Photon API (Fast, OpenStreetMap based, supports browser CORS)
      final res = await _dio.get(
        'https://photon.komoot.io/reverse',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : (res.data is String ? jsonDecode(res.data as String) as Map<String, dynamic> : null);

        if (json != null && json['features'] is List && (json['features'] as List).isNotEmpty) {
          final feature = (json['features'] as List).first as Map;
          final p = feature['properties'] as Map? ?? {};

          final name = p['name']?.toString() ?? '';
          final street = p['street']?.toString() ?? '';
          final district = p['district']?.toString() ?? '';
          final city = p['city']?.toString() ?? '';

          final addressParts = <String>[];
          if (name.isNotEmpty) addressParts.add(name);
          if (street.isNotEmpty && street != name) addressParts.add(street);
          if (district.isNotEmpty) addressParts.add(district);
          if (city.isNotEmpty) addressParts.add(city);

          final fullAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : 'Tọa độ: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

          return (venueName: name.isNotEmpty ? name : null, address: fullAddress);
        }
      }
    } catch (_) {
      // Soft fail
    }

    try {
      // 2. Fallback: BigDataCloud Reverse Geocoding
      final bdcRes = await _dio.get(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'localityLanguage': 'vi',
        },
      );

      if (bdcRes.statusCode == 200 && bdcRes.data != null) {
        final bdcJson = bdcRes.data is Map<String, dynamic>
            ? bdcRes.data as Map<String, dynamic>
            : (bdcRes.data is String ? jsonDecode(bdcRes.data as String) as Map<String, dynamic> : null);

        if (bdcJson != null) {
          final locality = bdcJson['locality']?.toString() ?? '';
          final city = bdcJson['city']?.toString() ?? bdcJson['principalSubdivision']?.toString() ?? '';
          final address = [locality, city].where((s) => s.isNotEmpty).join(', ');
          if (address.isNotEmpty) {
            return (venueName: null, address: address);
          }
        }
      }
    } catch (_) {
      // Soft fail
    }

    return (
      venueName: null,
      address: 'Tọa độ: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
    );
  }

  @override
  Future<List<LocationSearchResult>> searchLocations(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    final clean = query.trim();
    if (clean.isEmpty) return const [];

    try {
      final queryParams = <String, dynamic>{
        'q': clean,
        'limit': 5,
      };
      if (latitude != null && longitude != null) {
        queryParams['lat'] = latitude;
        queryParams['lon'] = longitude;
      }

      final res = await _dio.get(
        'https://photon.komoot.io/api',
        queryParameters: queryParams,
      );

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : (res.data is String ? jsonDecode(res.data as String) as Map<String, dynamic> : null);

        if (json != null && json['features'] is List) {
          final features = json['features'] as List;
          final results = <LocationSearchResult>[];

          for (final item in features) {
            if (item is! Map) continue;
            final geometry = item['geometry'] as Map? ?? {};
            final coords = geometry['coordinates'] as List? ?? [];
            if (coords.length < 2) continue;

            final lon = (coords[0] as num).toDouble();
            final lat = (coords[1] as num).toDouble();

            final p = item['properties'] as Map? ?? {};
            final name = p['name']?.toString() ?? '';
            final street = p['street']?.toString() ?? '';
            final district = p['district']?.toString() ?? '';
            final city = p['city']?.toString() ?? '';

            final parts = [name, street, district, city].where((s) => s.isNotEmpty).toSet().toList();
            final fullAddr = parts.join(', ');

            results.add(
              LocationSearchResult(
                name: name.isNotEmpty ? name : (street.isNotEmpty ? street : fullAddr),
                address: fullAddr,
                latitude: lat,
                longitude: lon,
              ),
            );
          }
          return results;
        }
      }
    } catch (_) {
      // Soft fail
    }
    return const [];
  }
}
