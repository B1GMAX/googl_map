import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googl_map/directions_repository.dart';
import 'package:googl_map/map_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';

import 'directions_model.dart';

class MapBloc {
  MapBloc() {
    getCurrentPosition();
  }

  TextEditingController originTextController = TextEditingController();
  TextEditingController destinationTextController = TextEditingController();

  final _originMarkerController = BehaviorSubject<Marker?>();

  final _destinationMarkerController = BehaviorSubject<Marker?>();

  final _infoController = BehaviorSubject<Directions?>();

  final _polylineController = BehaviorSubject<List<LatLng>>();

  final _markersController = BehaviorSubject<Set<Marker>>();

  final _mapModelController = BehaviorSubject<MapModel>();

  Stream<MapModel> get mapModelStream => _mapModelController.stream;

  Stream<Set<Marker>> get markersStream => _markersController.stream;

  Stream<List<LatLng>> get polylineStream => _polylineController.stream;

  Stream<Directions?> get infoStream => _infoController.stream;

  Stream<Marker?> get originMarkerStream => _originMarkerController.stream;

  Stream<Marker?> get destinationMarkerStream =>
      _destinationMarkerController.stream;

  late final GoogleMapController googleMapController;

  Marker? origin;
  Marker? destination;

  late Directions? info;

  Set<Marker> markers = {};

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void getCurrentPosition() async {
    final position = await _determinePosition();
    print('position - ${position.latitude} ${position.longitude}');

    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 14));
  }

  void addMarkerByButtonPress() async {
    info = null;
    if (markers.isNotEmpty) markers.clear();

    if (origin == null || (origin != null && destination != null)) {
      info = await DirectionsRepository().getDirections(
        origin: originTextController.text.trim(),
        destination: destinationTextController.text.trim(),
      );

      origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'A'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: LatLng(info!.startLat, info!.startLng));

      destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'B'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: LatLng(info!.endLat, info!.endLong));

      _mapModelController.add(MapModel(
          latLngList: [],
          directions: info,
          firstMarker: origin,
          secondMarker: destination,
          totalDistance: info!.totalDistance));
    }
  }

  void dispose() {
    _originMarkerController.close();
    _destinationMarkerController.close();
    _infoController.close();
    _polylineController.close();
    _markersController.close();
    _mapModelController.close();
  }
}
