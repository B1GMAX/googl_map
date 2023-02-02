import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../map/map_screen.dart';
import '../model/user_model.dart';

class RegisterUserBloc {
  final NavigatorState navigator;

  RegisterUserBloc({required this.navigator}) {
    _getCurrentPosition();
  }

  Position? _position;

  final _googleSignIn = GoogleSignIn();

  Future googleLogin() async {
    final googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    if (FirebaseAuth.instance.currentUser != null) {
      _createUser(FirebaseAuth.instance.currentUser!);

      navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const MapScreen()));
    }
  }

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

  void _getCurrentPosition() async {
    _position = await _determinePosition();
  }

  Future _createUser(User googleUser) async {
    final docUser = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    if (_position != null) {
      final user = UserModel(
          name: googleUser.displayName ?? '',
          email: googleUser.email ?? '',
          photo: googleUser.photoURL ?? 'assets/general_user_photo.png',
          latitude: _position!.latitude,
          longitude: _position!.longitude,
          id: googleUser.uid);

      final json = user.toJson();

      await docUser.set(json);
    }
  }

  void dispose() {}
}
