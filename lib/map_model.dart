import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'directions_model.dart';

class MapModel {
  final List<LatLng> latLngList;
  final Directions? directions;
  final Marker? firstMarker;
  final Marker? secondMarker;
  final String totalDistance;

  MapModel(
      {required this.latLngList,
      required this.directions,
      required this.firstMarker,
      required this.secondMarker,
      required this.totalDistance});
}
