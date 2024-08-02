import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otis/login/login.dart';
import 'package:otis/localization.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);

    _onLoginButtonPressed() {
      _loginBloc.add(LoginButtonPressed(
        username: _usernameController.text,
        password: _passwordController.text,
      ));
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        bloc: _loginBloc,
        builder: (
          BuildContext context,
          LoginState state,
        ) {
          return Form(
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      icon: Icon(Icons.email), labelText: AppLocalizations.of(context).username),
                  controller: _usernameController,
                  keyboardType: TextInputType.visiblePassword,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: AppLocalizations.of(context).password,
                    suffixIcon: GestureDetector(
                      onLongPress: () {
                        setState(() { _passwordVisible = true;});
                      },
                      onLongPressUp:  () {
                        setState(() { _passwordVisible = false;});
                      },
                      child: Icon(Icons.visibility),
                    ),
                  ),
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 20),

                  child: RaisedButton(
                    onPressed:
                        state is! LoginLoading ? _onLoginButtonPressed : null,
                    child: Text(AppLocalizations.of(context).login),
                  ),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  child: state is LoginLoading
                      ? CircularProgressIndicator()
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
