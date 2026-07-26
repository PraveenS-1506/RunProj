import 'package:latlong2/latlong.dart';
import '../models/run_location.dart';

class MapUtils {
  static List<LatLng> toLatLngList(List<RunLocation> route) {
    return route
        .map((location) => LatLng(location.latitude, location.longitude))
        .toList();
  }

  static MapFit? calculateOptimalView(List<LatLng> coordinates) {
    if (coordinates.length < 2) {
      return null;
    }

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      minLat = minLat > coord.latitude ? coord.latitude : minLat;
      maxLat = maxLat < coord.latitude ? coord.latitude : maxLat;
      minLng = minLng > coord.longitude ? coord.longitude : minLng;
      maxLng = maxLng < coord.longitude ? coord.longitude : maxLng;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final center = LatLng(centerLat, centerLng);

    final latDelta = maxLat - minLat;
    final lngDelta = maxLng - minLng;

    double zoom = 13.0; 

    if (latDelta > 0.1 || lngDelta > 0.1) {
      zoom = 11.0; 
    } else if (latDelta > 0.01 || lngDelta > 0.01) {
      zoom = 13.0; 
    } else {
      zoom = 15.0; 
    }

    return MapFit(center: center, zoom: zoom);
  }
}

class MapFit {
  final LatLng center;
  final double zoom;

  MapFit({required this.center, required this.zoom});
}
