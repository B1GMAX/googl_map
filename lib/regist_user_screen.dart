import 'package:flutter/cupertino.dart';
import 'package:googl_map/register_user_bloc.dart';
import 'package:provider/provider.dart';

class RegisterUserScreen extends StatelessWidget {
  const RegisterUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => RegisterUserBloc());
  }
}
