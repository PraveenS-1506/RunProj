import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/run.dart';
import '../utils/run_formatters.dart';
import '../utils/map_utils.dart';

class RunDetailsPage extends StatefulWidget {
  const RunDetailsPage({super.key, required this.run});

  final Run run;

  @override
  State<RunDetailsPage> createState() => _RunDetailsPageState();
}

class _RunDetailsPageState extends State<RunDetailsPage> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Auto-fit map bounds after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToBounds();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Fits the map view to show all route points
  void _fitMapToBounds() {
    if (widget.run.route.length < 2) return;

    final latLngList = MapUtils.toLatLngList(widget.run.route);
    final mapFit = MapUtils.calculateOptimalView(latLngList);

    if (mapFit != null && mounted) {
      _mapController.move(mapFit.center, mapFit.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              // Run Summary Card (unchanged)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_run, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Run Summary',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _InfoTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Date & Time',
                        value: RunFormatters.formatDate(widget.run.date),
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.straighten,
                        title: 'Distance',
                        value: RunFormatters.formatDistance(
                          widget.run.distanceInMeters,
                        ),
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.timer_outlined,
                        title: 'Duration',
                        value: RunFormatters.formatDuration(
                          widget.run.durationInSeconds,
                        ),
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.speed,
                        title: 'Average Pace',
                        value: RunFormatters.formatPace(widget.run.averagePace),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Route Map Display
              _buildRouteMapCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the route map card
  Widget _buildRouteMapCard() {
    // Check if route has sufficient data
    if (widget.run.route.length < 2) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[100],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Route data unavailable.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Build map with route data
    final latLngList = MapUtils.toLatLngList(widget.run.route);
    final startMarker = _buildMarker(latLngList.first, Colors.green, 'Start');
    final endMarker = _buildMarker(latLngList.last, Colors.red, 'Finish');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 400,
          child: Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: latLngList.first,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // OpenStreetMap tiles
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.runproj',
                    maxZoom: 19,
                  ),
                  // Polyline for route
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: latLngList,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                  // Markers for start and finish
                  MarkerLayer(markers: [startMarker, endMarker]),
                ],
              ),
              // Legend overlay
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(Colors.green, 'Start'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.red, 'Finish'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a marker for the map
  Marker _buildMarker(LatLng point, Color color, String label) {
    return Marker(
      point: point,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Marker badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Marker pin
          Icon(Icons.location_on, color: color, size: 40),
        ],
      ),
    );
  }

  /// Builds a legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
