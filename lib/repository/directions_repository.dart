import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import '../model/directions_model.dart';

const googleAPIKey = 'AIzaSyBvdnm7Zk-3Zpdo067VLVafjjPs8EHllyA';

class DirectionsRepository {
  Future<Directions?> getDirections(
      {String? origin, String? destination, LatLng? start, LatLng? end}) async {
    final response = await get(
      Uri.parse(
        origin != null && destination != null
            ? 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination}&key=$googleAPIKey'
            : 'https://maps.googleapis.com/maps/api/directions/json?origin=${start!.latitude},${start.longitude}&destination=${end!.latitude},${end.longitude}&key=$googleAPIKey',
      ),
    );
    if (response.statusCode == 200) {
      return Directions.fromMap(jsonDecode(response.body));
    }
    return null;
  }
}
