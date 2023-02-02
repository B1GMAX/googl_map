import 'package:flutter/material.dart';
import 'package:googl_map/user_profile/user_profile_bloc.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<UserProfileBloc>(
      lazy: false,
      create: (context) => UserProfileBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
          ),
          backgroundColor: Colors.indigo,
          body: StreamBuilder<UserModel>(
              stream: context.read<UserProfileBloc>().userStream,
              builder: (context, userSnapshot) {
                return userSnapshot.hasData
                    ? Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              ClipOval(
                                child: SizedBox.fromSize(
                                  size:
                                      const Size.fromRadius(82), // Image radius
                                  child: Image.network(userSnapshot.data!.photo,
                                      fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 50,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: Colors.white),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                child: Text(userSnapshot.data!.name,
                                    style: const TextStyle(
                                        fontSize: 22, color: Colors.black)),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 60,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: Colors.white),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 22),
                                child: Text(userSnapshot.data!.email,
                                    style: const TextStyle(
                                        fontSize: 22, color: Colors.black)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }),
        );
      },
    );
  }
}
