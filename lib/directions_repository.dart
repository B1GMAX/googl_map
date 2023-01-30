import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'directions_model.dart';

const googleAPIKey = 'AIzaSyBvdnm7Zk-3Zpdo067VLVafjjPs8EHllyA';

class DirectionsRepository {
  Future<Directions?> getDirections({
    required String origin,
    required String destination,
  }) async {
    final response = await get(Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination}&key=$googleAPIKey'));

    if (response.statusCode == 200) {
      return Directions.fromMap(jsonDecode(response.body));
    }
    return null;
  }
}
