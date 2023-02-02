import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';

class RegisterUserInfo extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;
  final Function(UserModel, UserModel) createWayButton;

  const RegisterUserInfo(
      {required this.user,
      required this.createWayButton,
      required this.currentUser,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(32), // Image radius
              child: Image.network(user.photo, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(user.name,
              style: const TextStyle(fontSize: 10, color: Colors.white)),
          const SizedBox(
            height: 5,
          ),
          Text(user.email,
              style: const TextStyle(fontSize: 10, color: Colors.white)),
          user.id == FirebaseAuth.instance.currentUser!.uid
              ? const SizedBox.shrink()
              : ElevatedButton(
                  onPressed: () {
                    createWayButton(user, currentUser);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text(
                    'Create a way to this user',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
        ],
      ),
    );
  }
}
