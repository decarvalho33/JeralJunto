import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapMarkerData {
  final String id;
  final LatLng position;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MapMarkerData({
    required this.id,
    required this.position,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class MapWidget extends StatelessWidget {
  const MapWidget({
    super.key,
    required this.mapController,
    required this.center,
    required this.markers,
  });

  final MapController mapController;
  final LatLng center;
  final List<MapMarkerData> markers;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14,
        minZoom: 3,
        maxZoom: 19,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jeraljunto.app',
        ),
        MarkerLayer(
          markers: markers
              .map(
                (marker) => Marker(
                  key: ValueKey(marker.id),
                  point: marker.position,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: marker.onTap,
                    child: _MapMarkerBubble(
                      label: marker.label,
                      color: marker.color,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MapMarkerBubble extends StatelessWidget {
  const _MapMarkerBubble({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x11000000)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
