import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../model/user_model.dart';

class UserProfileBloc {
  UserProfileBloc() {
    _getUser();
  }

  final _userController = BehaviorSubject<UserModel>();

  Stream<UserModel> get userStream => _userController.stream;

  void _getUser() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (documentSnapshot.data() != null) {
      final user = UserModel.fromJson(documentSnapshot.data()!);
      _userController.add(user);
    }
  }

  void dispose() {
    _userController.close();
  }
}
