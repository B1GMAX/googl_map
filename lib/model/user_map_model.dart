import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMapModel {
  final Marker currentUserMarker;
  final Set<Marker> allUsersMarker;

  UserMapModel({required this.allUsersMarker, required this.currentUserMarker});
}
