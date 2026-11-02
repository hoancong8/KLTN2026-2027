import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

class LocationPickResult {
  final String venueName;
  final String address;
  final double latitude;
  final double longitude;

  const LocationPickResult({
    required this.venueName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class MapLocationPickerSheet extends StatefulWidget {
  final String? initialVenueName;
  final String? initialAddress;
  final double? initialLat;
  final double? initialLng;

  const MapLocationPickerSheet({
    super.key,
    this.initialVenueName,
    this.initialAddress,
    this.initialLat,
    this.initialLng,
  });

  static Future<LocationPickResult?> show(
    BuildContext context, {
    String? initialVenueName,
    String? initialAddress,
    double? initialLat,
    double? initialLng,
  }) {
    return showModalBottomSheet<LocationPickResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapLocationPickerSheet(
        initialVenueName: initialVenueName,
        initialAddress: initialAddress,
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }

  @override
  State<MapLocationPickerSheet> createState() => _MapLocationPickerSheetState();
}

class _MapLocationPickerSheetState extends State<MapLocationPickerSheet> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final TextEditingController _venueNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _searchController;

  late LatLng _currentCenter;
  bool _isMoving = false;
  bool _isGeocoding = false;
  bool _isSearching = false;
  bool _isLocating = false;
  Timer? _debounceTimer;

  List<Map<String, dynamic>> _searchResults = [];

  static const LatLng _hcmKyHoa = LatLng(10.7725, 106.6698);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _venueNameController = TextEditingController(text: widget.initialVenueName ?? '');
    _addressController = TextEditingController(text: widget.initialAddress ?? '');
    _searchController = TextEditingController();

    if (widget.initialLat != null && widget.initialLng != null) {
      _currentCenter = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      _currentCenter = _hcmKyHoa;
    }

    if (_addressController.text.isEmpty && _venueNameController.text.isEmpty) {
      _reverseGeocode(_currentCenter);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    _venueNameController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _moveToCurrentGps() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 6),
          ),
        );
        if (mounted) {
          final pt = LatLng(position.latitude, position.longitude);
          _currentCenter = pt;
          _mapController.move(pt, 16.5);
          _reverseGeocode(pt);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vui lòng cấp quyền vị trí GPS để định vị sân'),
              backgroundColor: context.colors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      // Soft fail
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _currentCenter = camera.center;
    if (hasGesture) {
      if (!_isMoving) setState(() => _isMoving = true);
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _isMoving = false);
          _reverseGeocode(_currentCenter);
        }
      });
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isGeocoding = true);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

    try {
      // 1. Primary: Photon API (Fast, OpenStreetMap based)
      final uri = Uri.https('photon.komoot.io', '/reverse', {
        'lat': point.latitude.toString(),
        'lon': point.longitude.toString(),
      });
      final req = await client.getUrl(uri);
      req.headers.set('User-Agent', 'KLTN2026_BadmintonClub/1.0');
      final res = await req.close().timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && mounted) {
        final body = await res.transform(utf8.decoder).join();
        final json = jsonDecode(body);
        if (json is Map && json['features'] is List && (json['features'] as List).isNotEmpty) {
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
              : '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';

          setState(() {
            _addressController.text = fullAddress;
            if (name.isNotEmpty && (_venueNameController.text.isEmpty || _venueNameController.text == 'Sân Cầu Lông')) {
              _venueNameController.text = name;
            }
          });
          return;
        }
      }

      // 2. Fallback: BigDataCloud Reverse Geocoding
      final bdcUri = Uri.https('api.bigdatacloud.net', '/data/reverse-geocode-client', {
        'latitude': point.latitude.toString(),
        'longitude': point.longitude.toString(),
        'localityLanguage': 'vi',
      });
      final bdcReq = await client.getUrl(bdcUri);
      bdcReq.headers.set('User-Agent', 'KLTN2026_BadmintonClub/1.0');
      final bdcRes = await bdcReq.close().timeout(const Duration(seconds: 4));

      if (bdcRes.statusCode == 200 && mounted) {
        final bdcBody = await bdcRes.transform(utf8.decoder).join();
        final bdcJson = jsonDecode(bdcBody);
        if (bdcJson is Map) {
          final locality = bdcJson['locality']?.toString() ?? '';
          final city = bdcJson['city']?.toString() ?? bdcJson['principalSubdivision']?.toString() ?? '';
          final address = [locality, city].where((s) => s.isNotEmpty).join(', ');
          if (address.isNotEmpty) {
            setState(() {
              _addressController.text = address;
            });
            return;
          }
        }
      }
    } catch (_) {
      // Soft fail
    } finally {
      client.close();
      if (mounted) setState(() => _isGeocoding = false);
    }

    if (_addressController.text.isEmpty && mounted) {
      setState(() {
        _addressController.text = 'Tọa độ: ${_currentCenter.latitude.toStringAsFixed(4)}, ${_currentCenter.longitude.toStringAsFixed(4)}';
      });
    }
  }

  Future<void> _searchQuery(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

    try {
      final uri = Uri.https('photon.komoot.io', '/api', {
        'q': clean,
        'limit': '5',
        'lat': _currentCenter.latitude.toString(),
        'lon': _currentCenter.longitude.toString(),
      });
      final req = await client.getUrl(uri);
      req.headers.set('User-Agent', 'KLTN2026_BadmintonClub/1.0');
      final res = await req.close().timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && mounted) {
        final body = await res.transform(utf8.decoder).join();
        final json = jsonDecode(body);
        if (json is Map && json['features'] is List) {
          final list = (json['features'] as List).cast<Map<String, dynamic>>();
          setState(() {
            _searchResults = list;
          });
        }
      }
    } catch (_) {
      // Soft fail
    } finally {
      client.close();
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(Map<String, dynamic> item) {
    final geometry = item['geometry'] as Map? ?? {};
    final coords = geometry['coordinates'] as List? ?? [];
    if (coords.length >= 2) {
      final lon = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      final pt = LatLng(lat, lon);

      final p = item['properties'] as Map? ?? {};
      final name = p['name']?.toString() ?? '';
      final street = p['street']?.toString() ?? '';
      final district = p['district']?.toString() ?? '';
      final city = p['city']?.toString() ?? '';

      final parts = [name, street, district, city].where((s) => s.isNotEmpty).toSet().toList();
      final fullAddr = parts.join(', ');

      setState(() {
        _currentCenter = pt;
        _searchResults = [];
        _searchController.clear();
        _addressController.text = fullAddr;
        if (name.isNotEmpty) {
          _venueNameController.text = name;
        }
      });
      FocusScope.of(context).unfocus();
      _mapController.move(pt, 16.5);
    }
  }

  void _onConfirm() {
    final venue = _venueNameController.text.trim();
    final address = _addressController.text.trim();

    final finalVenue = venue.isNotEmpty ? venue : (address.isNotEmpty ? address : 'Sân Cầu Lông');
    final finalAddress = address.isNotEmpty ? address : finalVenue;

    Navigator.of(context).pop(
      LocationPickResult(
        venueName: finalVenue,
        address: finalAddress,
        latitude: _currentCenter.latitude,
        longitude: _currentCenter.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Stack(
          children: [
            // 1. High Performance Retina Map
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentCenter,
                  initialZoom: 16.0,
                  minZoom: 3.0,
                  maxZoom: 20.0,
                  onPositionChanged: _onPositionChanged,
                  onTap: (tapPosition, point) {
                    _currentCenter = point;
                    _mapController.move(point, _mapController.camera.zoom);
                    _reverseGeocode(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    subdomains: const ['0', '1', '2', '3'],
                    userAgentPackageName: 'com.legendsteam.kltn2026_2027',
                    maxNativeZoom: 20,
                    maxZoom: 20,
                    panBuffer: 1,
                    keepBuffer: 2,
                  ),
                ],
              ),
            ),

            // 2. Center Pin (Google Maps Pin Style with Drop Shadow and Ground Ellipse)
            IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        transform: Matrix4.translationValues(0, _isMoving ? -8 : 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: AppRadius.buttonPill,
                                boxShadow: AppShadows.md,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isGeocoding) ...[
                                    const SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    _isMoving ? 'Đang di chuyển...' : 'Địa điểm đã chọn',
                                    style: AppTypography.labelSmall.bold.colored(AppColors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 2,
                                  child: Icon(
                                    Icons.location_pin,
                                    size: 42,
                                    color: AppColors.black.withValues(alpha: 0.18),
                                  ),
                                ),
                                const Icon(
                                  Icons.location_pin,
                                  size: 42,
                                  color: AppColors.error,
                                ),
                                Positioned(
                                  top: 11,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      Container(
                        width: 12,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.24),
                          borderRadius: const BorderRadius.all(
                            Radius.elliptical(12, 5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.15),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Top Floating Search Bar & Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.cardBackground.withValues(alpha: 0.95),
                      colors.cardBackground.withValues(alpha: 0.8),
                      colors.cardBackground.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Icon(Icons.explore_rounded, color: colors.primary, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Chọn Vị Trí Sân Trên Bản Đồ',
                              style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: colors.textPrimary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Search input
                      Material(
                        elevation: 3,
                        shadowColor: colors.textPrimary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.buttonPill,
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onChanged: (q) {
                            _debounceTimer?.cancel();
                            _debounceTimer = Timer(const Duration(milliseconds: 350), () => _searchQuery(q));
                          },
                          style: AppTypography.bodySmall.colored(colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Tìm địa chỉ hoặc tên sân (vd: Sân Kỳ Hòa)...',
                            hintStyle: AppTypography.bodySmall.colored(colors.textMuted),
                            prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.primary),
                            suffixIcon: _isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : (_searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchResults = []);
                                        },
                                      )
                                    : null),
                            filled: true,
                            fillColor: colors.cardBackground,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.buttonPill,
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      // Search Results Dropdown List
                      if (_searchResults.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Material(
                          elevation: 6,
                          borderRadius: AppRadius.card,
                          color: colors.cardBackground,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, _) => Divider(height: 1, color: colors.cardBorder),
                              itemBuilder: (ctx, i) {
                                final item = _searchResults[i];
                                final p = item['properties'] as Map? ?? {};
                                final name = p['name']?.toString() ?? '';
                                final street = p['street']?.toString() ?? '';
                                final city = p['city']?.toString() ?? '';
                                final sub = [street, city].where((s) => s.isNotEmpty).join(', ');

                                return ListTile(
                                  dense: true,
                                  leading: Icon(Icons.place_rounded, size: 20, color: colors.primary),
                                  title: Text(
                                    name.isNotEmpty ? name : 'Địa điểm',
                                    style: AppTypography.bodySmall.bold.colored(colors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: sub.isNotEmpty
                                      ? Text(
                                          sub,
                                          style: AppTypography.labelSmall.colored(colors.textMuted),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  onTap: () => _selectSearchResult(item),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 4. Map Action Buttons (Zoom +, Zoom -, Current GPS)
            Positioned(
              right: 14,
              bottom: 230,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'map_gps_locate_btn',
                    backgroundColor: colors.cardBackground,
                    foregroundColor: colors.primary,
                    elevation: 3,
                    onPressed: _isLocating ? null : _moveToCurrentGps,
                    child: _isLocating
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: AppRadius.card,
                      boxShadow: AppShadows.md,
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_rounded, size: 20),
                          color: colors.textPrimary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                          onPressed: () {
                            _mapController.move(_currentCenter, (_mapController.camera.zoom + 1).clamp(3.0, 20.0));
                          },
                        ),
                        Divider(height: 1, color: colors.cardBorder),
                        IconButton(
                          icon: const Icon(Icons.remove_rounded, size: 20),
                          color: colors.textPrimary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                          onPressed: () {
                            _mapController.move(_currentCenter, (_mapController.camera.zoom - 1).clamp(3.0, 20.0));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 5. Bottom Card: Venue Name, Address & Confirmation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border(top: BorderSide(color: colors.cardBorder)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tên sân
                      Row(
                        children: [
                          Icon(Icons.sports_tennis_rounded, size: 16, color: colors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Tên sân cầu lông *',
                            style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _venueNameController,
                        style: AppTypography.bodySmall.bold.colored(colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'VD: Sân Cầu Lông Kỳ Hòa',
                          hintStyle: AppTypography.bodySmall.colored(colors.textMuted),
                          filled: true,
                          fillColor: colors.surfaceSubtle,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.button,
                            borderSide: BorderSide(color: colors.inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.button,
                            borderSide: BorderSide(color: colors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.button,
                            borderSide: BorderSide(color: colors.primary, width: 1.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Địa chỉ chi tiết
                      Row(
                        children: [
                          Icon(Icons.place_rounded, size: 16, color: colors.error),
                          const SizedBox(width: 6),
                          Text(
                            'Địa chỉ chi tiết *',
                            style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
                          ),
                          if (_isGeocoding) ...[
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: AppTypography.bodySmall.colored(colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Kéo bản đồ để tự động lấy địa chỉ...',
                          hintStyle: AppTypography.bodySmall.colored(colors.textMuted),
                          filled: true,
                          fillColor: colors.surfaceSubtle,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.button,
                            borderSide: BorderSide(color: colors.inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.button,
                            borderSide: BorderSide(color: colors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.button,
                            borderSide: BorderSide(color: colors.primary, width: 1.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Confirm Button
                      ElevatedButton.icon(
                        onPressed: _onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: Text(
                          'Xác nhận địa điểm này',
                          style: AppTypography.bodyMedium.bold.colored(AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
