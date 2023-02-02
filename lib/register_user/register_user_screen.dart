import 'package:flutter/material.dart';
import 'package:googl_map/register_user/register_user_bloc.dart';
import 'package:provider/provider.dart';

import '../utils/device_utils.dart';

class RegisterUserScreen extends StatelessWidget {
  const RegisterUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<RegisterUserBloc>(
      lazy: false,
      dispose: (context, bloc) => bloc.dispose(),
      create: (context) => RegisterUserBloc(),
      builder: (context, _) {
        return Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 55, top: 50),
                  child: Image.asset(
                    'assets/google_map_logo.png',
                    height: DeviceUtils.getDeviceHeight(context) / 3,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  width: DeviceUtils.getDeviceWidth(context) / 1.5,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<RegisterUserBloc>().googleLogin(context);
                    },
                    child: const Text(
                      'Sign Up with Google',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
