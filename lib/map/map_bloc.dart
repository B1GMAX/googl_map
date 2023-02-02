import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googl_map/repository/directions_repository.dart';
import 'package:googl_map/register_user/register_user_info_widget.dart';
import 'package:googl_map/model/user_map_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/directions_model.dart';
import '../model/map_model.dart';
import '../model/user_model.dart';
import '../register_user/register_user_screen.dart';

class MapBloc {
  MapBloc() {
    _startUserCollectionListener();
    _updateCurrentPosition();
    _getCurrentPosition();
  }

  final TextEditingController originTextController = TextEditingController();
  final TextEditingController destinationTextController =
      TextEditingController();

  final _originMarkerController = BehaviorSubject<Marker?>();

  final _destinationMarkerController = BehaviorSubject<Marker?>();

  final _infoController = BehaviorSubject<Directions?>();

  final _polylineController = BehaviorSubject<List<LatLng>>();

  final _markersController = BehaviorSubject<Set<Marker>>();

  final _mapModelController = BehaviorSubject<MapModel>();

  final _userModelController = BehaviorSubject<UserModel>();

  final _userMapModelController = BehaviorSubject<UserMapModel>();

  Stream<UserMapModel> get userMapModelStream => _userMapModelController.stream;

  Stream<UserModel> get userModelStream => _userModelController.stream;

  Stream<MapModel> get mapModelStream => _mapModelController.stream;

  Stream<Set<Marker>> get markersStream => _markersController.stream;

  Stream<List<LatLng>> get polylineStream => _polylineController.stream;

  Stream<Directions?> get infoStream => _infoController.stream;

  Stream<Marker?> get originMarkerStream => _originMarkerController.stream;

  Stream<Marker?> get destinationMarkerStream =>
      _destinationMarkerController.stream;

  GoogleMapController? googleMapController;

  final CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();

  Marker? _origin;
  Marker? _destination;

  Directions? _info;

  final Set<Marker> _allMarkers = {};

  final Set<Marker> _userDestinationMarkers = {};

  StreamSubscription? _listener;

  Timer? _timer;

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

  void getCurrentPositionForButton() async {
    final position = await _determinePosition();

    if (customInfoWindowController.googleMapController != null) {
      customInfoWindowController.googleMapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude), 8));
    }
  }

  void _updateCurrentPosition() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _getCurrentPosition();
    });
  }

  void _getCurrentPosition() async {
    final position = await _determinePosition();

    _updateCurrentUserPosition(position);
  }

  void _updateCurrentUserPosition(Position position) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(
            {'latitude': position.latitude, 'longitude': position.longitude});
  }

  void addMarkerByButtonPress() async {
    Set<Marker> markers = {};

    _info = null;

    if (_origin == null || (_origin != null && _destination != null)) {
      _info = await DirectionsRepository().getDirections(
        origin: originTextController.text.trim(),
        destination: destinationTextController.text.trim(),
      );

      if (_info != null) {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: InfoWindow(title: originTextController.text.trim()),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: LatLng(_info!.startLat, _info!.startLng));

        _destination = Marker(
            markerId: const MarkerId('destination'),
            infoWindow:
                InfoWindow(title: destinationTextController.text.trim()),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: LatLng(_info!.endLat, _info!.endLong));

        markers.add(_origin!);
        markers.add(_destination!);

        _allMarkers.addAll(markers);

        _mapModelController.add(
          MapModel(
              directions: _info,
              totalDistance: _info!.totalDistance,
              markers: _allMarkers),
        );
      }
    }
  }

  void _startUserCollectionListener() {
    _listener = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen(_parseUserData);
  }

  void _parseUserData(QuerySnapshot<Map<String, dynamic>> snapshot) async {
    List<UserModel> userModelList = [];

    for (final doc in snapshot.docs) {
      userModelList.add(UserModel.fromJson(doc.data()));
    }

    _createUsersMarkers(userModelList);
  }

  void _createUsersMarkers(List<UserModel> userModelList) {
    UserModel? currentUser;
    for (final user in userModelList) {
      if (user.id == FirebaseAuth.instance.currentUser!.uid) {
        currentUser = user;
      }
      _userDestinationMarkers.add(
        Marker(
          markerId: MarkerId(user.id),
          infoWindow: InfoWindow(title: user.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              user.id == FirebaseAuth.instance.currentUser!.uid
                  ? BitmapDescriptor.hueBlue
                  : BitmapDescriptor.hueYellow),
          position: LatLng(user.latitude, user.longitude),
          onTap: () {
            if (currentUser != null) {
              customInfoWindowController.addInfoWindow!(
                RegisterUserInfo(
                  user: user,
                  createWayButton: _createWayToUser,
                  currentUser: currentUser,
                ),
                LatLng(user.latitude, user.longitude),
              );
            }
          },
        ),
      );
    }

    _allMarkers.addAll(_userDestinationMarkers);

    _mapModelController.add(
      MapModel(
          directions: _info,
          totalDistance: _info?.totalDistance ?? '',
          markers: _allMarkers),
    );
  }

  void _createWayToUser(UserModel user, UserModel currentUser) async {
    _info = null;

    _allMarkers.clear();
    _allMarkers.addAll(_userDestinationMarkers);

    _info = await DirectionsRepository().getDirections(
      start: LatLng(currentUser.latitude, currentUser.longitude),
      end: LatLng(user.latitude, user.longitude),
    );

    if (_info != null) {
      _mapModelController.add(
        MapModel(
            directions: _info,
            totalDistance: _info?.totalDistance ?? '',
            markers: _allMarkers),
      );
    }
  }

  void clearInfo() {
    _info = null;

    _allMarkers.clear();
    _allMarkers.addAll(_userDestinationMarkers);

    _mapModelController.add(
      MapModel(
          directions: _info,
          totalDistance: _info?.totalDistance ?? '',
          markers: _allMarkers),
    );
  }

  Future logOut(BuildContext context) async {
    final googleSignIn = GoogleSignIn();

    await _listener?.cancel();
    _timer?.cancel();

    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const RegisterUserScreen()));
  }

  void dispose() {
    _originMarkerController.close();
    _destinationMarkerController.close();
    _infoController.close();
    _polylineController.close();
    _markersController.close();
    _mapModelController.close();
    _userModelController.close();
    destinationTextController.dispose();
    originTextController.dispose();
    _userMapModelController.close();
    _listener?.cancel();
    _timer?.cancel();
  }
}
