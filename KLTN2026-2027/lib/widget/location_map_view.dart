import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

class LocationMapView extends StatelessWidget {
  final MapController? mapController;
  final LatLng? initialCenter;
  final double initialZoom;
  final LatLng? currentLocation;
  final List<Marker> markers;
  final void Function(TapPosition tapPosition, LatLng point)? onTap;
  final void Function(TapPosition tapPosition, LatLng point)? onLongPress;
  final void Function(MapCamera camera, bool hasGesture)? onPositionChanged;
  final bool interactive;

  static const LatLng defaultHcmCenter = LatLng(10.7725, 106.6698);

  const LocationMapView({
    super.key,
    this.mapController,
    this.initialCenter,
    this.initialZoom = 15.0,
    this.currentLocation,
    this.markers = const [],
    this.onTap,
    this.onLongPress,
    this.onPositionChanged,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation ?? initialCenter ?? defaultHcmCenter,
        initialZoom: initialZoom,
        minZoom: 3.0,
        maxZoom: 20.0,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
        onPositionChanged: onPositionChanged,
      ),
      children: [
        TileLayer(
          urlTemplate: kIsWeb
              ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png'
              : 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
          fallbackUrl: kIsWeb
              ? 'https://a.basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png'
              : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
          subdomains: kIsWeb ? const ['a', 'b', 'c', 'd'] : const ['0', '1', '2', '3'],
          userAgentPackageName: 'com.legendsteam.kltn2026_2027',
          maxNativeZoom: 19,
          maxZoom: 20,
          panBuffer: 1,
          keepBuffer: 2,
        ),
        if (currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: currentLocation!,
                width: 32,
                height: 32,
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.textPrimary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: markers,
          ),
      ],
    );
  }
}

