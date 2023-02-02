import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'directions_model.dart';

class MapModel {
  final Directions? directions;

  final String totalDistance;
  final Set<Marker> markers;

  MapModel(
      {required this.directions,
      required this.totalDistance,
      required this.markers});

  MapModel copyWith({
    Set<Marker>? markers,
    Directions? directions,
    String? totalDistance,
  }) {
    return MapModel(
        markers: markers ?? this.markers,
        directions: directions ?? this.directions,
        totalDistance: totalDistance ?? this.totalDistance);
  }
}
