import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Directions {
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLong;

  const Directions({
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLong,
    required this.polylinePoints,
    required this.totalDistance,
  });

  factory Directions.fromMap(Map<String, dynamic> data) {
    String distance = '';
    double startLat = 0;
    double startLng = 0;
    double endLat = 0;
    double endLong = 0;
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      startLat = leg['start_location']['lat'];
      startLng = leg['start_location']['lng'];
      endLat = leg['end_location']['lat'];
      endLong = leg['end_location']['lng'];
    }

    return Directions(
      polylinePoints:
          PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLong: endLong,
    );
  }
}
