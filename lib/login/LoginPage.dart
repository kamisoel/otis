import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otis/model/model.dart';

import 'package:otis/authentication/authentication.dart';
import 'package:otis/login/login.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            repository: RepositoryProvider.of<Repository>(context),
          );
        },
        child: Container(
          padding: EdgeInsets.all(35.0),
          child: OrientationBuilder(
            builder: (context, orientation) => Flex(
            direction: orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Image.asset('assets/otis.png'),
              ),
              Expanded(
                flex: 5,
                child: LoginForm(),
              ),
            ],
          ),),
        ),
      ),
    );
  }
}
