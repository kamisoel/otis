import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otis/add_user/add_user_bloc.dart';
import 'package:otis/localization.dart';
import 'package:validators/validators.dart';

class AddUserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  String _firstName;
  String _lastName;
  String _email;
  String _password;

  String _validateEmail(String value) {
    try {
      isEmail(value);
    } catch (e) {
      return AppLocalizations.of(context).emailError;
    }

    return null;
  }

  String _validatePassword(String value) {
    if (value.length < 8) {
      return AppLocalizations.of(context).pwError;
    }

    return null;
  }

  String _validateName(String value) {
    if (value.isEmpty) {
      return AppLocalizations.of(context).fieldEmptyError;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).newPatient),
      ),
      body: BlocListener<AddUserBloc, AddUserState> (
        listener: (context, state) {
          if(state is AddUserFailed) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              )
            );
          } else if(state is AddUserSuccess) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final _addUserBloc = BlocProvider.of<AddUserBloc>(context);
    final Size _screenSize = MediaQuery.of(context).size;

    _addButtonPressed() {
      if (_formKey.currentState.validate()) {
        // validate form
        _formKey.currentState.save(); // Save our form now.

        _addUserBloc.add(AddButtonPressed(
          firstName: _firstName,
          lastName: _lastName,
          email: _email,
          password: _password,
        ));
        //Navigator.pop(context);
      }
    }

    return BlocBuilder<AddUserBloc, AddUserState>(
      bloc: _addUserBloc,
      builder: (context, state) => Form(
        key: this._formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
                keyboardType:
                    TextInputType.text,
                decoration:
                    InputDecoration(hintText: 'Max', labelText: AppLocalizations.of(context).name),
                validator: _validateName,
                onSaved: (value) => _firstName = value,
                ),
            TextFormField(
                keyboardType:
                    TextInputType.text,
                decoration: InputDecoration(
                    hintText: 'Mustermann', labelText: AppLocalizations.of(context).familyName),
                validator: _validateName,
                onSaved: (value) => _lastName = value,
                ),
            TextFormField(
                keyboardType: TextInputType
                    .visiblePassword, // email input type is buggy for samsung keyboard
                decoration: InputDecoration(
                    hintText: 'you@example.com', labelText: AppLocalizations.of(context).email),
                validator: _validateEmail,
                onSaved: (value) => _email = value,
            ),
            TextFormField(
                obscureText: true, // Use secure text for passwords.
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).password,
                  labelText: AppLocalizations.of(context).password,
                ),
                validator: _validatePassword,
                onSaved: (value) => _password = value,
                ),
            Container(
              width: _screenSize.width,
              child: RaisedButton(
                child: Text(
                  AppLocalizations.of(context).add,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed:
                  state is! AddUserLoading ? _addButtonPressed : null,
                color: Colors.green,
              ),
              margin: EdgeInsets.only(top: 20.0),
            ),
            Center(
              child: state is AddUserLoading
                  ? CircularProgressIndicator()
                  : null,
            ),
          ],
        ),
      ));
  }
}
